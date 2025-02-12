import 'package:flutter/material.dart';
import '../models/order_confirmation.dart';
import 'media_preview.dart';

class ConfirmationSwiper extends StatelessWidget {
  final List<OrderConfirmation> confirmations;
  final Function(OrderConfirmation) onAccept;

  const ConfirmationSwiper({
    Key? key,
    required this.confirmations,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: confirmations.length,
      itemBuilder: (context, index) {
        final confirmation = confirmations[index];
        return Card(
          margin: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: MediaPreview(
                  url: confirmation.mediaUrl,
                  type: confirmation.mediaType,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₦${confirmation.price}'),
                    ElevatedButton(
                      onPressed: () => onAccept(confirmation),
                      child: Text('Accept Offer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 