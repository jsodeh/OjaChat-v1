import 'package:flutter/material.dart';
import '../styles/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final List<dynamic>? products;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
    this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final typedProducts = products?.map((p) => p as Map<String, dynamic>).toList();
    
    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                margin: EdgeInsets.only(right: 8, top: 8),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: Colors.white70,
                ),
              ),
            ],
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? AppTheme.primaryColor : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!isUser && typedProducts != null && typedProducts.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 40), // Align with the message bubble
            child: Container(
              height: 120,
              margin: EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: typedProducts.length,
                itemBuilder: (context, index) {
                  final product = typedProducts[index];
                  return Container(
                    width: 160,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product['imageUrl'] != null && product['imageUrl'].isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              product['imageUrl'],
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 80,
                                color: Colors.white10,
                                child: Icon(Icons.image_not_supported, color: Colors.white30),
                              ),
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? 'Unknown Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₦${product['price']} per ${product['unit'] ?? 'unit'}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}