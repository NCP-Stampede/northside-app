// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
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
    final double blurHeight = screenSize.height * 0.25; // Extend blur area upward
    
    return SizedBox(
      height: blurHeight,
      child: Stack(
        children: [
          // Extended blur area with gradient fade effect
          Positioned.fill(
            child: ClipRect(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,     // No blur at top
                      Colors.transparent,     // Keep transparent longer
                      Colors.black,          // Gradual fade in
                      Colors.black,          // Full blur at bottom
                    ],
                    stops: [0.0, 0.5, 0.8, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFFF9F9F9).withOpacity(0.3),
                          const Color(0xFFFFFFFF).withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Actual navigation bar positioned at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: screenSize.height * 0.015),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppTheme.horizontalPadding),
                child: _buildFloatingM3NavBar(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DEFINITIVELY PROPORTIONAL FLOATING NAVIGATION BAR ---
  Widget _buildFloatingM3NavBar(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double navBarHeight = (screenSize.width * 0.14).clamp(56.0, 72.0); // Responsive, but capped
    final double iconSize = navBarHeight * 0.44; // Slightly larger for better balance
    final double innerPaddingHorizontal = navBarHeight * 0.32;
    final double innerPaddingVertical = navBarHeight * 0.18;
    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 32,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFF9F9F9).withOpacity(0.95),
                const Color(0xFFFFFFFF).withOpacity(0.9),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.symmetric(horizontal: innerPaddingHorizontal, vertical: innerPaddingVertical),
          child: Center(
            child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  selectedIndex: controller.navBarIndex.value,
                  onDestinationSelected: (index) {
                    HapticFeedbackHelper.buttonPress();
                    controller.changePage(index);
                  },
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                  destinations: <Widget>[
                    NavigationDestination(
                      selectedIcon: Icon(Icons.home, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.home_outlined, color: Colors.black87, size: iconSize),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.sports_basketball, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.sports_basketball_outlined, color: Colors.black87, size: iconSize),
                      label: 'Athletics',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.calendar_month, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.calendar_month_outlined, color: Colors.black87, size: iconSize),
                      label: 'Events',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.article, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.article_outlined, color: Colors.black87, size: iconSize),
                      label: 'Bulletin',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.settings, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.settings_outlined, color: Colors.black87, size: iconSize),
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
