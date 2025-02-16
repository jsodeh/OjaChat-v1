import 'package:flutter/material.dart';
import 'package:ojachat/widgets/product_card.dart';
import 'package:ojachat/styles/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final List<dynamic>? products;

  const ChatBubble({
    required this.message,
    required this.isUser,
    this.products,
  });

  @override
  Widget build(BuildContext context) {
    print('Building ChatBubble:');
    print('- Is user message: $isUser');
    print('- Message: $message');
    print('- Has products: ${products?.isNotEmpty}');
    if (products != null) {
      print('- Number of products: ${products!.length}');
      print('- Product details: $products');
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
        children: [
          if (!isUser) ...[
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUser 
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (products != null && products!.isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Related Products',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products!.length,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 4),
                        itemBuilder: (context, index) {
                          final product = products![index];
                          return ProductCard(
                            imageUrl: product['imageUrl'] as String? ?? '',
                            name: product['name'] as String? ?? 'Product Name',
                            price: (product['price'] as num?)?.toDouble() ?? 0.0,
                            unit: product['unit'] as String? ?? 'unit',
                            onTap: () {},
                            isLoading: false,
                          );
                        },
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