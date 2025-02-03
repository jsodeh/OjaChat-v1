import 'package:flutter/material.dart';

class ProductDetailView extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailView({
    Key? key,
    required this.product,
  }) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 340,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: ProductDetailView(product: product),
          ),
        ),
      ),
    );
  }

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int? selectedUnitIndex;

  String get selectedPrice {
    if (selectedUnitIndex == null || 
        widget.product['units'] == null || 
        (widget.product['units'] as List).isEmpty) {
      return 'Select size';
    }
    final unit = (widget.product['units'] as List)[selectedUnitIndex!];
    return '₦${unit['price']}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag Handle
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Content
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Product Image with Overlay
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      widget.product['imageUrl'] ?? 'placeholder_url',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: IconButton(
                            icon: Icon(Icons.share, size: 20),
                            onPressed: () {},
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: IconButton(
                            icon: Icon(Icons.favorite_border, size: 20),
                            onPressed: () {},
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Product Info
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          ' 4.8 ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('(2.3k)', style: TextStyle(color: Colors.grey)),
                        Spacer(),
                        Text(
                          'In stock',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Variants Section
                    Text(
                      'Select Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (widget.product['units'] as List?)?.length ?? 0,
                        itemBuilder: (context, index) {
                          final unit = (widget.product['units'] as List)[index];
                          final isSelected = selectedUnitIndex == index;
                          
                          return GestureDetector(
                            onTap: () => setState(() => selectedUnitIndex = index),
                            child: Container(
                              width: 120,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: isSelected ? Colors.blue.withOpacity(0.05) : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    unit['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Theme.of(context).primaryColor : null,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '₦${unit['price']}',
                                    style: TextStyle(
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor 
                                          : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    unit['quantity'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    selectedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedUnitIndex != null ? () {
                    // Handle add to cart
                    final selectedUnit = (widget.product['units'] as List)[selectedUnitIndex!];
                    print('Adding to cart: ${widget.product['name']} - ${selectedUnit['name']} at ₦${selectedUnit['price']}');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 