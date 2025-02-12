import 'package:flutter/material.dart';
import '../../models/order_confirmation.dart';
import '../../services/firebase_service.dart';
import '../../widgets/confirmation_swiper.dart';

class OrderProgressPage extends StatelessWidget {
  final String orderId;

  const OrderProgressPage({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  Future<void> _proceedToPayment(BuildContext context) async {
    // TODO: Implement payment flow
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Progress')),
      body: StreamBuilder<List<OrderConfirmation>>(
        stream: FirebaseService().getOrderConfirmations(orderId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ConfirmationSwiper(
                  confirmations: snapshot.data!,
                  onAccept: (confirmation) {
                    FirebaseService().acceptConfirmation(confirmation.id);
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: snapshot.data!.any((c) => c.isAccepted)
                        ? () => _proceedToPayment(context)
                        : null,
                    child: Text('Proceed to Payment'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 