import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../config/firebase_config.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Caching layer
  final Map<String, DocumentSnapshot?> _cache = {};

  Future<List<Map<String, dynamic>>> queryProducts(String query) async {
    try {
      // Clean up and extract keywords
      final keywords = query.toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(' ')
          .where((word) => 
            word.isNotEmpty && 
            !['i', 'want', 'to', 'buy', 'hi', 'hello', 'the', 'for', 'and', 'prices'].contains(word)
          )
          .toList();
      
      print('Cleaned keywords: $keywords');
      if (keywords.isEmpty) return [];

      // Store all results
      Set<QueryDocumentSnapshot> allDocs = {};

      // Query for each keyword
      for (String keyword in keywords) {
        // Try keywords array
        final keywordResults = await _firestore
            .collection(FirebaseCollections.products)
            .where('keywords', arrayContains: keyword)
            .get();

        // Try name field
        final nameResults = await _firestore
            .collection(FirebaseCollections.products)
            .where('name', isGreaterThanOrEqualTo: keyword.capitalize())
            .where('name', isLessThan: keyword.capitalize() + 'z')
            .get();

        // Add results for this keyword
        allDocs.addAll(keywordResults.docs);
        allDocs.addAll(nameResults.docs);
      }
      
      print('Found ${allDocs.length} products'); // Debug log
      
      // Transform results to include units and images
      final results = await Future.wait(
        allDocs.map((doc) => getProductWithUnits(doc))
      );
      
      return results;
    } catch (e) {
      print('Firestore error details: $e');
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
}

// Add this extension
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
