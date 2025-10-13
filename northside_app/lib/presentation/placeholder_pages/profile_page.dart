// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          // Background color matching bulletin page
          Container(
            color: const Color(0xFFF2F2F7),
          ),
          // Main content with exact same structure as bulletin page
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SharedHeader(title: 'Settings', showProfileIcon: false),
              SizedBox(height: screenWidth * 0.057), // Match bulletin page topSpacer
              // Settings content in scrollable area
              Expanded(
                child: Obx(() {
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06).copyWith(bottom: screenHeight * 0.12),
                    children: [
              
              // App Settings Section
              _buildSectionHeader(context, 'App Settings'),
              _buildToggleCard(
                context: context,
                title: 'Haptic Feedback',
                subtitle: 'Feel vibrations for interactions',
                value: settingsController.hapticFeedback.value,
                onToggle: settingsController.toggleHapticFeedback,
              ),
              _buildToggleCard(
                context: context,
                title: 'Calendar Sync',
                subtitle: 'Sync events to your calendar',
                value: settingsController.calendarSync.value,
                onToggle: settingsController.toggleCalendarSync,
              ),
              // Show sync all events button only if calendar sync is enabled
              Obx(() => settingsController.calendarSync.value 
                ? _buildActionCard(
                    context: context,
                    title: 'Sync All Events',
                    subtitle: 'Add all upcoming events to your calendar',
                    onTap: () => _syncAllEventsToCalendar(context),
                  )
                : const SizedBox.shrink()),
              _buildToggleCard(
                context: context,
                title: 'Push Notifications',
                subtitle: 'Receive app notifications',
                value: settingsController.pushNotifications.value,
                onToggle: settingsController.togglePushNotifications,
              ),
              
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
              
              // Event Filtering Section
              _buildSectionHeader(context, 'Event Filters'),
              _buildActionCard(
                context: context,
                title: 'Event Categories',
                subtitle: 'Filter events by type',
                onTap: () => _showEventFilters(context, settingsController),
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
                    ],
                  );
                }),
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
          color: Colors.black87,
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
    
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: titleFontSize, fontWeight: FontWeight.bold)),
                SizedBox(height: screenWidth * 0.01),
                Text(subtitle, style: GoogleFonts.inter(fontSize: subtitleFontSize, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (_) => onToggle(),
            activeColor: AppColors.primaryBlue,
          ),
        ],
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
      child: Container(
        margin: EdgeInsets.only(bottom: screenWidth * 0.03),
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
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
                      color: isDestructive ? Colors.red : Colors.black,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: subtitleFontSize, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: screenWidth * 0.06,
            ),
          ],
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
                'Reset Settings',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'Are you sure you want to reset all settings to their default values?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () { 
                        HapticFeedbackHelper.buttonPress(); 
                        Get.back(); 
                      },
                      child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.primaryBlue)),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: CupertinoButton.filled(
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
                      child: Text('Reset', style: GoogleFonts.inter(color: CupertinoColors.white)),
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
    'Basketball', 'Soccer', 'Track and Field', 'Swimming', 'Tennis', 
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
                return Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF2F2F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                      ),
                    ),
                    shadows: DesignConstants.standardShadow,
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 5,
                        decoration: ShapeDecoration(
                          color: Colors.grey.shade300,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: DesignConstants.get10Radius(context),
                              cornerSmoothing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose Your Favorite Sports',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              Text(
                                'Select exactly 4 sports to display on the Athletics page',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.06),
                              Expanded(
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount: availableSports.length,
                                  itemBuilder: (context, index) {
                                    final sport = availableSports[index];
                                    final isSelected = tempFavorites.contains(sport);
                                    final canSelect = tempFavorites.length < 4 || isSelected;
                                    
                                    return CupertinoListTile(
                                      title: Text(sport, style: GoogleFonts.inter()),
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
                                          } : null,
                                          activeColor: AppColors.primaryBlue,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.04),
                              Text(
                                '${tempFavorites.length}/4 sports selected',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.04,
                                  color: tempFavorites.length == 4 ? Colors.green : Colors.grey.shade600,
                                  fontWeight: tempFavorites.length == 4 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.04),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: tempFavorites.length == 4 ? () {
                                    HapticFeedbackHelper.buttonPress();
                                    widget.controller.updateFavoriteSports(tempFavorites);
                                    Get.back();
                                    Get.snackbar(
                                      'Sports Updated',
                                      'Your favorite sports have been saved',
                                      snackPosition: SnackPosition.BOTTOM,
                                      duration: Duration(seconds: 2),
                                    );
                                  } : null,
                                  child: Text('Save Selection', style: GoogleFonts.inter(color: CupertinoColors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                return Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF2F2F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                      ),
                    ),
                    shadows: DesignConstants.standardShadow,
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 5,
                        decoration: ShapeDecoration(
                          color: Colors.grey.shade300,
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: DesignConstants.get10Radius(context),
                              cornerSmoothing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Event Filters',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.02),
                              Text(
                                'Toggle event categories to show or hide them in the Events page. This helps you customize which types of events appear in your feed.',
                                style: GoogleFonts.inter(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.06),
                              Expanded(
                                child: GetBuilder<SettingsController>(
                                  builder: (controller) => ListView.builder(
                                    controller: scrollController,
                                    itemCount: eventTypes.length,
                                    itemBuilder: (context, index) {
                                      final eventType = eventTypes[index];
                                      final isVisible = controller.isEventTypeVisible(eventType);
                                      
                                      return CupertinoListTile(
                                        title: Text(eventType, style: GoogleFonts.inter()),
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
                              SizedBox(height: screenWidth * 0.04),
                              SizedBox(
                                width: double.infinity,
                                child: CupertinoButton.filled(
                                  onPressed: () { 
                                    HapticFeedbackHelper.buttonPress(); 
                                    Get.back(); 
                                  },
                                  child: Text('Done', style: GoogleFonts.inter(color: CupertinoColors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
