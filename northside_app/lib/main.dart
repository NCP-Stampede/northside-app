import 'package:flutter/material.dart';
// If you use SVG icons later, ensure 'flutter_svg' is in pubspec.yaml and uncomment:
// import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure 'Inter' font is added to pubspec.yaml and assets/fonts/
    const String appFontFamily = 'Inter';

    return MaterialApp(
      title: 'Northside App',
      theme: ThemeData(
        fontFamily: appFontFamily,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF007AFF), // Standard iOS Blue, for consistency
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

  // PLACEHOLDER FOR CUSTOM ICON ASSETS
  // This function uses IconData for placeholders and aims to match Figma icon colors.
  // Replace the Icon widget with Image.asset or SvgPicture.asset for your actual icons.
  Widget _getPlaceholderIconForFigma(String figmaIconName, {double size = 26}) { // Default size for quick action icons
    // Colors from Figma design's custom icons
    if (figmaIconName == 'grades') {
      // Placeholder for the Rubik's Cube. Your asset will provide the actual visual.
      // This colored container is just to represent the space and dominant color idea.
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // Example: Use a prominent color from the Rubik's cube if it's mostly one shade,
          // or just a neutral placeholder. For now, a generic colorful representation.
          color: const Color(0xFFF9A825), // Dominant yellow/orange from the cube
          // If you want to simulate blocks:
          // gradient: LinearGradient(colors: [Color(0xFFF9A825), Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFE91E63)])
        ),
        // child: Center(child: Icon(Icons.apps_rounded, size: size*0.7, color: Colors.white.withOpacity(0.5))), // Optional inner detail
      );
    } else if (figmaIconName == 'events') {
      return Icon(Icons.calendar_today_outlined, size: size, color: const Color(0xFF333333)); // Dark gray/black for calendar
    } else if (figmaIconName == 'hoofbeat') {
      // Placeholder for Hoofbeat (hoof + sound wave).
      return Icon(Icons.graphic_eq, size: size, color: const Color(0xFFE53935)); // Reddish-orange from Figma
    } else if (figmaIconName == 'flexes') {
      // Placeholder for Flexes (horse logo).
      return Icon(Icons.shield_outlined, size: size, color: const Color(0xFF7B1FA2)); // Deep red/maroon from Figma logo
    }
    return Icon(Icons.help_outline, size: size, color: Colors.grey); // Fallback
  }


  @override
  Widget build(BuildContext context) {
    const Color gradientStartColor = Color(0xFFED6E67);
    const Color gradientMidColor = Color(0xFFD083A8);
    const Color gradientEndColor = Color(0xFF8A98DE);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double topSystemPadding = MediaQuery.of(context).padding.top;
    const double appBarHeight = 60.0; // Consistent AppBar height

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        title: const Padding(
          padding: EdgeInsets.only(left: 4.0), // Figma has title slightly offset from absolute edge
          child: Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700, // Inter Bold
              fontSize: 26, // Matches Figma visually
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20.0), // Matches screen horizontal padding
            child: CircleAvatar(
              backgroundColor: Color(0xFF1C1C1E), // Very dark gray/off-black from Figma
              radius: 19, // Matches Figma profile icon size
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStartColor, gradientMidColor, gradientEndColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.only(
              top: topSystemPadding + appBarHeight + 20, // Status bar + AppBar + margin
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
            ),
            children: [
              _buildQuickActionGrid(context, screenWidth - 40), // available content width
              const SizedBox(height: 30), // Spacing from Figma
              _buildHomecomingCard(context),
              const SizedBox(height: 24), // Spacing from Figma
              _buildPaginationDots(),
              // This SizedBox ensures that the lowest content in ListView can scroll above the bottom nav bar
              SizedBox(height: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, double availableWidth) {
    double spacing = 16.0; // Spacing between cards from Figma
    double itemWidth = (availableWidth - spacing) / 2;
    // Height derived from Figma's visual proportion (approx 60-62% of itemWidth)
    double itemHeight = itemWidth * 0.62;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: itemWidth / itemHeight,
      children: [
        _buildQuickActionItem(context, figmaIconName: 'grades', label: 'Grades'),
        _buildQuickActionItem(context, figmaIconName: 'events', label: 'Events'),
        _buildQuickActionItem(context, figmaIconName: 'hoofbeat', label: 'HoofBeat'),
        _buildQuickActionItem(context, figmaIconName: 'flexes', label: 'Flexes'),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String figmaIconName,
    required String label,
    VoidCallback? onTap, // Made onTap optional if some are non-interactive initially
  }) {
    return GestureDetector(
      onTap: onTap ?? () {}, // Default empty tap if none provided
      child: Card(
        elevation: 1.5, // Figma buttons are quite flat, very subtle shadow
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0), // Matches Figma
        ),
        child: Padding(
          // Padding inside the card to position icon and text
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _getPlaceholderIconForFigma(figmaIconName, size: 26), // Icon size from Figma
              const SizedBox(width: 12), // Space between icon and text from Figma
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15, // Matches Figma
                    fontWeight: FontWeight.w600, // Inter SemiBold
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildHomecomingCard(BuildContext context) {
    // const String homecomingImageAsset = 'assets/images/YOUR_HOMECOMING_IMAGE.png'; // REPLACE THIS
    const String placeholderNetworkImage = 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&w=1200&q=80';
    const Color homecoming2024TextColor = Color(0xFF0A24F5); // Vibrant Blue from Figma

    return Card(
      elevation: 3.5, // Matches Figma shadow depth
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // Pronounced rounding from Figma
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 195, // Visual height from Figma
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    // image: AssetImage(homecomingImageAsset), // USE YOUR ACTUAL ASSET
                    image: NetworkImage(placeholderNetworkImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Text(
                'HOMECOMING',
                style: TextStyle(
                  fontSize: 44, // Matches Figma
                  fontWeight: FontWeight.w900, // Inter Black
                  color: Colors.white,
                  letterSpacing: 1.5, // Matches Figma
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 22.0, 20.0, 22.0), // Matches Figma padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Homecoming 2024',
                  style: TextStyle(
                    fontSize: 24, // Matches Figma
                    fontWeight: FontWeight.w800, // Inter ExtraBold
                    color: homecoming2024TextColor,
                  ),
                ),
                const SizedBox(height: 16), // Matches Figma spacing
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: const Color(0xFF555555)), // Dark gray icon
                    const SizedBox(width: 8),
                    Text(
                      'This Friday',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF333333)), // Dark gray text
                    ),
                    const Spacer(),
                    Icon(Icons.more_horiz_rounded, size: 22, color: const Color(0xFF555555)), // Dark gray icon
                    const SizedBox(width: 6),
                    Text(
                      'More Details',
                      style: TextStyle(
                        fontSize: 15, // Matches Figma
                        color: const Color(0xFF333333), // Dark gray text
                        fontWeight: FontWeight.w500, // Inter Medium
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
    int currentPage = 1; // Figma shows middle dot active
    int dotCount = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        bool isActive = index == currentPage;
        return Container(
          width: isActive ? 8.5 : 8.0, // Active dot can be subtly larger
          height: isActive ? 8.5 : 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0), // Matches Figma spacing
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF616161)  // Darker gray for active (Figma)
                : const Color(0xFFCCCCCC), // Lighter gray for inactive (Figma)
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    // Height needs to accommodate labels and icon, plus iPhone home indicator area padding
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    // Figma bottom nav bar seems compact, about 50-55 for items + label, then system padding
    double navBarContentHeight = 50.0;

    return Container(
      height: navBarContentHeight + bottomPadding, // Dynamic height
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding * 0.25 : 0), // Reduced padding for notch area for a tighter fit
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92), // Matches Figma's semi-transparency
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // Matches Figma's subtle shadow
            blurRadius: 10,
            offset: const Offset(0, -1),
          )
        ],
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5)), // Subtle top border from Figma
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() { _currentBottomNavIndex = index; });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF007AFF), // iOS Blue from Figma
        unselectedItemColor: const Color(0xFF8A8A8E), // iOS Gray from Figma (slightly adjusted from 8E8E93)
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10), // Inter Medium, size from Figma
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_basketball_outlined), label: 'Athletics'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined_rounded), label: 'Grades'), // Different icon for Grades
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(top: 1.5), // Fine-tune vertical alignment
              child: CircleAvatar(
                backgroundColor: Color(0xFF1C1C1E), // Dark gray/off-black from Figma
                radius: 13, // Matches Figma
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
