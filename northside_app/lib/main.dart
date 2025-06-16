import 'package:flutter/material.dart';
// SVG package is not needed for this testable version, but you will need it later.
// import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This version uses the default system font for immediate testing.
    // To add the "Inter" font later, declare it here in ThemeData.
    return MaterialApp(
      title: 'Northside App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007AFF),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomNavIndex = 0;

  // This function now returns a blank, sized box to prevent asset errors during testing.
  // It holds the exact 28x28 space your final icon will occupy.
  Widget _getIconPlaceholder({double size = 28}) {
    // This is a blank placeholder. It will not cause errors.
    return SizedBox(width: size, height: size);
    // When you are ready to add your assets, you will replace the call to this
    // function with your SvgPicture.asset(...) or Image.asset(...) widgets.
  }


  @override
  Widget build(BuildContext context) {
    const Color gradientStartColor = Color(0xFFEA6960);
    const Color gradientEndColor = Color(0xFFA485D7);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double topSystemPadding = MediaQuery.of(context).padding.top;
    const double appBarHeight = 60.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0),
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1C1C1E),
              radius: 19.0,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 22.0,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStartColor, gradientEndColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: EdgeInsets.only(
                  top: topSystemPadding + appBarHeight,
                  left: 20.0,
                  right: 20.0,
                  bottom: 120.0,
                ),
                children: [
                  const SizedBox(height: 24.0),
                  _buildQuickActionGrid(context, screenWidth - 40),
                  const SizedBox(height: 30),
                  _buildHomecomingCard(context),
                  const SizedBox(height: 24),
                  _buildPaginationDots(),
                ],
              ),
            ),
          ),
          _buildFloatingBottomNavBar(context),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, double availableWidth) {
    const double spacing = 16.0;
    final double itemWidth = (availableWidth - spacing) / 2;
    final double itemHeight = itemWidth * 0.62;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        _buildQuickActionItem(context, label: 'Grades'),
        _buildQuickActionItem(context, label: 'Events'),
        _buildQuickActionItem(context, label: 'HoofBeat'),
        _buildQuickActionItem(context, label: 'Flexes'),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Card(
        elevation: 1.5,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getIconPlaceholder(), // Blank, error-free placeholder
              const SizedBox(width: 12.0),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildHomecomingCard(BuildContext context) {
    // This now uses a NetworkImage to avoid local asset errors during testing.
    const String placeholderNetworkImage = 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=1200&q=80';
    const Color homecoming2024TextColor = Color(0xFF0A24F5);

    return Card(
      elevation: 4.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 195.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(placeholderNetworkImage), // ERROR-FREE
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Text(
                'HOMECOMING',
                style: TextStyle(
                  fontSize: 44.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Homecoming 2024',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w800,
                    color: homecoming2024TextColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18.0, color: Color(0xFF555555)),
                    const SizedBox(width: 8.0),
                    const Text(
                      'This Friday',
                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz_rounded, size: 22.0, color: Color(0xFF555555)),
                    const SizedBox(width: 6.0),
                    const Text(
                      'More Details',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Color(0xFF333333),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    const int currentPage = 1;
    const int dotCount = 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(dotCount, (index) {
          bool isActive = index == currentPage;
          return Container(
            width: isActive ? 9.0 : 8.0,
            height: isActive ? 9.0 : 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF616161) : const Color(0xFFCCCCCC),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingBottomNavBar(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 65.0,
        margin: EdgeInsets.only(left: 24.0, right: 24.0, bottom: bottomPadding + 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(32.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -1),
            )
          ],
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.5),
          child: BottomNavigationBar(
            currentIndex: _currentBottomNavIndex,
            onTap: (index) {
              setState(() { _currentBottomNavIndex = index; });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF007AFF),
            unselectedItemColor: const Color(0xFF8A8A8E),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10.0),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10.0),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.sports_basketball_outlined), label: 'Athletics'),
              BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
              BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined_rounded), label: 'Grades'),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(top: 1.5),
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF1C1C1E),
                    radius: 13.0,
                    child: Icon(Icons.person, color: Colors.white, size: 16.0),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
