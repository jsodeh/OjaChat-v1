import 'package:flutter/material.dart';

// API Configuration
class APIConfig {
  static const String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 4);
  static const int rateLimit = 3; // requests per minute
}

// UI Constants
class UIConfig {
  // Padding
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultRadius = 12.0;
  static const double buttonRadius = 20.0;
  static const double cardRadius = 8.0;

  // Colors
  static const Color primaryColor = Color(0xFF6B4EFF);
  static const Color backgroundColor = Color(0xFFF3F3F7);
  static const Color textFieldColor = Color(0xFFF7F8FC);
  static const Color errorColor = Color(0xFFFF4E4E);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Unable to connect. Please check your internet connection.';
  static const String apiError = 'Service temporarily unavailable. Please try again later.';
  static const String locationUnavailable = 'This location is not yet available.';
  static const String loadingText = 'Please wait...';
  
  // Debug Messages
  static const String debugAPICall = 'Making API call to OpenAI...';
  static const String debugFirebaseQuery = 'Querying Firebase database...';
} 