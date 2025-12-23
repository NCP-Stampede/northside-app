// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:ui'; // Needed for BackdropFilter

import 'app_shell_controller.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../home_screen_content/home_screen_content.dart';
import '../placeholder_pages/athletics_page.dart';
import '../placeholder_pages/profile_page.dart';
import '../placeholder_pages/events_page.dart';
import '../placeholder_pages/bulletin_page.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/bottom_melting_blur.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Create the pages list inside Obx to ensure fresh instances
      final List<Widget> pages = <Widget>[
        const HomeScreenContent(),
        const AthleticsPage(),
        const EventsPage(),
        const BulletinPage(),
        const ProfilePage(),
      ];

      return Scaffold(
        body: Stack(
          children: [
            // The main page content with Cupertino fade transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(controller.navBarIndex.value),
                child: pages[controller.navBarIndex.value],
              ),
            ),

            // Bottom melting blur effect behind the nav bar
            const BottomMeltingBlur(),

            // The floating navigation bar at the bottom with extended blur area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFloatingM3NavBarWithBlur(context),
            ),
          ],
        ),
      );
    });
  }

  // --- EXTENDED BLUR AREA FOR NAVIGATION BAR ---
  Widget _buildFloatingM3NavBarWithBlur(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return SafeArea(
      minimum: EdgeInsets.only(bottom: screenSize.height * 0.015),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppTheme.horizontalPadding),
        child: _buildFloatingM3NavBar(context),
      ),
    );
  }

  // --- DEFINITIVELY PROPORTIONAL FLOATING NAVIGATION BAR ---
  Widget _buildFloatingM3NavBar(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double navBarHeight = (screenSize.width * 0.14).clamp(56.0, 72.0);
    final double iconSize = navBarHeight * 0.32;
    final double innerPaddingHorizontal = navBarHeight * 0.32;
    final double innerPaddingVertical = navBarHeight * 0.18;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: navBarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.12),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.symmetric(horizontal: innerPaddingHorizontal, vertical: innerPaddingVertical),
          child: Center(
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Colors.white.withOpacity(0.2),
              selectedIndex: controller.navBarIndex.value,
              onDestinationSelected: (index) {
                HapticFeedbackHelper.buttonPress();
                controller.changePage(index);
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(CupertinoIcons.house_fill, color: const Color(0xFF64B5F6), size: iconSize), // Light Blue
                  icon: Icon(CupertinoIcons.house, color: Colors.white54, size: iconSize),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(CupertinoIcons.sportscourt_fill, color: const Color(0xFFFF8A65), size: iconSize), // Orange
                  icon: Icon(CupertinoIcons.sportscourt, color: Colors.white54, size: iconSize),
                  label: 'Athletics',
                ),
                NavigationDestination(
                  selectedIcon: Icon(CupertinoIcons.calendar, color: const Color(0xFFBA68C8), size: iconSize), // Purple
                  icon: Icon(CupertinoIcons.calendar, color: Colors.white54, size: iconSize),
                  label: 'Events',
                ),
                NavigationDestination(
                  selectedIcon: Icon(CupertinoIcons.doc_text_fill, color: const Color(0xFF81C784), size: iconSize), // Green
                  icon: Icon(CupertinoIcons.doc_text, color: Colors.white54, size: iconSize),
                  label: 'Bulletin',
                ),
                NavigationDestination(
                  selectedIcon: Icon(CupertinoIcons.gear_solid, color: const Color(0xFF90A4AE), size: iconSize), // Blue Grey
                  icon: Icon(CupertinoIcons.gear, color: Colors.white54, size: iconSize),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData selectedIcon, IconData unselectedIcon, double iconSize) {
    final isSelected = controller.navBarIndex.value == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePage(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            color: isSelected ? Colors.white : Colors.black87,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
