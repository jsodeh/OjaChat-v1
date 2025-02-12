import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double price;
  final String? unit;
  final VoidCallback onTap;
  final bool isLoading;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.unit,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(Icons.error),
              )
            else
              Container(
                height: 40,
                width: 40,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, size: 20),
              ),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '₦${price.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
            if (unit != null)
              Text(
                'per $unit',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
} 