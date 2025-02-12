class UserRole {
  final bool isUser;
  final bool isVendor;
  final bool isAdmin;

  UserRole({
    this.isUser = true,  // Default to true
    this.isVendor = false,
    this.isAdmin = false,
  });

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      isUser: map['isUser'] ?? true,
      isVendor: map['isVendor'] ?? false,
      isAdmin: map['isAdmin'] ?? false,
    );
  }
} 