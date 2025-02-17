import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class ProductRecommendation extends StatefulWidget {
  final Map<String, dynamic> productInfo;

  const ProductRecommendation({
    Key? key,
    required this.productInfo,
  }) : super(key: key);

  @override
  _ProductRecommendationState createState() => _ProductRecommendationState();
}

class _ProductRecommendationState extends State<ProductRecommendation> {
  final Map<String, int> _quantities = {};
  int _baseQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final variants = widget.productInfo['variants'] as List;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.productInfo['imageUrl'] != null)
            Image.network(
              widget.productInfo['imageUrl'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productInfo['name'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Base Price: ₦${widget.productInfo['basePrice']} per ${widget.productInfo['unit'] ?? 'unit'}',
                    ),
                    Spacer(),
                    _buildQuantitySelector(
                      quantity: _baseQuantity,
                      onChanged: (value) => setState(() => _baseQuantity = value),
                    ),
                  ],
                ),
                if (variants.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Available Variants:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...variants.map((variant) => ListTile(
                    title: Text(variant['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₦${variant['price']}'),
                        if (variant['description'] != null)
                          Text(
                            variant['description'],
                            style: TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildQuantitySelector(
                          quantity: _quantities[variant['id']] ?? 1,
                          onChanged: (value) => setState(() => 
                            _quantities[variant['id']] = value),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Text('Add'),
                          onPressed: () {
                            context.read<CartProvider>().addToCart(
                              widget.productInfo,
                              variantId: variant['id'],
                              quantity: _quantities[variant['id']] ?? 1,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added to cart')),
                            );
                          },
                        ),
                      ],
                    ),
                  )),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Add Base Product'),
                  onPressed: () {
                    context.read<CartProvider>().addToCart(
                      widget.productInfo,
                      quantity: _baseQuantity,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to cart')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector({
    required int quantity,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        Text('$quantity'),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
} 