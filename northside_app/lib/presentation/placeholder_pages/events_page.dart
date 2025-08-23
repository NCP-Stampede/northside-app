// lib/presentation/placeholder_pages/events_page.dart

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stampede/models/article.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controllers/events_controller.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/text_helper.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/shared_header.dart';
import '../../core/design_constants.dart';

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
    // Listen to events controller changes
    ever(eventsController.generalEvents, (_) {
      AppLogger.debug('General events updated: ${eventsController.generalEvents.length}');
      _updateEventsMap();
    });
    ever(eventsController.athleticsEvents, (_) {
      AppLogger.debug('Athletics events updated: ${eventsController.athleticsEvents.length}');
      _updateEventsMap();
    });
    
    // Initial load
    _updateEventsMap();
  }

  void _updateEventsMap() {
    _kEvents = LinkedHashMap<DateTime, List<Article>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    final eventsMap = eventsController.getAllEventsMap();
    _kEvents.addAll(eventsMap);
    
    AppLogger.debug('Events map updated with ${_kEvents.length} days containing events');
    AppLogger.debug('Total events across all days: ${_kEvents.values.fold(0, (sum, events) => sum + events.length)}');

    // Update selected events for current day
    _selectedEvents.value = _getEventsForDay(_selectedDay!);
    
    if (mounted) {
      setState(() {});
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
    // final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          // Single gradient container for background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFDC143C), // Darker, more vibrant red (Crimson)
                  Color(0xFFE74C3C), // Rich red
                  Color(0xFFFF5733), // Bright red-orange
                  Color(0xFFF2F2F7), // Transition Color
                  Color(0xFFF2F2F7), // Final Background Color
                ],
                stops: [0.0, 0.15, 0.3, 0.45, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Obx(() {
            if (eventsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
          return ListView(
          padding: EdgeInsets.only(bottom: screenHeight * 0.12),
          children: [
            const SharedHeader(title: 'Events'),
            SizedBox(height: screenHeight * 0.02),
            _buildFilterButton(context),
            SizedBox(height: screenHeight * 0.02),
            _buildCalendar(context),
            SizedBox(height: screenHeight * 0.03),
            _buildEventList(context),
          ],
        );
        }),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.045;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
          decoration: ShapeDecoration(
            color: Colors.grey.shade200,
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 10,
                cornerSmoothing: 1.0,
              ),
            ),
          ),
          child: Text(
            'For Current Year',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBlue, fontSize: fontSize),
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
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: verticalPadding),
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
                color: Colors.black,
              ),
              leftChevronIcon: Icon(Icons.arrow_back_ios, size: iconSize),
              rightChevronIcon: Icon(Icons.arrow_forward_ios, size: iconSize),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.black),
              weekendStyle: TextStyle(fontSize: dowFontSize, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.black),
              weekendTextStyle: TextStyle(fontSize: dayFontSize, color: Colors.black),
              outsideTextStyle: TextStyle(fontSize: dayFontSize * 0.95, color: Colors.black),
              todayDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
            ),
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
        },
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
    return Container(
      padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.05),
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
      child: Center(
        child: Text(
          'No Events Today',
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04),
      padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: GoogleFonts.inter(
              fontSize: MediaQuery.of(context).size.width * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, 
                  size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045, 
                  color: Colors.black),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                child: TextHelper.responsiveText(
                  article.subtitle,
                  context: context,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
