// lib/presentation/placeholder_pages/bulletin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';

// --- CENTRAL DATA SOURCE ---
// In a real app, this would come from your backend/API.
final List<Article> allAnnouncements = [
  // Pinned Items
  Article(
    title: 'Finals Week Schedule',
    subtitle: 'Important Dates & Times',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 10)),
    content: 'Detailed schedule for final exams.',
    isPinned: true,
  ),
  Article(
    title: 'Summer Break Info',
    subtitle: 'Last Day of School: June 28',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 20)),
    content: 'Information about the upcoming summer break.',
    isPinned: true,
  ),
  // Past Items
  Article(
    title: 'Last Week\'s Soccer Game',
    subtitle: 'A thrilling victory!',
    date: DateTime.now().subtract(const Duration(days: 7)),
    content: 'A recap of the amazing game last week.',
  ),
  Article(
    title: 'Yesterday\'s Bake Sale',
    subtitle: 'Raised over \$500!',
    date: DateTime.now().subtract(const Duration(days: 1)),
    content: 'Thank you for your support!',
  ),
  // Today's Items
  Article(
    title: 'Parent-Teacher Conferences',
    subtitle: 'Today in the main hall',
    date: DateTime.now(),
    content: 'Conferences are happening all day today.',
  ),
  Article(
    title: 'Library Closing Early',
    subtitle: 'Closes at 3 PM today',
    date: DateTime.now(),
    content: 'The library will be closing early for maintenance.',
  ),
  // Future Items
  Article(
    title: 'Homecoming 2024',
    subtitle: 'This Friday',
    imagePath: 'assets/images/homecoming_bg.png',
    date: DateTime.now().add(const Duration(days: 3)),
    content: 'Join us for a night of fun and festivities!',
  ),
  Article(
    title: 'Spirit Week',
    subtitle: 'Starts next Monday!',
    date: DateTime.now().add(const Duration(days: 5)),
    content: 'Get ready for a week of school spirit!',
  ),
];
// --- END OF DATA SOURCE ---


class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _todayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // This scrolls to the "Today" section automatically after the page is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _todayKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: 0.05 // Align near the top of the viewport
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showArticleSheet(Article article) {
    Get.bottomSheet(
      ArticleDetailSheet(article: article),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinned = allAnnouncements.where((a) => a.isPinned).toList();
    final nonPinned = allAnnouncements.where((a) => !a.isPinned).toList();
    // Sort announcements by date, from past to future.
    nonPinned.sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF2F2F7),
            expandedHeight: 200.0, // Adjust as needed
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SharedHeader(title: 'Bulletin'),
                  const SizedBox(height: 16),
                  _buildSectionHeader("Pinned"),
                  const SizedBox(height: 16),
                  _buildPinnedCarousel(pinned),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = nonPinned[index];
                final isFirst = index == 0;
                final previousArticleDate = isFirst ? null : nonPinned[index - 1].date;
                final showDateHeader = isFirst || !isSameDay(article.date, previousArticleDate);

                // Check if this is the first item for "Today"
                final isToday = isSameDay(article.date, DateTime.now());
                final isFirstToday = isToday && (isFirst || !isSameDay(previousArticleDate, DateTime.now()));
                
                return Column(
                  children: [
                    if (showDateHeader)
                      _buildDateHeader(article.date, key: isFirstToday ? _todayKey : null),
                    GestureDetector(
                      onTap: () => _showArticleSheet(article),
                      child: _buildAnnouncementCard(article),
                    ),
                  ],
                );
              },
              childCount: nonPinned.length,
            ),
          ),
        ],
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

  Widget _buildPinnedCarousel(List<Article> articles) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        clipBehavior: Clip.none,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () => _showArticleSheet(article),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: _buildAnnouncementCard(article, isPinned: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, {Key? key}) {
    String formattedDate;
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      formattedDate = 'Today';
    } else if (isSameDay(date, now.add(const Duration(days: 1)))) {
      formattedDate = 'Tomorrow';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = DateFormat('EEEE, MMMM d').format(date);
    }

    return Padding(
      key: key,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        formattedDate,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnnouncementCard(Article article, {bool isPinned = false}) {
    return Container(
      margin: isPinned ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: isPinned ? null : BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (article.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(article.imagePath!, width: 60, height: 60, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
