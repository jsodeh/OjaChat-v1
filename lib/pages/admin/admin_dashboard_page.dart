import 'package:flutter/material.dart';
import 'payout_management_page.dart';
import 'payout_analytics_page.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildDashboardItem(
              context,
              'Payouts',
              Icons.payments,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PayoutManagementPage()),
              ),
            ),
            _buildDashboardItem(
              context,
              'Analytics',
              Icons.analytics,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PayoutAnalyticsPage()),
              ),
            ),
            ElevatedButton(
              onPressed: () => _updateProductSearchTerms(context),
              child: Text('Update Product Search Terms'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            SizedBox(height: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProductSearchTerms(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      await _firebaseService.updateAllProductsWithSearchTerms();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully updated search terms')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
} 