import 'package:flutter/material.dart';
import 'package:ojachat/widgets/product_card.dart';

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely extract message data
    final role = message['role'] as String? ?? 'user';
    final content = message['content'] as String? ?? '';
    final products = message['products'] as List<dynamic>? ?? [];
    final isUser = role == 'user';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Icon(Icons.auto_awesome, size: 16, color: Colors.grey[700]),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(content, style: TextStyle(fontSize: 16)),
                  if (!isUser && products.isNotEmpty)
                    _buildProductsList(products),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<dynamic> products) {
    if (products.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Divider(),
        const Text('Available Products:', 
                 style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                imageUrl: product['imageUrl'] ?? '',
                name: product['name'] ?? 'No name',
                price: (product['price'] as num).toDouble(),
                unit: product['unit'],
                onTap: () {},
                isLoading: false,
              );
            },
          ),
        ),
      ],
    );
  }
} 