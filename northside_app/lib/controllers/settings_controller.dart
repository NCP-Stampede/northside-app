// lib/controllers/settings_controller.dart

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SettingsController extends GetxController {
  // Observable settings
  final RxBool hapticFeedback = true.obs;
  final RxBool calendarSync = false.obs;
  final RxBool pushNotifications = true.obs;
  final RxBool darkMode = false.obs;
  
  // Favorite sports for Athletics page (exactly 4 sports)
  final RxList<String> favoriteSports = <String>[
    'Basketball',
    'Soccer', 
    'Outdoor Track',
    'Swimming',
  ].obs;

  // Event filtering settings
  final RxSet<String> hiddenEventTypes = <String>{}.obs;
  final RxSet<String> favoriteEventTypes = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load boolean settings
      hapticFeedback.value = prefs.getBool('haptic_feedback') ?? true;
      calendarSync.value = prefs.getBool('calendar_sync') ?? false;
      pushNotifications.value = prefs.getBool('push_notifications') ?? true;
      darkMode.value = prefs.getBool('dark_mode') ?? false;
      
      // Load favorite sports
      final savedFavorites = prefs.getStringList('favorite_sports') ?? [
        'Basketball', 'Soccer', 'Outdoor Track', 'Swimming'
      ];
      if (savedFavorites.length == 4) {
        favoriteSports.assignAll(savedFavorites);
      }
      
      // Load event filters
      final hiddenTypes = prefs.getStringList('hidden_event_types') ?? [];
      hiddenEventTypes.clear();
      hiddenEventTypes.addAll(hiddenTypes);
      
      final favoriteTypes = prefs.getStringList('favorite_event_types') ?? [];
      favoriteEventTypes.clear();
      favoriteEventTypes.addAll(favoriteTypes);
      
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleHapticFeedback() async {
    hapticFeedback.value = !hapticFeedback.value;
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> toggleCalendarSync() async {
    calendarSync.value = !calendarSync.value;
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> syncAllEventsToCalendar() async {
    if (!calendarSync.value) {
      Get.snackbar(
        'Calendar Sync Disabled',
        'Please enable calendar sync in settings first',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
      return;
    }

    try {
      // This would need to be implemented to get all events from controllers
      // For now, show a message that sync is starting
      Get.snackbar(
        'Sync Starting',
        'Syncing events to calendar...',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
      
      if (hapticFeedback.value) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      Get.snackbar(
        'Sync Error',
        'Failed to sync events to calendar',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    }
  }

  Future<void> togglePushNotifications() async {
    pushNotifications.value = !pushNotifications.value;
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> toggleDarkMode() async {
    darkMode.value = !darkMode.value;
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> updateFavoriteSports(List<String> newFavorites) async {
    if (newFavorites.length == 4) {
      favoriteSports.assignAll(newFavorites);
      await _saveSettings();
      
      if (hapticFeedback.value) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  Future<void> toggleEventTypeVisibility(String eventType) async {
    if (hiddenEventTypes.contains(eventType)) {
      hiddenEventTypes.remove(eventType);
    } else {
      hiddenEventTypes.add(eventType);
    }
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> toggleFavoriteEventType(String eventType) async {
    if (favoriteEventTypes.contains(eventType)) {
      favoriteEventTypes.remove(eventType);
    } else {
      favoriteEventTypes.add(eventType);
    }
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save boolean settings
      await prefs.setBool('haptic_feedback', hapticFeedback.value);
      await prefs.setBool('calendar_sync', calendarSync.value);
      await prefs.setBool('push_notifications', pushNotifications.value);
      await prefs.setBool('dark_mode', darkMode.value);
      
      // Save favorite sports
      await prefs.setStringList('favorite_sports', favoriteSports.toList());
      
      // Save event filters
      await prefs.setStringList('hidden_event_types', hiddenEventTypes.toList());
      await prefs.setStringList('favorite_event_types', favoriteEventTypes.toList());
      
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Helper methods for other controllers to use
  List<String> getFavoriteSports() {
    return favoriteSports.toList();
  }

  bool isEventTypeVisible(String eventType) {
    return !hiddenEventTypes.contains(eventType);
  }

  bool isEventTypeFavorite(String eventType) {
    return favoriteEventTypes.contains(eventType);
  }

  void resetToDefaults() async {
    hapticFeedback.value = true;
    calendarSync.value = false;
    pushNotifications.value = true;
    darkMode.value = false;
    
    favoriteSports.assignAll(['Basketball', 'Soccer', 'Outdoor Track', 'Swimming']);
    
    hiddenEventTypes.clear();
    favoriteEventTypes.clear();
    
    await _saveSettings();
    
    if (hapticFeedback.value) {
      HapticFeedback.mediumImpact();
    }
  }
}