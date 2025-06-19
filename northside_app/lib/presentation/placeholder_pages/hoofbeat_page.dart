// lib/presentation/placeholder_pages/hoofbeat_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HoofBeatPage extends StatelessWidget {
  const HoofBeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTopStoryCarousel(),
          const SizedBox(height: 32),
          _buildSectionHeader("Trending Stories"),
          const SizedBox(height: 16),
          _buildTrendingStories(),
          const SizedBox(height: 32),
          _buildSectionHeader("News"),
          const SizedBox(height: 16),
          _buildNewsList(),
          const SizedBox(height: 32),
          _buildSectionHeader("Polls"),
          const SizedBox(height: 16),
          _buildPollsSection(),
        ],
      ),
    );
  }

  // --- Section Builder Widgets ---

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        'HoofBeat',
        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildTopStoryCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        clipBehavior: Clip.none,
        itemCount: 3,
        itemBuilder: (context, index) {
          return const _TopStoryCard(
            imagePath: 'assets/images/school_building.png',
            title: 'Building Damage: Insights from the Principal',
            authors: 'John Appleseed and Mac Pineapple',
          );
        },
      ),
    );
  }

  Widget _buildTrendingStories() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 24),
        children: const [
          _TrendingStoryCard(imagePath: 'assets/images/trending_1.png', title: 'Hopping into Spring: Bunny Bowl 2024', author: 'By John Appleseed'),
          _TrendingStoryCard(imagePath: 'assets/images/trending_2.png', title: '2023/2024 20 Hour Show', author: 'By John Appleseed'),
          _TrendingStoryCard(imagePath: 'assets/images/trending_3.png', title: 'The Grass is Greener on This Side', author: 'By John Appleseed'),
        ],
      ),
    );
  }

  Widget _buildNewsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: List.generate(3, (index) => const _NewsListItem(
          imagePath: 'assets/images/news_swim.png',
          title: 'Making a Splash: Men\'s Swim completes season',
          author: 'By John Appleseed',
        )),
      ),
    );
  }

  Widget _buildPollsSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: _PollCard(
        question: 'Do You Have Senioritis?',
        options: ['Yes', 'No', 'Maybe'],
      ),
    );
  }
}

// --- Reusable Component Widgets ---

class _TopStoryCard extends StatelessWidget {
  const _TopStoryCard({required this.imagePath, required this.title, required this.authors});
  final String imagePath;
  final String title;
  final String authors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imagePath, fit: BoxFit.cover),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                      child: const Text('News', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2),
                  const SizedBox(height: 8),
                  Text(authors, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// FIX: This widget now has a proper card background.
class _TrendingStoryCard extends StatelessWidget {
  const _TrendingStoryCard({required this.imagePath, required this.title, required this.author});
  final String imagePath;
  final String title;
  final String author;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(imagePath, height: 100, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(author, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FIX: Corrected the layout of this widget to prevent overflow.
class _NewsListItem extends StatelessWidget {
  const _NewsListItem({required this.imagePath, required this.title, required this.author});
  final String imagePath;
  final String title;
  final String author;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold), softWrap: true),
                const SizedBox(height: 4),
                Text(author, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatefulWidget {
  const _PollCard({required this.question, required this.options});
  final String question;
  final List<String> options;

  @override
  State<_PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<_PollCard> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...widget.options.map((option) => _buildPollOption(option)).toList(),
        ],
      ),
    );
  }

  Widget _buildPollOption(String option) {
    final isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Text(option, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
