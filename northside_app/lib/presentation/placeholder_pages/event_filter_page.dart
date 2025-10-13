import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stampede/controllers/athletics_controller.dart';
import 'package:stampede/core/utils/event_filter_provider.dart';
import 'package:stampede/widgets/shared_header.dart';
import '../../core/utils/haptic_feedback_helper.dart';

class EventFilterPage extends ConsumerWidget {
  const EventFilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(eventFilterProvider);
    final filterNotifier = ref.read(eventFilterProvider.notifier);
    final athleticsController = ref.watch(athleticsControllerProvider);
    final allSports = athleticsController.getAllAvailableSports();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SharedHeader(title: 'Filter Events'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () { HapticFeedbackHelper.buttonPress(); filterNotifier.clearFilters(); },
                    child: const Text('Clear All'),
                  )
                ],
              ),
            ),
            SwitchListTile(
              title: const Text('General Events'),
              value: filter.eventTypes.contains(EventType.general),
              onChanged: (value) {
                final newTypes = Set<EventType>.from(filter.eventTypes);
                if (value) {
                  newTypes.add(EventType.general);
                } else {
                  newTypes.remove(EventType.general);
                }
                filterNotifier.setEventTypes(newTypes);
              },
            ),
            SwitchListTile(
              title: const Text('Athletics Events'),
              value: filter.eventTypes.contains(EventType.athletics),
              onChanged: (value) {
                final newTypes = Set<EventType>.from(filter.eventTypes);
                if (value) {
                  newTypes.add(EventType.athletics);
                } else {
                  newTypes.remove(EventType.athletics);
                }
                filterNotifier.setEventTypes(newTypes);
              },
            ),
            if (filter.eventTypes.contains(EventType.athletics))
              Expanded(
                child: ListView.builder(
                  itemCount: allSports.length,
                  itemBuilder: (context, index) {
                    final sport = allSports[index];
                    return CheckboxListTile(
                      title: Text(sport),
                      value: filter.selectedSports.contains(sport),
                      onChanged: (value) {
                        filterNotifier.toggleSport(sport);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
