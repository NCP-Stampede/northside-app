// lib/core/utils/haptic_feedback_helper.dart

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class HapticFeedbackHelper {
  // Light impact for button presses (like keyboard key press)
  static void lightImpact() {
    try {
      final settingsController = Get.find<SettingsController>();
      if (settingsController.hapticFeedback.value) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Settings controller not available, default to enabled
      HapticFeedback.lightImpact();
    }
  }

  // Medium impact for more important actions
  static void mediumImpact() {
    try {
      final settingsController = Get.find<SettingsController>();
      if (settingsController.hapticFeedback.value) {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Settings controller not available, default to enabled
      HapticFeedback.mediumImpact();
    }
  }

  // Heavy impact for major actions (like reset)
  static void heavyImpact() {
    try {
      final settingsController = Get.find<SettingsController>();
      if (settingsController.hapticFeedback.value) {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Settings controller not available, default to enabled
      HapticFeedback.heavyImpact();
    }
  }

  // Selection click for toggles and selections
  static void selectionClick() {
    try {
      final settingsController = Get.find<SettingsController>();
      if (settingsController.hapticFeedback.value) {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      // Settings controller not available, default to enabled
      HapticFeedback.selectionClick();
    }
  }

  // Keyboard-like feedback for button press (down)
  static void buttonPress() {
    lightImpact();
  }

  // Keyboard-like feedback for button release (up) - using a slightly different pattern
  static void buttonRelease() {
    // Use a very light vibration for the "release" feeling
    try {
      final settingsController = Get.find<SettingsController>();
      if (settingsController.hapticFeedback.value) {
        // Create a subtle release feeling with a short delay
        Future.delayed(const Duration(milliseconds: 50), () {
          HapticFeedback.selectionClick();
        });
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.selectionClick();
      });
    }
  }
}