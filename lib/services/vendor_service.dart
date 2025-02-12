import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import 'firebase_service.dart';

class VendorService {
  final FirebaseService _firebaseService = FirebaseService();
  
  Future<void> handleNewOrder(String orderId, List<String> products, String market) async {
    // Get matching vendors
    final vendorIds = await _firebaseService.getMatchingVendorIds(products, market);
    
    if (vendorIds.isEmpty) {
      print('No matching vendors found for order $orderId');
      return;
    }

    // Send alerts to matching vendors
    await _firebaseService.sendOrderAlert(orderId, vendorIds);
  }

  Stream<VendorModel?> getCurrentVendor(String userId) {
    return FirebaseFirestore.instance
        .collection('vendors')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final doc = snapshot.docs.first;
          return VendorModel.fromMap(doc.id, doc.data());
        });
  }

  Future<void> updateVendorStatus(String vendorId, bool isActive) async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId)
        .update({
          'isActive': isActive,
          'lastSeen': DateTime.now().toIso8601String(),
        });
  }
} 