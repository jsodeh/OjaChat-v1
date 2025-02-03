import 'package:json_annotation/json_annotation.dart';
import 'product_model.dart'; // Import the ProductModel if needed

part 'chat_message_model.g.dart';

enum SenderType { user, bot }
enum MessageStatus { sending, sent, error }

@JsonSerializable()
class ChatMessageModel {
  final String content;
  final DateTime timestamp;
  final SenderType senderType;
  
  @JsonKey(fromJson: _productFromJson, toJson: _productToJson)
  final ProductModel? product;
  
  final MessageStatus status;

  const ChatMessageModel({
    required this.content,
    required this.timestamp,
    required this.senderType,
    this.product,
    required this.status,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModel &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          timestamp == other.timestamp &&
          senderType == other.senderType &&
          product == other.product &&
          status == other.status;

  @override
  int get hashCode => content.hashCode ^ timestamp.hashCode ^ senderType.hashCode ^ (product?.hashCode ?? 0) ^ status.hashCode;
}

ProductModel? _productFromJson(Map<String, dynamic>? json) =>
    json != null ? ProductModel.fromJson(json) : null;

Map<String, dynamic>? _productToJson(ProductModel? product) =>
    product?.toJson();

class ProductModel {
  final String imageUrl;
  final String name;
  final double price;

  ProductModel({
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'name': name,
      'price': price,
    };
  }
}
