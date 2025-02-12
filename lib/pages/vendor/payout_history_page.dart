import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../models/payout_model.dart';

class PayoutHistoryPage extends StatelessWidget {
  final String vendorId;

  const PayoutHistoryPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payout History')),
      body: StreamBuilder<List<PayoutModel>>(
        stream: FirebaseService().getVendorPayouts(vendorId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final payouts = snapshot.data!;
          if (payouts.isEmpty) {
            return Center(child: Text('No payouts yet'));
          }

          return ListView.builder(
            itemCount: payouts.length,
            itemBuilder: (context, index) {
              final payout = payouts[index];
              return _PayoutCard(payout: payout);
            },
          );
        },
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  final PayoutModel payout;

  const _PayoutCard({
    Key? key,
    required this.payout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('₦${payout.amount.toStringAsFixed(2)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM d, y HH:mm').format(payout.createdAt)),
            Text(
              'Reference: ${payout.reference}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: _buildStatusChip(payout.status),
        onTap: () => _showPayoutDetails(context),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'completed':
        color = Colors.green;
        break;
      case 'failed':
        color = Colors.red;
        break;
      case 'reversed':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showPayoutDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _PayoutDetailsSheet(payout: payout),
    );
  }
}

class _PayoutDetailsSheet extends StatelessWidget {
  final PayoutModel payout;

  const _PayoutDetailsSheet({
    Key? key,
    required this.payout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metadata = payout.metadata;
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          _buildDetailRow('Amount', '₦${payout.amount.toStringAsFixed(2)}'),
          _buildDetailRow('Status', payout.status),
          _buildDetailRow('Reference', payout.reference),
          if (metadata != null) ...[
            SizedBox(height: 8),
            Text(
              'Transfer Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            _buildDetailRow('Bank', metadata['bank'] ?? 'N/A'),
            _buildDetailRow('Account', metadata['account'] ?? 'N/A'),
            if (metadata['reason'] != null)
              _buildDetailRow('Reason', metadata['reason']),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
} 