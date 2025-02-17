import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

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

@JsonSerializable()
class OrderModel {
  final String id;
  final String customerName;
  final String customerId;
  final String phoneNumber;
  final String deliveryAddress;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String market;
  final List<String> vendorIds;
  final bool paidOut;
  final List<String>? paidVendors;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerId,
    required this.phoneNumber,
    required this.deliveryAddress,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.market,
    required this.vendorIds,
    this.paidOut = false,
    this.paidVendors,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerName: map['customerName'] ?? '',
      customerId: map['customerId'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      deliveryAddress: map['deliveryAddress'] ?? '',
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      total: (map['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      market: map['market'] ?? '',
      vendorIds: List<String>.from(map['vendorIds'] ?? []),
      paidOut: map['paidOut'] ?? false,
      paidVendors: map['paidVendors'] != null 
          ? List<String>.from(map['paidVendors'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerId': customerId,
      'phoneNumber': phoneNumber,
      'deliveryAddress': deliveryAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'market': market,
      'vendorIds': vendorIds,
      'paidOut': paidOut,
      'paidVendors': paidVendors,
    };
  }

  double get totalAmount => items.fold(
    0, 
    (sum, item) => sum + (item.price * item.quantity)
  );
}

@JsonSerializable()
class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? unit;
  final List<String>? confirmedBy;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.unit,
    this.confirmedBy,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'] as int,
    unit: json['unit'] as String?,
    confirmedBy: (json['confirmedBy'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'unit': unit,
    'confirmedBy': confirmedBy,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem.fromJson(map);
  Map<String, dynamic> toMap() => toJson();
} 