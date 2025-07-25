import 'package:flutter/material.dart';

class AppTheme {
  static const double horizontalPadding = 24.0;
  static const double cardRadius = 24.0;
  static const double sectionSpacing = 32.0;

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
      bodySmall: TextStyle(fontSize: 14, color: Colors.black),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: const Color(0xFF007AFF),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
