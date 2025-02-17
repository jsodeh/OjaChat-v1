import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/order_model.dart';
import '../../styles/app_theme.dart';
import 'package:intl/intl.dart';

class DeliveryManagementPage extends StatefulWidget {
  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedStatus = 'all'; // all, pending, delivering, delivered

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Delivery Management'),
        actions: [
          _buildFilterButton(),
        ],
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firebaseService.getDeliveryOrders(_selectedStatus),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildDeliveryCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: (value) {
        setState(() => _selectedStatus = value);
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'all', child: Text('All Deliveries')),
        PopupMenuItem(value: 'ready', child: Text('Ready for Delivery')),
        PopupMenuItem(value: 'delivering', child: Text('In Transit')),
        PopupMenuItem(value: 'delivered', child: Text('Delivered')),
      ],
    );
  }

  Widget _buildDeliveryCard(OrderModel order) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: _buildStatusIcon(order.status),
        title: Text(
          'Order #${order.id.substring(0, 8)}',
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${order.customerName} • ${DateFormat('MMM d, y').format(order.createdAt)}',
          style: TextStyle(color: Colors.white70),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Customer', order.customerName),
                _buildInfoRow('Market', order.market),
                _buildInfoRow('Items', '${order.items.length} items'),
                _buildInfoRow('Total', '₦${order.total.toStringAsFixed(2)}'),
                SizedBox(height: 16),
                if (order.status == OrderStatus.ready)
                  _buildStartDeliveryButton(order)
                else if (order.status == OrderStatus.delivering)
                  _buildCompleteDeliveryButton(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(OrderStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case OrderStatus.ready:
        icon = Icons.local_shipping_outlined;
        color = Colors.orange;
        break;
      case OrderStatus.delivering:
        icon = Icons.delivery_dining;
        color = Colors.blue;
        break;
      case OrderStatus.delivered:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartDeliveryButton(OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.delivery_dining),
        label: Text('Start Delivery'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => _startDelivery(order),
      ),
    );
  }

  Widget _buildCompleteDeliveryButton(OrderModel order) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.check_circle),
        label: Text('Complete Delivery'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => _completeDelivery(order),
      ),
    );
  }

  Future<void> _startDelivery(OrderModel order) async {
    try {
      await _firebaseService.updateOrderStatus(
        order.id,
        OrderStatus.delivering,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _completeDelivery(OrderModel order) async {
    try {
      await _firebaseService.updateOrderStatus(
        order.id,
        OrderStatus.delivered,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delivery completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
} 