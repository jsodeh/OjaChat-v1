import 'package:flutter/material.dart';

class OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onConfirm;

  const OrderItemCard({
    Key? key,
    required this.item,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(item['name']),
        subtitle: Text('Quantity: ${item['quantity']} ${item['unit']}'),
        trailing: ElevatedButton(
          onPressed: onConfirm,
          child: Text('Confirm'),
        ),
      ),
    );
  }
} 