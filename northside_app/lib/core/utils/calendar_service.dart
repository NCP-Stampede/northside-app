// lib/core/utils/calendar_service.dart

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:device_calendar/device_calendar.dart' as device_cal;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarService {
  static final device_cal.DeviceCalendarPlugin _deviceCalendar = device_cal.DeviceCalendarPlugin();

  // Request calendar permissions
  static Future<bool> requestPermissions() async {
    final status = await Permission.calendar.request();
    return status.isGranted;
  }

  // Add a single event to calendar
  static Future<void> addEventToCalendar({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    String? location,
  }) async {
    // Use add_2_calendar for cross-platform add
    final addEvent = Event(
      title: title,
      description: description,
      location: location ?? '',
      startDate: start,
      endDate: end,
    );
    await Add2Calendar.addEvent2Cal(addEvent);
  }

  // Sync all events to calendar
  static Future<void> syncAllEventsToCalendar(List<Event> events) async {
    for (final event in events) {
      await Add2Calendar.addEvent2Cal(event);
    }
  }

  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy h:mm a').format(date);
  }
}
