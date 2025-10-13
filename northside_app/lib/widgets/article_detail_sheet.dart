// lib/widgets/article_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_constants.dart';
import '../core/utils/calendar_service.dart';
import '../controllers/settings_controller.dart';
import '../models/article.dart';

class ArticleDetailSheet extends StatelessWidget {
  const ArticleDetailSheet({super.key, required this.article, this.scrollController});
  final ScrollController? scrollController;
  final Article article;

  // Helper method to parse simple markdown links [text](url)
  Widget _buildContentWithLinks(String content) {
    final linkRegex = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
    final matches = linkRegex.allMatches(content);
    
    if (matches.isEmpty) {
      // No links found, return plain text
      return Text(
        content,
        style: const TextStyle(fontSize: 16, height: 1.5),
      );
    }
    
    List<TextSpan> spans = [];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before the link
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
        ));
      }
      
      // Add the link
      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;
      
      spans.add(TextSpan(
        text: linkText,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            try {
              final uri = Uri.parse(linkUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar(
                  'Error',
                  'Unable to open link in external browser',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              }
            } catch (e) {
              Get.snackbar(
                'Error',
                'Error opening link',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
          },
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text after the last link
    if (lastEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastEnd),
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This container gives the sheet its shape and background color.
    return Container(
      decoration: ShapeDecoration(
        color: const Color(0xFFF2F2F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
            topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
          ),
        ),
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
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Display article image with fallback
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: ClipSmoothRect(
                    radius: SmoothBorderRadius(
                      cornerRadius: DesignConstants.get24Radius(context),
                      cornerSmoothing: 1.0,
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // Standard aspect ratio for consistency
                      child: Container(
                        width: double.infinity,
                        child: Image.asset(
                          article.imagePath ?? 'assets/images/flexes_icon.png', 
                          fit: BoxFit.contain, // Maintain aspect ratio, fit within bounds
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to flexes_icon.png if image fails to load
                            return Image.asset(
                              'assets/images/flexes_icon.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                // Title with optional sports badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_extractSportFromTitle(article.title) != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF007AFF),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 1.0,
                            ),
                          ),
                        ),
                        child: Text(
                          _extractSportFromTitle(article.title)!,
                          style: GoogleFonts.inter(
                            fontSize: MediaQuery.of(context).size.width * 0.032,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Main content with link support
                Container(
                  width: double.infinity,
                  child: _buildContentWithLinks(article.content),
                ),
                const SizedBox(height: 24),
                                  // Add to Calendar button (only show if Calendar Sync is disabled and article is an event)
                  Builder(
                    builder: (context) {
                      try {
                        // Try to find the controller, but don't crash if it's not available
                        if (Get.isRegistered<SettingsController>()) {
                          final settingsController = Get.find<SettingsController>();
                          // Only show individual calendar button if sync is disabled and this is an event
                          if (!settingsController.calendarSync.value && _isEventArticle(article)) {
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, color: Colors.white),
                          label: Text('Add to Calendar', style: GoogleFonts.inter(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF), // AppColors.primaryBlue
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final eventInfo = _parseEventInfo(article);
                            if (eventInfo != null) {
                              try {
                                await CalendarService.requestPermissions();
                                await CalendarService.addEventToCalendar(
                                  title: eventInfo['title'],
                                  description: eventInfo['description'],
                                  start: eventInfo['start'],
                                  end: eventInfo['end'],
                                  location: eventInfo['location'],
                                );
                                Get.snackbar(
                                  'Success', 
                                  'Event added to calendar', 
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error', 
                                  'Failed to add event to calendar', 
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              Get.snackbar(
                                'Error', 
                                'Event information not available', 
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                              );
                            }
                          },
                        ),
                        );
                          }
                        } else {
                          // If settings controller not available, show the button by default for events
                          if (_isEventArticle(article)) {
                            return Container(
                              margin: const EdgeInsets.only(top: 16),
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.calendar_today, color: Colors.white),
                                label: Text('Add to Calendar', style: GoogleFonts.inter(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF007AFF), // AppColors.primaryBlue
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final eventInfo = _parseEventInfo(article);
                                  if (eventInfo != null) {
                                    try {
                                      await CalendarService.requestPermissions();
                                      await CalendarService.addEventToCalendar(
                                        title: eventInfo['title'],
                                        description: eventInfo['description'],
                                        start: eventInfo['start'],
                                        end: eventInfo['end'],
                                        location: eventInfo['location'],
                                      );
                                      Get.snackbar(
                                        'Success', 
                                        'Event added to calendar', 
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    } catch (e) {
                                      Get.snackbar(
                                        'Error', 
                                        'Failed to add event to calendar', 
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      'Error', 
                                      'Event information not available', 
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                    );
                                  }
                                },
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    }),
                const SizedBox(height: 40), // Extra space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Universal event detection - show calendar for ANYTHING with date information
  bool _isEventArticle(Article article) {
    final content = '${article.title} ${article.subtitle} ${article.content}'.toLowerCase();
    
    // Comprehensive date patterns - if ANY of these match, show calendar button
    final datePatterns = [
      // Year patterns
      RegExp(r'202\d'), // Any year like 2024, 2025, etc.
      RegExp(r'\b20\d{2}\b'), // Four digit years starting with 20
      
      // Month names (full and abbreviated)
      RegExp(r'\b(january|february|march|april|may|june|july|august|september|october|november|december)\b'),
      RegExp(r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b'),
      
      // Date formats
      RegExp(r'\b\d{1,2}\/\d{1,2}\/\d{2,4}\b'), // MM/DD/YYYY or M/D/YY
      RegExp(r'\b\d{1,2}-\d{1,2}-\d{2,4}\b'), // MM-DD-YYYY or M-D-YY
      RegExp(r'\b\d{1,2}\.\d{1,2}\.\d{2,4}\b'), // MM.DD.YYYY or M.D.YY
      
      // Time formats
      RegExp(r'\b\d{1,2}:\d{2}\b'), // HH:MM or H:MM
      RegExp(r'\b\d{1,2}:\d{2}\s*(am|pm|AM|PM)\b'), // HH:MM AM/PM
      
      // Day references
      RegExp(r'\b(today|tomorrow|yesterday|tonight|this\s+weekend)\b'),
      RegExp(r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b'),
      RegExp(r'\b(mon|tue|wed|thu|fri|sat|sun)\b'),
      
      // Date-related words
      RegExp(r'\b(schedule|upcoming|date|time|when|during|at\s+\d)\b'),
      RegExp(r'\b(morning|afternoon|evening|night|noon|midnight)\b'),
      RegExp(r'\b(\d+\s*(day|week|month)s?\s*(away|from\s+now))\b'),
      
      // Ordinal dates
      RegExp(r'\b\d{1,2}(st|nd|rd|th)\b'), // 1st, 2nd, 3rd, 4th, etc.
      
      // Season references
      RegExp(r'\b(spring|summer|fall|autumn|winter)\b'),
      
      // Academic terms
      RegExp(r'\b(semester|quarter|term)\b'),
    ];
    
    // Check if ANY date pattern matches - if so, show calendar button
    for (final pattern in datePatterns) {
      if (pattern.hasMatch(content)) {
        return true;
      }
    }
    
    // Additional broad categories that likely have dates
    final broadEventIndicators = [
      'event', 'meeting', 'game', 'match', 'tournament', 'competition',
      'orientation', 'assembly', 'conference', 'workshop', 'presentation',
      'ceremony', 'dance', 'party', 'fundraiser', 'volunteer', 'activity',
      'sports', 'athletics', 'vs', 'versus', 'against', 'home', 'away',
      'practice', 'rehearsal', 'class', 'lesson', 'session', 'appointment',
      'deadline', 'due', 'registration', 'signup', 'enrollment', 'tryout',
      'audition', 'interview', 'test', 'exam', 'quiz', 'assignment',
      'project', 'performance', 'concert', 'show', 'play', 'musical',
      'trip', 'field', 'excursion', 'visit', 'tour', 'camp', 'retreat'
    ];
    
    // If content contains any broad event indicators, show calendar
    for (final indicator in broadEventIndicators) {
      if (content.contains(indicator)) {
        return true;
      }
    }
    
    // If we still haven't found a match, check subtitle for common patterns
    if (article.subtitle.toLowerCase().contains('pm') || 
        article.subtitle.toLowerCase().contains('am') ||
        article.subtitle.toLowerCase().contains('day') ||
        article.subtitle.toLowerCase().contains('away')) {
      return true;
    }
    
    // Default to showing calendar button - better to show it when not needed
    // than to miss showing it when it could be useful
    return true;
  }

  Map<String, dynamic>? _parseEventInfo(Article article) {
    // Example: parse event info from subtitle/content
    // Replace with real parsing logic
    try {
      final start = DateTime.now().add(const Duration(days: 1));
      final end = start.add(const Duration(hours: 2));
      return {
        'title': article.title,
        'description': article.content,
        'start': start,
        'end': end,
        'location': 'School Campus',
      };
    } catch (e) {
      return null;
    }
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
