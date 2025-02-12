class OrderConfirmation {
  final String id;
  final String orderId;
  final String vendorId;
  final String productId;
  final String mediaUrl;
  final MediaType mediaType;
  final double price;
  final String? note;
  final DateTime timestamp;
  final bool isAccepted;

  OrderConfirmation({
    required this.id,
    required this.orderId,
    required this.vendorId,
    required this.productId,
    required this.mediaUrl,
    required this.mediaType,
    required this.price,
    this.note,
    required this.timestamp,
    this.isAccepted = false,
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'vendorId': vendorId,
    'productId': productId,
    'mediaUrl': mediaUrl,
    'mediaType': mediaType.toString(),
    'price': price,
    'note': note,
    'timestamp': timestamp.toIso8601String(),
    'isAccepted': isAccepted,
  };

  factory OrderConfirmation.fromMap(Map<String, dynamic> map) {
    return OrderConfirmation(
      id: map['id'] ?? '',
      orderId: map['orderId'],
      vendorId: map['vendorId'],
      productId: map['productId'],
      mediaUrl: map['mediaUrl'],
      mediaType: MediaType.values.firstWhere(
        (e) => e.toString() == map['mediaType'],
      ),
      price: map['price'].toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

enum MediaType { image, video } 