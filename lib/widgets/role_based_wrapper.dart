import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_role.dart';
import '../pages/chat_page.dart';
import '../pages/vendor/vendor_dashboard_page.dart';
import '../pages/admin/admin_dashboard_page.dart';

class RoleBasedWrapper extends StatelessWidget {
  final Widget userView;
  final Widget adminView;

  const RoleBasedWrapper({
    Key? key,
    required this.userView,
    required this.adminView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserRole>(
      stream: AuthService().userRoleStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final role = snapshot.data!;
        
        if (role.isAdmin) return adminView;
        if (role.isVendor) return VendorDashboardPage();
        return userView;
      },
    );
  }
} 