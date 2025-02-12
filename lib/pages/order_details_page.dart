import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          StreamBuilder<OrderModel>(
            stream: OrderService().getOrderById(orderId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              
              final order = snapshot.data!;
              if (!OrderService().canCancelOrder(order.status)) return SizedBox();

              return TextButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: Icon(Icons.cancel_outlined, color: Colors.red),
                label: Text(
                  'Cancel Order',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<OrderModel>(
        stream: OrderService().getOrderById(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final order = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildStatusTimeline(order.status),
              SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Items',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ...order.items.map((item) => ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.unit ?? ""}'),
                        trailing: Text('₦${item.price}'),
                      )),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '₦${order.total}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivery Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text(order.customerName),
                      ),
                      ListTile(
                        leading: Icon(Icons.phone_outlined),
                        title: Text(order.phoneNumber),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on_outlined),
                        title: Text(order.deliveryAddress),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusTimeline(OrderStatus currentStatus) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.delivering,
      OrderStatus.delivered,
    ];

    return Row(
      children: statuses.map((status) {
        final isActive = _isStatusActive(currentStatus, status);
        final isCompleted = _isStatusCompleted(currentStatus, status);

        return Expanded(
          child: Column(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isActive || isCompleted ? Colors.green : Colors.grey,
              ),
              SizedBox(height: 4),
              Text(
                status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: isActive || isCompleted ? Colors.green : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isStatusActive(OrderStatus currentStatus, OrderStatus status) {
    return currentStatus == status;
  }

  bool _isStatusCompleted(OrderStatus currentStatus, OrderStatus status) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.delivering,
      OrderStatus.delivered,
    ];
    
    final currentIndex = statuses.indexOf(currentStatus);
    final statusIndex = statuses.indexOf(status);
    
    return statusIndex < currentIndex;
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Order'),
        content: Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('YES, CANCEL'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await OrderService().cancelOrder(orderId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order cancelled successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel order: $e')),
        );
      }
    }
  }
} 