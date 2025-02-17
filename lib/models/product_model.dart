import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductModel {
  final String? id;
  final String name;
  final double price;
  final String? unit;
  final String? imageUrl;
  final String category;
  final String market;
  final DateTime createdAt;
  final List<String> searchTerms;
  final bool isActive;
  final List<ProductVariant> variants;

  const ProductModel({
    this.id,
    required this.name,
    required this.price,
    this.unit,
    this.imageUrl,
    required this.category,
    required this.market,
    required this.createdAt,
    required this.searchTerms,
    this.isActive = true,
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  // For Firestore documents
  factory ProductModel.fromFirestore(String id, Map<String, dynamic> map) {
    return ProductModel.fromJson({
      'id': id,
      ...map,
      'createdAt': map['createdAt']?.toIso8601String() ?? DateTime.now().toIso8601String(),
    });
  }

  // This method is used for chat context
  Map<String, dynamic> toChatContext() {
    return {
      'id': id,
      'name': name,
      'basePrice': price,
      'unit': unit,
      'category': category,
      'market': market,
      'variants': variants.map((v) => {
        'id': v.id,
        'name': v.name,
        'price': v.price,
        'description': '${name} - ${v.name} at ₦${v.price}',
      }).toList(),
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      unit: map['unit'] as String?,
      imageUrl: map['imageUrl'] as String?,
      category: map['category'] as String? ?? 'uncategorized',
      market: map['market'] as String? ?? 'unknown',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      searchTerms: (map['searchTerms'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isActive: map['isActive'] as bool? ?? true,
      variants: (map['variants'] as List<dynamic>?)
          ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ProductVariant {
  final String? id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  const ProductVariant({
    this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.createdAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    id: json['id'] as String?,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String?,
    description: json['description'] as String?,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };
}
