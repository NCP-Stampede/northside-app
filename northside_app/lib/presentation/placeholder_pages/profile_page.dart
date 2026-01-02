// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Needed for BackdropFilter

import '../../core/design_constants.dart';
import '../../core/utils/app_colors.dart';
import '../../controllers/settings_controller.dart';

import '../../models/article.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/login_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../core/utils/calendar_service.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../widgets/liquid_mesh_background.dart';
import '../../widgets/liquid_melting_header.dart';

// Data Model with different action types
enum ProfileActionType { info, link, login, toggle, action }

class ProfileOption {
  const ProfileOption({
    required this.title,
    required this.subtitle,
    required this.actionType,
    this.url,
    this.toggleKey,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final ProfileActionType actionType;
  final String? url;
  final String? toggleKey;
  final VoidCallback? onTap;
}

// Add this at the top-level, after imports and before ProfilePage
const Article appInfoArticle = Article(
  title: 'App Info',
  subtitle: 'Version, credits, and more',
    content: '''
Stampede: Northside App
Version 1.0.0
  
Developed by the Sarveshwaraan Swaminathan ('26) & Tanmay Garg ('26).
  
Special thanks to all contributors, the school community, Claude, and Gemini.
  
Contact us:
- Email: stampede.ncp@gmail.com
- Github: https://github.com/CODERTG2/northside-app
- Instagram: @ncpstampede

If you encounter any bugs or would like to suggest anything please do so on this [Google Form](https://forms.gle/sQKcGmnXk2KFjkC79) or on [Github](https://github.com/CODERTG2/northside-app).'''
);

Future<void> _launchInExternalBrowser(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppLogger.warning('Could not launch URL: $url');
      Get.snackbar(
        'Error',
        'Unable to open link in external browser',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  } catch (e) {
    AppLogger.error('Error launching URL in external browser', e);
    Get.snackbar(
      'Error',
      'Error opening link in external browser',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LiquidMeltingHeader(
                  title: 'Settings',
                  topPadding: MediaQuery.of(context).padding.top,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.057,
                  right: screenWidth * 0.057,
                  top: screenWidth * 0.04,
                  bottom: screenHeight * 0.15,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                  // App Settings Section
                  _buildSectionHeader(context, 'App Settings'),
              Obx(() => _buildToggleCard(
                context: context,
                title: 'Haptic Feedback',
                subtitle: 'Feel vibrations for interactions',
                value: settingsController.hapticFeedback.value,
                onToggle: settingsController.toggleHapticFeedback,
              )),
              Obx(() => _buildToggleCard(
                context: context,
                title: 'Calendar Sync',
                subtitle: 'Sync events to your calendar',
                value: settingsController.calendarSync.value,
                onToggle: settingsController.toggleCalendarSync,
              )),
              // Show sync all events button only if calendar sync is enabled
              Obx(() => AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                sizeCurve: Curves.easeInOut,
                firstCurve: Curves.easeInOut,
                secondCurve: Curves.easeInOut,
                crossFadeState: settingsController.calendarSync.value 
                  ? CrossFadeState.showFirst 
                  : CrossFadeState.showSecond,
                firstChild: _buildActionCard(
                  context: context,
                  title: 'Sync All Events',
                  subtitle: 'Add all upcoming events to your calendar',
                  onTap: () => _syncAllEventsToCalendar(context),
                ),
                secondChild: const SizedBox(width: double.infinity),
              )),
              Obx(() => _buildToggleCard(
                context: context,
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                value: settingsController.pushNotifications.value,
                onToggle: settingsController.togglePushNotifications,
              )),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Sports Customization Section
              _buildSectionHeader(context, 'Athletics Page'),
              _buildActionCard(
                context: context,
                title: 'Favorite Sports',
                subtitle: 'Choose your 4 favorite sports for main display',
                onTap: () => _showSportsCustomization(context, settingsController),
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Account & Info Section
              _buildSectionHeader(context, 'Account & Info'),
              _buildActionCard(
                context: context,
                title: 'Events & Announcement Submissions',
                subtitle: 'Submit events and announcements',
                onTap: () => _launchInExternalBrowser('https://forms.gle/Ff6RoPK9WqQhBEyu9'),
              ),
              _buildActionCard(
                context: context,
                title: 'Your Athletic Account',
                subtitle: 'Login with your athletic account',
                onTap: () => _launchInExternalBrowser('https://ncp-ar.rschooltoday.com/oar'),
              ),
              _buildActionCard(
                context: context,
                title: 'App Info',
                subtitle: 'Version, credits, and more',
                onTap: () {
                  Get.bottomSheet(
                    ArticleDetailDraggableSheet(article: appInfoArticle),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    useRootNavigator: false,
                    enableDrag: true,
                  );
                },
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Reset Settings Button
              _buildActionCard(
                context: context,
                title: 'Reset Settings',
                subtitle: 'Reset all settings to defaults',
                onTap: () => _showResetDialog(context, settingsController),
                isDestructive: true,
              ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildSectionHeader(BuildContext context, String title) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.042;
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02, left: screenWidth * 0.02),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required bool value,
    required VoidCallback onToggle,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.045;
    final double subtitleFontSize = screenWidth * 0.037;
    
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: DesignConstants.get24Radius(context),
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
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
                side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.inter(fontSize: titleFontSize, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: screenWidth * 0.01),
                      Text(subtitle, style: GoogleFonts.inter(fontSize: subtitleFontSize, color: Colors.white.withOpacity(0.7))),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.primaryBlue,
                  activeTrackColor: AppColors.primaryBlue.withOpacity(0.5),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double titleFontSize = screenWidth * 0.045;
    final double subtitleFontSize = screenWidth * 0.037;
    
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
      onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: screenWidth * 0.03),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: DesignConstants.get24Radius(context),
            cornerSmoothing: 1.0,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
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
                  side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title, 
                          style: GoogleFonts.inter(
                            fontSize: titleFontSize, 
                            fontWeight: FontWeight.bold,
                            color: isDestructive ? Colors.red.shade300 : Colors.white,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.015),
                        Text(subtitle, style: GoogleFonts.inter(fontSize: subtitleFontSize, color: Colors.white.withOpacity(0.7))),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: AppColors.primaryBlue,
                    size: screenWidth * 0.06,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSportsCustomization(BuildContext context, SettingsController controller) {
    Get.bottomSheet(
      _SportsCustomizationSheet(controller: controller),
      isScrollControlled: true,
      settings: RouteSettings(name: 'SportsCustomization'),
    );
  }

  void _showEventFilters(BuildContext context, SettingsController controller) {
    Get.bottomSheet(
      _EventFiltersSheet(controller: controller),
      isScrollControlled: true,
      settings: RouteSettings(name: 'EventFilters'),
    );
  }

  void _showResetDialog(BuildContext context, SettingsController controller) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    Get.dialog(
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
          child: ClipSmoothRect(
            radius: SmoothBorderRadius(
              cornerRadius: DesignConstants.get20Radius(context),
              cornerSmoothing: 1.0,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.057),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.18),
                    ],
                  ),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: DesignConstants.get20Radius(context),
                      cornerSmoothing: 1.0,
                    ),
                    side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_counterclockwise,
                      size: MediaQuery.of(context).size.width * 0.143,
                      color: Colors.white,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.048),
                    Text(
                      'Reset Settings',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.057,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.029),
                    Text(
                      'Are you sure you want to reset all settings to their default values?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.038,
                        color: Colors.white.withOpacity(0.8),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.057),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedbackHelper.buttonPress();
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.029),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 8,
                                    cornerSmoothing: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.038,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.029),
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedbackHelper.buttonPress();
                                controller.resetToDefaults();
                                Get.back();
                                Get.snackbar(
                                  'Settings Reset',
                                  'All settings have been reset to defaults',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: Duration(seconds: 2),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.029),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 8,
                                    cornerSmoothing: 1.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.038,
                                  fontWeight: FontWeight.w600,
                                ),
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
          ),
        ),
      ),
    );
  }

  Future<void> _syncAllEventsToCalendar(BuildContext context) async {
    HapticFeedbackHelper.buttonPress();
    
    try {
      // Show loading dialog
      final double screenWidth = MediaQuery.of(context).size.width;
      
      Get.dialog(
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: ShapeDecoration(
              color: const Color(0xFFF2F2F7),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: DesignConstants.get24Radius(context),
                  cornerSmoothing: 1.0,
                ),
              ),
              shadows: DesignConstants.standardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Syncing Events',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, 
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(radius: screenWidth * 0.03),
                    SizedBox(width: 16),
                    Text(
                      'Adding events to calendar...',
                      style: GoogleFonts.inter(fontSize: screenWidth * 0.04),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Request calendar permissions first
      final hasPermission = await CalendarService.requestPermissions();
      if (!hasPermission) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Permission Denied',
          'Calendar access is required to sync events',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Create example events (replace with real data from your controllers)
      final List<Event> events = [
        Event(
          title: 'Football vs. Rival School',
          description: 'Home game against our biggest rivals',
          location: 'Northside Stadium',
          startDate: DateTime.now().add(Duration(days: 7)),
          endDate: DateTime.now().add(Duration(days: 7, hours: 3)),
        ),
        Event(
          title: 'Basketball Tournament',
          description: 'Regional basketball championship',
          location: 'School Gymnasium',
          startDate: DateTime.now().add(Duration(days: 14)),
          endDate: DateTime.now().add(Duration(days: 14, hours: 4)),
        ),
        Event(
          title: 'School Dance',
          description: 'Annual winter formal dance',
          location: 'School Cafeteria',
          startDate: DateTime.now().add(Duration(days: 21)),
          endDate: DateTime.now().add(Duration(days: 21, hours: 4)),
        ),
      ];

      // Sync all events
      await CalendarService.syncAllEventsToCalendar(events);

      Get.back(); // Close loading dialog
      Get.snackbar(
        'Success',
        '${events.length} events added to your calendar',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to sync events: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }
}

// Sports Customization Draggable Sheet
class _SportsCustomizationSheet extends StatefulWidget {
  final SettingsController controller;
  
  const _SportsCustomizationSheet({required this.controller});

  @override
  State<_SportsCustomizationSheet> createState() => _SportsCustomizationSheetState();
}

class _SportsCustomizationSheetState extends State<_SportsCustomizationSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final List<String> availableSports = [
    'Basketball', 'Soccer', 'Outdoor Track', 'Indoor Track', 'Swimming', 'Tennis', 
    'Volleyball', 'Baseball', 'Cross Country', 'Golf', 'Wrestling',
    'Football', 'Water Polo', 'Bowling'
  ];
  
  late List<String> tempFavorites;

  @override
  void initState() {
    super.initState();
    tempFavorites = List<String>.from(widget.controller.favoriteSports);
    
    // Create animation controller with iOS-style duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create iOS-style animation
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    // Start the animation when the sheet is created
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    final double initialChildSize = isNarrowScreen ? 0.85 : 0.9;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.85 : 0.9;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: minChildSize,
              maxChildSize: maxChildSize,
              expand: false,
              builder: (context, scrollController) {
                return ClipSmoothRect(
                  radius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                    topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.18),
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                            topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                            topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                          ),
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Scrollable list (now full height, content scrolls under header)
                          Positioned.fill(
                            child: ListView.builder(
                              controller: scrollController,
                              padding: EdgeInsets.only(
                                top: screenWidth * 0.28, // Space for header
                                bottom: 40,
                                left: screenWidth * 0.02,
                                right: screenWidth * 0.02,
                              ),
                              itemCount: availableSports.length,
                              itemBuilder: (context, index) {
                                final sport = availableSports[index];
                                final isSelected = tempFavorites.contains(sport);
                                final canSelect = tempFavorites.length < 4 || isSelected;
                                
                                return CupertinoListTile(
                                  title: Text(sport, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                                  trailing: Transform.scale(
                                    scale: 1.2,
                                    child: CupertinoCheckbox(
                                      value: isSelected,
                                      onChanged: canSelect ? (bool? value) {
                                        setState(() {
                                          if (value == true && tempFavorites.length < 4) {
                                            tempFavorites.add(sport);
                                          } else if (value == false) {
                                            tempFavorites.remove(sport);
                                          }
                                        });
                                        // Auto-save when exactly 4 sports are selected
                                        if (tempFavorites.length == 4) {
                                          widget.controller.updateFavoriteSports(tempFavorites);
                                        }
                                      } : null,
                                      activeColor: AppColors.primaryBlue,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Melting header overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.7, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                                  child: Container(
                                    height: screenWidth * 0.32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF030308).withOpacity(1.0),
                                          const Color(0xFF030308).withOpacity(0.85),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Header content (on top of blur)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  // Drag handle
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    width: 40,
                                    height: 5,
                                    decoration: ShapeDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: DesignConstants.get10Radius(context),
                                          cornerSmoothing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Choose Your Favorite Sports',
                                          style: GoogleFonts.inter(
                                            fontSize: screenWidth * 0.055,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Select exactly 4 sports to display on the Athletics page',
                                          style: GoogleFonts.inter(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
          ),
        );
      },
    );
  }
}

// Event Filters Draggable Sheet
class _EventFiltersSheet extends StatefulWidget {
  final SettingsController controller;
  
  const _EventFiltersSheet({required this.controller});

  @override
  State<_EventFiltersSheet> createState() => _EventFiltersSheetState();
}

class _EventFiltersSheetState extends State<_EventFiltersSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  final List<String> eventTypes = [
    'Academic Events',
    'Sports Events', 
    'Social Events',
    'Club Activities',
    'Performances',
    'Meetings',
    'Workshops',
    'Field Trips',
  ];

  @override
  void initState() {
    super.initState();
    
    // Create animation controller with iOS-style duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create iOS-style animation
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    // Start the animation when the sheet is created
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    final double initialChildSize = isNarrowScreen ? 0.75 : 0.8;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.75 : 0.8;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: minChildSize,
              maxChildSize: maxChildSize,
              expand: false,
              builder: (context, scrollController) {
                return ClipSmoothRect(
                  radius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                    topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.18),
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                            topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                            topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                          ),
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Scrollable list (now full height, content scrolls under header)
                          Positioned.fill(
                            child: GetBuilder<SettingsController>(
                              builder: (controller) => ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.only(
                                  top: screenWidth * 0.28, // Space for header
                                  bottom: 40,
                                  left: screenWidth * 0.02,
                                  right: screenWidth * 0.02,
                                ),
                                itemCount: eventTypes.length,
                                itemBuilder: (context, index) {
                                  final eventType = eventTypes[index];
                                  final isVisible = controller.isEventTypeVisible(eventType);
                                  
                                  return CupertinoListTile(
                                    title: Text(eventType, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                                    trailing: Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        value: isVisible,
                                        onChanged: (_) {
                                          HapticFeedbackHelper.selectionClick();
                                          controller.toggleEventTypeVisibility(eventType);
                                        },
                                        activeColor: AppColors.primaryBlue,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Melting header overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.7, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                                  child: Container(
                                    height: screenWidth * 0.32,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF030308).withOpacity(1.0),
                                          const Color(0xFF030308).withOpacity(0.85),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Header content (on top of blur)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.only(top: 12),
                              child: Column(
                                children: [
                                  // Drag handle
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    width: 40,
                                    height: 5,
                                    decoration: ShapeDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: DesignConstants.get10Radius(context),
                                          cornerSmoothing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Event Filters',
                                          style: GoogleFonts.inter(
                                            fontSize: screenWidth * 0.055,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Toggle event categories to show or hide them in the Events page.',
                                          style: GoogleFonts.inter(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
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
            ),
          ),
        );
      },
    );
  }
}
