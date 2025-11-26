// lib/presentation/home_screen_content/home_screen_content.dart

import 'dart:ui'; // Needed for BackdropFilter
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen_content_controller.dart';
import '../app_shell/app_shell_controller.dart';
import '../placeholder_pages/hoofbeat_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/design_constants.dart';
import '../../widgets/shared_header.dart';
import '../../controllers/home_carousel_controller.dart';
import '../../core/utils/haptic_feedback_helper.dart';

class HomeScreenContent extends GetView<HomeScreenContentController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeCarouselController homeCarouselController = Get.find<HomeCarouselController>();
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF6B6B), // Red
                  Color(0xFF4A90E2), // True blue (less green)
                ],
                stops: [0.0, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xFFF2F2F7).withOpacity(0.03),
                  Color(0xFFF2F2F7).withOpacity(0.07),
                  Color(0xFFF2F2F7).withOpacity(0.15),
                  Color(0xFFF2F2F7).withOpacity(0.25),
                  Color(0xFFF2F2F7).withOpacity(0.4),
                  Color(0xFFF2F2F7).withOpacity(0.6),
                  Color(0xFFF2F2F7).withOpacity(0.8),
                  Color(0xFFF2F2F7).withOpacity(0.95),
                  Color(0xFFF2F2F7),
                ],
                stops: [0.0, 0.12, 0.18, 0.25, 0.32, 0.38, 0.42, 0.45, 0.47, 0.49, 0.5],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + (MediaQuery.of(context).size.width * 0.12) + (MediaQuery.of(context).size.height * 0.05),
              bottom: 120
            ),
            children: [
              _buildQuickActions(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04), // 4% of screen height
              // Carousel moved to overlay, leaving space for it
              Obx(() => _buildEventsCarousel(context, homeCarouselController)),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02), // 2% of screen height
              Obx(() => _buildPageIndicator(homeCarouselController)),
            ],
          ),
          _buildHeader(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.07;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = screenWidth * 0.4 + topPadding;
    
    return ClipRect(
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black,
              Colors.transparent,
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
          child: Container(
            height: headerHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFC7C7CC).withOpacity(0.85),
                  const Color(0xFFF9F9F9).withOpacity(0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: topPadding + 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Home',
                        style: GoogleFonts.inter(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildQuickActions() {
    final AppShellController appShellController = Get.find();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      margin: EdgeInsets.zero,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.7,
        children: [
          _QuickActionButton(iconWidget: const Icon(Icons.sports_basketball, color: Color(0xFFFF6B35), size: 26), label: 'Athletics', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(1); }),
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today, color: Color(0xFF4285F4), size: 26), label: 'Events', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(2); }),
          _QuickActionButton(iconWidget: const Icon(Icons.article, color: Color(0xFF34A853), size: 26), label: 'HoofBeat', onTap: () { HapticFeedbackHelper.buttonPress(); Get.to(() => const HoofBeatPage()); }),
          // FIX: The label is now "Bulletin", the icon is updated, and it correctly navigates to index 3.
          _QuickActionButton(iconWidget: const Icon(Icons.campaign, color: Color(0xFFEA4335), size: 26), label: 'Bulletin', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(3); }),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel(BuildContext context, HomeCarouselController carouselController) {
    final events = carouselController.getCarouselAsArticles();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double carouselHeight = screenHeight * 0.4; // 40% of screen height
    
    if (events.isEmpty) {
      return SizedBox(
        height: carouselHeight,
        child: Center(
          child: carouselController.isLoading 
            ? const LoadingIndicator(
                message: 'Loading events...',
                showBackground: false,
              )
            : Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                padding: const EdgeInsets.all(20),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 32,
                      cornerSmoothing: 1.0,
                    ),
                  ),
                  shadows: DesignConstants.standardShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.announcement_outlined, size: 48, color: Colors.black.withOpacity(0.5)),
                    SizedBox(height: 16),
                    Text(
                      'No Recent Announcements',
                      style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back later for updates!',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
        ),
      );
    }
    
    // Set the event count for infinite scroll calculation
    controller.setEventCount(events.length);
    
    // For single event, don't enable infinite scroll
    if (events.length == 1) {
      return SizedBox(
        height: carouselHeight,
        child: PageView.builder(
          controller: PageController(),
          itemCount: 1,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final post = events[0];
            final article = Article(
              title: post.title,
              subtitle: post.subtitle,
              imagePath: post.imagePath,
              content: post.content,
            );
            return GestureDetector(
              onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
              onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
              onTap: () {
                Get.bottomSheet(
                  ArticleDetailDraggableSheet(article: article),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  useRootNavigator: false,
                  enableDrag: true,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildEventCard(context, article),
              ),
            );
          },
        ),
      );
    }
    
    // For multiple events, enable infinite scroll
    return SizedBox(
      height: carouselHeight,
      child: PageView.builder(
        controller: PageController(
          initialPage: controller.getVirtualIndex(0),
        ),
        itemCount: null, // Infinite
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          controller.onPageChanged(index);
        },
        itemBuilder: (context, index) {
          final actualIndex = index % events.length;
          final post = events[actualIndex];
          final article = Article(
            title: post.title,
            subtitle: post.subtitle,
            imagePath: post.imagePath,
            content: post.content,
          );
          return GestureDetector(
            onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
            onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
            onTap: () {
              Get.bottomSheet(
                ArticleDetailDraggableSheet(article: article),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useRootNavigator: false,
                enableDrag: true,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildEventCard(context, article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Article article) {
    final double screenHeight = MediaQuery.of(Get.context!).size.height;
    final double carouselHeight = screenHeight * 0.4; // 40% of screen height
    final double imageHeight = carouselHeight * 0.70; // 70% of carousel height for image
    
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: DesignConstants.get32Radius(context),
            cornerSmoothing: 1.0,
          ),
        ),
        shadows: DesignConstants.standardShadow,
      ),                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                        cornerRadius: DesignConstants.get32Radius(context),
                        cornerSmoothing: 1.0,
                      ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: imageHeight, // Dynamic height based on screen size
                  padding: const EdgeInsets.only(top: 17.0, bottom: 0.0),
                  child: Image.asset(
                    'assets/images/flexes_icon.png', // Always use flexes icon regardless of content type
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black.withOpacity(0.05),
                        child: Center(
                          child: Icon(
                            Icons.event,
                            size: 48,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -1),
                  child: Container(
                    height: carouselHeight - imageHeight, // Use remaining height
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(article.title, style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.black.withOpacity(0.5)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                article.subtitle,
                                style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.more_horiz, size: 20, color: Colors.black.withOpacity(0.5)),
                          ],
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(HomeCarouselController carouselController) {
    final events = carouselController.getCarouselAsArticles();
    if (events.isEmpty || events.length == 1) {
      return const SizedBox.shrink(); // Don't show indicator if no events or single event
    }
    
    // Use the controller's currentPageIndex directly, normalizing it to the actual item count
    return Obx(() {
      final currentIndex = controller.currentPageIndex.value % events.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(events.length, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentIndex == index ? const Color(0xFF333333) : Colors.black.withOpacity(0.2),
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
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
      onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: DesignConstants.get24Radius(context),
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: DesignConstants.standardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
