import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/payout_model.dart';
import '../../services/firebase_service.dart';
export 'payout_analytics_page.dart';

class PayoutAnalyticsPage extends StatefulWidget {
  @override
  State<PayoutAnalyticsPage> createState() => _PayoutAnalyticsPageState();
}

class _PayoutAnalyticsPageState extends State<PayoutAnalyticsPage> {
  String _timeRange = 'week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payout Analytics'),
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
        stream: FirebaseService().getPayoutAnalytics(_timeRange),
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
                _AnalyticsSummaryGrid(data: data),
                SizedBox(height: 24),
                _PayoutTrendsChart(data: data),
                SizedBox(height: 24),
                _VendorPerformanceList(data: data),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsSummaryGrid extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnalyticsSummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          context,
          'Total Payouts',
          '₦${data['totalPayouts'].toStringAsFixed(2)}',
          Icons.payments,
          Colors.blue,
        ),
        _buildSummaryCard(
          context,
          'Active Vendors',
          data['activeVendors'].toString(),
          Icons.store,
          Colors.green,
        ),
        _buildSummaryCard(
          context,
          'Pending Payouts',
          '₦${data['pendingPayouts'].toStringAsFixed(2)}',
          Icons.pending,
          Colors.orange,
        ),
        _buildSummaryCard(
          context,
          'Failed Payouts',
          data['failedPayouts'].toString(),
          Icons.error,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutTrendsChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PayoutTrendsChart({required this.data});

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
              'Payout Trends',
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

class _VendorPerformanceList extends StatelessWidget {
  final Map<String, dynamic> data;

  const _VendorPerformanceList({required this.data});

  @override
  Widget build(BuildContext context) {
    final vendors = data['topVendors'] as List<Map<String, dynamic>>;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Vendors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ...vendors.map((vendor) => _buildVendorTile(context, vendor)),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorTile(BuildContext context, Map<String, dynamic> vendor) {
    return ListTile(
      title: Text(vendor['name']),
      subtitle: Text('Total Payouts: ₦${vendor['totalPayouts'].toStringAsFixed(2)}'),
      trailing: Text(
        '${vendor['completionRate']}%',
        style: TextStyle(
          color: _getCompletionColor(vendor['completionRate']),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // Navigate to vendor details
      },
    );
  }

  Color _getCompletionColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }
}