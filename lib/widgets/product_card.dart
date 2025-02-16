import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String unit;
  final VoidCallback onTap;
  final bool isLoading;

  const ProductCard({
    this.imageUrl = '',  // Default empty string
    required this.name, 
    required this.price,
    this.unit = 'unit',  // Default unit
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    print('Building ProductCard:');
    print('Name: $name');
    print('Price: $price');
    print('Unit: $unit');
    print('ImageUrl: $imageUrl');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: Container(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with fallback
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                color: Colors.grey[800], // Fallback background color
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Network image error: $error');
                          return Image.asset(
                            'assets/issue 1.png', // Fallback image
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/issue 1a.png', // Default image when URL is empty
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            // Product details with null checks
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'Product Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₦${price.toStringAsFixed(2)} / ${unit.isNotEmpty ? unit : 'unit'}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}