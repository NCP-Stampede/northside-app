// lib/presentation/home_screen_content/home_screen_content.dart
// (This code is the same as the last correct version)

import 'package:flutter/material.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8A1A1), Color(0xFFADC6E6), Colors.white],
              stops: [0.0, 0.25, 0.4],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 25),
              Expanded(child: _buildEventsCarousel()),
              const SizedBox(height: 15),
              _buildPageIndicator(),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ],
    );
  }
  
  // All _build... methods and private widgets go here
  Widget _buildHeader() { /* ... Same as before ... */ }
  Widget _buildQuickActions() { /* ... Same as before ... */ }
  Widget _buildEventsCarousel() { /* ... Same as before ... */ }
  Widget _buildPageIndicator() { /* ... Same as before ... */ }
}
class _QuickActionButton extends StatelessWidget { /* ... Same as before ... */ }
class _HomecomingCard extends StatelessWidget { /* ... Same as before ... */ }
