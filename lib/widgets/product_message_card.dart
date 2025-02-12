import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
      width: 140,
      margin: EdgeInsets.only(right: 8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.network(
                  product['imageUrl'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey[400],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Text(
                product['name'] ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Price not available',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => onDetailsPressed(product['name']),
                  child: Text('View Product'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 