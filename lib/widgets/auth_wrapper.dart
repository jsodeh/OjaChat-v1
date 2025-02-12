import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/chat_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import 'role_based_wrapper.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return RoleBasedWrapper(
            userView: ChatPage(),
            adminView: AdminDashboardPage(),
          );
        }

        return LoginPage();
      },
    );
  }
} 