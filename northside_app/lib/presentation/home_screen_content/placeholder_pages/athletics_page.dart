// lib/presentation/placeholder_pages/athletics_page.dart

import 'package:flutter/material.dart';
import 'dart:ui';

class AthleticsPage extends StatelessWidget {
  const AthleticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildNewsCarousel(),
          const SizedBox(height: 32),
          _buildSectionHeader(context, 'Sports', () {}),
          const SizedBox(height: 16),
          _buildSportsGrid(),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildNewsCarousel() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        // FIX: Added clipBehavior to prevent the shadow from being cut off.
        clipBehavior: Clip.none,
        itemCount: 3,
        itemBuilder: (context, index) {
          return const _NewsCard(
            imagePath: 'assets/images/softball_image.png',
            title: 'Girls Softball make it to state',
            subtitle: 'For the first time in 2 years...',
          );
        },
      ),
    );
  }

  Widget _buildSportsGrid() {
    final sports = ['Baseball', 'Cross Country', 'Lacrosse', 'Soccer'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemCount: sports.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _SportButton(name: sports[index]);
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // FIX: Added shadow to match the style of other interactive elements.
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
              'Register for a sport',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // --- Other helper widgets are unchanged but included for completeness ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Athletics',
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

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.imagePath, required this.title, required this.subtitle});
  final String imagePath;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SportButton extends StatelessWidget {
  const _SportButton({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // FIX: Added shadow to give the button depth.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
