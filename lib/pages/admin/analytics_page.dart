import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firebase_service.dart';
import '../../styles/app_theme.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedTimeRange = 'week';
  String _selectedMetric = 'revenue'; // revenue, orders, vendors

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Analytics'),
        actions: [
          _buildTimeRangeSelector(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricSelector(),
            SizedBox(height: 24),
            _buildChartSection(),
            SizedBox(height: 24),
            _buildTopVendorsSection(),
            SizedBox(height: 24),
            _buildMarketPerformanceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return DropdownButton<String>(
      value: _selectedTimeRange,
      dropdownColor: Colors.black87,
      style: TextStyle(color: Colors.white70),
      underline: SizedBox(),
      items: [
        DropdownMenuItem(value: 'week', child: Text('This Week')),
        DropdownMenuItem(value: 'month', child: Text('This Month')),
        DropdownMenuItem(value: 'year', child: Text('This Year')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedTimeRange = value);
        }
      },
    );
  }

  Widget _buildMetricSelector() {
    return Row(
      children: [
        _buildMetricButton('Revenue', 'revenue'),
        SizedBox(width: 12),
        _buildMetricButton('Orders', 'orders'),
        SizedBox(width: 12),
        _buildMetricButton('Vendors', 'vendors'),
      ],
    );
  }

  Widget _buildMetricButton(String label, String value) {
    final isSelected = _selectedMetric == value;
    return InkWell(
      onTap: () => setState(() => _selectedMetric = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _firebaseService.getAnalyticsData(
                _selectedTimeRange,
                _selectedMetric,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                return LineChart(
                  _buildChartData(data),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(Map<String, dynamic> data) {
    final spots = (data['chartData'] as List<Map<String, dynamic>>)
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['y']))
        .toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final labels = data['labels'] as List<String>;
              if (value.toInt() >= labels.length) return Text('');
              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  labels[value.toInt()],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppTheme.primaryColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildTopVendorsSection() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firebaseService.getTopVendors(_selectedTimeRange),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final vendors = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Vendors',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            ...vendors.map((vendor) => _buildVendorPerformanceCard(vendor)),
          ],
        );
      },
    );
  }

  Widget _buildVendorPerformanceCard(Map<String, dynamic> vendor) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: Text(
            vendor['name'].substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          vendor['name'],
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${vendor['ordersCompleted']} orders • ₦${NumberFormat('#,###').format(vendor['revenue'])}',
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${vendor['completionRate']}%',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketPerformanceSection() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firebaseService.getMarketPerformance(_selectedTimeRange),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Performance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildMarketMetric(
                    'Mile 12',
                    data['mile12Revenue'] as double,
                    data['mile12Orders'] as int,
                  ),
                  Divider(color: Colors.white24),
                  _buildMarketMetric(
                    'Oyingbo',
                    data['oyingboRevenue'] as double,
                    data['oyingboOrders'] as int,
                  ),
                  Divider(color: Colors.white24),
                  _buildMarketMetric(
                    'Kara',
                    data['karaRevenue'] as double,
                    data['karaOrders'] as int,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarketMetric(String market, double revenue, int orders) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              market,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '₦${NumberFormat('#,###').format(revenue)}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$orders orders',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
} 