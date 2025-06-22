// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import the package

import 'presentation/app_shell/app_shell_binding.dart';
import 'presentation/app_shell/app_shell_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the base theme data
    final ThemeData theme = ThemeData();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Northside App',

      // FIX: Apply the "Inter" font to the entire application theme.
      // This will make all text widgets automatically use the Inter font.
      theme: theme.copyWith(
        textTheme: GoogleFonts.interTextTheme(theme.textTheme),
      ),

      initialBinding: AppShellBinding(),
      home: const AppShellScreen(),
    );
  }
}
