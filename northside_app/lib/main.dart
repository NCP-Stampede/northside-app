import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const NorthsideApp());
}

class NorthsideApp extends StatelessWidget {
  const NorthsideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Northside App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'sans-serif',
        // Define a page transition animation for a more native feel
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // The AppShell is the home screen with the bottom nav bar
      home: const AppShell(),
      // Define all the routes for push navigation
      routes: {
        '/events': (context) => const EventsDetailPage(),
        '/hoofbeat': (context) => const HoofbeatPage(),
        '/flexes': (context) => const FlexesPage(),
        '/homecomingDetail': (context) => const HomecomingDetailPage(),
        // Note: The top-level 'Grades' page is in the AppShell's IndexedStack.
        // If the 'Grades' button needed to push a page, we'd add it here too.
      },
    );
  }
}


// --- DETAIL PAGES (Destinations for button taps) ---

// A generic detail page to show how navigation works.
class EventsDetailPage extends StatelessWidget {
  const EventsDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: const Center(child: Text('Full Events Calendar', style: TextStyle(fontSize: 24))),
    );
  }
}

class HoofbeatPage extends StatelessWidget {
  const HoofbeatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HoofBeat')),
      body: const Center(child: Text('HoofBeat News Feed', style: TextStyle(fontSize: 24))),
    );
  }
}

class FlexesPage extends StatelessWidget {
  const FlexesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flexes')),
      body: const Center(child: Text('Flexes Schedule and Info', style: TextStyle(fontSize: 24))),
    );
  }
}

class HomecomingDetailPage extends StatelessWidget {
  const HomecomingDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Homecoming 2024')),
      body: const Center(child: Text('Detailed Homecoming Information', style: TextStyle(fontSize: 24))),
    );
  }
}


// --- TOP-LEVEL PAGES (For the Bottom Nav Bar) ---

class AthleticsPage extends StatelessWidget {
  const AthleticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Athletics Page', style: TextStyle(fontSize: 24))));
  }
}

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Attendance Page', style: TextStyle(fontSize: 24))));
  }
}

class GradesPage extends StatelessWidget {
  const GradesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Grades Page', style: TextStyle(fontSize: 24))));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))));
  }
}


// --- MAIN APP SHELL (Handles the bottom nav and page switching) ---

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _navIndex = 0;

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const AthleticsPage(),
    const AttendancePage(),
    const GradesPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8A1A1), Color(0xFFADC6E6), Colors.white],
                stops: [0.0, 0.35, 0.35],
              ),
            ),
          ),
          IndexedStack(index: _navIndex, children: _pages),
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  // --- Methods for building the floating nav bar ---
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.80),
                borderRadius: BorderRadius.circular(50.0),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('Home', 0),
                  _buildNavItem('Athletics', 1),
                  _buildNavItem('Attendance', 2),
                  _buildNavItem('Grades', 3),
                  _buildNavIconItem(Icons.person_outline, 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
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

  Widget _buildNavIconItem(IconData icon, int index) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 1.5) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? const Color(0xFF007AFF) : Colors.grey[700],
        ),
      ),
    );
  }
}


// --- HOME SCREEN CONTENT WIDGET (The main UI from your image) ---

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});
  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  int _pageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() { /* ... Same as before ... */
      return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 16.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Home',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 28,
            ),
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
          // The "Grades" button in the nav bar goes to the top-level Grades page.
          // This button could go to the same page or a more specific detail page.
          // For demonstration, let's make it go to the top-level page as well.
          _QuickActionButton(
            iconWidget: const Icon(Icons.apps_rounded, color: Colors.blue, size: 28),
            label: 'Grades',
            onTap: () {
                // To navigate to the Grades tab via the button:
                // This is a bit more complex. For now, we'll assume it might
                // go to a different "detail" page if needed, or we'd need
                // to pass the AppShell's state down. Let's make it simple.
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Navigating from here would require state management (Provider, Riverpod, etc.)"),
                ));
            },
          ),
          _QuickActionButton(
            iconWidget: const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 24),
            label: 'Events',
            onTap: () => Navigator.pushNamed(context, '/events'),
          ),
          _QuickActionButton(
            iconWidget: const Icon(Icons.whatshot, color: Colors.orange, size: 28),
            label: 'HoofBeat',
            onTap: () => Navigator.pushNamed(context, '/hoofbeat'),
          ),
          _QuickActionButton(
            iconWidget: const Icon(Icons.verified_user_outlined, color: Colors.red, size: 28),
            label: 'Flexes',
            onTap: () => Navigator.pushNamed(context, '/flexes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel() {
    return SizedBox(
      height: 260,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _pageIndex = index),
        children: [
          // Wrap the card in a GestureDetector to make it tappable
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/homecomingDetail'),
            child: _HomecomingCard(),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/homecomingDetail'),
            child: _HomecomingCard(),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/homecomingDetail'),
            child: _HomecomingCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() { /* ... Same as before ... */
      return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pageIndex == index
                ? const Color(0xFF333333)
                : Colors.grey.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}


// --- REUSABLE UI COMPONENTS ---

class _QuickActionButton extends StatelessWidget { /* ... Same as before ... */
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.iconWidget,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomecomingCard extends StatelessWidget { /* ... Same as before ... */
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1519669556878-63bd5de507a7?fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                   decoration: BoxDecoration(
                     color: Colors.black.withOpacity(0.25),
                     borderRadius: const BorderRadius.only(
                       topLeft: Radius.circular(24),
                       topRight: Radius.circular(24),
                     )
                   ),
                ),
                const Center(
                  child: Text(
                    'HOMECOMING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(blurRadius: 5.0, color: Colors.black45, offset: Offset(2, 2))
                      ]
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
                   const Text(
                    'Homecoming 2024',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(82, 36, 171, 1),
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
