import 'package:json_annotation/json_annotation.dart';

part 'vendor_model.g.dart';

@JsonSerializable()
class VendorModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String market;
  final List<String> categories;
  final List<String> products;
  final bool isActive;
  final DateTime createdAt;
  final String? fcmToken;
  final Map<String, dynamic>? bankInfo;

  const VendorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.market,
    required this.categories,
    required this.products,
    required this.isActive,
    required this.createdAt,
    this.fcmToken,
    this.bankInfo,
  });

  factory VendorModel.fromMap(String id, Map<String, dynamic> map) {
    return VendorModel(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      market: map['market'] as String,
      categories: List<String>.from(map['categories'] ?? []),
      products: List<String>.from(map['products'] ?? []),
      isActive: map['isActive'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      fcmToken: map['fcmToken'] as String?,
      bankInfo: map['bankInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'market': market,
      'categories': categories,
      'products': products,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'fcmToken': fcmToken,
      'bankInfo': bankInfo,
    };
  }
} 