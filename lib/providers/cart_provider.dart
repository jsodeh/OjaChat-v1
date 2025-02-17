import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? unit;
  final String? variantId;
  final String? variantName;

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
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  double get total => _items.fold(
    0, 
    (sum, item) => sum + (item.price ?? 0) * item.quantity
  );

  void addToCart(Map<String, dynamic> productInfo, {String? variantId, int quantity = 1}) {
    final variant = variantId != null 
        ? (productInfo['variants'] as List).firstWhere(
            (v) => v['id'] == variantId,
            orElse: () => null,
          )
        : null;

    final item = CartItem(
      productId: productInfo['id'],
      name: productInfo['name'],
      price: variant != null 
          ? (variant['price'] as num).toDouble()
          : (productInfo['basePrice'] as num).toDouble(),
      quantity: quantity,
      unit: productInfo['unit'],
      variantId: variant?['id'],
      variantName: variant?['name'],
    );

    final existingIndex = _items.indexWhere((i) => 
        i.productId == item.productId && i.variantId == item.variantId);

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
} 