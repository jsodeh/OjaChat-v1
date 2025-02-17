import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../styles/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';
import './admin/admin_dashboard.dart';
import './vendor/vendor_dashboard.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Profile'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<UserRole>(
        stream: AuthService().userRoleStream(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white10,
                  child: Icon(Icons.person_outline, size: 40, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Amehnoname Raheem',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'UI/UX Designer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Activity Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Activity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityIndicator(
                              'Completed',
                              '26',
                              Colors.green,
                            ),
                          ),
                          Expanded(
                            child: _buildActivityIndicator(
                              'In Progress',
                              '5',
                              Colors.orange,
                            ),
                          ),
                          Expanded(
                            child: _buildActivityIndicator(
                              'Upcoming',
                              '17',
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Menu Options
                _buildMenuOption(
                  context,
                  Icons.person_outline,
                  'Personal Information',
                  onTap: () {},
                ),
                _buildMenuOption(
                  context,
                  Icons.notifications_outlined,
                  'Notifications',
                  onTap: () {},
                ),
                _buildMenuOption(
                  context,
                  Icons.palette_outlined,
                  'Theme',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
                _buildMenuOption(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  onTap: () {},
                ),
                
                // Admin Dashboard Link (only shown for admins)
                if (snapshot.data?.isAdmin ?? false)
                  _buildMenuOption(
                    context,
                    Icons.admin_panel_settings_outlined,
                    'Admin Dashboard',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminDashboard()),
                    ),
                  ),
                
                // Vendor Dashboard Link (only shown for vendors)
                if (snapshot.data?.isVendor ?? false)
                  _buildMenuOption(
                    context,
                    Icons.store_outlined,
                    'Vendor Dashboard',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VendorDashboard()),
                    ),
                  ),
                
                _buildMenuOption(
                  context,
                  Icons.logout,
                  'Log Out',
                  onTap: () async {
                    await context.read<AuthService>().signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.white70),
      onTap: onTap,
    );
  }
} 