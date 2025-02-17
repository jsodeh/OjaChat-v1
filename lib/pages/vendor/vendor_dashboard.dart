import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

class VendorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text('Vendor Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Vendor Dashboard',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 