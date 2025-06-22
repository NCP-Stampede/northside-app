// lib/presentation/home_screen_content/home_screen_content.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen_content_controller.dart';
import '../app_shell/app_shell_controller.dart';
import '../placeholder_pages/hoofbeat_page.dart';
import '../../models/article.dart';
import '../../widgets/article_detail_sheet.dart';
import '../../widgets/shared_header.dart';

// Import the bulletin page to access its central data source
import '../placeholder_pages/bulletin_page.dart';

class HomeScreenContent extends GetView<HomeScreenContentController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter the announcements to get only relevant items for the carousel.
    // "Relevant" is defined here as not pinned and occurring today or in the future.
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final upcomingAnnouncements = allAnnouncements
        .where((article) =>
            !article.isPinned &&
            !article.date.isBefore(today))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF44336), // Vibrant Red
                  Color(0xFF2196F3), // Vibrant Blue
                  Colors.white
                ],
                stops: [0.0, 0.25, 0.4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SharedHeader(title: 'Home'),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 32),
              // Pass the filtered list to the carousel
              _buildEventsCarousel(upcomingAnnouncements),
              const SizedBox(height: 20),
              // Pass the count of the filtered list to the indicator
              Obx(() => _buildPageIndicator(upcomingAnnouncements.length)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final AppShellController appShellController = Get.find();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.7,
        children: [
          _QuickActionButton(iconWidget: const Icon(Icons.sports_basketball, color: Colors.black54, size: 26), label: 'Athletics', onTap: () => appShellController.changePage(1)),
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 26), label: 'Events', onTap: () => appShellController.changePage(2)),
          _QuickActionButton(iconWidget: const Icon(Icons.article, color: Colors.black54, size: 26), label: 'HoofBeat', onTap: () => Get.to(() => const HoofBeatPage())),
          _QuickActionButton(iconWidget: const Icon(Icons.article_outlined, color: Colors.black54, size: 26), label: 'Bulletin', onTap: () => appShellController.changePage(3)),
        ],
      ),
    );
  }

  Widget _buildEventsCarousel(List<Article> articles) {
    if (articles.isEmpty) {
      return Container(
        height: 350,
        margin: const EdgeInsets.symmetric(horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: const Center(
          child: Text(
            "No upcoming announcements",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return SizedBox(
      height: 350,
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: articles.length,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () {
              Get.bottomSheet(
                ArticleDetailSheet(article: article),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildEventCard(article),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Article article) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(article.imagePath!, fit: BoxFit.cover),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(article.subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        const Spacer(),
                        const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('More Details', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageCount) {
    // If there are no pages, don't show an indicator.
    if (pageCount == 0) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.currentPageIndex.value == index ? const Color(0xFF333333) : Colors.grey.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.iconWidget, required this.label, required this.onTap});
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
}
