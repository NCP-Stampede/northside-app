// lib/main.dart

import 'package:flutter/material.dart';
import 'package:northside_app/presentation/home_screen/home_screen.dart'; // Import the new screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Northside App',
      // This line tells the app to use your new HomeScreen as its starting page
      home: HomeScreen(),
    );
  }
}
