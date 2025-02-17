// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VendorModel _$VendorModelFromJson(Map<String, dynamic> json) => VendorModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      market: json['market'] as String,
      categories: (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
      products: (json['products'] as List<dynamic>).map((e) => e as String).toList(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fcmToken: json['fcmToken'] as String?,
      bankInfo: json['bankInfo'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$VendorModelToJson(VendorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'market': instance.market,
      'products': instance.products,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'fcmToken': instance.fcmToken,
      'userId': instance.userId,
      'bankInfo': instance.bankInfo,
    };
