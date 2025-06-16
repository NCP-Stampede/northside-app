import 'package:flutter/material.dart';

void main() {
  runApp(const SchoolApp());
}

class SchoolApp extends StatelessWidget {
  const SchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // To use a custom font like SFProDisplay, you'd need to add it to your project
        // and declare it in pubspec.yaml. For now, Flutter's default will be used.
        // fontFamily: 'SFProDisplay',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 30),
            onPressed: () {
              print('Profile icon tapped');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8A98DE), // A lighter purplish-blue
              Color(0xFFC4CBF2), // A very light, almost white-blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: kToolbarHeight + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQuickActionButtons(context),
                const SizedBox(height: 24),
                _buildHomecomingCard(context),
                const SizedBox(height: 12),
                _buildPaginationDots(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickActionItem(
            context,
            icon: Icons.school_outlined,
            label: 'Grades',
            color: Colors.orange.shade300,
            onTap: () => print('Grades tapped'),
          ),
          _buildQuickActionItem(
            context,
            icon: Icons.event_outlined,
            label: 'Events',
            color: Colors.blue.shade300,
            onTap: () => print('Events tapped'),
          ),
          _buildQuickActionItem(
            context,
            icon: Icons.article_outlined,
            label: 'HoofBeat',
            color: Colors.green.shade300,
            onTap: () => print('HoofBeat tapped'),
          ),
          _buildQuickActionItem(
            context,
            icon: Icons.widgets_outlined,
            label: 'Flexes',
            color: Colors.purple.shade300,
            onTap: () => print('Flexes tapped'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomecomingCard(BuildContext context) {
    // IMPORTANT: If you use a local asset, create the assets folder and update pubspec.yaml
    // Then change NetworkImage to AssetImage('assets/images/your_image_name.png')
    const String homeComingImageUrl = 'https://images.unsplash.com/photo-1531058020387-3be344556be6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fGV2ZW50fGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(homeComingImageUrl), // Or AssetImage('assets/images/your_image.png')
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0]
                  )
                ),
                alignment: Alignment.center,
                child: Text(
                  'HOMECOMING',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
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
                      color: Color(0xFF4A0D66),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        'This Friday',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                        label: Text(
                          'More Details',
                          style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          print('Homecoming More Details tapped');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == 0
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }
}
