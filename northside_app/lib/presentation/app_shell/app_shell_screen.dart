// lib/presentation/app_shell/app_shell_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// Import all the content pages that this shell will display.
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

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const AthleticsPage(),
    const AttendancePage(),
    const Center(child: Text("Grades Page")), // Placeholder
    const Center(child: Text("Profile Page")), // Placeholder
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
              // The mainAxisAlignment is no longer needed because Expanded handles the space.
              children: [
                _buildNavItem('Home', 0),
                _buildNavItem('Athletics', 1),
                _buildNavItem('Attendance', 2),
                _buildNavItem('Grades', 3),
                // The profile icon is NOT expanded, so it keeps its fixed size.
                _buildProfileNavIcon(4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // THIS WIDGET CONTAINS THE CORRECT FIX FOR THE OVERFLOW BUG
  Widget _buildNavItem(String label, int index) {
    final isSelected = _navBarIndex == index;
    // THE FIX: We wrap the GestureDetector in an Expanded widget.
    // This tells the four text items to share the available space.
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _navBarIndex = index),
        child: Container(
          // The horizontal padding is removed from here because Expanded handles spacing.
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              maxLines: 1, // Prevents text like "Attendance" from wrapping
              overflow: TextOverflow.ellipsis, // Fades out text if it's still too long
            ),
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
