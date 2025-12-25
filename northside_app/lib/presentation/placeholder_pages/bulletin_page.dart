// lib/presentation/placeholder_pages/bulletin_page.dart

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../controllers/bulletin_controller.dart';
import '../../core/design_constants.dart';
import '../../core/utils/haptic_feedback_helper.dart';
import '../../models/article.dart';
import '../../models/bulletin_post.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/liquid_mesh_background.dart';
import '../../widgets/animated_segmented_control.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final BulletinController controller = Get.put(BulletinController(), permanent: true);
  final ScrollController _scrollController = ScrollController();
  
  String _selectedTab = 'Pinned';
  final List<String> _tabs = ['Pinned', 'All'];
  
  Map<String, List<BulletinPost>> _groupedPosts = {};
  Map<String, GlobalKey> _dateKeys = {};
  String? _todayKey;
  bool _showScrollToTodayButton = false;
  bool _hasScrolledInitially = false;

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _buildGroupedList();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasScrolledInitially) return;
    if (!_scrollController.hasClients) return;
    
    // Check if Today section is visible by looking at its GlobalKey
    bool todayIsVisible = false;
    if (_todayKey != null && _dateKeys.containsKey(_todayKey)) {
      final keyContext = _dateKeys[_todayKey]?.currentContext;
      if (keyContext != null) {
        final RenderBox? box = keyContext.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final position = box.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.of(context).size.height;
          // Today section is visible if it's within the viewport (between top and 70% of screen)
          // Also check if it's not too far above the viewport (position.dy > -100)
          todayIsVisible = position.dy > -100 && position.dy < screenHeight * 0.7;
        }
      }
    }
    
    // Show button whenever Today section is NOT visible (scrolled up or down away from it)
    final shouldShow = !todayIsVisible;
    
    if (_showScrollToTodayButton != shouldShow) {
      setState(() {
        _showScrollToTodayButton = shouldShow;
      });
    }
  }

  void _buildGroupedList() {
    final today = DateTime.now();
    List<BulletinPost> posts;
    
    if (_selectedTab == 'Pinned') {
      // Use controller pinned posts only
      posts = [...controller.pinnedPosts];
    } else {
      // Use controller all posts only
      posts = [...controller.allPosts.where((p) => !p.isPinned)];
    }
    
    posts.sort((a, b) => a.date.compareTo(b.date));
    
    final Map<String, List<BulletinPost>> grouped = {};
    _dateKeys.clear();
    
    for (var post in posts) {
      String dateHeader;
      if (isSameDay(post.date, today)) {
        dateHeader = 'Today';
        _todayKey = dateHeader;
      } else if (isSameDay(post.date, today.subtract(const Duration(days: 1)))) {
        dateHeader = 'Yesterday';
      } else if (isSameDay(post.date, today.add(const Duration(days: 1)))) {
        dateHeader = 'Tomorrow';
      } else {
        dateHeader = DateFormat('EEEE, MMMM d').format(post.date);
      }
      
      if (grouped[dateHeader] == null) {
        grouped[dateHeader] = [];
        _dateKeys[dateHeader] = GlobalKey();
      }
      grouped[dateHeader]!.add(post);
    }
    
    // Find the best key to scroll to if there's no "Today"
    if (_todayKey == null && grouped.isNotEmpty) {
      final keys = grouped.keys.toList();
      
      // Try to find closest future date
      for (final key in keys) {
        final firstPost = grouped[key]!.first;
        if (firstPost.date.isAfter(today)) {
          _todayKey = key;
          break;
        }
      }
      
      // If no future date, use the most recent past date
      if (_todayKey == null) {
        _todayKey = keys.last;
      }
    }
    
    setState(() => _groupedPosts = grouped);
    
    // Scroll to today after build
    if (!_hasScrolledInitially) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _scrollToToday(animate: false);
            _hasScrolledInitially = true;
          }
        });
      });
    }
  }

  void _scrollToToday({bool animate = true}) {
    if (_todayKey == null || !_dateKeys.containsKey(_todayKey)) return;
    
    final keyContext = _dateKeys[_todayKey]?.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: animate ? const Duration(milliseconds: 400) : Duration.zero,
        curve: Curves.easeInOut,
        alignment: 0.1, // Offset a bit from top to account for header
      );
      
      if (mounted) {
        setState(() {
          _showScrollToTodayButton = false;
        });
      }
    } else if (_scrollController.hasClients) {
      // Fallback: scroll to top
      _scrollController.animateTo(
        0,
        duration: animate ? const Duration(milliseconds: 400) : Duration.zero,
        curve: Curves.easeInOut,
      );
      
      if (mounted) {
        setState(() {
          _showScrollToTodayButton = false;
        });
      }
    }
  }

  void _onTabChanged(String tab) {
    HapticFeedbackHelper.buttonPress();
    setState(() {
      _selectedTab = tab;
      _hasScrolledInitially = false;
      _showScrollToTodayButton = false;
    });
    // Reset scroll position first
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _buildGroupedList();
  }

  @override
  Widget build(BuildContext context) {
    final dateKeys = _groupedPosts.keys.toList();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          const LiquidMeshBackground(),
          
          // Main scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header with integrated segmented control
              SliverPersistentHeader(
                pinned: true,
                delegate: _BulletinMeltingHeader(
                  title: 'Bulletin',
                  topPadding: topPadding,
                  tabs: _tabs,
                  selectedTab: _selectedTab,
                  onTabChanged: _onTabChanged,
                ),
              ),
              
              // Content with AnimatedContentSwitcher for tab animation
              SliverPadding(
                padding: EdgeInsets.only(
                  top: screenWidth * 0.02,
                  bottom: screenHeight * 0.15,
                ),
                sliver: SliverToBoxAdapter(
                  child: AnimatedContentSwitcher(
                    switchKey: _selectedTab,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Posts grouped by date
                        if (dateKeys.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.06),
                            child: Center(
                              child: Text(
                                _selectedTab == 'Pinned' 
                                    ? 'No pinned announcements' 
                                    : 'No announcements available',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: screenWidth * 0.04,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...dateKeys.expand((dateKey) => [
                            _buildDateHeader(dateKey),
                            ..._groupedPosts[dateKey]!.map((post) => _BulletinEventCard(post: post)),
                          ]).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Animated scroll to today button
          Positioned(
            bottom: screenHeight * 0.12,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSlide(
                offset: _showScrollToTodayButton ? Offset.zero : const Offset(0, 2),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: _showScrollToTodayButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !_showScrollToTodayButton,
                    child: _buildScrollToTodayButton(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToTodayButton(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () {
        HapticFeedbackHelper.buttonPress();
        _scrollToToday();
      },
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: screenWidth * 0.08,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenWidth * 0.03,
            ),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.15),
                ],
              ),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: screenWidth * 0.08,
                  cornerSmoothing: 1.0,
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.arrow_counterclockwise,
                  color: Colors.white,
                  size: screenWidth * 0.045,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'Back to Today',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isToday = date == 'Today';
    
    return Container(
      key: _dateKeys[date],
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.057,
        screenWidth * 0.04,
        screenWidth * 0.057,
        screenWidth * 0.02,
      ),
      child: Text(
        date,
        style: GoogleFonts.inter(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: isToday ? Colors.white : Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}

/// Custom header delegate that includes both title AND segmented control
/// The segmented control moves up/down with the header as it shrinks/expands
class _BulletinMeltingHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final double topPadding;
  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;

  _BulletinMeltingHeader({
    required this.title,
    required this.topPadding,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  double get minExtent => topPadding + 155.0; // Fixed size - title + segmented control
  @override
  double get maxExtent => topPadding + 155.0; // Fixed size - title + segmented control

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Fixed title size - matches other headers at expanded position (36)
    final double titleFontSize = 36;
    // Match Events page spacing: header ends, then screenWidth * 0.04 gap, then content
    final double titleToTabSpacing = screenWidth * 0.055;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // THE TOP-DOWN MELTING GLASS LAYER (background - behind content)
        ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black,
                Colors.black.withOpacity(0.8),
                Colors.black.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 0.7, 0.82, 0.9, 0.96, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030308).withOpacity(1.0),
                      const Color(0xFF030308).withOpacity(1.0),
                      const Color(0xFF030308).withOpacity(1.0),
                      const Color(0xFF030308).withOpacity(1.0),
                      const Color(0xFF030308).withOpacity(0.7),
                      const Color(0xFF030308).withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 0.68, 0.8, 0.9, 0.96, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // HEADER CONTENT - Title + Segmented Control (on top of blur layer)
        // Use same positioning as LiquidMeltingHeader for the title
        Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: topPadding + 10,
            bottom: 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Title row - matches LiquidMeltingHeader exactly
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: titleToTabSpacing),
              // Segmented control - part of header
              SizedBox(
                height: screenWidth * 0.105,
                child: AnimatedSegmentedControl(
                  segments: tabs,
                  selectedSegment: selectedTab,
                  onSelectionChanged: onTabChanged,
                  compact: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _BulletinMeltingHeader oldDelegate) {
    return oldDelegate.selectedTab != selectedTab || 
           oldDelegate.topPadding != topPadding;
  }
}

class _BulletinEventCard extends StatelessWidget {
  const _BulletinEventCard({required this.post});
  final BulletinPost post;

  void _showArticleSheet(BulletinPost post) {
    Get.bottomSheet(
      ArticleDetailDraggableSheet(article: Article(
        title: post.title,
        subtitle: post.subtitle,
        imagePath: post.imagePath,
        content: post.content,
      )),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: false,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    
    return GestureDetector(
      onTapDown: (_) => HapticFeedbackHelper.buttonPress(),
      onTapUp: (_) => HapticFeedbackHelper.buttonRelease(),
      onTap: () => _showArticleSheet(post),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.057,
          0,
          screenWidth * 0.057,
          isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04,
        ),
        child: ClipSmoothRect(
          radius: SmoothBorderRadius(
            cornerRadius: DesignConstants.get24Radius(context),
            cornerSmoothing: 1.0,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
              decoration: ShapeDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.25),
                    Colors.white.withOpacity(0.12),
                  ],
                ),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: DesignConstants.get24Radius(context),
                    cornerSmoothing: 1.0,
                  ),
                  side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (post.isPinned)
                        Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.02),
                          child: Icon(
                            CupertinoIcons.pin_fill,
                            size: screenWidth * 0.04,
                            color: Colors.amber,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          post.title,
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        child: Text(
                          post.subtitle,
                          style: TextStyle(
                            fontSize: isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
