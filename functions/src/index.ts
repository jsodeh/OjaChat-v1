import * as admin from 'firebase-admin';
import * as payouts from './payouts';

admin.initializeApp();

export const processPayouts = payouts.processPayouts;
export const triggerPayouts = payouts.triggerPayouts;
export const handlePaystackWebhook = payouts.handlePaystackWebhook; 