// lib/controllers/events_controller.dart

import 'package:get/get.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../models/article.dart';
import '../models/bulletin_post.dart';
import '../services/api_service.dart';
import '../core/utils/logger.dart';


  final ApiService _apiService = ApiService();
  final RxList<GeneralEvent> generalEvents = <GeneralEvent>[].obs;
  final RxList<AthleticsSchedule> athleticsEvents = <AthleticsSchedule>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('EventsController initialized');
    // TODO: Replace with actual API calls using _apiService
    // TODO: Use new ApiService instance methods for events when implemented
    // generalEvents.assignAll(events);
  }

  // Get events for a specific date
  List<Article> getEventsForDay(DateTime date) {
    final events = <Article>[];

    // Add general events for this date
    final dayGeneralEvents = generalEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && _isSameDay(eventDate, date);
      } catch (e) {
        return false;
      }
    });
    events.addAll(dayGeneralEvents.map((event) => event.toArticle()));

    // Add athletics events for this date
    final dayAthleticsEvents = athleticsEvents.where((event) {
      try {
        final eventDate = _parseEventDate(event.date);
        return eventDate != null && _isSameDay(eventDate, date);
      } catch (e) {
        return false;
      }
    });
    events.addAll(dayAthleticsEvents.map((event) => event.toArticle()));

    return events;
  }

  // Helper method to parse various date formats
  DateTime? _parseEventDate(String dateString) {
    if (dateString.isEmpty) return null;
    
    try {
      // Try parsing M/D/YYYY format first (most common in our data)
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final month = int.tryParse(parts[0]) ?? 1;
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Validate month range (now using standard 1-12 format)
          if (month < 1 || month > 12) {
            AppLogger.info('Invalid month in date: $dateString');
            return null;
          }
          
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing "Aug 26 2025" format (athletics schedule format)
      if (dateString.contains(' ') && !dateString.contains('/') && !dateString.contains('-')) {
        final parts = dateString.split(' ');
        if (parts.length == 3) {
          final monthStr = parts[0];
          final day = int.tryParse(parts[1]) ?? 1;
          final year = int.tryParse(parts[2]) ?? DateTime.now().year;
          
          // Map month abbreviations to numbers
          final monthMap = {
            'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
            'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
          };
          
          final month = monthMap[monthStr] ?? 1;
          return DateTime(year, month, day);
        }
      }
      
      // Try parsing ISO format (YYYY-MM-DD)
      return DateTime.parse(dateString);
    } catch (e) {
      AppLogger.info('Error parsing date: $dateString - $e');
      return null;
    }
  }

  // Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  // Get all events as a map for calendar
  Map<DateTime, List<Article>> getAllEventsMap() {
    final eventsMap = <DateTime, List<Article>>{};

    // Add general events
    for (final event in generalEvents) {
      try {
        final date = _parseEventDate(event.date);
        if (date != null) {
          final dayKey = DateTime(date.year, date.month, date.day);
          if (eventsMap[dayKey] == null) {
            eventsMap[dayKey] = [];
          }
          eventsMap[dayKey]!.add(event.toArticle());
        }
      } catch (e) {
        AppLogger.info('Error parsing date for general event: ${event.date} - $e');
      }
    }

    // Add athletics events with deduplication
    for (final event in athleticsEvents) {
      try {
        final date = _parseEventDate(event.date);
        if (date != null) {
          final dayKey = DateTime(date.year, date.month, date.day);
          if (eventsMap[dayKey] == null) {
            eventsMap[dayKey] = [];
          }
          
          final article = event.toArticle();
          
          // Check for duplicates in the same day
          final isDuplicate = eventsMap[dayKey]!.any((existingArticle) =>
            existingArticle.title == article.title &&
            existingArticle.subtitle == article.subtitle
          );
          
          if (!isDuplicate) {
            eventsMap[dayKey]!.add(article);
          } else {
            AppLogger.info('Duplicate athletics event filtered out: ${article.title} on ${event.date}');
          }
        }
      } catch (e) {
        AppLogger.info('Error parsing date for athletics event: ${event.date} - $e');
      }
    }

    return eventsMap;
  }

  // Get upcoming events (10 most recent)
  List<Article> getUpcomingEvents() {
    final now = DateTime.now();
    final upcomingEventsWithDates = <Map<String, dynamic>>[];

    // Add upcoming general events with their parsed dates
    for (final event in generalEvents) {
      try {
        final eventDate = _parseEventDate(event.date);
        if (eventDate != null && eventDate.isAfter(now)) {
          upcomingEventsWithDates.add({
            'article': event.toArticle(),
            'date': eventDate,
            'type': 'general'
          });
        }
      } catch (e) {
        // Skip events with invalid dates
      }
    }

    // Add upcoming athletics events with their parsed dates
    for (final event in athleticsEvents) {
      try {
        final eventDate = _parseEventDate(event.date);
        if (eventDate != null && eventDate.isAfter(now)) {
          upcomingEventsWithDates.add({
            'article': event.toArticle(),
            'date': eventDate,
            'type': 'athletics'
          });
        }
      } catch (e) {
        // Skip events with invalid dates
      }
    }

    // Sort by date (earliest first)
    upcomingEventsWithDates.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Take the first 10 events and return just the articles
    return upcomingEventsWithDates
        .take(10)
        .map((eventData) => eventData['article'] as Article)
        .toList();
  }

  // Get upcoming events as pinned bulletin posts (10 most recent)
  List<BulletinPost> getUpcomingEventsAsPinnedPosts() {
    final now = DateTime.now();
    final upcomingEventsWithDates = <Map<String, dynamic>>[];

    // Add upcoming general events with their parsed dates
    for (final event in generalEvents) {
      try {
        final eventDate = _parseEventDate(event.date);
        if (eventDate != null && eventDate.isAfter(now)) {
          // Create a pinned bulletin post
          final bulletinPost = event.toBulletinPost();
          final pinnedPost = BulletinPost(
            title: bulletinPost.title,
            subtitle: bulletinPost.subtitle,
            date: bulletinPost.date,
            content: bulletinPost.content,
            imagePath: bulletinPost.imagePath,
            isPinned: true, // Pin this event
          );
          
          upcomingEventsWithDates.add({
            'post': pinnedPost,
            'date': eventDate,
            'type': 'general'
          });
        }
      } catch (e) {
        // Skip events with invalid dates
      }
    }

    // Add upcoming athletics events with their parsed dates
    for (final event in athleticsEvents) {
      try {
        final eventDate = _parseEventDate(event.date);
        if (eventDate != null && eventDate.isAfter(now)) {
          // Create a pinned bulletin post
          final bulletinPost = event.toBulletinPost();
          final pinnedPost = BulletinPost(
            title: bulletinPost.title,
            subtitle: bulletinPost.subtitle,
            date: bulletinPost.date,
            content: bulletinPost.content,
            imagePath: bulletinPost.imagePath,
            isPinned: true, // Pin this event
          );
          
          upcomingEventsWithDates.add({
            'post': pinnedPost,
            'date': eventDate,
            'type': 'athletics'
          });
        }
      } catch (e) {
        // Skip events with invalid dates
      }
    }

    // Sort by date (earliest first)
    upcomingEventsWithDates.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // Take the first 10 events and return as pinned bulletin posts
    return upcomingEventsWithDates
        .take(10)
        .map((eventData) => eventData['post'] as BulletinPost)
        .toList();
  }

  // Get all events (for debugging and testing)
  List<Article> getAllEvents() {
    final allEvents = <Article>[];
    
    // Add all general events
    allEvents.addAll(generalEvents.map((event) => event.toArticle()));
    
    // Add all athletics events
    allEvents.addAll(athleticsEvents.map((event) => event.toArticle()));
    
    AppLogger.info('Total events: ${allEvents.length} (${generalEvents.length} general + ${athleticsEvents.length} athletics)');
    
    return allEvents;
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadData();
  }

  // Get all events as bulletin posts with upcoming events pinned
  List<BulletinPost> getAllEventsAsBulletinPosts({bool includeUpcomingAsPinned = true}) {
    final bulletinPosts = <BulletinPost>[];

    // Add all general events as bulletin posts
    for (final event in generalEvents) {
      bulletinPosts.add(event.toBulletinPost());
    }

    // Add all athletics events as bulletin posts  
    for (final event in athleticsEvents) {
      bulletinPosts.add(event.toBulletinPost());
    }

    if (includeUpcomingAsPinned) {
      // Get upcoming events as pinned posts
      final upcomingPinnedPosts = getUpcomingEventsAsPinnedPosts();
      
      // Remove any duplicate events that might already be in the list
      final now = DateTime.now();
      bulletinPosts.removeWhere((post) => 
        post.date.isAfter(now) && 
        upcomingPinnedPosts.any((pinnedPost) => 
          pinnedPost.title == post.title && 
          pinnedPost.date.day == post.date.day &&
          pinnedPost.date.month == post.date.month &&
          pinnedPost.date.year == post.date.year
        )
      );
      
      // Add the pinned upcoming events
      bulletinPosts.addAll(upcomingPinnedPosts);
    }

    // Sort by date (newest first) but keep pinned items at the top
    bulletinPosts.sort((a, b) {
      // Pinned items first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      
      // Then sort by date (newest first)
      return b.date.compareTo(a.date);
    });

    return bulletinPosts;
  }
}