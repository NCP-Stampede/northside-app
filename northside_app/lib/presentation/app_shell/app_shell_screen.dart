// lib/presentation/app_shell/app_shell_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_controller.dart';
import 'package:northside_app/presentation/home_screen_content/home_screen_content.dart';
import 'package:northside_app/presentation/placeholder_pages/athletics_page.dart';
import 'package:northside_app/presentation/placeholder_pages/grades_page.dart';
import 'package:northside_app/presentation/placeholder_pages/attendance_page.dart';
import 'package:northside_app/presentation/placeholder_pages/profile_page.dart';

// This is a GetView, which is a stateless widget that has access to a controller.
class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreenContent(),
      const AthleticsPage(),
      const AttendancePage(),
      const GradesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Obx wraps the IndexedStack. When controller.navBarIndex changes,
          // only this part of the UI rebuilds to show the new page.
          Obx(() => IndexedStack(
                index: controller.navBarIndex.value,
                children: pages,
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  // The floating nav bar now gets its state from the controller.
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
            // Obx ensures the Row rebuilds when an item is tapped.
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem('Home', 0),
                    _buildNavItem('Athletics', 1),
                    _buildNavItem('Attendance', 2),
                    _buildNavItem('Grades', 3),
                    _buildProfileNavIcon(4),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  // The build methods now call controller.changePage() instead of setState().
  Widget _buildNavItem(String label, int index) {
    final isSelected = controller.navBarIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
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
    final isSelected = controller.navBarIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
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
