import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../styles/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../widgets/admin/overview_card.dart';
import '../../widgets/admin/activity_chart.dart';
import '../../widgets/admin/recent_orders_table.dart';
import '../../models/order_model.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  String selectedTimeRange = 'week'; // week, month, year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Admin Dashboard'),
        actions: [
          _buildTimeRangeSelector(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(),
            SizedBox(height: 24),
            _buildChartSection(),
            SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return DropdownButton<String>(
      value: selectedTimeRange,
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
          setState(() => selectedTimeRange = value);
        }
      },
    );
  }

  Widget _buildOverviewSection() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _firebaseService.getAdminOverview(selectedTimeRange),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingOverview();
        }

        final data = snapshot.data!;
        return GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            OverviewCard(
              title: 'Total Orders',
              value: data['totalOrders'].toString(),
              trend: data['ordersTrend'],
              icon: Icons.shopping_cart_outlined,
            ),
            OverviewCard(
              title: 'Total Revenue',
              value: '₦${data['totalRevenue']}',
              trend: data['revenueTrend'],
              icon: Icons.attach_money,
            ),
            OverviewCard(
              title: 'Active Vendors',
              value: data['activeVendors'].toString(),
              trend: data['vendorsTrend'],
              icon: Icons.store_outlined,
            ),
            OverviewCard(
              title: 'Pending Deliveries',
              value: data['pendingDeliveries'].toString(),
              trend: 0,
              icon: Icons.local_shipping_outlined,
            ),
          ],
        );
      },
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
            'Sales Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: ActivityChart(timeRange: selectedTimeRange),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        RecentOrdersTable(),
      ],
    );
  }

  Widget _buildLoadingOverview() {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(4, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
} 