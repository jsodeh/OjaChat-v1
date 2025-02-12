import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payout_model.dart';
import '../../services/firebase_service.dart';
import '../../services/payout_service.dart';
export 'payout_management_page.dart';

class PayoutManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payout Management'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Processing'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => _triggerPayouts(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _PayoutList(status: 'pending'),
            _PayoutList(status: 'processing'),
            _PayoutList(status: 'completed'),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerPayouts(BuildContext context) async {
    try {
      await FirebaseService().triggerPayouts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payouts triggered successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _PayoutList extends StatelessWidget {
  final String status;

  const _PayoutList({required this.status});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PayoutModel>>(
      stream: FirebaseService().getPayoutsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final payouts = snapshot.data!;
        if (payouts.isEmpty) {
          return Center(child: Text('No $status payouts'));
        }

        return ListView.builder(
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            return _PayoutListItem(payout: payouts[index]);
          },
        );
      },
    );
  }
}

class _PayoutListItem extends StatelessWidget {
  final PayoutModel payout;

  const _PayoutListItem({required this.payout});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('₦${payout.amount.toStringAsFixed(2)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vendor ID: ${payout.vendorId}'),
            Text('Ref: ${payout.reference}'),
            Text(DateFormat('MMM d, y HH:mm').format(payout.createdAt)),
          ],
        ),
        trailing: _buildStatusButton(context),
        onTap: () => _showPayoutDetails(context),
      ),
    );
  }

  Widget _buildStatusButton(BuildContext context) {
    if (payout.status == 'pending') {
      return TextButton(
        onPressed: () => _processPayoutManually(context),
        child: Text('Process'),
      );
    }
    return Chip(
      label: Text(payout.status.toUpperCase()),
      backgroundColor: _getStatusColor(),
    );
  }

  Color _getStatusColor() {
    switch (payout.status) {
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'processing':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _processPayoutManually(BuildContext context) async {
    try {
      await PayoutService().initiateTransfer(
        payout.vendorId,
        payout.amount,
        payout.reference,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payout initiated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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

  const _PayoutDetailsSheet({required this.payout});

  @override
  Widget build(BuildContext context) {
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
          _buildDetailRow('Vendor ID', payout.vendorId),
          _buildDetailRow('Created', 
            DateFormat('MMM d, y HH:mm').format(payout.createdAt)),
          if (payout.updatedAt != null)
            _buildDetailRow('Updated', 
              DateFormat('MMM d, y HH:mm').format(payout.updatedAt!)),
          if (payout.metadata != null) ...[
            SizedBox(height: 8),
            Text(
              'Transfer Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            ...payout.metadata!.entries.map(
              (e) => _buildDetailRow(e.key, e.value.toString()),
            ),
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

