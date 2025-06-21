// lib/presentation/placeholder_pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/webview_sheet.dart';
import '../../widgets/login_sheet.dart';

enum ProfileActionType { info, link, login }

class ProfileOption {
  const ProfileOption({
    required this.title,
    required this.subtitle,
    required this.actionType,
    this.url,
  });
  final String title;
  final String subtitle;
  final ProfileActionType actionType;
  final String? url;
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final List<ProfileOption> _options = const [
    ProfileOption(
      title: 'App Info',
      subtitle: 'Version, credits, and more',
      actionType: ProfileActionType.info,
    ),
    ProfileOption(
      title: 'Your Athletic Profile',
      subtitle: 'Apply to sports teams with your profile',
      actionType: ProfileActionType.link,
      url: 'https://www.google.com',
    ),
    ProfileOption(
      title: 'Your Athletic Account',
      subtitle: 'Login with your athletic account',
      actionType: ProfileActionType.link,
      url: 'https://ncp-ar.rschooltoday.com/oar',
    ),
    ProfileOption(
      title: 'Flex Account',
      subtitle: 'Link your flex account to pick flexes',
      actionType: ProfileActionType.login,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const appInfoArticle = Article(
      title: 'App Information',
      subtitle: '',
      content: 'Version 1.0.0\nDeveloped by Northside App Team.\n\nThis application is designed to provide students and parents with easy access to school-related information. For support, please contact the school administration.',
      imagePath: null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 120.0),
        children: [
          const SizedBox(height: 40),
          _buildProfileHeader(),
          const SizedBox(height: 32),
          ..._options.map((option) {
            return _buildInfoCard(
              title: option.title,
              subtitle: option.subtitle,
              onTap: () {
                if (option.actionType == ProfileActionType.info) {
                  Get.bottomSheet(
                    ArticleDetailSheet(article: appInfoArticle),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                } else if (option.actionType == ProfileActionType.link && option.url != null) {
                  Get.bottomSheet(
                    WebViewSheet(url: option.url!),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                } else if (option.actionType == ProfileActionType.login) {
                  Get.bottomSheet(
                    const LoginSheet(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                }
              },
            );
          }).toList(),
          const SizedBox(height: 8),
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
          // This ensures the main name is bold
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

  Widget _buildInfoCard({required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
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
            Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
