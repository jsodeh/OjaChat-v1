import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';

class OrderFulfillmentPage extends StatelessWidget {
  final OrderModel order;

  const OrderFulfillmentPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id.substring(0, 8)}'),
      ),
      body: Column(
        children: [
          _OrderStatusStepper(order: order),
          Expanded(
            child: ListView.builder(
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _FulfillmentItemCard(
                  item: item,
                  orderId: order.id,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: order.status == OrderStatus.processing
                ? () => _markAsReady(context)
                : null,
            child: Text('Mark as Ready'),
          ),
        ),
      ),
    );
  }

  Future<void> _markAsReady(BuildContext context) async {
    try {
      await FirebaseService().updateOrderStatus(order.id, OrderStatus.ready);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as ready')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _OrderStatusStepper extends StatelessWidget {
  final OrderModel order;

  const _OrderStatusStepper({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = [
      OrderStatus.paid,
      OrderStatus.processing,
      OrderStatus.ready,
      OrderStatus.completed,
    ];

    return Stepper(
      currentStep: steps.indexOf(order.status),
      controlsBuilder: (_, __) => SizedBox(),
      steps: steps.map((status) {
        return Step(
          title: Text(status.toString().split('.').last),
          content: SizedBox(),
          isActive: steps.indexOf(status) <= steps.indexOf(order.status),
          state: steps.indexOf(status) < steps.indexOf(order.status)
              ? StepState.complete
              : StepState.indexed,
        );
      }).toList(),
    );
  }
}

class _FulfillmentItemCard extends StatelessWidget {
  final OrderItem item;
  final String orderId;

  const _FulfillmentItemCard({
    Key? key,
    required this.item,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text('Quantity: ${item.quantity} ${item.unit}'),
            Text('Price: ₦${item.price}'),
          ],
        ),
      ),
    );
  }
} 