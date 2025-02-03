import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Firestore Schema
class FirebaseCollections {
  static const String products = 'products';
  static const String markets = 'markets';
  static const String prices = 'prices';
  static const String users = 'users';
}

// Document Structure
class FirebaseSchema {
  static const Map<String, dynamic> productStructure = {
    'name': String,
    'keywords': List<String>,
    'price': double,
    'unit': String,
    'market': String,
    'lastUpdated': Timestamp,
    'trend': double,
    'available': bool,
    'category': String,
  };

  static const Map<String, dynamic> marketStructure = {
    'name': String,
    'location': GeoPoint,
    'isOpen': bool,
    'openingHours': Map<String, String>,
    'products': List<String>,
  };
}

// Error Handling
class FirebaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'You don\'t have permission to access this resource';
        case 'unavailable':
          return 'Service is temporarily unavailable';
        case 'not-found':
          return 'Requested resource was not found';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  static const Duration queryTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
} 