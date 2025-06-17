// lib/presentation/app_shell/app_shell_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// Import all the pages that will live inside the shell
import 'package:northside_app/presentation/home_screen_content/home_screen_content.dart';
import 'package:northside_app/presentation/athletics_screen/athletics_screen.dart';
import 'package:northside_app/presentation/attendance_screen/attendance_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _navBarIndex = 0;

  // The list of pages now includes all three new designs.
  final List<Widget> _pages = [
    const HomeScreenContent(),
    const AthleticsPage(),
    const AttendancePage(),
    // TODO: Add GradesPage and ProfilePage here when ready
    Container(color: Colors.white), // Placeholder for Grades
    Container(color: Colors.white), // Placeholder for Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _navBarIndex,
            children: _pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem('Home', 0),
                _buildNavItem('Athletics', 1),
                _buildNavItem('Attendance', 2),
                _buildNavItem('Grades', 3),
                _buildProfileNavIcon(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navBarIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavIcon(int index) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navBarIndex = index),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : Colors.grey.shade400,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.person_outline,
          size: 28,
          color: isSelected ? const Color(0xFF007AFF) : Colors.grey[700],
        ),
      ),
    );
  }
}
