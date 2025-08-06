// lib/controllers/bulletin_controller.dart

import 'package:get/get.dart';
import '../models/bulletin_post.dart';
import '../models/announcement.dart';
import '../models/general_event.dart';
import '../models/athletics_schedule.dart';
import '../api.dart';
import '../core/utils/logger.dart';
import 'athletics_controller.dart';

class BulletinController extends GetxController {
  // Observable lists for reactive UI
  final RxList<BulletinPost> _allPosts = <BulletinPost>[].obs;
  final RxBool _isLoading = false.obs;
  
  // Store original announcements for home carousel (not included in bulletin posts)
  List<Announcement> _announcements = [];
  List<AthleticsSchedule> _athleticsEvents = [];

  // Getters
  List<BulletinPost> get allPosts => _allPosts;
  RxList<BulletinPost> get allPostsRx => _allPosts;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load and combine data from all sources
  Future<void> loadData() async {
    try {
      _isLoading.value = true;
      
      // Load data from all sources
      final announcements = await _loadAnnouncements();
      final generalEvents = await _loadGeneralEvents();
      final athleticsEvents = await _loadAthleticsEvents();

      // Store original data for home carousel
      _announcements = announcements;
      _athleticsEvents = athleticsEvents;

      // Combine into bulletin posts (excluding athletics)
      final bulletinPosts = _createBulletinPosts(announcements, generalEvents, athleticsEvents);
      
      // Update the observable list
      _allPosts.assignAll(bulletinPosts);
    } catch (e) {
      AppLogger.error('Error loading bulletin data', e);
    } finally {
      _isLoading.value = false;
    }
  }

  // Load announcements
  Future<List<Announcement>> _loadAnnouncements() async {
    try {
      final fetchedAnnouncements = await ApiService.getAnnouncements();
      return fetchedAnnouncements;
    } catch (e) {
      AppLogger.error('Error loading announcements', e);
      return [];
    }
  }

  // Load general events
  Future<List<GeneralEvent>> _loadGeneralEvents() async {
    try {
      final fetchedEvents = await ApiService.getGeneralEvents();
      return fetchedEvents;
    } catch (e) {
      AppLogger.error('Error loading general events', e);
      return [];
    }
  }

  // Load athletics events
  Future<List<AthleticsSchedule>> _loadAthleticsEvents() async {
    try {
      final fetchedEvents = await ApiService.getAthleticsSchedule();
      return fetchedEvents;
    } catch (e) {
      AppLogger.error('Error loading athletics events', e);
      return [];
    }
  }

  // Create bulletin posts from announcements and events (excluding athletics)
  List<BulletinPost> _createBulletinPosts(List<Announcement> announcements, List<GeneralEvent> generalEvents, List<AthleticsSchedule> athleticsEvents) {
    final List<BulletinPost> combinedPosts = [];
    
    // Convert announcements to bulletin posts (using start_date for bulletin display)
    for (final announcement in announcements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: false);
      combinedPosts.add(bulletinPost);
    }
    
    // Convert general events to bulletin posts
    for (final event in generalEvents) {
      final bulletinPost = event.toBulletinPost();
      combinedPosts.add(bulletinPost);
    }
    
    // Note: Athletics events are excluded from bulletin posts
    // They appear only on the athletics page
    
    // Sort by date (newest first)
    combinedPosts.sort((a, b) => b.date.compareTo(a.date));
    
    return combinedPosts;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Get upcoming events (future events only) for home screen carousel (includes athletics and announcements)
  List<BulletinPost> get upcomingEvents {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    // Create combined posts including athletics for home carousel
    final List<BulletinPost> homeCarouselPosts = [];
    final Set<String> addedEventKeys = {}; // To prevent duplicates
    
    // Add ALL upcoming events (general events)
    final generalEventPosts = allPosts.toList();
    
    for (final post in generalEventPosts) {
      if (!post.date.isBefore(todayStart)) {
        final eventKey = '${post.title}_${post.date.toIso8601String()}';
        if (!addedEventKeys.contains(eventKey)) {
          homeCarouselPosts.add(post);
          addedEventKeys.add(eventKey);
        }
      }
    }
    
    // Use AthleticsController to get athletics news (includes track sports)
    try {
      final athleticsController = Get.find<AthleticsController>();
      final athleticsNews = athleticsController.getAthleticsNews();
      
      // Convert athletics articles to bulletin posts
      for (final article in athleticsNews) {
        final eventKey = '${article.title}_${article.subtitle}';
        if (!addedEventKeys.contains(eventKey)) {
          final bulletinPost = BulletinPost(
            title: article.title,
            subtitle: article.subtitle,
            date: _parseArticleDate(article.subtitle),
            content: article.content,
            imagePath: article.imagePath ?? 'assets/images/flexes_icon.png',
            isPinned: false,
          );
          homeCarouselPosts.add(bulletinPost);
          addedEventKeys.add(eventKey);
        }
      }
    } catch (e) {
      AppLogger.warning('Athletics controller not found, falling back to original athletics events: $e');
      
      // Fallback to original athletics events if athletics controller is not available
      for (final event in _athleticsEvents) {
        final bulletinPost = event.toBulletinPost();
        if (!bulletinPost.date.isBefore(todayStart)) {
          final eventKey = '${bulletinPost.title}_${event.location}_${bulletinPost.date.toIso8601String()}_${event.time}';
          
          if (!addedEventKeys.contains(eventKey)) {
            homeCarouselPosts.add(bulletinPost);
            addedEventKeys.add(eventKey);
          }
        }
      }
    }
    
    // Add up to 3 most recent announcements that are currently active
    final sortedAnnouncements = _announcements.where((announcement) {
      try {
        // Parse start and end dates to check if announcement is currently active
        final startDate = _parseAnnouncementDate(announcement.startDate);
        final endDate = _parseAnnouncementDate(announcement.endDate);
        final today = DateTime(now.year, now.month, now.day);
        
        // Check if announcement is currently active (today is between start and end date)
        return !today.isBefore(startDate) && !today.isAfter(endDate);
      } catch (e) {
        // If date parsing fails, include the announcement
        return true;
      }
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Most recent first
    
    final recentAnnouncements = sortedAnnouncements.take(3);
    for (final announcement in recentAnnouncements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: false); // Use start date for announcements in carousel
      final eventKey = '${bulletinPost.title}_${bulletinPost.date.toIso8601String()}_announcement';
      if (!addedEventKeys.contains(eventKey)) {
        homeCarouselPosts.add(bulletinPost);
        addedEventKeys.add(eventKey);
      }
    }
    
    // Sort by date only (earliest first, regardless of type)
    homeCarouselPosts.sort((a, b) => a.date.compareTo(b.date));
    
    return homeCarouselPosts.take(15).toList(); // Increased limit to accommodate events + announcements
  }

  // Helper method to parse date from article subtitle
  DateTime _parseArticleDate(String subtitle) {
    final now = DateTime.now();
    
    if (subtitle.contains('Today')) {
      return DateTime(now.year, now.month, now.day);
    }
    
    if (subtitle.contains('day away')) {
      final match = RegExp(r'(\d+) day').firstMatch(subtitle);
      if (match != null) {
        final days = int.tryParse(match.group(1) ?? '0') ?? 0;
        return now.add(Duration(days: days));
      }
    }
    
    // Default to tomorrow if we can't parse
    return now.add(const Duration(days: 1));
  }

  // Helper method to parse announcement dates
  DateTime _parseAnnouncementDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return DateTime.now();
      
      // Try to parse formats like "6/27/2025"
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        int month = int.tryParse(parts[0]) ?? 1;
        int day = int.tryParse(parts[1]) ?? 1;
        int year = int.tryParse(parts[2]) ?? DateTime.now().year;
        
        // Validate ranges
        if (month > 12) month = 12;
        if (month < 1) month = 1;
        if (day < 1) day = 1;
        if (day > 31) day = 31;
        
        return DateTime(year, month, day);
      }
      
      // Fallback to trying DateTime.parse
      return DateTime.parse(dateStr);
    } catch (e) {
      AppLogger.warning('Error parsing announcement date "$dateStr"', e);
      return DateTime.now();
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  // Get pinned posts (5 most recent announcements and events for today or near future)
  List<BulletinPost> get pinnedPosts {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final List<BulletinPost> candidatePosts = [];
    
    // Add general events (filter out announcements from allPosts - these use start_date)
    final generalEventPosts = allPosts.where((post) => 
        post.imagePath != 'assets/images/flexes_icon.png').toList();
    
    for (final post in generalEventPosts) {
      if (!post.date.isBefore(todayStart)) {
        candidatePosts.add(post);
      }
    }
    
    // Add announcements using end_date for pinned post relevance
    for (final announcement in _announcements) {
      final bulletinPost = announcement.toBulletinPost(useEndDate: true);
      if (!bulletinPost.date.isBefore(todayStart)) {
        candidatePosts.add(bulletinPost);
      }
    }
    
    // Sort by date (earliest first)
    candidatePosts.sort((a, b) => a.date.compareTo(b.date));
    
    // Take top 5 and mark as pinned
    return candidatePosts.take(5).map((post) => BulletinPost(
      title: post.title,
      subtitle: post.subtitle,
      date: post.date,
      content: post.content,
      imagePath: post.imagePath,
      isPinned: true,
    )).toList();
  }

  // Get future posts (beyond the next 7 days)
  List<BulletinPost> get futurePosts {
    final now = DateTime.now();
    final nearFuture = now.add(const Duration(days: 7));
    
    final future = allPosts.where((post) => !post.date.isBefore(nearFuture)).toList();
    future.sort((a, b) => a.date.compareTo(b.date)); // Earliest first
    
    return future;
  }

  // Get past posts (before today)
  List<BulletinPost> get pastPosts {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final past = allPosts.where((post) => post.date.isBefore(todayStart)).toList();
    past.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    
    return past;
  }
}
