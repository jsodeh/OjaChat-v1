import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import 'firebase_service.dart';
import 'payment_service.dart';

class CheckoutService {
  final FirebaseService _firebaseService = FirebaseService();
  final PaymentService _paymentService = PaymentService();

  Future<String> initiateCheckout(OrderModel order) async {
    try {
      // Validate order
      if (order.items.isEmpty) {
        throw Exception('Order must have at least one item');
      }

      // Create order first
      final orderId = await _firebaseService.createOrder(order);
      
      // Start listening for vendor confirmations
      _firebaseService.streamOrder(orderId).listen(
        (updatedOrder) {
          _handleOrderUpdates(updatedOrder);
        },
        onError: (error) {
          print('Error streaming order: $error');
        },
      );

      return orderId;
    } catch (e) {
      print('Error initiating checkout: $e');
      rethrow;
    }
  }

  void _handleOrderUpdates(OrderModel order) {
    switch (order.status) {
      case OrderStatus.confirmed:
        // All items confirmed, ready for payment
        _initiatePayment(order);
        break;
      case OrderStatus.paid:
        // Payment received, notify vendors
        _notifyVendors(order);
        break;
      default:
        break;
    }
  }

  Future<void> _initiatePayment(OrderModel order) async {
    try {
      final paymentResult = await _paymentService.processPayment(
        amount: order.totalAmount,
        orderId: order.id,
      );
      
      if (paymentResult.success) {
        await _firebaseService.updateOrderStatus(
          order.id, 
          OrderStatus.paid,
        );
      }
    } catch (e) {
      print('Payment error: $e');
      rethrow;
    }
  }

  Future<void> _notifyVendors(OrderModel order) async {
    try {
      for (final vendorId in order.vendorIds) {
        await _firebaseService.sendOrderNotification(
          vendorId: vendorId,
          orderId: order.id,
          type: 'order_paid',
        );
      }
    } catch (e) {
      print('Notification error: $e');
      rethrow;
    }
  }
} 