class VendorModel {
  final String id;
  final String userId;
  final String market;
  final List<String> categories;
  final List<String> products;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastSeen;

  VendorModel({
    required this.id,
    required this.userId,
    required this.market,
    required this.categories,
    required this.products,
    this.isActive = true,
    required this.createdAt,
    this.lastSeen,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'market': market,
    'categories': categories,
    'products': products,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastSeen': lastSeen?.toIso8601String(),
  };

  factory VendorModel.fromMap(String id, Map<String, dynamic> map) {
    return VendorModel(
      id: id,
      userId: map['userId'],
      market: map['market'],
      categories: List<String>.from(map['categories']),
      products: List<String>.from(map['products']),
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      lastSeen: map['lastSeen'] != null 
          ? DateTime.parse(map['lastSeen']) 
          : null,
    );
  }
} 