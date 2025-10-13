import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sportsPreferencesProvider =
    StateNotifierProvider<SportsPreferencesNotifier, List<String>>((ref) {
  return SportsPreferencesNotifier();
});

class SportsPreferencesNotifier extends StateNotifier<List<String>> {
  SportsPreferencesNotifier() : super([]) {
    _loadSelectedSports();
  }

  Future<void> _loadSelectedSports() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      state = prefs.getStringList('selected_sports') ?? [];
    }
  }

  Future<void> updateSelectedSports(List<String> newSelection) async {
    if (mounted) {
      state = newSelection;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('selected_sports', newSelection);
    }
  }
}
