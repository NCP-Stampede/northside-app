// lib/presentation/home_screen_content/home_screen_content.dart

import 'dart:ui'; // Needed for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import '../../widgets/liquid_mesh_background.dart';
import '../../widgets/liquid_melting_header.dart';

class HomeScreenContent extends GetView<HomeScreenContentController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeCarouselController homeCarouselController = Get.find<HomeCarouselController>();
    
    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LiquidMeltingHeader(
                  title: 'Home',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildQuickActions(),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                    Obx(() => _buildEventsCarousel(context, homeCarouselController)),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Obx(() => _buildPageIndicator(homeCarouselController)),
                  ]),
                ),
              ),
            ],
          ),
        ],
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
          _QuickActionButton(iconWidget: const Icon(CupertinoIcons.sportscourt, color: Color(0xFFFF8A65), size: 26), label: 'Athletics', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(1); }),
          _QuickActionButton(iconWidget: const Icon(CupertinoIcons.calendar, color: Color(0xFFBA68C8), size: 26), label: 'Events', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(2); }),
          _QuickActionButton(iconWidget: const Icon(CupertinoIcons.doc_text, color: Color(0xFF64B5F6), size: 26), label: 'HoofBeat', onTap: () { HapticFeedbackHelper.buttonPress(); Get.to(() => const HoofBeatPage()); }),
          _QuickActionButton(iconWidget: const Icon(CupertinoIcons.bell, color: Color(0xFF81C784), size: 26), label: 'Bulletin', onTap: () { HapticFeedbackHelper.buttonPress(); appShellController.changePage(3); }),
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
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                    cornerRadius: 32,
                    cornerSmoothing: 1.0,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.12),
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 32,
                            cornerSmoothing: 1.0,
                          ),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.speaker_2, size: 48, color: Colors.white.withOpacity(0.7)),
                    SizedBox(height: 16),
                    Text(
                      'No Recent Announcements',
                      style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Check back later for updates!',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ),
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
    
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: DesignConstants.get32Radius(context),
        cornerSmoothing: 1.0,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.12),
              ],
            ),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: DesignConstants.get32Radius(context),
                cornerSmoothing: 1.0,
              ),
              side: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
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
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            CupertinoIcons.calendar,
                            size: 48,
                            color: Colors.white.withOpacity(0.5),
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
                          Text(article.title, style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(CupertinoIcons.calendar, size: 16, color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                article.subtitle,
                                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(CupertinoIcons.ellipsis, size: 20, color: Colors.white.withOpacity(0.7)),
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
              color: currentIndex == index ? Colors.white : Colors.white.withOpacity(0.3),
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
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 28,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.12),
                ],
              ),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 28,
                  cornerSmoothing: 1.0,
                ),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: MediaQuery.of(context).size.width * 0.045, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
