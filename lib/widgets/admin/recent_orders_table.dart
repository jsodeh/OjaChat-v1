import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/order_model.dart';
import 'package:intl/intl.dart';

class RecentOrdersTable extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<List<OrderModel>>(
        stream: _firebaseService.getRecentOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: TextStyle(
                color: Colors.white70,
              ),
              columns: [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Items')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
              ],
              rows: orders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order.id.substring(0, 8))),
                    DataCell(Text(order.customerName)),
                    DataCell(Text(order.items.length.toString())),
                    DataCell(Text('₦${order.total.toStringAsFixed(2)}')),
                    DataCell(_buildStatusChip(order.status)),
                    DataCell(Text(
                      DateFormat('MMM d, y').format(order.createdAt),
                    )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        break;
      case OrderStatus.processing:
        color = Colors.blue;
        break;
      case OrderStatus.completed:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }
} 