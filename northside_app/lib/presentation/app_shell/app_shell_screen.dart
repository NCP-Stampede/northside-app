// lib/presentation/app_shell/app_shell_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import 'app_shell_controller.dart';
import '../home_screen_content/home_screen_content.dart';
import '../placeholder_pages/athletics_page.dart';
import '../placeholder_pages/profile_page.dart';
import '../placeholder_pages/events_page.dart';
// FIX: Import the new BulletinPage
import '../placeholder_pages/bulletin_page.dart';

class AppShellScreen extends GetView<AppShellController> {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Updated the page list
    final List<Widget> pages = <Widget>[
      const HomeScreenContent(),
      const AthleticsPage(),
      const EventsPage(),
      const BulletinPage(), // Replaced Flexes
      const ProfilePage(),
    ];

    return Obx(() => Scaffold(
          body: Stack(
            children: [
              pages[controller.navBarIndex.value],
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildFloatingM3NavBar(context),
              ),
            ],
          ),
        ));
  }

  Widget _buildFloatingM3NavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 65,
      // ... (decoration is unchanged) ...
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            color: const Color(0xFFF9F9F9).withOpacity(0.85),
            child: Center(
              child: SizedBox(
                width: 330,
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: const Color(0xFF007AFF),
                  selectedIndex: controller.navBarIndex.value,
                  onDestinationSelected: controller.changePage,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,

                  // FIX: Updated destinations
                  destinations: const <Widget>[
                    NavigationDestination(
                      selectedIcon: Icon(Icons.home, color: Colors.white),
                      icon: Icon(Icons.home_outlined, color: Colors.black87),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.sports_basketball, color: Colors.white),
                      icon: Icon(Icons.sports_basketball_outlined, color: Colors.black87),
                      label: 'Athletics',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.calendar_month, color: Colors.white),
                      icon: Icon(Icons.calendar_month_outlined, color: Colors.black87),
                      label: 'Events',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.article_outlined, color: Colors.white), // New Icon
                      icon: Icon(Icons.article_outlined, color: Colors.black87),
                      label: 'Bulletin',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.person, color: Colors.white),
                      icon: Icon(Icons.person_outline, color: Colors.black87),
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
}
