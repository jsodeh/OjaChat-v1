import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../config/firebase_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/vendor_model.dart';
import '../services/auth_service.dart';
import '../models/order_confirmation.dart';
import '../models/order_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../models/vendor_bank_account.dart';
import '../models/payout_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Caching layer
  final Map<String, DocumentSnapshot?> _cache = {};

  Future<List<Map<String, dynamic>>> queryProducts(String query) async {
    try {
      final keywords = query.toLowerCase().split(' ');
      
      if (keywords.isEmpty) return [];

      print('Querying with keywords: $keywords'); // Debug print

      final querySnapshot = await _firestore
          .collection('products')
          .where('searchTerms', arrayContainsAny: keywords)
          .limit(5)
          .get();

      print('Found ${querySnapshot.docs.length} matching products'); // Debug print

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Product data: $data'); // Debug print
        
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown Product',
          'price': (data['price'] ?? 0.0).toDouble(),
          'unit': data['unit'] ?? 'unit',
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();

      print('Processed products: $products'); // Debug print
      return products;
      
    } catch (e) {
      print('Error querying products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductDetails(String productId) async {
    if (_cache.containsKey(productId)) {
      return _cache[productId]?.data() as Map<String, dynamic>?;
    }

    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        _cache[productId] = doc; // Cache the document
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamRecentProducts() {
    return _firestore.collection('products').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        _cache[doc.id] = doc; // Cache the document
        return doc.data() as Map<String, dynamic>;
      }).toList();
    });
  }

  Future<List<ProductModel>> fetchMatchingProducts(String userInput) async {
    final productsCollection = _firestore.collection('products');
    final keywords = userInput.split(' ');

    List<ProductModel> matchingProducts = [];
    for (String keyword in keywords) {
      final querySnapshot = await productsCollection
          .where('name', isEqualTo: keyword)
          .get();

      for (var doc in querySnapshot.docs) {
        matchingProducts.add(ProductModel.fromJson(doc.data()));
      }
    }

    return matchingProducts;
  }

  Future<Map<String, dynamic>> getProductWithUnits(QueryDocumentSnapshot doc) async {
    final productData = doc.data() as Map<String, dynamic>;
    
    // Get units subcollection
    final unitsSnapshot = await _firestore
        .collection(FirebaseCollections.products)
        .doc(doc.id)
        .collection('units')
        .get();

    // Add units to product data
    final units = unitsSnapshot.docs.map((unitDoc) => unitDoc.data()).toList();
    return {
      ...productData,
      'units': units,
      'imageUrl': productData['image'] ?? '', // Handle existing image field
      'id': doc.id,
    };
  }

  Future<void> updateProductSearchTerms(String productId, String name) async {
    // Generate search terms from the product name
    final searchTerms = _generateSearchTerms(name);
    
    await _firestore.collection('products').doc(productId).update({
      'searchTerms': searchTerms,
    });
  }

  List<String> _generateSearchTerms(String name) {
    final terms = <String>{};  // Using Set to avoid duplicates
    
    // Convert to lowercase and split into words
    final words = name.toLowerCase().split(' ');
    
    // Add full name
    terms.add(name.toLowerCase());
    
    // Add individual words
    terms.addAll(words);
    
    // Add partial matches (minimum 3 characters)
    for (final word in words) {
      for (int i = 3; i <= word.length; i++) {
        terms.add(word.substring(0, i));
      }
    }

    // Add common variations
    final variations = {
      'tomatoes': ['tomato', 'tomatoe'],
      'onions': ['onion'],
      'potatoes': ['potato', 'potatoe'],
      'rice': ['rice'],
      // Add more variations as needed
    };

    for (final word in words) {
      if (variations.containsKey(word)) {
        terms.addAll(variations[word]!);
      }
    }

    return terms.toList();
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('products')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
        data['imageUrl'] = imageUrl;
      }

      // Extract variants from data
      final variants = List<Map<String, dynamic>>.from(data.remove('variants') ?? []);

      data['searchTerms'] = _generateSearchTerms(data['name']);
      data['updatedAt'] = FieldValue.serverTimestamp();

      // Update product document
      await _firestore.collection('products').doc(id).update(data);

      // Update variants subcollection
      final batch = _firestore.batch();
      final variantsRef = _firestore.collection('products').doc(id).collection('variants');
      
      // Delete existing variants
      final existingVariants = await variantsRef.get();
      for (var doc in existingVariants.docs) {
        batch.delete(doc.reference);
      }

      // Add new variants
      for (var variant in variants) {
        final variantRef = variantsRef.doc();
        batch.set(variantRef, {
          ...variant,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> data, File? imageFile) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('products')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      // Extract variants from data
      final variants = List<Map<String, dynamic>>.from(data.remove('variants') ?? []);

      final productData = {
        ...data,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'searchTerms': _generateSearchTerms(data['name']),
        'isActive': true,
      };

      // Add product document
      final docRef = await _firestore.collection('products').add(productData);

      // Add variants as subcollection
      final batch = _firestore.batch();
      for (var variant in variants) {
        final variantRef = docRef.collection('variants').doc();
        batch.set(variantRef, {
          ...variant,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<String> _uploadImage(File file, String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Stream<List<ProductModel>> streamProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final products = <ProductModel>[];
      
      for (var doc in snapshot.docs) {
        // Get variants subcollection
        final variantsSnapshot = await doc.reference
            .collection('variants')
            .orderBy('createdAt', descending: true)
            .get();
            
        final variants = variantsSnapshot.docs
            .map((vDoc) => ProductVariant.fromJson({
                  'id': vDoc.id,
                  ...vDoc.data(),
                }))
            .toList();

        products.add(ProductModel.fromMap(doc.id, {
          ...doc.data(),
          'variants': variants,
        }));
      }
      
      return products;
    });
  }

  // Vendor Methods
  Future<List<String>> getProductsByCategories(List<String> categories) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('categories', arrayContainsAny: categories)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
    } catch (e) {
      print('Error getting products by categories: $e');
      return [];
    }
  }

  Future<String> createVendor(VendorModel vendor) async {
    try {
      // Create vendor document
      final docRef = await _firestore.collection('vendors').add(vendor.toMap());
      
      // Update user's role
      await _firestore
          .collection('users')
          .doc(vendor.userId)
          .set({
            'role': 'vendor',
            'vendorId': docRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      print('Error creating vendor: $e');
      rethrow;
    }
  }

  // Order alert methods
  Future<List<String>> getMatchingVendorIds(List<String> products, String market) async {
    try {
      final querySnapshot = await _firestore
          .collection('vendors')
          .where('market', isEqualTo: market)
          .where('products', arrayContainsAny: products)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting matching vendors: $e');
      return [];
    }
  }

  Future<void> sendOrderAlert(String orderId, List<String> vendorIds) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final vendorId in vendorIds) {
      final alertRef = _firestore.collection('orderAlerts').doc();
      batch.set(alertRef, {
        'orderId': orderId,
        'vendorId': vendorId,
        'status': 'pending',
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(Duration(minutes: 30)).toIso8601String(),
      });
    }

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getVendorOrderAlerts(String vendorId) {
    return _firestore
        .collection('orderAlerts')
        .where('vendorId', isEqualTo: vendorId)
        .where('status', isEqualTo: 'pending')
        .where('expiresAt', isGreaterThan: DateTime.now().toIso8601String())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<void> respondToOrderAlert(String alertId, bool accept) async {
    await _firestore
        .collection('orderAlerts')
        .doc(alertId)
        .update({
          'status': accept ? 'accepted' : 'declined',
          'respondedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<String> uploadOrderMedia(File file, MediaType type) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userId = AuthService().currentUser!.uid;
      final ext = type == MediaType.image ? 'jpg' : 'mp4';
      final path = 'order_media/$userId/$timestamp.$ext';
      
      final ref = FirebaseStorage.instance.ref().child(path);
      final metadata = SettableMetadata(
        contentType: type == MediaType.image ? 'image/jpeg' : 'video/mp4',
      );
      
      await ref.putFile(file, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  Future<String> submitOrderConfirmation(OrderConfirmation confirmation) async {
    try {
      final doc = await _firestore.collection('orderConfirmations').add(confirmation.toMap());
      
      // Send notification to user
      await _sendOrderConfirmationNotification(
        confirmation.orderId,
        confirmation.mediaType == MediaType.image ? 'photo' : 'video',
      );
      
      return doc.id;
    } catch (e) {
      print('Error submitting confirmation: $e');
      rethrow;
    }
  }

  Stream<List<OrderConfirmation>> getOrderConfirmations(String orderId) {
    return _firestore
        .collection('orderConfirmations')
        .where('orderId', isEqualTo: orderId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderConfirmation.fromMap(doc.data()))
            .toList());
  }

  Future<void> acceptConfirmation(String confirmationId) async {
    await _firestore
        .collection('orderConfirmations')
        .doc(confirmationId)
        .update({'isAccepted': true});
  }

  // Notification methods
  Future<void> _sendOrderConfirmationNotification(String orderId, String mediaType) async {
    final order = await _firestore.collection('orders').doc(orderId).get();
    final userId = order.data()?['userId'];
    
    if (userId == null) return;

    await _firestore.collection('notifications').add({
      'userId': userId,
      'type': 'orderConfirmation',
      'title': 'New Product Confirmation',
      'body': 'A vendor has sent a $mediaType confirmation',
      'orderId': orderId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<String> createOrder(OrderModel order) async {
    try {
      // Create order document
      await _firestore.collection('orders').doc(order.id).set(order.toMap());
      
      // Find matching vendors if not already set
      if (order.vendorIds.isEmpty) {
        final productNames = order.items.map((item) => item.name).toList();
        final vendorIds = await _getMatchingVendorIds(productNames, order.market);
        
        // Update order with vendor IDs
        await _firestore.collection('orders').doc(order.id).update({
          'vendorIds': vendorIds,
        });

        // Send alerts to vendors
        await _sendVendorAlerts(order.id, vendorIds);
      }
      
      return order.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Stream<OrderModel> streamOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()!));
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.toString(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmOrderItem(String orderId, String productId, String vendorId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    final order = OrderModel.fromMap(doc.id, doc.data()!);
    
    final items = order.items.map((item) {
      if (item.productId == productId) {
        final confirmedBy = [...(item.confirmedBy ?? []), vendorId];
        return {...item.toMap(), 'confirmedBy': confirmedBy};
      }
      return item.toMap();
    }).toList();

    await doc.reference.update({'items': items});
  }

  Stream<List<OrderModel>> getVendorOrders(String vendorId, List<OrderStatus> status) {
    return _firestore
        .collection('orders')
        .where('vendorIds', arrayContains: vendorId)
        .where('status', whereIn: status.map((s) => s.toString()).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendVendorNotification(
    String vendorId,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    // Save notification to Firestore
    await _firestore.collection('notifications').add({
      'vendorId': vendorId,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });

    // Get vendor's FCM token
    final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
    final fcmToken = vendorDoc.data()?['fcmToken'];
    
    if (fcmToken != null) {
      // Send FCM notification
      await _sendFCMNotification(
        fcmToken,
        title,
        body,
        data,
      );
    }
  }

  Future<void> _sendFCMNotification(
    String token,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=${Config.fcmServerKey}',
        },
        body: jsonEncode({
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data,
          'to': token,
        }),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  Future<void> updateOrderFulfillment(
    String orderId,
    String itemId,
    String vendorId,
    bool fulfilled,
  ) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    
    await _firestore.runTransaction((transaction) async {
      final orderDoc = await transaction.get(orderRef);
      final order = OrderModel.fromMap(orderDoc.id, orderDoc.data()!);
      
      // Update the specific item's fulfillment status
      final updatedItems = order.items.map((item) {
        if (item.productId == itemId) {
          final confirmedBy = List<String>.from(item.confirmedBy ?? []);
          if (fulfilled && !confirmedBy.contains(vendorId)) {
            confirmedBy.add(vendorId);
          } else if (!fulfilled) {
            confirmedBy.remove(vendorId);
          }
          return {...item.toMap(), 'confirmedBy': confirmedBy};
        }
        return item.toMap();
      }).toList();

      // Check if all items are fulfilled
      final allFulfilled = updatedItems.every((item) =>
          (item['confirmedBy'] as List).isNotEmpty);

      // Update order status if needed
      final newStatus = allFulfilled ? OrderStatus.ready : OrderStatus.processing;
      
      transaction.update(orderRef, {
        'items': updatedItems,
        'status': newStatus.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> verifyVendorBankAccount(String accountId) async {
    await _firestore
        .collection('bankAccounts')
        .doc(accountId)
        .update({'isVerified': true});
  }

  Future<VendorBankAccount?> getVendorBankAccount(String vendorId) async {
    final snapshot = await _firestore
        .collection('bankAccounts')
        .where('vendorId', isEqualTo: vendorId)
        .where('isVerified', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    final doc = snapshot.docs.first;
    return VendorBankAccount.fromMap(doc.id, doc.data());
  }

  Future<void> recordPayout({
    required String vendorId,
    required double amount,
    required String reference,
    required String status,
  }) async {
    await _firestore.collection('payouts').add({
      'vendorId': vendorId,
      'amount': amount,
      'reference': reference,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<PayoutModel>> getVendorPayouts(String vendorId) {
    return _firestore
        .collection('payouts')
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PayoutModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<VendorBankAccount?> getVendorBankAccountStream(String vendorId) {
    return _firestore
        .collection('bankAccounts')
        .where('vendorId', isEqualTo: vendorId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return VendorBankAccount.fromMap(
            snapshot.docs.first.id,
            snapshot.docs.first.data(),
          );
        });
  }

  Future<void> addVendorBankAccount(VendorBankAccount account) async {
    // Check if vendor already has a bank account
    final existing = await _firestore
        .collection('bankAccounts')
        .where('vendorId', isEqualTo: account.vendorId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Vendor already has a bank account');
    }

    await _firestore.collection('bankAccounts').add(account.toMap());
  }

  Future<void> updatePayout({
    required String reference,
    required String status,
    required Map<String, dynamic> metadata,
  }) async {
    final snapshot = await _firestore
        .collection('payouts')
        .where('reference', isEqualTo: reference)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Payout not found');
    }

    await snapshot.docs.first.reference.update({
      'status': status,
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> notifyAdmin(String title, String message) async {
    await _firestore.collection('adminNotifications').add({
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Future<List<OrderModel>> getUnpaidCompletedOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: OrderStatus.completed.toString())
        .where('paidOut', isEqualTo: false)
        .get();

    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> markOrderPaid(String orderId, String vendorId) async {
    final orderRef = _firestore.collection('orders').doc(orderId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(orderRef);
      final paidVendors = List<String>.from(doc.data()?['paidVendors'] ?? []);
      
      if (!paidVendors.contains(vendorId)) {
        paidVendors.add(vendorId);
        
        transaction.update(orderRef, {
          'paidVendors': paidVendors,
          'paidOut': paidVendors.length == doc.data()?['vendorIds'].length,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<List<PayoutModel>> getPayoutsByStatus(String status) {
    return _firestore
        .collection('payouts')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PayoutModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> triggerPayouts() async {
    final functions = FirebaseFunctions.instance;
    try {
      await functions.httpsCallable('triggerPayouts').call();
    } catch (e) {
      print('Error triggering payouts: $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getVendorEarningsReport(
    String vendorId,
    String timeRange,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('orders')
        .where('vendorIds', arrayContains: vendorId)
        .where('status', isEqualTo: OrderStatus.completed.toString())
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
          .toList();

      return _calculateEarningsReport(orders, vendorId, timeRange);
    });
  }

  Map<String, dynamic> _calculateEarningsReport(
    List<OrderModel> orders,
    String vendorId,
    String timeRange,
  ) {
    double totalEarnings = 0;
    final chartData = <Map<String, dynamic>>[];
    final labels = <String>[];

    // Calculate total earnings and chart data
    for (final order in orders) {
      double orderTotal = 0;
      for (final item in order.items) {
        if (item.confirmedBy?.contains(vendorId) ?? false) {
          orderTotal += item.price * item.quantity;
        }
      }
      totalEarnings += orderTotal;

      // Add to chart data based on time range
      // Implementation depends on your specific requirements
    }

    return {
      'totalEarnings': totalEarnings,
      'ordersCompleted': orders.length,
      'averageOrderValue': orders.isEmpty ? 0 : totalEarnings / orders.length,
      'pendingPayout': 0, // Calculate from pending payouts
      'chartData': chartData,
      'labels': labels,
    };
  }

  Stream<Map<String, dynamic>> getPayoutAnalytics(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('payouts')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .asyncMap((snapshot) async {
      final payouts = snapshot.docs
          .map((doc) => PayoutModel.fromMap(doc.id, doc.data()))
          .toList();

      // Get vendor data
      final vendorSnapshots = await Future.wait(
        payouts.map((p) => _firestore.collection('vendors').doc(p.vendorId).get()),
      );

      final vendorData = Map.fromEntries(
        vendorSnapshots.map((doc) => MapEntry(doc.id, doc.data()!)),
      );

      return _calculatePayoutAnalytics(payouts, vendorData, timeRange);
    });
  }

  Map<String, dynamic> _calculatePayoutAnalytics(
    List<PayoutModel> payouts,
    Map<String, Map<String, dynamic>> vendorData,
    String timeRange,
  ) {
    // Calculate summary statistics
    final totalPayouts = payouts.fold<double>(
      0,
      (sum, payout) => sum + payout.amount,
    );

    final pendingPayouts = payouts
        .where((p) => p.status == 'pending')
        .fold<double>(0, (sum, p) => sum + p.amount);

    final failedPayouts = payouts.where((p) => p.status == 'failed').length;

    // Calculate vendor performance
    final vendorPerformance = <String, Map<String, dynamic>>{};
    for (final payout in payouts) {
      vendorPerformance.putIfAbsent(
        payout.vendorId,
        () => {
          'totalPayouts': 0.0,
          'completedPayouts': 0,
          'totalPayoutCount': 0,
          'name': vendorData[payout.vendorId]?['name'] ?? 'Unknown Vendor',
        },
      );

      vendorPerformance[payout.vendorId]!['totalPayouts'] += payout.amount;
      vendorPerformance[payout.vendorId]!['totalPayoutCount']++;
      if (payout.status == 'completed') {
        vendorPerformance[payout.vendorId]!['completedPayouts']++;
      }
    }

    // Calculate completion rates and sort vendors
    final topVendors = vendorPerformance.entries.map((e) {
      final completionRate = (e.value['completedPayouts'] / 
          e.value['totalPayoutCount'] * 100).roundToDouble();
      return {
        'id': e.key,
        'name': e.value['name'],
        'totalPayouts': e.value['totalPayouts'],
        'completionRate': completionRate,
      };
    }).toList()
      ..sort((a, b) => b['totalPayouts'].compareTo(a['totalPayouts']));

    return {
      'totalPayouts': totalPayouts,
      'activeVendors': vendorPerformance.length,
      'pendingPayouts': pendingPayouts,
      'failedPayouts': failedPayouts,
      'topVendors': topVendors.take(5).toList(),
      'chartData': _generateChartData(payouts, timeRange),
      'labels': _generateChartLabels(timeRange),
    };
  }

  List<Map<String, dynamic>> _generateChartData(
    List<PayoutModel> payouts,
    String timeRange,
  ) {
    final now = DateTime.now();
    final data = <DateTime, double>{};
    
    // Initialize data points
    switch (timeRange) {
      case 'week':
        for (int i = 6; i >= 0; i--) {
          data[now.subtract(Duration(days: i))] = 0;
        }
        break;
      case 'month':
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (int i = 0; i < daysInMonth; i++) {
          data[DateTime(now.year, now.month, i + 1)] = 0;
        }
        break;
      case 'year':
        for (int i = 0; i < 12; i++) {
          data[DateTime(now.year, i + 1, 1)] = 0;
        }
        break;
    }

    // Aggregate payout amounts
    for (final payout in payouts) {
      final date = _normalizeDate(payout.createdAt, timeRange);
      data[date] = (data[date] ?? 0) + payout.amount;
    }

    // Convert to chart format
    return data.entries.map((e) => {
      'x': timeRange == 'year' 
          ? e.key.month - 1.0 
          : e.key.day - 1.0,
      'y': e.value,
    }).toList();
  }

  DateTime _normalizeDate(DateTime date, String timeRange) {
    switch (timeRange) {
      case 'week':
      case 'month':
        return DateTime(date.year, date.month, date.day);
      case 'year':
        return DateTime(date.year, date.month, 1);
      default:
        return date;
    }
  }

  List<String> _generateChartLabels(String timeRange) {
    final now = DateTime.now();
    final dateFormat = DateFormat(timeRange == 'year' ? 'MMM' : 'd MMM');
    
    switch (timeRange) {
      case 'week':
        return List.generate(7, (i) => 
          dateFormat.format(now.subtract(Duration(days: 6 - i))));
      case 'month':
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        return List.generate(daysInMonth, (i) =>
          dateFormat.format(DateTime(now.year, now.month, i + 1)));
      case 'year':
        return List.generate(12, (i) =>
          dateFormat.format(DateTime(now.year, i + 1, 1)));
      default:
        return [];
    }
  }

  Future<void> sendOrderNotification({
    required String vendorId,
    required String orderId,
    required String type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
  }) async {
    await _firestore.collection('notifications').add({
      'vendorId': vendorId,
      'orderId': orderId,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> _getMatchingVendorIds(List<String> products, String market) async {
    final querySnapshot = await _firestore
        .collection('vendors')
        .where('market', isEqualTo: market)
        .where('products', arrayContainsAny: products)
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _sendVendorAlerts(String orderId, List<String> vendorIds) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final vendorId in vendorIds) {
      final alertRef = _firestore.collection('orderAlerts').doc();
      batch.set(alertRef, {
        'orderId': orderId,
        'vendorId': vendorId,
        'status': 'pending',
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(Duration(minutes: 30)).toIso8601String(),
      });
    }

    await batch.commit();
  }

  Future<void> updateAllProductsWithSearchTerms() async {
    final products = await _firestore.collection('products').get();
    
    final batch = _firestore.batch();
    for (final doc in products.docs) {
      final name = doc.data()['name'] as String;
      batch.update(doc.reference, {
        'searchTerms': _generateSearchTerms(name),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }

  Future<void> deleteProduct(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists && doc.data()?['imageUrl'] != null) {
        await FirebaseStorage.instance.refFromURL(doc.data()!['imageUrl']).delete();
      }

      // Delete variants subcollection
      final variantsSnapshot = await doc.reference.collection('variants').get();
      final batch = _firestore.batch();
      for (var variantDoc in variantsSnapshot.docs) {
        batch.delete(variantDoc.reference);
      }
      
      // Delete product document
      batch.delete(doc.reference);
      await batch.commit();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getAdminOverview(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .asyncMap((ordersSnapshot) async {
      // Get vendors count
      final vendorsSnapshot = await _firestore
          .collection('vendors')
          .where('isActive', isEqualTo: true)
          .get();

      // Calculate totals
      double totalRevenue = 0;
      int pendingDeliveries = 0;

      for (var doc in ordersSnapshot.docs) {
        final order = OrderModel.fromMap(doc.id, doc.data());
        totalRevenue += order.total;
        if (order.status == OrderStatus.processing) {
          pendingDeliveries++;
        }
      }

      // Calculate trends (simplified)
      final previousPeriod = await _getPreviousPeriodData(timeRange);

      return {
        'totalOrders': ordersSnapshot.docs.length,
        'totalRevenue': totalRevenue,
        'activeVendors': vendorsSnapshot.docs.length,
        'pendingDeliveries': pendingDeliveries,
        'ordersTrend': _calculateTrend(
          ordersSnapshot.docs.length,
          previousPeriod['orders'],
        ),
        'revenueTrend': _calculateTrend(
          totalRevenue,
          previousPeriod['revenue'],
        ),
        'vendorsTrend': _calculateTrend(
          vendorsSnapshot.docs.length,
          previousPeriod['vendors'],
        ),
      };
    });
  }

  Stream<List<OrderModel>> getRecentOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<Map<String, dynamic>> _getPreviousPeriodData(String timeRange) async {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (timeRange) {
      case 'week':
        endDate = now.subtract(Duration(days: 7));
        startDate = endDate.subtract(Duration(days: 7));
        break;
      case 'month':
        endDate = DateTime(now.year, now.month, 1);
        startDate = DateTime(now.year, now.month - 1, 1);
        break;
      case 'year':
        endDate = DateTime(now.year, 1, 1);
        startDate = DateTime(now.year - 1, 1, 1);
        break;
      default:
        endDate = now.subtract(Duration(days: 7));
        startDate = endDate.subtract(Duration(days: 7));
    }

    final ordersSnapshot = await _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThan: endDate)
        .get();

    final vendorsSnapshot = await _firestore
        .collection('vendors')
        .where('isActive', isEqualTo: true)
        .get();

    double totalRevenue = 0;
    for (var doc in ordersSnapshot.docs) {
      final order = OrderModel.fromMap(doc.id, doc.data());
      totalRevenue += order.total;
    }

    return {
      'orders': ordersSnapshot.docs.length,
      'revenue': totalRevenue,
      'vendors': vendorsSnapshot.docs.length,
    };
  }

  double _calculateTrend(num current, num previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous * 100).roundToDouble();
  }

  Stream<List<VendorModel>> streamVendors(String filter) {
    Query query = _firestore.collection('vendors');
    
    switch (filter) {
      case 'active':
        query = query.where('isActive', isEqualTo: true);
        break;
      case 'inactive':
        query = query.where('isActive', isEqualTo: false);
        break;
    }
    
    return query
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> updateVendorStatus(String vendorId, bool isActive) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating vendor status: $e');
      rethrow;
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      // Get vendor data to update user role
      final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
      final userId = vendorDoc.data()?['userId'];

      // Delete vendor document
      await _firestore.collection('vendors').doc(vendorId).delete();

      // Update user role if userId exists
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'role': 'user',
          'vendorId': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error deleting vendor: $e');
      rethrow;
    }
  }

  Stream<List<OrderModel>> getDeliveryOrders(String status) {
    Query query = _firestore.collection('orders');
    
    switch (status) {
      case 'ready':
        query = query.where('status', isEqualTo: OrderStatus.ready.toString());
        break;
      case 'delivering':
        query = query.where('status', isEqualTo: OrderStatus.delivering.toString());
        break;
      case 'delivered':
        query = query.where('status', isEqualTo: OrderStatus.delivered.toString());
        break;
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<Map<String, dynamic>> getAnalyticsData(String timeRange, String metric) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .asyncMap((snapshot) async {
      final chartData = <Map<String, dynamic>>[];
      final labels = <String>[];
      double totalValue = 0;

      // Group data by date
      final groupedData = <DateTime, double>{};
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(doc.id, doc.data());
        final date = DateTime(
          order.createdAt.year,
          order.createdAt.month,
          timeRange == 'year' ? 1 : order.createdAt.day,
        );
        
        switch (metric) {
          case 'revenue':
            groupedData[date] = (groupedData[date] ?? 0) + order.total;
            break;
          case 'orders':
            groupedData[date] = (groupedData[date] ?? 0) + 1;
            break;
          case 'vendors':
            groupedData[date] = (groupedData[date] ?? 0) + order.vendorIds.length;
            break;
        }
      }

      // Sort dates and create chart data
      final sortedDates = groupedData.keys.toList()..sort();
      for (var date in sortedDates) {
        chartData.add({
          'x': chartData.length,
          'y': groupedData[date]!,
        });
        
        labels.add(timeRange == 'year'
            ? DateFormat('MMM').format(date)
            : DateFormat('MMM d').format(date));
        
        totalValue += groupedData[date]!;
      }

      return {
        'chartData': chartData,
        'labels': labels,
        'total': totalValue,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> getTopVendors(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('status', isEqualTo: OrderStatus.completed.toString())
        .snapshots()
        .asyncMap((snapshot) async {
      // Calculate vendor performance
      final vendorStats = <String, Map<String, dynamic>>{};
      
      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(doc.id, doc.data());
        for (var vendorId in order.vendorIds) {
          if (!vendorStats.containsKey(vendorId)) {
            final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
            vendorStats[vendorId] = {
              'name': vendorDoc.data()?['name'] ?? 'Unknown Vendor',
              'revenue': 0.0,
              'ordersCompleted': 0,
              'totalOrders': 0,
            };
          }
          
          vendorStats[vendorId]!['totalOrders'] = 
              (vendorStats[vendorId]!['totalOrders'] as int) + 1;
              
          if (order.status == OrderStatus.completed) {
            vendorStats[vendorId]!['ordersCompleted'] = 
                (vendorStats[vendorId]!['ordersCompleted'] as int) + 1;
            vendorStats[vendorId]!['revenue'] = 
                (vendorStats[vendorId]!['revenue'] as double) + order.total;
          }
        }
      }

      // Calculate completion rates and format for display
      final vendorList = vendorStats.entries.map((e) {
        final stats = e.value;
        final completionRate = stats['totalOrders'] > 0
            ? (stats['ordersCompleted'] / stats['totalOrders'] * 100).round()
            : 0;
            
        return {
          'id': e.key,
          'name': stats['name'],
          'revenue': stats['revenue'],
          'ordersCompleted': stats['ordersCompleted'],
          'completionRate': completionRate,
        };
      }).toList();

      // Sort by revenue
      vendorList.sort((a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));
      
      return vendorList.take(5).toList();
    });
  }

  Stream<Map<String, dynamic>> getMarketPerformance(String timeRange) {
    final now = DateTime.now();
    DateTime startDate;

    switch (timeRange) {
      case 'week':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: 7));
    }

    return _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .snapshots()
        .map((snapshot) {
      final marketStats = {
        'mile12Revenue': 0.0,
        'mile12Orders': 0,
        'oyingboRevenue': 0.0,
        'oyingboOrders': 0,
        'karaRevenue': 0.0,
        'karaOrders': 0,
      };

      for (var doc in snapshot.docs) {
        final order = OrderModel.fromMap(doc.id, doc.data());
        
        switch (order.market.toLowerCase()) {
          case 'mile 12':
            marketStats['mile12Revenue'] = 
                (marketStats['mile12Revenue'] as double) + order.total;
            marketStats['mile12Orders'] = 
                (marketStats['mile12Orders'] as int) + 1;
            break;
          case 'oyingbo':
            marketStats['oyingboRevenue'] = 
                (marketStats['oyingboRevenue'] as double) + order.total;
            marketStats['oyingboOrders'] = 
                (marketStats['oyingboOrders'] as int) + 1;
            break;
          case 'kara':
            marketStats['karaRevenue'] = 
                (marketStats['karaRevenue'] as double) + order.total;
            marketStats['karaOrders'] = 
                (marketStats['karaOrders'] as int) + 1;
            break;
        }
      }

      return marketStats;
    });
  }

  // Add this method to fetch product with variants for chat context
  Future<Map<String, dynamic>> getProductWithVariants(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw 'Product not found';
      }

      final variantsSnapshot = await doc.reference.collection('variants').get();
      final variants = variantsSnapshot.docs
          .map((vDoc) => ProductVariant.fromJson({
                'id': vDoc.id,
                ...vDoc.data(),
              }))
          .toList();

      final product = ProductModel.fromMap(doc.id, {
        ...doc.data()!,
        'variants': variants,
      });

      return product.toChatContext();
    } catch (e) {
      print('Error getting product with variants: $e');
      rethrow;
    }
  }

  // Create product with variants
  Future<void> createProduct(ProductModel product, List<ProductVariant> variants) async {
    try {
      final docRef = await _firestore.collection('products').add(product.toJson());
      
      final batch = _firestore.batch();
      for (var variant in variants) {
        final variantRef = docRef.collection('variants').doc();
        batch.set(variantRef, variant.toJson());
      }
      await batch.commit();
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to create product: $e',
      );
    }
  }

  // Get product with variants
  Future<ProductModel> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw 'Product not found';
      }

      final variantsSnapshot = await doc.reference.collection('variants').get();
      final variants = variantsSnapshot.docs
          .map((doc) => ProductVariant.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();

      return ProductModel.fromFirestore(doc.id, {
        ...doc.data()!,
        'variants': variants,
      });
    } catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        message: 'Failed to get product: $e',
      );
    }
  }
}
