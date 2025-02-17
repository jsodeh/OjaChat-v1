import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';
import 'admin_dashboard.dart';
import 'product_management_page.dart';
import 'vendor_management_page.dart';
import 'delivery_management_page.dart';
import 'analytics_page.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String currentPage;

  const AdminLayout({
    Key? key,
    required this.child,
    required this.currentPage,
  }) : super(key: key);

  @override
  _AdminLayoutState createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(child: widget.child),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.black87,
      child: _buildNavigationItems(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black87,
      child: _buildNavigationItems(),
    );
  }

  Widget _buildNavigationItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.admin_panel_settings),
              ),
              SizedBox(height: 12),
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _buildNavItem(
          'Dashboard',
          Icons.dashboard_outlined,
          '/admin',
          widget.currentPage == 'dashboard',
        ),
        _buildNavItem(
          'Products',
          Icons.inventory_2_outlined,
          '/admin/products',
          widget.currentPage == 'products',
        ),
        _buildNavItem(
          'Vendors',
          Icons.store_outlined,
          '/admin/vendors',
          widget.currentPage == 'vendors',
        ),
        _buildNavItem(
          'Deliveries',
          Icons.local_shipping_outlined,
          '/admin/deliveries',
          widget.currentPage == 'deliveries',
        ),
        _buildNavItem(
          'Analytics',
          Icons.analytics_outlined,
          '/admin/analytics',
          widget.currentPage == 'analytics',
        ),
        Divider(color: Colors.white24),
        _buildNavItem(
          'Settings',
          Icons.settings_outlined,
          '/admin/settings',
          widget.currentPage == 'settings',
        ),
        _buildNavItem(
          'Back to Chat',
          Icons.chat_outlined,
          '/',
          false,
        ),
      ],
    );
  }

  Widget _buildNavItem(String title, IconData icon, String route, bool selected) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppTheme.primaryColor : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppTheme.primaryColor : Colors.white,
        ),
      ),
      selected: selected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: () {
        if (route != widget.currentPage) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
} 