// lib/presentation/home_screen_content/home_screen_content.dart

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

  // THIS WIDGET CONTAINS THE FIX FOR THE CLIPPED SHADOW
  Widget _buildEventsCarousel() {
    return PageView(
      // THE FIX: This line allows the cards inside the PageView
      // to draw their shadows outside of the PageView's rectangular boundary.
      clipBehavior: Clip.none,
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
        ],
      ),
    );
  }
}
}
