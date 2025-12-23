import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_carousel_controller.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final HomeCarouselController carouselController = Get.put(HomeCarouselController());
  
  // Animation Controller for the Liquid Background
  late AnimationController _liquidController;
  
  int _currentPageIndex = 0;
  int _navBarIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start the endless loop for the liquid animation
    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black, // Dark base for the glass to pop
      body: Stack(
        children: [
          // LAYER 1: The Animated Liquid Background
          // This replaces the static gradient to give the "Glass" something to distort.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _liquidController,
              builder: (context, child) {
                return CustomPaint(
                  painter: LiquidBackgroundPainter(
                    animationValue: _liquidController.value,
                  ),
                  size: Size(screenWidth, screenHeight),
                );
              },
            ),
          ),

          // LAYER 2: The Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: screenHeight * 0.025),
                // This section now uses the Glass Cards
                _buildQuickActions(context),
                SizedBox(height: screenHeight * 0.03),
                Expanded(child: _buildEventsCarousel()),
                SizedBox(height: screenHeight * 0.02),
                _buildPageIndicator(screenWidth),
                SizedBox(height: screenHeight * 0.13),
              ],
            ),
          ),

          // LAYER 3: The Floating Nav Bar
          _buildFloatingNavBar(context, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, screenWidth * 0.05, screenHeight * 0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.13),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Increased blur
            child: Container(
              height: screenHeight * 0.08,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              decoration: BoxDecoration(
                // Darker glass for the nav bar
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(screenWidth * 0.13),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('Home', 0, screenWidth),
                  _buildNavItem('Athletics', 1, screenWidth),
                  _buildNavItem('Attendance', 2, screenWidth),
                  _buildNavItem('Grades', 3, screenWidth),
                  _buildNavIconItem(Icons.person_outline, 4, screenWidth),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navBarIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035, 
            fontWeight: FontWeight.w600, 
            // Text color must be white to show on dark liquid background
            color: isSelected ? Colors.white : Colors.white60
          ),
        ),
      ),
    );
  }

  Widget _buildNavIconItem(IconData icon, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navBarIndex = index),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.01),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Icon(icon, size: screenWidth * 0.07, color: isSelected ? Colors.white : Colors.white60),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.07;
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Home', 
            // Changed to White for Liquid Dark Mode
            style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.white), 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis
          ),
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Icon(Icons.person_outline, color: Colors.white, size: screenWidth * 0.07),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double crossAxisSpacing = screenWidth * 0.04;
    final double mainAxisSpacing = screenWidth * 0.04;
    final double childAspectRatio = 2.7; // Adjusted aspect ratio slightly
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: [
          // Using the new Glass Button widget
          _GlassQuickActionButton(
            iconWidget: Image.asset('assets/images/grades_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08, color: Colors.cyanAccent), // Tinted for neon look
            label: 'Grades', 
            colorAccent: Colors.cyanAccent,
            onTap: () {}
          ),
          _GlassQuickActionButton(
            iconWidget: Icon(Icons.calendar_today_outlined, color: Colors.purpleAccent, size: screenWidth * 0.065), 
            label: 'Events', 
            colorAccent: Colors.purpleAccent,
            onTap: () {}
          ),
          _GlassQuickActionButton(
            iconWidget: Image.asset('assets/images/hoofbeat_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08, color: Colors.pinkAccent), 
            label: 'HoofBeat', 
            colorAccent: Colors.pinkAccent,
            onTap: () {}
          ),
          _GlassQuickActionButton(
            iconWidget: Image.asset('assets/images/flexes_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08, color: Colors.orangeAccent), 
            label: 'Flexes', 
            colorAccent: Colors.orangeAccent,
            onTap: () {}
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel() {
    return Obx(() {
      if (carouselController.isLoading) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      
      final carouselEvents = carouselController.getCarouselAsArticles();
      
      if (carouselEvents.isEmpty) {
        return const Center(
          child: Text(
            'No events available',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }
      
      return PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        itemCount: carouselEvents.length,
        itemBuilder: (context, index) {
          final article = carouselEvents[index];
          return GestureDetector(
            onTap: () {
              Get.bottomSheet(
                ArticleDetailDraggableSheet(article: article),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useRootNavigator: false,
                enableDrag: true,
              );
            },
            child: _EventCard(article: article),
          );
        },
      );
    });
  }

  Widget _buildPageIndicator(double screenWidth) {
    return Obx(() {
      final carouselEvents = carouselController.getCarouselAsArticles();
      final eventCount = carouselEvents.length;
      
      if (eventCount <= 1) return const SizedBox.shrink();
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(eventCount, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
            width: screenWidth * 0.02,
            height: screenWidth * 0.02,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPageIndex == index ? Colors.white : Colors.white24,
            ),
          );
        }),
      );
    });
  }
}

// --- NEW WIDGET: LIQUID GLASS BUTTON ---
class _GlassQuickActionButton extends StatelessWidget {
  const _GlassQuickActionButton({
    required this.iconWidget, 
    required this.label, 
    required this.onTap,
    required this.colorAccent,
  });
  
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;
  final Color colorAccent;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double borderRadius = screenWidth * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          // THE BLUR: Makes the background blobs fuzzy behind the button
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              // THE GRADIENT: Semi-transparent white to mimic glass surface
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              // THE BORDER: Essential for glassmorphism
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add a subtle glow behind the icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorAccent.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: -5,
                      )
                    ]
                  ),
                  child: iconWidget
                ),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  label, 
                  style: GoogleFonts.inter(
                    fontSize: fontSize, 
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9), // White text
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double fontSizeSubtitle = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.045;
    
    // Also Glassifying the Event Card to match the theme
    return ClipRRect(
      borderRadius: BorderRadius.circular(cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Glassy background
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    article.imagePath != null 
                      ? Image.asset(article.imagePath!, fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.white10,
                            child: Icon(Icons.event, size: 48, color: Colors.white54),
                          ),
                        )
                      : Container(
                          color: Colors.white10,
                          child: Icon(Icons.event, size: 48, color: Colors.white54),
                        ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        article.title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)]
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.03),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        article.subtitle,
                        style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: iconSize, color: Colors.white70),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              article.content,
                              style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.more_horiz, size: iconSize * 1.2, color: Colors.white70),
                          SizedBox(width: screenWidth * 0.01),
                          Text('Details', style: TextStyle(fontSize: fontSizeSubtitle * 0.9, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW CLASS: LIQUID BACKGROUND PAINTER ---
class LiquidBackgroundPainter extends CustomPainter {
  final double animationValue;

  LiquidBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    
    // Draw Deep Dark Background
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0A0A0F), Color(0xFF1A1A2E)], // Deep space blue/black
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    
    canvas.drawRect(rect, bgPaint);

    // Draw Moving Blobs
    // We use Screen blending to make them glow where they overlap
    final Paint blobPaint = Paint()..blendMode = BlendMode.screen;

    void drawBlob(Color color, double offsetX, double offsetY, double scale, double speedOffset) {
      // Calculate animated position
      final double t = (animationValue * 2 * math.pi) + speedOffset;
      final double x = size.width / 2 + math.sin(t) * (size.width * 0.3) + offsetX;
      final double y = size.height / 2 + math.cos(t * 0.7) * (size.height * 0.2) + offsetY;
      final double radius = size.width * 0.5 * scale;

      // Radial gradient for soft edges
      blobPaint.shader = RadialGradient(
        colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
        stops: const [0.1, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

      canvas.drawCircle(Offset(x, y), radius, blobPaint);
    }

    // Blob 1: Deep Blue
    drawBlob(const Color(0xFF4361EE), -50, -100, 1.0, 0);
    
    // Blob 2: Purple
    drawBlob(const Color(0xFF7209B7), 50, 100, 0.8, 2.0);
    
    // Blob 3: Pink Accent
    drawBlob(const Color(0xFFF72585), -20, 150, 0.6, 4.0);
  }

  @override
  bool shouldRepaint(covariant LiquidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}