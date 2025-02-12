class VendorBankAccount {
  final String id;
  final String vendorId;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final bool isVerified;
  final DateTime createdAt;

  VendorBankAccount({
    required this.id,
    required this.vendorId,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.isVerified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'vendorId': vendorId,
    'bankName': bankName,
    'accountNumber': accountNumber,
    'accountName': accountName,
    'isVerified': isVerified,
    'createdAt': createdAt.toIso8601String(),
  };

  factory VendorBankAccount.fromMap(String id, Map<String, dynamic> map) {
    return VendorBankAccount(
      id: id,
      vendorId: map['vendorId'],
      bankName: map['bankName'],
      accountNumber: map['accountNumber'],
      accountName: map['accountName'],
      isVerified: map['isVerified'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 