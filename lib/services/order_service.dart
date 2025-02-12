import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Possible order statuses
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_PROCESSING = 'processing';
  static const String STATUS_DELIVERING = 'delivering';
  static const String STATUS_DELIVERED = 'delivered';
  static const String STATUS_CANCELLED = 'cancelled';

  Future<String> createOrder(OrderModel order) async {
    final doc = await _firestore.collection('orders').add(order.toMap());
    return doc.id;
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<OrderModel> getOrderById(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => OrderModel.fromMap(doc.id, doc.data() ?? {}));
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': STATUS_CANCELLED,
        'updatedAt': DateTime.now().toIso8601String(),
        'cancelledAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  bool canCancelOrder(OrderStatus status) {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }

  Future<void> confirmOrder(String orderId, String itemId, String vendorId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final orderDoc = await transaction.get(
          _firestore.collection('orders').doc(orderId)
        );
        
        if (!orderDoc.exists) {
          throw Exception('Order not found');
        }

        final items = List<Map<String, dynamic>>.from(
          orderDoc.data()?['items'] ?? []
        );

        final itemIndex = items.indexWhere((item) => item['id'] == itemId);
        if (itemIndex == -1) {
          throw Exception('Item not found in order');
        }

        final confirmedBy = List<String>.from(
          items[itemIndex]['confirmedBy'] ?? []
        );

        if (!confirmedBy.contains(vendorId)) {
          confirmedBy.add(vendorId);
          items[itemIndex]['confirmedBy'] = confirmedBy;
          
          transaction.update(orderDoc.reference, {'items': items});
        }
      });
    } catch (e) {
      print('Error confirming order: $e');
      rethrow;
    }
  }
}