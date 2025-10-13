// lib/services/calendar_service.dart

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:get/get.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../core/utils/logger.dart';

class CalendarService {
  
  // Add single event to device calendar
  static Future<bool> addEventToCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    DateTime? endTime,
    String? location,
  }) async {
    try {
      final Event event = Event(
        title: title,
        description: description,
        startDate: startTime,
        endDate: endTime ?? startTime.add(Duration(hours: 1)),
        location: location,
      );

      final result = await Add2Calendar.addEvent2Cal(event);
      
      if (result) {
        Get.snackbar(
          'Success',
          'Event added to calendar',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to add event to calendar',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error adding event to calendar', e);
      Get.snackbar(
        'Error',
        'Failed to add event to calendar: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }

  // Add general event to calendar
  static Future<bool> addGeneralEventToCalendar(GeneralEvent event) async {
    return await addEventToCalendar(
      title: event.title,
      description: event.description,
      startTime: event.startDate,
      endTime: event.endDate,
      location: event.location.isNotEmpty ? event.location : null,
    );
  }

  // Add athletics event to calendar
  static Future<bool> addAthleticsEventToCalendar(AthleticsSchedule event) async {
    final eventDateTime = _parseEventDateTime(event.date, event.time);
    if (eventDateTime == null) return false;

    return await addEventToCalendar(
      title: '${event.sport} vs ${event.opponent}',
      description: '${event.sport} ${event.level} game\nLocation: ${event.location}',
      startTime: eventDateTime,
      endTime: eventDateTime.add(Duration(hours: 2)), // Default 2 hour duration
      location: event.location,
    );
  }

  // Add article event to calendar (for bulletin/news events)
  static Future<bool> addArticleEventToCalendar(Article article) async {
    // Try to extract date from article content or use current date
    final eventDateTime = DateTime.now().add(Duration(days: 1)); // Default to tomorrow
    
    return await addEventToCalendar(
      title: article.title,
      description: article.subtitle.isNotEmpty ? article.subtitle : article.content,
      startTime: eventDateTime,
      location: null,
    );
  }

  // Sync all events to calendar
  static Future<void> syncAllEventsToCalendar({
    required List<GeneralEvent> generalEvents,
    required List<AthleticsSchedule> athleticsEvents,
    required List<Article> bulletinEvents,
  }) async {
    int successCount = 0;
    int totalCount = 0;

    // Add general events
    for (final event in generalEvents) {
      totalCount++;
      if (await addGeneralEventToCalendar(event)) {
        successCount++;
      }
      // Small delay to avoid overwhelming the system
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Add athletics events
    for (final event in athleticsEvents) {
      totalCount++;
      if (await addAthleticsEventToCalendar(event)) {
        successCount++;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Add bulletin events (limit to upcoming ones)
    final upcomingBulletinEvents = bulletinEvents.take(5); // Limit to avoid spam
    for (final event in upcomingBulletinEvents) {
      totalCount++;
      if (await addArticleEventToCalendar(event)) {
        successCount++;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }

    // Show summary
    Get.snackbar(
      'Sync Complete',
      'Added $successCount of $totalCount events to calendar',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
    );
  }

  // Helper method to parse event date and time
  static DateTime? _parseEventDateTime(String dateString, String timeString) {
    try {
      // Parse date
      DateTime? date = _parseEventDate(dateString);
      if (date == null) return null;

      // Parse time if provided
      if (timeString.isNotEmpty && timeString != 'TBD') {
        final timePattern = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false);
        final match = timePattern.firstMatch(timeString);
        
        if (match != null) {
          int hour = int.parse(match.group(1)!);
          int minute = int.parse(match.group(2)!);
          String? ampm = match.group(3)?.toUpperCase();
          
          if (ampm == 'PM' && hour != 12) {
            hour += 12;
          } else if (ampm == 'AM' && hour == 12) {
            hour = 0;
          }
          
          return DateTime(date.year, date.month, date.day, hour, minute);
        }
      }

      // Default to 3 PM if no time specified
      return DateTime(date.year, date.month, date.day, 15, 0);
    } catch (e) {
      AppLogger.error('Error parsing event date/time', e);
      return null;
    }
  }

  // Helper method to parse various date formats
  static DateTime? _parseEventDate(String dateString) {
    if (dateString.isEmpty) return null;
    
    try {
      // Handle date ranges by taking the first date
      if (dateString.contains('-') && dateString.contains(',')) {
        final dateParts = dateString.split('-');
        if (dateParts.isNotEmpty) {
          dateString = dateParts[0].trim();
        }
      }
      
      // Try parsing M/D/YYYY format
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing "Fri, May 23" format
      if (dateString.contains(',')) {
        final parts = dateString.split(',');
        if (parts.length == 2) {
          final datePart = parts[1].trim();
          final dateSubParts = datePart.split(' ');
          if (dateSubParts.length == 2) {
            final monthStr = dateSubParts[0];
            final day = int.tryParse(dateSubParts[1]) ?? 1;
            final year = DateTime.now().year;
            
            final monthMap = {
              'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
              'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
            };
            
            final month = monthMap[monthStr] ?? 1;
            return DateTime(year, month, day);
          }
        }
      }
      
      // Try parsing "Aug 26 2025" format
      if (dateString.contains(' ')) {
        final parts = dateString.split(' ');
        if (parts.length == 3) {
          final monthStr = parts[0];
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          final monthMap = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
          };
          
          final month = monthMap[monthStr] ?? 1;
          return DateTime(year, month, day);
        }
      }
      
      return DateTime.parse(dateString);
    } catch (e) {
      AppLogger.warning('Error parsing date: $dateString', e);
      return null;
    }
  }
}