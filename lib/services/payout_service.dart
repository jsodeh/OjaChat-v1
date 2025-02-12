import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/config.dart';
import '../models/vendor_bank_account.dart';
import 'firebase_service.dart';

class PayoutService {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Map<String, dynamic>>> getAvailableBanks() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.paystack.co/bank'),
        headers: {
          'Authorization': 'Bearer ${Config.paystackSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      throw Exception('Failed to load banks');
    } catch (e) {
      print('Error getting banks: $e');
      rethrow;
    }
  }

  Future<void> verifyBankAccount(VendorBankAccount account) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.paystack.co/bank/resolve?account_number=${account.accountNumber}&bank_code=${_getBankCode(account.bankName)}',
        ),
        headers: {
          'Authorization': 'Bearer ${Config.paystackSecretKey}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['account_name'] == account.accountName) {
          await _firebaseService.verifyVendorBankAccount(account.id);
        } else {
          throw Exception('Account name does not match');
        }
      } else {
        throw Exception('Failed to verify account');
      }
    } catch (e) {
      print('Error verifying account: $e');
      rethrow;
    }
  }

  Future<void> initiateTransfer(
    String vendorId,
    double amount,
    String reference,
  ) async {
    try {
      // Get vendor's bank account
      final account = await _firebaseService.getVendorBankAccount(vendorId);
      if (account == null || !account.isVerified) {
        throw Exception('No verified bank account found');
      }

      // Create transfer recipient
      final recipientResponse = await http.post(
        Uri.parse('https://api.paystack.co/transferrecipient'),
        headers: {
          'Authorization': 'Bearer ${Config.paystackSecretKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'nuban',
          'name': account.accountName,
          'account_number': account.accountNumber,
          'bank_code': _getBankCode(account.bankName),
          'currency': 'NGN',
        }),
      );

      if (recipientResponse.statusCode != 201) {
        throw Exception('Failed to create transfer recipient');
      }

      final recipientData = jsonDecode(recipientResponse.body);
      final recipientCode = recipientData['data']['recipient_code'];

      // Initiate transfer
      final transferResponse = await http.post(
        Uri.parse('https://api.paystack.co/transfer'),
        headers: {
          'Authorization': 'Bearer ${Config.paystackSecretKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'source': 'balance',
          'amount': (amount * 100).toInt(), // Convert to kobo
          'recipient': recipientCode,
          'reason': 'Payout for order $reference',
          'reference': reference,
        }),
      );

      if (transferResponse.statusCode != 200) {
        throw Exception('Failed to initiate transfer');
      }

      // Record transfer in Firestore
      await _firebaseService.recordPayout(
        vendorId: vendorId,
        amount: amount,
        reference: reference,
        status: 'pending',
      );
    } catch (e) {
      print('Error initiating transfer: $e');
      rethrow;
    }
  }

  String _getBankCode(String bankName) {
    final code = Config.bankCodes[bankName];
    if (code == null) {
      throw Exception('Bank code not found for $bankName');
    }
    return code;
  }
} 