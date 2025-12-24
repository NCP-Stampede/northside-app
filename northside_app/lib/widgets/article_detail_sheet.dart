// lib/widgets/article_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui'; // Needed for BackdropFilter
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
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
      );
    }
    
    List<TextSpan> spans = [];
    int lastEnd = 0;
    
    for (final match in matches) {
      // Add text before the link
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: content.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
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
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Special case for App Info - use melting header style like Sports/Event sheets
    if (article.title == 'App Info') {
      return _buildAppInfoSheet(context, screenWidth);
    }
    
    // Glass effect container with melting header at top
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
              // Scrollable content (full height, scrolls under header)
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    top: screenWidth * 0.28, // Space for header
                    bottom: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image below header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ClipSmoothRect(
                          radius: SmoothBorderRadius(
                            cornerRadius: DesignConstants.get24Radius(context),
                            cornerSmoothing: 1.0,
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              width: double.infinity,
                              child: Image.asset(
                                article.imagePath ?? 'assets/images/flexes_icon.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) {
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
                      const SizedBox(height: 20),
                      // Main content with link support
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: _buildContentWithLinks(article.content),
                      ),
                      const SizedBox(height: 24),
                      // Add to Calendar button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Builder(
                          builder: (context) {
                            try {
                              if (Get.isRegistered<SettingsController>()) {
                                final settingsController = Get.find<SettingsController>();
                                if (!settingsController.calendarSync.value && _isEventArticle(article)) {
                                  return _buildCalendarButton(context);
                                }
                              } else {
                                if (_isEventArticle(article)) {
                                  return _buildCalendarButton(context);
                                }
                              }
                              return const SizedBox.shrink();
                            } catch (e) {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ],
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
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
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (article.subtitle.isNotEmpty) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      article.subtitle,
                                      style: GoogleFonts.inter(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (_extractSportFromTitle(article.title) != null)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                    fontSize: screenWidth * 0.028,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
  }

  // Special App Info sheet with melting header at the very top
  Widget _buildAppInfoSheet(BuildContext context, double screenWidth) {
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
              // Scrollable content (full height, scrolls under header)
              Positioned.fill(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    top: screenWidth * 0.28, // Space for header
                    bottom: 40,
                    left: 24,
                    right: 24,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: _buildContentWithLinks(article.content),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
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
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Info',
                              style: GoogleFonts.inter(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              article.subtitle,
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
  }

  Widget _buildCalendarButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 8,
              cornerSmoothing: 1.0,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text(
              'Add to Calendar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Universal event detection - show calendar for ANYTHING with date information
  bool _isEventArticle(Article article) {
    // Explicitly exclude "App Info" article
    if (article.title == 'App Info') {
      return false;
    }

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
