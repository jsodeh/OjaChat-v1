import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final String itemId;

  const OrderConfirmationPage({
    Key? key,
    required this.orderId,
    required this.itemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirm Order')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!;
          final items = List<Map<String, dynamic>>.from(
            order.get('items') ?? []
          );
          
          final item = items.firstWhere(
            (i) => i['id'] == itemId,
            orElse: () => throw Exception('Item not found')
          );

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderItemDetails(item: item),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await OrderService().confirmOrder(
                        orderId,
                        itemId,
                        AuthService().currentUser!.uid,
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: Text('Confirm Order'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class OrderItemDetails extends StatelessWidget {
  final Map<String, dynamic> item;

  const OrderItemDetails({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text('Quantity: ${item['quantity']}'),
            Text('Price: ₦${item['price']}'),
          ],
        ),
      ),
    );
  }
}