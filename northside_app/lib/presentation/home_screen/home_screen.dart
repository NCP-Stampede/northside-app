// lib/presentation/home_screen/home_screen.dart

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

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final HomeCarouselController carouselController = Get.put(HomeCarouselController());
  int _currentPageIndex = 0;
  // This variable TRACKS which nav item is selected. It's the key to making it interactive.
  int _navBarIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Layer 1: The correct background gradient.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D1A2F), // much darker blue
                  Color(0xFF174EA6), // dark blue
                  Color(0xFFF7F7F7), // light grey-white
                  Color(0xFFF7F7F7), // solid from even higher up
                ],
                stops: [0.0, 0.09, 0.18, 0.26], // transition to white/grey much higher up
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Layer 2: The main UI content.
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                SizedBox(height: screenHeight * 0.025),
                _buildQuickActions(context),
                SizedBox(height: screenHeight * 0.03),
                Expanded(child: _buildEventsCarousel()),
                SizedBox(height: screenHeight * 0.02),
                _buildPageIndicator(screenWidth),
                SizedBox(height: screenHeight * 0.13),
              ],
            ),
          ),
          // Layer 3: The floating navigation bar.
          _buildFloatingNavBar(context, screenWidth, screenHeight),
        ],
      ),
    );
  }

  // THIS IS THE CORRECT, INTERACTIVE FLOATING NAVIGATION BAR.
  Widget _buildFloatingNavBar(BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(screenWidth * 0.05, 0, screenWidth * 0.05, screenHeight * 0.04),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.13),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: screenHeight * 0.08,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(screenWidth * 0.13),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Each item is now built with its index to check for selection.
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

  // This helper widget now handles taps to change the state.
  Widget _buildNavItem(String label, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _navBarIndex = index; // Updates the state when tapped.
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // This helper widget also handles taps.
  Widget _buildNavIconItem(IconData icon, int index, double screenWidth) {
    final isSelected = _navBarIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _navBarIndex = index; // Updates the state when tapped.
        });
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.01),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: const Color(0xFF007AFF), width: 1.5) : null,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
        ),
        child: Icon(icon, size: screenWidth * 0.07, color: isSelected ? const Color(0xFF007AFF) : Colors.black),
      ),
    );
  }

  // --- The rest of the file (header, buttons, etc.) is the same. ---

  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.07;
    return Padding(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, screenWidth * 0.04, screenWidth * 0.04, screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Home', style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.9),
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
    final double childAspectRatio = 2.7;
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
          _QuickActionButton(iconWidget: Image.asset('assets/images/grades_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'Grades', onTap: () {}),
          _QuickActionButton(iconWidget: Icon(Icons.calendar_today_outlined, color: Color(0xFF4285F4), size: screenWidth * 0.065), label: 'Events', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/hoofbeat_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'HoofBeat', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/flexes_icon.png', width: screenWidth * 0.08, height: screenWidth * 0.08), label: 'Flexes', onTap: () {}),
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
              color: _currentPageIndex == index ? const Color(0xFF333333) : Colors.grey.withOpacity(0.4),
            ),
          );
        }),
      );
    });
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.iconWidget, required this.label, required this.onTap});
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double borderRadius = screenWidth * 0.04;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [iconWidget, SizedBox(width: screenWidth * 0.03), Text(label, style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w600))],
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
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(cardRadius), topRight: Radius.circular(cardRadius)),
                  child: article.imagePath != null 
                    ? Image.asset(article.imagePath!, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.event, size: 48, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.event, size: 48, color: Colors.grey),
                      ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(cardRadius), topRight: Radius.circular(cardRadius)),
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
                    style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: iconSize, color: Colors.black),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          article.content,
                          style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.more_horiz, size: iconSize * 1.2, color: Colors.black),
                      SizedBox(width: screenWidth * 0.01),
                      Text('Tap for Details', style: TextStyle(fontSize: fontSizeSubtitle * 0.9, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
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
