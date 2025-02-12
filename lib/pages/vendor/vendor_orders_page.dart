import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';
import 'order_fulfillment_page.dart';

class VendorOrdersPage extends StatelessWidget {
  final String vendorId;

  const VendorOrdersPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Orders'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderList(
              vendorId: vendorId,
              status: [OrderStatus.paid, OrderStatus.processing, OrderStatus.ready],
            ),
            _OrderList(
              vendorId: vendorId,
              status: [OrderStatus.completed],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String vendorId;
  final List<OrderStatus> status;

  const _OrderList({
    Key? key,
    required this.vendorId,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: FirebaseService().getVendorOrders(vendorId, status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return Center(child: Text('No orders found'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderFulfillmentPage(order: order),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Order #${order.id.substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.toString().split('.').last}'),
            Text('Items: ${order.items.length}'),
            Text('Total: ₦${order.total}'),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 