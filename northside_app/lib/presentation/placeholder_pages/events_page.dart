// lib/presentation/placeholder_pages/events_page.dart

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:stampede/models/article.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/events_controller.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/sport_badge.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/text_helper.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/design_constants.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../widgets/liquid_mesh_background.dart';
import '../../widgets/liquid_melting_header.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventsController eventsController = Get.put(EventsController());
  late final ValueNotifier<List<Article>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  LinkedHashMap<DateTime, List<Article>> _kEvents = LinkedHashMap<DateTime, List<Article>>();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEventsData();
  }

  void _loadEventsData() {
        // Listen for events data changes
    ever(eventsController.generalEvents, (_) => _updateEventsMap());
    ever(eventsController.athleticsEvents, (_) => _updateEventsMap());
    ever(eventsController.selectedFilter, (_) => _updateEventsMap());
    
    // Initial load
    _updateEventsMap();
  }

  void _updateEventsMap() {
    _kEvents = LinkedHashMap<DateTime, List<Article>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    // Use filtered events instead of all events
    final filteredEvents = eventsController.getFilteredEvents();
    
    // Group filtered events by date
    for (final event in filteredEvents) {
      final eventDate = _parseEventDate(event);
      if (eventDate != null) {
        final dateKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (_kEvents[dateKey] == null) {
          _kEvents[dateKey] = [];
        }
        _kEvents[dateKey]!.add(event);
      }
    }
    
    AppLogger.debug('Events map updated with ${_kEvents.length} days containing events (filter: ${eventsController.selectedFilter.value})');
    AppLogger.debug('Total events across all days: ${_kEvents.values.fold(0, (sum, events) => sum + events.length)}');

    // Update selected events for current day
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
    
    if (mounted) {
      setState(() {});
    }
  }

  DateTime? _parseEventDate(Article event) {
    try {
      // Try to parse date from subtitle (format: "January 1, 2024")
      final subtitle = event.subtitle;
      // This is a simple implementation - you might need more robust date parsing
      // based on your actual date formats
      return DateTime.now().add(Duration(days: 1)); // Placeholder - replace with actual parsing
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Article> _getEventsForDay(DateTime day) {
    return _kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          // Single gradient container for background
          const LiquidMeshBackground(),
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: LiquidMeltingHeader(
                  title: 'Events',
                  topPadding: MediaQuery.of(context).padding.top,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.04,
                  bottom: screenHeight * 0.15,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildFilterButton(context),
                    SizedBox(height: screenHeight * 0.02),
                    _buildCalendar(context),
                    SizedBox(height: screenHeight * 0.03),
                    _buildEventList(context),
                  ]),
                ),
              ),
            ],
          ),
          Obx(() {
            if (eventsController.isLoading.value) {
              return const LoadingIndicator(
                message: 'Loading events data...',
                showBackground: false,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.038;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Obx(() => Row(
        children: [
          _buildFilterChip(context, 'All', eventsController.selectedFilter.value == 'All'),
          SizedBox(width: screenWidth * 0.02),
          _buildFilterChip(context, 'Sports', eventsController.selectedFilter.value == 'Sports'),
          SizedBox(width: screenWidth * 0.02),
          _buildFilterChip(context, 'Events', eventsController.selectedFilter.value == 'Events'),
          SizedBox(width: screenWidth * 0.02),
          _buildFilterChip(context, 'Announcements', eventsController.selectedFilter.value == 'Announcements'),
        ],
      )),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.035;
    
    return GestureDetector(
      onTap: () {
        HapticFeedbackHelper.buttonPress();
        eventsController.setFilter(label);
      },
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: 10,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected 
                  ? [Colors.white.withOpacity(0.45), Colors.white.withOpacity(0.3)]
                  : [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.12)],
              ),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 10,
                  cornerSmoothing: 1.0,
                ),
                side: BorderSide(color: Colors.white.withOpacity(isSelected ? 0.4 : 0.2), width: 1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar small devices
    final double dayFontSize = isNarrowScreen ? screenWidth * 0.037 : screenWidth * 0.042;
    final double dowFontSize = isNarrowScreen ? screenWidth * 0.028 : screenWidth * 0.031;
    final double headerFontSize = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.052;
    final double iconSize = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.052;
    final double verticalPadding = isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.055;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: DesignConstants.get24Radius(context),
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: verticalPadding),
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
            // Wrap in LayoutBuilder to adjust calendar based on available space
            child: LayoutBuilder(
              builder: (context, constraints) {
                return TableCalendar<Article>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            // Adjust size to ensure it fits on small screens
            rowHeight: isNarrowScreen ? 40 : 50,
            calendarBuilders: CalendarBuilders<Article>(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();
                
                final eventCount = events.length;
                if (eventCount <= 3) {
                  // Show dots for 1-3 events
                  return SizedBox(
                    height: 20, // Ensures consistent height for alignment
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(eventCount, (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          )),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Show 3 dots + "+" for more than 3 events
                  return SizedBox(
                    height: 20, // Ensures consistent height for alignment
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ...List.generate(3, (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            )),
                            const SizedBox(width: 2),
                            Text(
                              '+',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isNarrowScreen ? 8 : 10,
                                fontWeight: FontWeight.bold,
                                height: 6 / (isNarrowScreen ? 8 : 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
              titleTextStyle: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              leftChevronIcon: Icon(CupertinoIcons.chevron_left, size: iconSize, color: AppColors.primaryBlue),
              rightChevronIcon: Icon(CupertinoIcons.chevron_right, size: iconSize, color: AppColors.primaryBlue),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.white),
              weekendStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.white),
              weekendTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.white),
              outsideTextStyle: TextStyle(fontSize: dayFontSize * 0.95, color: Colors.white.withOpacity(0.5)),
              todayDecoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventList(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: ValueListenableBuilder<List<Article>>(
        valueListenable: _selectedEvents,
        builder: (context, value, _) {
          if (value.isEmpty) {
            return const _NoEventsCard();
          }
          return Column(
            children: value.map((article) => GestureDetector(
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
              child: _EventDetailCard(article: article),
            )).toList(),
          );
        },
      ),
    );
  }
}

class _NoEventsCard extends StatelessWidget {
  const _NoEventsCard();
  
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: DesignConstants.get24Radius(context),
        cornerSmoothing: 1.0,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.05),
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
          child: Center(
            child: Text(
              'No Events Today',
              style: GoogleFonts.inter(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventDetailCard extends StatelessWidget {
  const _EventDetailCard({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04),
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: DesignConstants.get24Radius(context),
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: GoogleFonts.inter(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    SportBadge(sport: _extractSportFromArticle(article)),
                  ],
                ),
                SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
                Row(
                  children: [
                    Icon(CupertinoIcons.calendar, 
                        size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045, 
                        color: Colors.white.withOpacity(0.7)),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
                      child: TextHelper.responsiveText(
                        article.subtitle,
                        context: context,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _extractSportFromArticle(Article article) {
    // Try to extract sport from title or subtitle
    final text = '${article.title} ${article.subtitle}'.toLowerCase();
    
    // Common sports keywords
    final sportsMap = {
      'football': 'Football',
      'basketball': 'Basketball',
      'soccer': 'Soccer',
      'baseball': 'Baseball',
      'softball': 'Softball',
      'volleyball': 'Volleyball',
      'tennis': 'Tennis',
      'track': 'Track and Field',
      'cross country': 'Cross Country',
      'swimming': 'Swimming',
      'wrestling': 'Wrestling',
      'golf': 'Golf',
      'lacrosse': 'Lacrosse',
      'hockey': 'Hockey',
    };
    
    for (final entry in sportsMap.entries) {
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // If no sport is identified and it's not a general event, return null
    if (text.contains('vs') || text.contains('game') || text.contains('match')) {
      return 'Sports'; // Generic sports badge
    }
    
    return null; // No sport badge for general events
  }
}
