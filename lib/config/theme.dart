import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF9b87f5), Color(0xFF7E69AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const darkBackground = Color(0xFF0A0A0A);
  static const textLight = Colors.white;
  static const textMuted = Color(0xB3FFFFFF); // 70% white

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBackground,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: textLight,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        fontSize: 20,
        color: textMuted,
        fontFamily: 'Inter',
      ),
      // Add other text styles...
    ),
  );
} 