class ProductVariant {
  final String? id;
  final String unit;
  final double price;
  final int? stock;

  ProductVariant({
    this.id,
    required this.unit,
    required this.price,
    this.stock,
  });

  Map<String, dynamic> toMap() => {
    'unit': unit,
    'price': price,
    'stock': stock,
  };

  factory ProductVariant.fromMap(String id, Map<String, dynamic> map) {
    return ProductVariant(
      id: id,
      unit: map['unit'],
      price: map['price'],
      stock: map['stock'],
    );
  }
} 