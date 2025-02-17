// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String?,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String,
      market: json['market'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      searchTerms: (json['searchTerms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'unit': instance.unit,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'market': instance.market,
      'createdAt': instance.createdAt.toIso8601String(),
      'searchTerms': instance.searchTerms,
      'isActive': instance.isActive,
      'variants': instance.variants.map((e) => e.toJson()).toList(),
    };

ProductVariant _$ProductVariantFromJson(Map<String, dynamic> json) =>
    ProductVariant(
      id: json['id'] as String?,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ProductVariantToJson(ProductVariant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
