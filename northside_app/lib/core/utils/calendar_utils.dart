import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stampede/models/bulletin_post.dart';

class CalendarUtils {
  static void addEventToCalendar(BulletinPost post) {
    final Event event = Event(
      title: post.title,
      description: post.content,
      location: 'Northside College Prep',
      startDate: post.date,
      endDate: post.date.add(const Duration(hours: 1)),
    );

    Add2Calendar.addEvent2Cal(event).then((success) {
      Get.snackbar(
        'Calendar',
        success ? 'Event added to calendar.' : 'Failed to add event.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: success ? Colors.green : Colors.red,
        colorText: Colors.white,
      );
    });
  }

  static void syncAllEventsToCalendar(List<BulletinPost> posts) {
    for (var post in posts) {
      addEventToCalendar(post);
    }
    Get.snackbar(
      'Calendar Sync',
      'Attempting to sync all events. You may need to confirm each one.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
