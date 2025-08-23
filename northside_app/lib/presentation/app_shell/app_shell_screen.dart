// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // Needed for BackdropFilter

import 'app_shell_controller.dart';
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

            // The floating navigation bar at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildFloatingM3NavBar(context),
            ),
          ],
        ),
      );
    });
  }

  // --- DEFINITIVELY PROPORTIONAL FLOATING NAVIGATION BAR ---
  Widget _buildFloatingM3NavBar(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double navBarHeight = (screenSize.width * 0.14).clamp(56.0, 72.0); // Responsive, but capped
    final double iconSize = navBarHeight * 0.44; // Slightly larger for better balance
    final double innerPaddingHorizontal = navBarHeight * 0.32;
    final double innerPaddingVertical = navBarHeight * 0.18;
    return SafeArea(
      minimum: EdgeInsets.only(bottom: screenSize.height * 0.015),
      child: Container(
        margin: EdgeInsets.fromLTRB(AppTheme.horizontalPadding, 0, AppTheme.horizontalPadding, 0),
        height: navBarHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              color: const Color(0xFFF9F9F9).withValues(alpha: 0.85),
              padding: EdgeInsets.symmetric(horizontal: innerPaddingHorizontal, vertical: innerPaddingVertical),
              child: Center(
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  selectedIndex: controller.navBarIndex.value,
                  onDestinationSelected: controller.changePage,
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
                      selectedIcon: Icon(Icons.person, color: Colors.white, size: iconSize),
                      icon: Icon(Icons.person_outline, color: Colors.black87, size: iconSize),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildNavItem(BuildContext context, int index, IconData selectedIcon, IconData unselectedIcon, double iconSize) {
  //   final isSelected = controller.navBarIndex.value == index;
    
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: () => controller.changePage(index),
  //       behavior: HitTestBehavior.opaque,
  //       child: Center(
  //         child: Icon(
  //           isSelected ? selectedIcon : unselectedIcon,
  //           color: isSelected ? Colors.white : Colors.black87,
  //           size: iconSize,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
