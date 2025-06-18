// lib/presentation/placeholder_pages/flexes_page.dart

import 'package:flutter/material.dart';

class FlexesPage extends StatelessWidget {
  const FlexesPage({super.key});

  // --- Placeholder Data ---
  // You can easily change the number of flex periods by modifying this list.
  final List<String> _flexPeriods = const [
    'Flex 1',
    'Flex 2',
    'Flex 3',
    'Flex 4',
  ];
  // --- End of Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildDateSubtitle(),
          const SizedBox(height: 24),
          _buildFlexSections(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Flexes',
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.black, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'For Wednesday, August 28',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildFlexSections() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        // Use map to create a section for each item in the _flexPeriods list.
        children: _flexPeriods
            .map((title) => _FlexRegistrationSection(title: title))
            .toList(),
      ),
    );
  }
}

// A reusable widget for each "Flex" section
class _FlexRegistrationSection extends StatelessWidget {
  const _FlexRegistrationSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Register for $title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
