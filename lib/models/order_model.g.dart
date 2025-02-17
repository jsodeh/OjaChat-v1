// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerId: json['customerId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      deliveryAddress: json['deliveryAddress'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      market: json['market'] as String,
      vendorIds:
          (json['vendorIds'] as List<dynamic>).map((e) => e as String).toList(),
      paidOut: json['paidOut'] as bool? ?? false,
      paidVendors: (json['paidVendors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'customerId': instance.customerId,
      'phoneNumber': instance.phoneNumber,
      'deliveryAddress': instance.deliveryAddress,
      'items': instance.items,
      'total': instance.total,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'market': instance.market,
      'vendorIds': instance.vendorIds,
      'paidOut': instance.paidOut,
      'paidVendors': instance.paidVendors,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.matching: 'matching',
  OrderStatus.confirming: 'confirming',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.paid: 'paid',
  OrderStatus.processing: 'processing',
  OrderStatus.ready: 'ready',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
  OrderStatus.delivering: 'delivering',
  OrderStatus.delivered: 'delivered',
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String?,
      confirmedBy: (json['confirmedBy'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'price': instance.price,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'confirmedBy': instance.confirmedBy,
    };
