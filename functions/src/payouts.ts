import * as functions from 'firebase-functions/v1';
import { PayoutScheduler } from './services/payout-scheduler';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

admin.initializeApp();

// Change exports to export const
export const processPayouts = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const scheduler = new PayoutScheduler();
    await scheduler.processVendorPayouts();
  });

// Manual trigger for admin
export const triggerPayouts = functions.https.onCall(async (data, context) => {
  // Verify admin
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can trigger payouts'
    );
  }

  const scheduler = new PayoutScheduler();
  await scheduler.processVendorPayouts();
});

export const handlePaystackWebhook = functions.https.onRequest(async (req, res) => {
  try {
    const hash = crypto
      .createHmac('sha512', functions.config().paystack.secret_key)
      .update(JSON.stringify(req.body))
      .digest('hex');

    if (hash !== req.headers['x-paystack-signature']) {
      throw new Error('Invalid signature');
    }

    const event = req.body;
    const transfer = event.data;
    const db = admin.firestore();

    // Update payout status
    const payoutSnapshot = await db
      .collection('payouts')
      .where('reference', '==', transfer.reference)
      .get();

    if (payoutSnapshot.empty) {
      throw new Error('Payout not found');
    }

    const payout = payoutSnapshot.docs[0];
    await payout.ref.update({
      status: _getPayoutStatus(event.event),
      metadata: transfer,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).send('Webhook processed');
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(400).send('Webhook error');
  }
});

function _getPayoutStatus(event: string): string {
  switch (event) {
    case 'transfer.success':
      return 'completed';
    case 'transfer.failed':
      return 'failed';
    case 'transfer.reversed':
      return 'reversed';
    default:
      return 'pending';
  }
} 