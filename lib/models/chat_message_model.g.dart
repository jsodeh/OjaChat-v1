// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      senderType: $enumDecode(_$SenderTypeEnumMap, json['senderType']),
      product: _productFromJson(json['product'] as Map<String, dynamic>?),
      status: $enumDecode(_$MessageStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'senderType': _$SenderTypeEnumMap[instance.senderType]!,
      'product': _productToJson(instance.product),
      'status': _$MessageStatusEnumMap[instance.status]!,
    };

const _$SenderTypeEnumMap = {
  SenderType.user: 'user',
  SenderType.bot: 'bot',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.error: 'error',
};
