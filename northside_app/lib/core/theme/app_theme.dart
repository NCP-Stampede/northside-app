// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class AppTheme {
  // Detect if we're on a narrow screen like S9
  static bool isNarrowScreen(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360; // S9 width threshold
  }

  // Get adjusted size for narrow screens
  static double getResponsiveSize(BuildContext context, double size) {
    return isNarrowScreen(context) ? size * 0.9 : size;
  }

  // This is the single source of truth for all our theme data
  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light();

    return base.copyWith(
      // --- COLOR SCHEME ---
      // This defines the app's primary color palette
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryBlue,
        secondary: Colors.amber, // Example secondary color
        surface: const Color(0xFFF2F2F7), // Main background color
        onSurface: Colors.black,
      ),

      // --- TEXT THEME ---
      // Modified to be more adaptive to small screens
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme.copyWith(
          // For large page titles (e.g., "Bulletin")
          displayLarge: TextStyle(
            // Original size was 28.sp
            fontSize: 26.sp, // Slightly smaller default to help on S9
            fontWeight: FontWeight.w900, // Bold
            color: Colors.black,
          ),
          // For section headers (e.g., "Pinned")
          headlineMedium: TextStyle(
            fontSize: 15.sp, // Reduced from 16.sp
            fontWeight: FontWeight.w900, // Bold
            color: Colors.black,
          ),
          // For card titles (e.g., "Homecoming 2024")
          titleLarge: TextStyle(
            fontSize: 15.sp, // Reduced from 16.sp
            fontWeight: FontWeight.w900, // Bold
            color: Colors.black,
          ),
          // For subtitles and body text
          bodyMedium: TextStyle(
            fontSize: 11.sp, // Reduced from 12.sp
            fontWeight: FontWeight.w500, // No super thin text
            color: Colors.black, // No grey text
          ),
          // For button text
          labelLarge: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900, // Bold
            color: Colors.black,
          ),
        ),
      ),

      // --- OTHER WIDGET THEMES ---
      cardTheme: CardThemeData(
        elevation: 0, // We will use custom shadows
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40), // Squiggle shape
        ),
        color: Colors.white,
      ),
    );
  }

  static double get horizontalPadding => 6.w; // Responsive horizontal padding
  static double get cardRadius => 4.w; // Responsive card radius

  // Custom Shadow
  static const List<BoxShadow> standardShadow = [
    BoxShadow(
      offset: Offset(0, 10),
      blurRadius: 60,
      spreadRadius: 0,
      color: Color(0x1A000000), // 10% opacity black
    ),
  ];

  // Squiggle Border Radius for ShapeDecoration
  static ContinuousRectangleBorder get squiggleShape => ContinuousRectangleBorder(
    borderRadius: BorderRadius.circular(40),
  );

  // Add helper methods for responsive spacing
  static double responsivePadding(BuildContext context, double defaultPadding) {
    return isNarrowScreen(context) ? defaultPadding * 0.8 : defaultPadding;
  }
}
