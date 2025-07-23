// lib/presentation/placeholder_pages/athletics_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hs_app_toolkit/models/article.dart';
import 'package:hs_app_toolkit/models/sport_data.dart';
import 'package:frontend_package/widgets/article_detail_draggable_sheet.dart';
import '../athletics/all_sports_page.dart';
import '../athletics/sport_detail_page.dart';
import 'package:frontend_package/widgets/shared_header.dart';
import 'package:frontend_package/core/utils/app_colors.dart';
import 'package:hs_app_toolkit/controllers/athletics_controller.dart';
import '../../core/utils/logger.dart';
import 'package:frontend_package/core/utils/design_constants.dart';

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
              return const Center(child: CircularProgressIndicator());
            }
            
            return ListView(
              padding: EdgeInsets.only(bottom: screenHeight * 0.12),
              children: [
                const SharedHeader(title: 'Athletics'),
                SizedBox(height: screenHeight * 0.02),
                _buildNewsCarousel(context, athleticsController),
                SizedBox(height: screenHeight * 0.04),
                _buildSectionHeader(context, 'Sports', () => Get.to(() => const AllSportsPage())),
                _buildSportsGrid(context, athleticsController),
                SizedBox(height: screenHeight * 0.015),
                _buildRegisterButton(context),
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
              color: Colors.white.withOpacity(0.9),                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: DesignConstants.get32Radius(context),
                    cornerSmoothing: 1.0,
                  ),
                ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 60,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Recent Athletics News',
                  style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for updates!',
                  style: TextStyle(color: Colors.grey),
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
    
    // Get top 4 sports for current season (2 girls, 2 boys)
    final topSports = SportsData.getTopSportsForCurrentSeason();
    
    print('=== DEBUG: Current season: ${SportsData.getCurrentSeason()}');
    print('=== DEBUG: Top sports for current season: ${topSports.map((s) => '${s.sport} (${s.gender})').toList()}');
    
    if (topSports.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.06),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.sports_outlined, size: 48, color: Colors.grey),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  'No Sports This Season',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  'Check back later for updates!',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade500,
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
                      Text(
                        article.subtitle,
                        style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
