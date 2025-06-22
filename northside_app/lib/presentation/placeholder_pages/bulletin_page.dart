// lib/presentation/placeholder_pages/bulletin_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart'; // FIX: Added the missing import

import '../../models/bulletin_post.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  // --- Placeholder Data ---
  final List<BulletinPost> _allPosts = [
    BulletinPost(title: 'Homecoming Tickets on Sale!', subtitle: 'Get them before they sell out!', date: DateTime.now().add(const Duration(days: 2)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Spirit Week Next Week', subtitle: 'Show your school spirit!', date: DateTime.now().add(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png', isPinned: true),
    BulletinPost(title: 'Parent-Teacher Conferences', subtitle: 'Sign-ups are open', date: DateTime.now(), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'Soccer Team Wins!', subtitle: 'A thrilling victory', date: DateTime.now().subtract(const Duration(days: 1)), imagePath: 'assets/images/homecoming_bg.png'),
    BulletinPost(title: 'School Play Auditions', subtitle: 'In the auditorium', date: DateTime.now().add(const Duration(days: 5)), imagePath: 'assets/images/homecoming_bg.png'),
  ];
  // --- End Placeholder Data ---

  List<dynamic> _groupedItems = [];

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
  }
  
  void _buildGroupedList() {
    final today = DateTime.now();
    final nonPinnedPosts = _allPosts.where((post) => !post.isPinned).toList();
    nonPinnedPosts.sort((a, b) => b.date.compareTo(a.date));

    final Map<String, List<BulletinPost>> grouped = {};
    for (var post in nonPinnedPosts) {
      String dateHeader;
      if (isSameDay(post.date, today)) {
        dateHeader = 'Today';
      } else if (isSameDay(post.date, today.subtract(const Duration(days: 1)))) {
        dateHeader = 'Yesterday';
      } else {
        dateHeader = DateFormat('MMMM d, yyyy').format(post.date);
      }
      if (grouped[dateHeader] == null) {
        grouped[dateHeader] = [];
      }
      grouped[dateHeader]!.add(post);
    }
    
    final List<dynamic> flattenedList = [];
    grouped.forEach((date, posts) {
      flattenedList.add(date);
      flattenedList.addAll(posts);
    });
    setState(() {
      _groupedItems = flattenedList;
    });
  }

  void _showArticleSheet(BulletinPost post) {
    Get.bottomSheet(
      ArticleDetailSheet(
        article: Article(
          title: post.title,
          subtitle: post.subtitle,
          imagePath: post.imagePath,
          content: post.content,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinnedPosts = _allPosts.where((post) => post.isPinned).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SharedHeader(title: 'Bulletin')),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (pinnedPosts.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader("Pinned")),
            SliverToBoxAdapter(child: _buildPinnedCarousel(pinnedPosts)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _groupedItems[index];
                if (item is String) {
                  return _buildDateHeader(item);
                } else if (item is BulletinPost) {
                  return _buildEventCard(item);
                }
                return const SizedBox.shrink();
              },
              childCount: _groupedItems.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      child: Text(
        date,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<BulletinPost> posts) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        clipBehavior: Clip.none,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildEventCard(posts[index], isPinned: true);
        },
      ),
    );
  }

  Widget _buildEventCard(BulletinPost post, {bool isPinned = false}) {
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        margin: isPinned ? const EdgeInsets.only(right: 16) : const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: isPinned ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(post.imagePath!, fit: BoxFit.cover),
              ),
            ),
            if (!isPinned)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(post.subtitle, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
