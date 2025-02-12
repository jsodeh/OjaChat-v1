import 'cart_item.dart';

enum OrderStatus {
  pending,    // Initial state when order is created
  matching,   // Looking for vendors
  confirming, // Vendors are confirming items
  confirmed,  // User has accepted confirmations
  paid,       // Payment received
  processing, // Vendors are fulfilling
  ready,      // Ready for pickup/delivery
  completed,  // Order completed
  cancelled,  // Order cancelled
  delivering, // Order is being delivered
  delivered,  // Order has been delivered
}

class OrderModel {
  final String id;
  final String userId;
  final String market;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;
  final double total;
  final List<String> vendorIds;
  final double totalAmount;
  final Map<String, dynamic>? metadata;
  final String customerName;
  final String phoneNumber;
  final String deliveryAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.market,
    required this.items,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.vendorIds,
    required this.totalAmount,
    this.metadata,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryAddress,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'market': market,
    'items': items.map((item) => item.toMap()).toList(),
    'status': status.toString(),
    'createdAt': createdAt.toIso8601String(),
    'total': total,
    'vendorIds': vendorIds,
    'totalAmount': totalAmount,
    'metadata': metadata,
    'customerName': customerName,
    'phoneNumber': phoneNumber,
    'deliveryAddress': deliveryAddress,
  };

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'],
      market: map['market'],
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      total: map['total'],
      vendorIds: List<String>.from(map['vendorIds']),
      totalAmount: map['totalAmount'],
      metadata: map['metadata'],
      customerName: map['customerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
    );
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String name;
  final double quantity;
  final String unit;
  final double price;
  final List<String>? confirmedBy;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    this.confirmedBy,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'confirmedBy': confirmedBy,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      productId: map['productId'],
      name: map['name'],
      quantity: map['quantity'].toDouble(),
      unit: map['unit'],
      price: map['price'].toDouble(),
      confirmedBy: map['confirmedBy'] != null 
          ? List<String>.from(map['confirmedBy'])
          : null,
    );
  }
} 