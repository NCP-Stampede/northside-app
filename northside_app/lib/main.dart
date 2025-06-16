import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Example for using SVGs later

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a font family if you have one (e.g., SF Pro Display)
    // const String appFontFamily = 'SFProDisplay'; // Ensure added to pubspec.yaml

    return MaterialApp(
      title: 'Northside App',
      theme: ThemeData(
        // fontFamily: appFontFamily, // Apply default font family
        brightness: Brightness.light, // Assuming a light theme from the mockup
        // appBarTheme is handled in HomeScreen for transparency
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
  int _currentBottomNavIndex = 0; // For BottomNavigationBar

  // Placeholder for custom icons. Replace with Image.asset or SvgPicture.asset
  Widget _getCustomIcon(String iconName, Color color) {
    // In a real app, you'd load your actual asset here.
    // For example: return Image.asset('assets/icons/$iconName.png', width: 30, height: 30, color: color);
    // Or: return SvgPicture.asset('assets/icons/$iconName.svg', width: 30, height: 30, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
    IconData placeholderIcon = Icons.help_outline; // Default placeholder
    double iconSize = 30;
    if (iconName == 'grades') placeholderIcon = Icons.apps; // Closest to Rubik's cube
    if (iconName == 'events') placeholderIcon = Icons.calendar_today_outlined;
    if (iconName == 'hoofbeat') placeholderIcon = Icons.graphic_eq; // Placeholder for sound/beat
    if (iconName == 'flexes') placeholderIcon = Icons.star_border; // Generic placeholder for logo

    if (iconName == 'events') {
       return Icon(placeholderIcon, size: iconSize, color: const Color(0xFF6C63FF)); // Specific blue for events icon
    }
    if (iconName == 'grades') {
       return Icon(placeholderIcon, size: iconSize, color: const Color(0xFFFFB02F)); // Orange for grades
    }
     if (iconName == 'hoofbeat') {
       return Icon(placeholderIcon, size: iconSize, color: const Color(0xFFE94F37)); // Reddish for hoofbeat
    }
     if (iconName == 'flexes') {
       return Icon(placeholderIcon, size: iconSize, color: const Color(0xFF6C63FF).withOpacity(0.8)); // Purple for flexes
    }


    return Icon(placeholderIcon, size: iconSize, color: color);
  }


  @override
  Widget build(BuildContext context) {
    // Approximate gradient colors from Figma
    const Color gradientStartColor = Color(0xFFF07C70); // Pinkish-Red top-left
    const Color gradientEndColor = Color(0xFF8A98DE);   // Light Blue/Purple bottom-right

    return Scaffold(
      extendBodyBehindAppBar: true, // Make body go behind AppBar
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22, // Adjusted size
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              radius: 18,
              child: Icon(
                Icons.person_outline,
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
            colors: [gradientStartColor, gradientEndColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0], // Gradient stops
          ),
        ),
        child: SafeArea( // Ensures content is not obscured by notches etc.
          bottom: false, // We'll handle bottom padding with the BottomNav
          child: ListView( // Using ListView for scrollability if content overflows
            padding: const EdgeInsets.fromLTRB(16.0, kToolbarHeight + 20, 16.0, 16.0), // Top padding for AppBar
            children: [
              _buildQuickActionGrid(context),
              const SizedBox(height: 24),
              _buildHomecomingCard(context),
              const SizedBox(height: 16),
              _buildPaginationDots(),
              // Add more content here if needed, or SizedBox for spacing above BottomNav
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    // Using GridView for a 2x2 layout
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true, // Important for GridView inside ListView
      physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
      mainAxisSpacing: 12.0,
      crossAxisSpacing: 12.0,
      childAspectRatio: (MediaQuery.of(context).size.width / 2 - 22) / 80, // Adjust aspect ratio for height
      children: [
        _buildQuickActionItem(
          context,
          iconName: 'grades',
          label: 'Grades',
          // iconColor: const Color(0xFFFFB02F), // Orange
          onTap: () => print('Grades tapped'),
        ),
        _buildQuickActionItem(
          context,
          iconName: 'events',
          label: 'Events',
          // iconColor: const Color(0xFF6C63FF), // Blue/Purple
          onTap: () => print('Events tapped'),
        ),
        _buildQuickActionItem(
          context,
          iconName: 'hoofbeat',
          label: 'HoofBeat',
          // iconColor: const Color(0xFFE94F37), // Reddish
          onTap: () => print('HoofBeat tapped'),
        ),
        _buildQuickActionItem(
          context,
          iconName: 'flexes',
          label: 'Flexes',
          // iconColor: const Color(0xFF1EAE98), // Teal/Green - Pick from your design
          onTap: () => print('Flexes tapped'),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String iconName, // Changed to iconName for custom icon handling
    required String label,
    // required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getCustomIcon(iconName, Colors.black), // Pass a default color, custom icon might have its own colors
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500, // Slightly bolder than normal
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildHomecomingCard(BuildContext context) {
    const String homeComingImageUrl = 'https://images.unsplash.com/photo-1531058020387-3be344556be6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGV2ZW50fGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'; // Placeholder
    // Color from Figma for "Homecoming 2024" text
    const Color homecomingTitleColor = Color(0xFF4A0D66); // Dark Magenta/Purple

    return Card(
      elevation: 3.0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // More rounded corners
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 180, // Adjust height as per design
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(homeComingImageUrl), // Replace with your actual image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Optional: Dark overlay if needed for text contrast, though Figma doesn't show a strong one
              // Container(height: 180, color: Colors.black.withOpacity(0.2)),
              const Text(
                'HOMECOMING',
                style: TextStyle(
                  fontSize: 40, // Large and Bold
                  fontWeight: FontWeight.w900, // Extra bold
                  color: Colors.white,
                  letterSpacing: 1.5,
                  // No explicit text shadow visible in Figma
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Homecoming 2024',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: homecomingTitleColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'This Friday',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    ),
                    const Spacer(),
                     Icon(Icons.more_horiz_outlined, size: 20, color: Colors.grey.shade700), // Three dots icon
                    const SizedBox(width: 4),
                    Text(
                      'More Details',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800, // Dark grey, not blue
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
    int currentPage = 0;
    int dotCount = 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentPage
                ? Colors.grey.shade600 // Active dot (darker grey)
                : Colors.grey.shade400, // Inactive dot (lighter grey)
          ),
        );
      }),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90), // Semi-transparent white
        // For blur effect, you might need a package like `glassmorphism` or custom painting.
        // This is a simpler semi-transparent background.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          )
        ],
        // borderRadius: BorderRadius.only( // Optional: if you want rounded top corners
        //   topLeft: Radius.circular(20),
        //   topRight: Radius.circular(20),
        // )
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
          // Handle navigation based on index
          print('Tapped item $index');
        },
        type: BottomNavigationBarType.fixed, // Fixed type for more than 3 items
        backgroundColor: Colors.transparent, // Handled by container
        elevation: 0, // Handled by container's shadow
        selectedItemColor: Colors.blue.shade700, // Color for selected icon and label
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 10, // Font size for selected label
        unselectedFontSize: 10, // Font size for unselected label
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_basketball_outlined), label: 'Athletics'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), label: 'Grades'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.black, // Small profile icon
              radius: 12,
              child: Icon(Icons.person_outline, color: Colors.white, size: 14),
            ),
            label: 'Profile', // Or an empty string if no label desired
          ),
        ],
      ),
    );
  }
}
