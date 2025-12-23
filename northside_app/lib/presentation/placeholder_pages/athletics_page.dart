// lib/presentation/placeholder_pages/athletics_page.dart

import 'dart:ui'; // Needed for BackdropFilter
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/article.dart';
import '../../models/sport_data.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../athletics/all_sports_page.dart';
import '../athletics/sport_detail_page.dart';
import '../../widgets/shared_header.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/utils/app_colors.dart';
import '../../controllers/athletics_controller.dart';
import '../../core/utils/logger.dart';
import '../../core/design_constants.dart';
import '../../controllers/settings_controller.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../widgets/liquid_mesh_background.dart';
import '../../widgets/liquid_melting_header.dart';

class AthleticsPage extends StatelessWidget {
  const AthleticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AthleticsController athleticsController = Get.put(AthleticsController());
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          Obx(() {
            if (athleticsController.isLoading.value) {
              return const LoadingIndicator(
                message: 'Loading athletics data...',
                showBackground: false,
              );
            }
            
            return CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: LiquidMeltingHeader(title: 'Athletics'),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.12),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildNewsCarousel(context, athleticsController),
                      SizedBox(height: screenHeight * 0.04),
                      _buildSectionHeader(context, 'Sports', () => Get.to(() => const AllSportsPage())),
                      SizedBox(height: screenHeight * 0.025),
                      _buildSportsGrid(context, athleticsController),
                      SizedBox(height: screenHeight * 0.015),
                      _buildRegisterButton(context),
                    ]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    const String registrationUrl = 'https://ncp-ar.rschooltoday.com/oar';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: GestureDetector(
        onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
        onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
        onTap: () async {
          try {
            final uri = Uri.parse(registrationUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              AppLogger.warning('Could not launch URL: $registrationUrl');
              Get.snackbar(
                'Error',
                'Unable to open registration link',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
          } catch (e) {
            AppLogger.error('Error launching registration URL', e);
            Get.snackbar(
              'Error',
              'Error opening registration link',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            );
          }
        },
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: DesignConstants.get24Radius(context),
            cornerSmoothing: 1.0,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
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
                    cornerRadius: DesignConstants.get24Radius(context),
                    cornerSmoothing: 1.0,
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.add_circled, color: AppColors.primaryBlue, size: screenWidth * 0.06),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Register for a sport',
                    style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCarousel(BuildContext context, AthleticsController athleticsController) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar devices
    // Adjust card height for smaller screens
    final double cardHeight = isNarrowScreen ? screenWidth * 0.65 : screenWidth * 0.7;
    
    // Get real athletics news from the controller
    final athleticsNews = athleticsController.getAthleticsNews();
    
    // If no real data, show empty state message instead of fallback articles
    if (athleticsNews.isEmpty) {
      return SizedBox(
        height: cardHeight,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: DesignConstants.get32Radius(context),
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
                        cornerRadius: DesignConstants.get32Radius(context),
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
                      Icon(CupertinoIcons.sportscourt, size: 48, color: Colors.white.withOpacity(0.7)),
                      SizedBox(height: 16),
                      Text(
                        'No Recent Athletics News',
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
    
    return SizedBox(
      height: cardHeight,
      child: PageView.builder(
        controller: PageController(
          viewportFraction: isNarrowScreen ? 0.8 : 0.85, // Reduce card width on smaller screens
        ),
        clipBehavior: Clip.none,
        itemCount: athleticsNews.length,
        itemBuilder: (context, index) {
          final article = athleticsNews[index];
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
            child: _NewsCard(article: article),
          );
        },
      ),
    );
  }

  Widget _buildSportsGrid(BuildContext context, AthleticsController athleticsController) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double crossAxisSpacing = screenWidth * 0.04;
    final double mainAxisSpacing = screenWidth * 0.04;
    final double childAspectRatio = 2.5;
    
    // Get user's favorite sports or fallback to default
    List<SportEntry> topSports;
    try {
      final settingsController = Get.find<SettingsController>();
      topSports = SportsData.getFavoriteSports(settingsController.getFavoriteSports());
    } catch (e) {
      // Fallback to default sports
      topSports = SportsData.getTopSportsForCurrentSeason();
    }
    
    print('=== DEBUG: Current season: ${SportsData.getCurrentSeason()}');
    print('=== DEBUG: Top sports for current season: ${topSports.map((s) => '${s.sport} (${s.gender})').toList()}');
    
    if (topSports.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 1.0,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
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
                    cornerRadius: 16,
                    cornerSmoothing: 1.0,
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.sportscourt, size: 48, color: Colors.white.withOpacity(0.7)),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      'No Sports This Season',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      'Check back later for updates!',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return Transform.translate(
      offset: Offset(0, -screenHeight * 0.01), // Pull cards closer to header
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: topSports.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final sport = topSports[index];
            final displayName = SportsData.getDisplaySportName(sport.sport);
            
            return _SportButton(
              name: displayName,
              onTap: () => Get.to(() => SportDetailPage(
                sportName: displayName,
                gender: sport.gender,
                season: sport.season,
              )),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
            onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(fontSize: screenWidth * 0.04, color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
                ),
                SizedBox(width: screenWidth * 0.01),
                Icon(CupertinoIcons.chevron_right, size: screenWidth * 0.04, color: AppColors.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar devices
    final double cardRadius = DesignConstants.get32Radius(context);
    final double fontSizeTitle = isNarrowScreen ? screenWidth * 0.042 : screenWidth * 0.045;
    final double fontSizeSubtitle = isNarrowScreen ? screenWidth * 0.032 : screenWidth * 0.035;
    final double cardPadding = isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardHeight = constraints.maxHeight;
        // More text space for narrow screens
        final double imageHeight = isNarrowScreen ? cardHeight * 0.55 : cardHeight * 0.58;
        
        return ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: cardRadius,
            cornerSmoothing: 1.0,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              margin: EdgeInsets.only(right: screenWidth * 0.04),
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
                    cornerRadius: cardRadius,
                    cornerSmoothing: 1.0,
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: cardRadius, cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: cardRadius, cornerSmoothing: 1.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.only(top: cardHeight * 0.06, bottom: 0.0),
                        child: Center(
                          child: article.imagePath != null 
                            ? Image.asset(
                                article.imagePath!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/flexes_icon.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(CupertinoIcons.sportscourt, size: 48, color: Colors.white70);
                                    },
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/flexes_icon.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(CupertinoIcons.sportscourt, size: 48, color: Colors.white70);
                                },
                              ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            article.title,
                            style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: isNarrowScreen ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  article.subtitle,
                                  style: GoogleFonts.inter(fontSize: fontSizeSubtitle, color: Colors.white.withOpacity(0.7)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                          // Sports badge in bottom-right of description
                          if (_extractSportFromTitle(article.title) != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF007AFF),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 12,
                                    cornerSmoothing: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                _extractSportFromTitle(article.title)!,
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
      },
    );
  }

  // Helper method to extract sport name from article title
  String? _extractSportFromTitle(String title) {
    final sports = [
      'Basketball', 'Soccer', 'Football', 'Baseball', 'Tennis', 'Golf',
      'Swimming', 'Track', 'Wrestling', 'Volleyball', 'Cross Country',
      'Water Polo', 'Bowling'
    ];
    
    final lowerTitle = title.toLowerCase();
    for (final sport in sports) {
      if (lowerTitle.contains(sport.toLowerCase())) {
        return sport;
      }
    }
    
    // Check for variations
    if (lowerTitle.contains('track and field') || lowerTitle.contains('track & field')) {
      return 'Track & Field';
    }
    
    return null;
  }
}

class _SportButton extends StatelessWidget {
  const _SportButton({required this.name, required this.onTap});
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    final double borderRadius = DesignConstants.get24Radius(context);
    final double verticalPadding = screenWidth * 0.04;
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
      onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
      onTap: onTap,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: borderRadius,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
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
                  cornerRadius: borderRadius,
                  cornerSmoothing: 1.0,
                ),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                name,
                style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
