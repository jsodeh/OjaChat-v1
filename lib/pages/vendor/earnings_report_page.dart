import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/payout_model.dart';
import '../../services/firebase_service.dart';

class EarningsReportPage extends StatefulWidget {
  final String vendorId;

  const EarningsReportPage({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<EarningsReportPage> createState() => _EarningsReportPageState();
}

class _EarningsReportPageState extends State<EarningsReportPage> {
  String _timeRange = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings Report'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _timeRange,
            onSelected: (value) => setState(() => _timeRange = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'week', child: Text('This Week')),
              PopupMenuItem(value: 'month', child: Text('This Month')),
              PopupMenuItem(value: 'year', child: Text('This Year')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: FirebaseService().getVendorEarningsReport(
          widget.vendorId,
          _timeRange,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EarningsSummaryCard(data: data),
                SizedBox(height: 24),
                _EarningsChart(data: data),
                SizedBox(height: 24),
                _RecentTransactionsList(vendorId: widget.vendorId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EarningsSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _EarningsSummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            _buildSummaryRow(
              'Total Earnings',
              '₦${data['totalEarnings'].toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              'Orders Completed',
              data['ordersCompleted'].toString(),
            ),
            _buildSummaryRow(
              'Average Order Value',
              '₦${data['averageOrderValue'].toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              'Pending Payout',
              '₦${data['pendingPayout'].toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EarningsChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const _EarningsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = (data['chartData'] as List<Map<String, dynamic>>)
        .map((point) => FlSpot(
              point['x'].toDouble(),
              point['y'].toDouble(),
            ))
        .toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('₦${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(data['labels'][value.toInt()]);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: Theme.of(context).primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final String vendorId;

  const _RecentTransactionsList({required this.vendorId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        StreamBuilder<List<PayoutModel>>(
          stream: FirebaseService().getVendorPayouts(vendorId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final payouts = snapshot.data!.take(5).toList();
            if (payouts.isEmpty) {
              return Center(child: Text('No transactions yet'));
            }

            return Column(
              children: payouts.map((payout) {
                return Card(
                  child: ListTile(
                    title: Text('₦${payout.amount.toStringAsFixed(2)}'),
                    subtitle: Text(
                      DateFormat('MMM d, y').format(payout.createdAt),
                    ),
                    trailing: Chip(
                      label: Text(payout.status.toUpperCase()),
                      backgroundColor: _getStatusColor(payout.status),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
} 