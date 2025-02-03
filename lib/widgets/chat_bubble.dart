import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import 'product_message_card.dart';
import 'product_card.dart'; // Import ProductCard if needed
import 'product_detail_view.dart';  // Add this import

class ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message['role'] == 'user';
    final content = message['content'] as String;
    final products = message['products'] as List<Map<String, dynamic>>?;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) 
            Padding(
              padding: EdgeInsets.only(right: 8, top: 4),
              child: Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.grey[700],
              ),
            ),
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
                  Text(content),
                  if (products != null && products.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      height: 320,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: products.map((product) => 
                          ProductMessageCard(
                            product: product,
                            onDetailsPressed: (name) {
                              ProductDetailView.show(context, product);
                            },
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 