import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/payout_model.dart';
import 'firebase_service.dart';
import 'payout_service.dart';

class PayoutScheduler {
  final FirebaseService _firebaseService = FirebaseService();
  final PayoutService _payoutService = PayoutService();
  final _uuid = Uuid();

  // Process payouts for completed orders
  Future<void> processVendorPayouts() async {
    try {
      // Get all completed orders that haven't been paid out
      final orders = await _firebaseService.getUnpaidCompletedOrders();
      
      // Group orders by vendor
      final vendorOrders = _groupOrdersByVendor(orders);
      
      // Process payouts for each vendor
      for (final vendorId in vendorOrders.keys) {
        await _processVendorPayout(
          vendorId,
          vendorOrders[vendorId]!,
        );
      }
    } catch (e) {
      print('Error processing payouts: $e');
      rethrow;
    }
  }

  Map<String, List<OrderModel>> _groupOrdersByVendor(List<OrderModel> orders) {
    final vendorOrders = <String, List<OrderModel>>{};
    
    for (final order in orders) {
      for (final item in order.items) {
        if (item.confirmedBy == null || item.confirmedBy!.isEmpty) continue;
        
        for (final vendorId in item.confirmedBy!) {
          vendorOrders.putIfAbsent(vendorId, () => []);
          if (!vendorOrders[vendorId]!.contains(order)) {
            vendorOrders[vendorId]!.add(order);
          }
        }
      }
    }
    
    return vendorOrders;
  }

  Future<void> _processVendorPayout(
    String vendorId,
    List<OrderModel> orders,
  ) async {
    try {
      // Calculate total payout amount
      final amount = _calculatePayoutAmount(vendorId, orders);
      if (amount <= 0) return;

      // Generate unique reference
      final reference = 'PAY_${_uuid.v4()}';

      // Initiate transfer
      await _payoutService.initiateTransfer(
        vendorId,
        amount,
        reference,
      );

      // Mark orders as paid
      await Future.wait(orders.map((order) =>
          _firebaseService.markOrderPaid(order.id, vendorId)));

    } catch (e) {
      print('Error processing payout for vendor $vendorId: $e');
      // Notify admin of failed payout
      await _firebaseService.notifyAdmin(
        'Payout Failed',
        'Failed to process payout for vendor $vendorId: $e',
      );
      rethrow;
    }
  }

  double _calculatePayoutAmount(String vendorId, List<OrderModel> orders) {
    double total = 0;
    
    for (final order in orders) {
      for (final item in order.items) {
        if (item.confirmedBy?.contains(vendorId) ?? false) {
          total += item.price * item.quantity;
        }
      }
    }
    
    return total;
  }
} 