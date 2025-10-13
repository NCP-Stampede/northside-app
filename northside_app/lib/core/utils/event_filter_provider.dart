import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EventType { general, athletics }

class EventFilter {
  final Set<EventType> eventTypes;
  final Set<String> selectedSports;

  EventFilter({
    this.eventTypes = const {EventType.general, EventType.athletics},
    this.selectedSports = const {},
  });

  EventFilter copyWith({
    Set<EventType>? eventTypes,
    Set<String>? selectedSports,
  }) {
    return EventFilter(
      eventTypes: eventTypes ?? this.eventTypes,
      selectedSports: selectedSports ?? this.selectedSports,
    );
  }
}

final eventFilterProvider = StateNotifierProvider<EventFilterNotifier, EventFilter>((ref) {
  return EventFilterNotifier();
});

class EventFilterNotifier extends StateNotifier<EventFilter> {
  EventFilterNotifier() : super(EventFilter());

  void setEventTypes(Set<EventType> eventTypes) {
    state = state.copyWith(eventTypes: eventTypes);
  }

  void toggleSport(String sport) {
    final newSports = Set<String>.from(state.selectedSports);
    if (newSports.contains(sport)) {
      newSports.remove(sport);
    } else {
      newSports.add(sport);
    }
    state = state.copyWith(selectedSports: newSports);
  }

  void clearFilters() {
    state = EventFilter();
  }
}
