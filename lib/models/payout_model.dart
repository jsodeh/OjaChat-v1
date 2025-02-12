import 'package:cloud_firestore/cloud_firestore.dart';

class PayoutModel {
  final String id;
  final String vendorId;
  final double amount;
  final String reference;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  PayoutModel({
    required this.id,
    required this.vendorId,
    required this.amount,
    required this.reference,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() => {
    'vendorId': vendorId,
    'amount': amount,
    'reference': reference,
    'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    'metadata': metadata,
  };

  factory PayoutModel.fromMap(String id, Map<String, dynamic> map) {
    return PayoutModel(
      id: id,
      vendorId: map['vendorId'],
      amount: map['amount'],
      reference: map['reference'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      metadata: map['metadata'],
    );
  }
} 