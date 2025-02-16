import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const darkBackground = Color(0xFF0A0A0A);
  static const primaryColor = Color(0xFF9b87f5);
  static const secondaryColor = Color(0xFF7E69AB);
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF9b87f5), Color(0xFF7E69AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const headingStyle = TextStyle(
    fontSize: 32,  // Reduced from 42
    fontWeight: FontWeight.w800,
    color: Colors.white,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const subtitleStyle = TextStyle(
    fontSize: 16,  // Reduced from 20
    color: Color(0xB3FFFFFF),
    height: 1.5,
  );

  // Input Styles
  static final inputDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
    ),
  );

  // Enhanced Input Styles
  static final chatInputDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.15),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  static final modernInputDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  );

  static final enhancedInputDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 15,
        offset: Offset(0, 8),
      ),
    ],
  );

  static const inputTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.white,
    height: 1.5,
  );

  static const inputHintStyle = TextStyle(
    fontSize: 16,
    color: Colors.white38,
    height: 1.5,
  );

  // Button Styles
  static final actionButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
    padding: MaterialStateProperty.all(EdgeInsets.all(12)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Logo Text Style
  static const logoTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );
}