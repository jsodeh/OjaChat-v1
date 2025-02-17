class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? unit;
  final String? variantId;
  final String? variantName;

  double get amount => price * quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.unit,
    this.variantId,
    this.variantName,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': variantName != null ? '$name - $variantName' : name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'variantId': variantId,
      'variantName': variantName,
    };
  }

  CartItem copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? unit,
    String? variantId,
    String? variantName,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] as String,
      name: map['name'] as String,
      price: map['price'] as double,
      quantity: map['quantity'] as int,
      unit: map['unit'] as String?,
      variantId: map['variantId'] as String?,
      variantName: map['variantName'] as String?,
    );
  }

  static List<CartItem>? parseShoppingList(String message) {
    // Match patterns like "rice 2k", "tomatoes 1500", "onions 600"
    final regex = RegExp(r'(\w+)\s+(\d+)(?:k)?', multiLine: true);
    final matches = regex.allMatches(message.toLowerCase());

    if (matches.isEmpty) return null;

    return matches.map((match) {
      final name = match.group(1)!;
      var amount = double.parse(match.group(2)!);
      // Convert 'k' to thousands
      if (message.toLowerCase().contains('${match.group(2)}k')) {
        amount *= 1000;
      }
      return CartItem(
        productId: '',
        name: name,
        price: amount,
        quantity: 1,
        unit: match.group(3) == 'k' ? 'kg' : null,
        variantId: null,
        variantName: null,
      );
    }).toList();
  }
} 