import 'package:flutter/material.dart';
import '../../services/vendor_service.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../models/vendor_model.dart';
import 'earnings_report_page.dart';

class VendorDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VendorModel?>(
      stream: VendorService().getCurrentVendor(AuthService().currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final vendor = snapshot.data!;
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Vendor Dashboard'),
            actions: [
              Switch(
                value: vendor.isActive,
                onChanged: (value) {
                  VendorService().updateVendorStatus(vendor.id, value);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Vendor Info Card
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market: ${vendor.market}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Categories: ${vendor.categories.join(", ")}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Products: ${vendor.products.join(", ")}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Order Alerts
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirebaseService().getVendorOrderAlerts(vendor.id),
                  builder: (context, alertSnapshot) {
                    if (alertSnapshot.hasError) {
                      return Center(child: Text('Error: ${alertSnapshot.error}'));
                    }

                    if (!alertSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final alerts = alertSnapshot.data!;
                    
                    if (alerts.isEmpty) {
                      return Center(
                        child: Text('No pending order requests'),
                      );
                    }

                    return ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return OrderAlertCard(
                          alert: alert,
                          onAccept: () async {
                            await FirebaseService().respondToOrderAlert(
                              alert['id'],
                              true,
                            );
                          },
                          onDecline: () async {
                            await FirebaseService().respondToOrderAlert(
                              alert['id'],
                              false,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EarningsReportPage(vendorId: vendor.id),
              ),
            ),
            icon: Icon(Icons.payments),
            label: Text('Earnings'),
          ),
        );
      },
    );
  }
}

class OrderAlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const OrderAlertCard({
    Key? key,
    required this.alert,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final expiresAt = DateTime.parse(alert['expiresAt']);
    final timeLeft = expiresAt.difference(DateTime.now());

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag),
                SizedBox(width: 8),
                Text(
                  'New Order Request',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Spacer(),
                Text(
                  '${timeLeft.inMinutes}m left',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDecline,
                    child: Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 