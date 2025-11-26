// lib/presentation/placeholder_pages/athletics_page.dart

import 'dart:ui'; // Needed for BackdropFilter
import 'package:flutter/material.dart';
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

class AthleticsPage extends StatelessWidget {
  const AthleticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AthleticsController athleticsController = Get.put(AthleticsController());
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB22222), // Dark maroon
                  Color(0xFFB22222), // Light maroon
                  Color(0xFFD4A5A5), // Very light maroon transition
                  Color(0xFFE8D0D0), // Even lighter maroon
                  Color(0xFFF2F2F7)  // Same as events page background
                ],
                stops: [0.0, 0.15, 0.3, 0.4, 0.5],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Obx(() {
            if (athleticsController.isLoading.value) {
              return const LoadingIndicator(
                message: 'Loading athletics data...',
                showBackground: false,
              );
            }
            
            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + (screenWidth * 0.12) + (screenHeight * 0.05),
                    bottom: screenHeight * 0.12
                  ),
                  children: [
                    _buildNewsCarousel(context, athleticsController),
                    SizedBox(height: screenHeight * 0.04),
                    _buildSectionHeader(context, 'Sports', () => Get.to(() => const AllSportsPage())),
                    SizedBox(height: screenHeight * 0.025),
                    _buildSportsGrid(context, athleticsController),
                    SizedBox(height: screenHeight * 0.015),
                    _buildRegisterButton(context),
                  ],
                ),
                _buildHeader(context),
              ],
            );
          }),
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
                        'Athletics',
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
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.045),
          decoration: ShapeDecoration(
            color: Colors.white,              shape: SmoothRectangleBorder(
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
              Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: screenWidth * 0.06),
              SizedBox(width: screenWidth * 0.02),
              Text(
                'Register for a sport',
                style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: DesignConstants.get32Radius(context),
                  cornerSmoothing: 1.0,
                ),
              ),
              shadows: DesignConstants.standardShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_outlined, size: 48, color: Colors.black.withOpacity(0.5)),
                SizedBox(height: 16),
                Text(
                  'No Recent Athletics News',
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
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 1.0,
              ),
            ),
            shadows: DesignConstants.standardShadow,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.sports_outlined, size: 48, color: Colors.black.withOpacity(0.5)),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  'No Sports This Season',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Check back later for updates!',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
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
            style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
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
                Icon(Icons.arrow_forward_ios, size: screenWidth * 0.03, color: AppColors.primaryBlue),
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
        
        return Container(
          margin: EdgeInsets.only(right: screenWidth * 0.04),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: cardRadius,
                cornerSmoothing: 1.0,
              ),
            ),
            shadows: DesignConstants.standardShadow,
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
                    padding: EdgeInsets.only(top: cardHeight * 0.06, bottom: 0.0), // Same ratio as home carousel
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
                                  return const Icon(Icons.sports_basketball, size: 48, color: Colors.grey);
                                },
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/flexes_icon.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.sports_basketball, size: 48, color: Colors.grey);
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
                        style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
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
                              style: GoogleFonts.inter(fontSize: fontSizeSubtitle, color: Colors.black),
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
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: borderRadius,
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: DesignConstants.standardShadow,
        ),
        child: Center(
          child: Text(
            name,
            style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
