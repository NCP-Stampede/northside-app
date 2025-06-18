// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';

import 'app_shell_controller.dart';
import '../home_screen_content/home_screen_content.dart';
import '../placeholder_pages/athletics_page.dart';
import '../placeholder_pages/profile_page.dart';

// UPDATED: Import Events and Flexes
import '../placeholder_pages/events_page.dart';
import '../placeholder_pages/flexes_page.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UPDATED: The list of pages is now in the correct order.
    final List<Widget> pages = <Widget>[
      const HomeScreenContent(),
      const AthleticsPage(),
      const EventsPage(), // Replaced Attendance
      const FlexesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => Stack(
            children: [
              pages[controller.navBarIndex.value],
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFloatingNavBar(),
              ),
            ],
          )),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9).withOpacity(0.90),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              // UPDATED: The Row now has the correct labels and indices.
              child: Row(
                children: [
                  Expanded(child: _buildNavItem('Home', 0)),
                  Expanded(child: _buildNavItem('Athletics', 1)),
                  Expanded(child: _buildNavItem('Events', 2)), // Replaced Attendance
                  Expanded(child: _buildNavItem('Flexes', 3)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildProfileNavIcon(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildNavItem(String label, int index) {
    final isSelected = controller.navBarIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          // FIX: Added a shadow when the item is selected to give it depth.
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildProfileNavIcon(int index) {
    final isSelected = controller.navBarIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: Container(
        width: 40,
        height: 40,
        // FIX: Updated decoration to match the Figma design for both states.
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade200,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF007AFF),
                  width: 1.5,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Icon(
          isSelected ? Icons.person : Icons.person_outline,
          size: 24,
          color: isSelected ? const Color(0xFF007AFF) : Colors.grey[700],
        ),
      ),
    );
  }
}
