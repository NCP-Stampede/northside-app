// lib/presentation/home_screen/home_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// NOTE: The AngledBackgroundClipper has been removed as it's not needed.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now a Stack, which lets us layer the background and UI.
      body: Stack(
        children: [
          // This Container is the new background. It fills the entire screen.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                // These are the colors of the gradient.
                colors: [
                  Color(0xFFE8A1A1), // Top-left red
                  Color(0xFFADC6E6), // Middle blue
                  Colors.white,      // Bottom white
                ],
                // These 'stops' are the key to the effect.
                // They control where each color transition finishes.
                stops: [
                  0.0,  // Red starts at the beginning (0%).
                  0.25, // Blue takes over by the 25% mark.
                  0.4,  // White takes over by the 40% mark, covering the rest.
                ],
                // These control the angle of the gradient.
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // The rest of the UI sits on top of the gradient background.
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
          // The floating nav bar sits on top of everything.
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Home', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.7,
        children: [
          _QuickActionButton(iconWidget: Image.asset('assets/images/grades_icon.png', width: 32, height: 32), label: 'Grades', onTap: () {}),
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 26), label: 'Events', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/hoofbeat_icon.png', width: 32, height: 32), label: 'HoofBeat', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/flexes_icon.png', width: 32, height: 32), label: 'Flexes', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
      children: const [
        _HomecomingCard(),
        _HomecomingCard(),
        _HomecomingCard(),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == index ? const Color(0xFF333333) : Colors.grey.withOpacity(0.4),
          ),
        );
      }),
    );
  }

  Widget _buildFloatingNavBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
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
                  _buildNavItem('Home', isSelected: true),
                  _buildNavItem('Athletics'),
                  _buildNavItem('Attendance'),
                  _buildNavItem('Grades'),
                  _buildNavIconItem(Icons.person_outline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
    );
  }

  Widget _buildNavIconItem(IconData icon, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 1.5) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 28, color: isSelected ? const Color(0xFF007AFF) : Colors.grey[700]),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.iconWidget, required this.label, required this.onTap});
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [iconWidget, const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))],
        ),
      ),
    );
  }
}

class _HomecomingCard extends StatelessWidget {
  const _HomecomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Image.asset('assets/images/homecoming_bg.png', fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                ),
                Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFE474A2), Color(0xFF8A9AE4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: const Text(
                      'HOMECOMING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        shadows: [Shadow(blurRadius: 5.0, color: Colors.black45, offset: Offset(2, 2))],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'sans-serif'),
                      children: [
                        TextSpan(text: 'Homecoming ', style: TextStyle(color: Color(0xFFB94056))),
                        TextSpan(text: '2024', style: TextStyle(color: Color(0xFF2E4096))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text('This Friday', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      const Spacer(),
                      Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('More Details', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
