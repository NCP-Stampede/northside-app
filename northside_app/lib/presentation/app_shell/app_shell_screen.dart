import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:northside_app/presentation/app_shell/app_shell_controller.dart';
import 'package:northside_app/presentation/home_screen_content/home_screen_content.dart';
import 'package:northside_app/presentation/athletics_screen/athletics_screen.dart';
import 'package:northside_app/presentation/attendance_screen/attendance_screen.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreenContent(),
      const AthleticsPage(),
      const AttendancePage(),
      const Center(child: Text("Grades Page Placeholder")),
      const Center(child: Text("Profile Page Placeholder")),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Obx automatically listens to changes in controller variables.
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
            // This Obx makes sure only the Row rebuilds on tap, which is efficient.
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

  Widget _buildNavItem(String label, int index) {
    final isSelected = controller.navBarIndex.value == index;
    return GestureDetector(
      // The onTap now calls the controller's function.
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
}
