import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stampede/core/utils/sports_preferences_provider.dart';
import 'package:stampede/widgets/shared_header.dart';

class SportsSelectionPage extends ConsumerWidget {
  const SportsSelectionPage({super.key});

  static const List<String> allSports = [
    'Boys Basketball',
    'Girls Basketball',
    'Boys Soccer',
    'Girls Soccer',
    'Boys Volleyball',
    'Girls Volleyball',
    'Boys Cross Country',
    'Girls Cross Country',
    'Boys Track & Field',
    'Girls Track & Field',
    'Boys Swimming',
    'Girls Swimming',
    'Boys Tennis',
    'Girls Tennis',
    'Boys Golf',
    'Girls Golf',
    'Boys Lacrosse',
    'Girls Lacrosse',
    'Baseball',
    'Softball',
    'Wrestling'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSports = ref.watch(sportsPreferencesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SharedHeader(title: 'Select Sports'),
            Expanded(
              child: ListView.builder(
                itemCount: allSports.length,
                itemBuilder: (context, index) {
                  final sport = allSports[index];
                  final isSelected = selectedSports.contains(sport);
                  return CheckboxListTile(
                    title: Text(sport),
                    value: isSelected,
                    onChanged: (bool? value) {
                      final currentSelection =
                          List<String>.from(selectedSports);
                      if (value == true) {
                        if (!currentSelection.contains(sport)) {
                          currentSelection.add(sport);
                        }
                      } else {
                        currentSelection.remove(sport);
                      }
                      ref
                          .read(sportsPreferencesProvider.notifier)
                          .updateSelectedSports(currentSelection);
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
