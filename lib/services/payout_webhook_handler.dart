import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../config/config.dart';
import 'firebase_service.dart';

class PayoutWebhookHandler {
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> handleWebhook(String payload, String signature) async {
    // Verify webhook signature
    final computedSignature = sha512
        .convert(utf8.encode(Config.paystackSecretKey + payload))
        .toString();
        
    if (computedSignature != signature) {
      throw Exception('Invalid webhook signature');
    }

    final data = jsonDecode(payload);
    final event = data['event'];
    final transfer = data['data'];

    if (event.startsWith('transfer.')) {
      await _handleTransferEvent(event, transfer);
    }
  }

  Future<void> _handleTransferEvent(String event, Map<String, dynamic> transfer) async {
    final reference = transfer['reference'];
    final status = _getTransferStatus(event);

    await _firebaseService.updatePayout(
      reference: reference,
      status: status,
      metadata: transfer,
    );

    if (status == 'failed') {
      // Handle failed transfer - notify admin
      await _firebaseService.notifyAdmin(
        'Transfer Failed',
        'Transfer ${transfer['reference']} failed: ${transfer['reason']}',
      );
    }
  }

  String _getTransferStatus(String event) {
    switch (event) {
      case 'transfer.success':
        return 'completed';
      case 'transfer.failed':
        return 'failed';
      case 'transfer.reversed':
        return 'reversed';
      default:
        return 'pending';
    }
  }
} 