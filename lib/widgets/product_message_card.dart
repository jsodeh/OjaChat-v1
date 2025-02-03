import 'package:flutter/material.dart';
import 'dart:math';

class ProductMessageCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function(String) onDetailsPressed;

  const ProductMessageCard({
    Key? key, 
    required this.product,
    required this.onDetailsPressed,
  }) : super(key: key);

  String _getPriceRange() {
    if (product['units'] == null || (product['units'] as List).isEmpty) {
      return 'Price not available';
    }
    final prices = (product['units'] as List)
        .map((unit) => unit['price'] as num)
        .toList();
    return '₦${prices.reduce(min)} - ₦${prices.reduce(max)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Fixed width for consistent card size
      margin: EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product Image
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: product['imageUrl']?.isNotEmpty == true
                    ? Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.image_outlined, color: Colors.grey[400]),
                      ),
              ),
            ),
            
            // Rating Stars
            Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: List.generate(5, (index) => 
                  Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  )
                ),
              ),
            ),

            // Product Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                product['name'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Price Range
            Padding(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Text(
                _getPriceRange(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // View Product Button
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ElevatedButton(
                onPressed: () => onDetailsPressed(product['name']),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 32),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                child: Text('View Product', style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 