class CartItem {
  final String name;
  final double amount;
  double? price;
  String? unit;

  CartItem({
    required this.name,
    required this.amount,
    this.price,
    this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'price': price,
      'unit': unit,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name'] as String,
      amount: map['amount'] as double,
      price: map['price'] as double?,
      unit: map['unit'] as String?,
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
        name: name,
        amount: amount,
      );
    }).toList();
  }
} 