// lib/presentation/home_screen_content/home_screen_content.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_screen_content_controller.dart';

class HomeScreenContent extends GetView<HomeScreenContentController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE8A1A1), Color(0xFFADC6E6), Colors.white],
                stops: [0.0, 0.25, 0.4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildEventsCarousel(),
              const SizedBox(height: 20),
              Obx(() => _buildPageIndicator()),
            ],
          ),
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
            'Home',
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

  Widget _buildQuickActions() {
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
          _QuickActionButton(iconWidget: Image.asset('assets/images/grades_icon.png', width: 32, height: 32), label: 'Grades', onTap: () {}),
          _QuickActionButton(iconWidget: const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 26), label: 'Events', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/hoofbeat_icon.png', width: 32, height: 32), label: 'HoofBeat', onTap: () {}),
          _QuickActionButton(iconWidget: Image.asset('assets/images/flexes_icon.png', width: 32, height: 32), label: 'Flexes', onTap: () {}),
        ],
      ),
    );
  }

  // --- WIDGET WITH THE FIX ---
  Widget _buildEventsCarousel() {
    return SizedBox(
      // FIX: Increased the height to make the event card taller.
      height: 350,
      child: PageView.builder(
        controller: controller.pageController,
        itemCount: 3,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        onPageChanged: controller.onPageChanged,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildEventCard(),
          );
        },
      ),
    );
  }

  Widget _buildEventCard() {
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
              child: Image.asset('assets/images/homecoming_bg.png', fit: BoxFit.cover),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Homecoming 2024',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text('This Friday', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        const Spacer(),
                        Icon(Icons.more_horiz, size: 20, color: Colors.grey.shade600),
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.currentPageIndex.value == index
                ? const Color(0xFF333333)
                : Colors.grey.withOpacity(0.4),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [iconWidget, const SizedBox(width: 12), Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))],
        ),
      ),
    );
  }
}
