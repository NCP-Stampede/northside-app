// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';

// --- Data Model for options ---
class ProfileOption {
  const ProfileOption({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
// --- End of Data Model ---

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- Placeholder Data ---
  final List<ProfileOption> _options = const [
    ProfileOption(title: 'My Info', subtitle: 'GPA, Address, Ethnicity...'),
    ProfileOption(title: 'Schedule', subtitle: 'Your School Schedule'),
    ProfileOption(title: 'Your Athletic Profile', subtitle: 'Apply to sports teams with your profile'),
    ProfileOption(title: 'Your Athletic Account', subtitle: 'Login with your athletic account'),
    ProfileOption(title: 'Flex Account', subtitle: 'Link your flex account to pick flexes'),
  ];
  // --- End of Placeholder Data ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 120.0),
        children: [
          const SizedBox(height: 40),
          _buildProfileHeader(),
          const SizedBox(height: 32),
          // Create the list of option cards from the data
          ..._options.map((option) => _buildInfoCard(option.title, option.subtitle)).toList(),
          const SizedBox(height: 8), // Space before the logout button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: const Icon(Icons.person, size: 60, color: Colors.black),
        ),
        const SizedBox(height: 16),
        const Text(
          'John',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '60546723',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Northside College Prep',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Text(
            'Log Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
