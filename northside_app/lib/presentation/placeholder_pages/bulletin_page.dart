// lib/presentation/placeholder_pages/bulletin_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../controllers/bulletin_controller.dart';
import '../../core/design_constants.dart';
import '../../models/article.dart';
import '../../models/bulletin_post.dart';
import '../../widgets/article_detail_draggable_sheet.dart';
import '../../widgets/shared_header.dart';

class BulletinPage extends StatefulWidget {
  const BulletinPage({super.key});

  @override
  State<BulletinPage> createState() => _BulletinPageState();
}

class _BulletinPageState extends State<BulletinPage> {
  final BulletinController controller = Get.put(BulletinController(), permanent: true);

  Map<String, List<BulletinPost>> _groupedPosts = {};
  ScrollController? _draggableSheetController;
  int? _todaySectionIndex;
  Timer? _inactivityTimer;
  Timer? _midnightTimer;
  bool _isAutoScrolling = false;
  // double? _lastSheetExtent;
  double? _initialSheetExtent;
  
  // Track section headers with GlobalKeys for precise measurement
  Map<String, GlobalKey> _sectionKeys = {};

  // Calculate responsive sheet extents based on screen dimensions
  double get responsiveInitialExtent {
    if (_initialSheetExtent != null) return _initialSheetExtent!;
    
    final context = this.context;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust based on screen aspect ratio and size - balanced to show first card without next date
    double baseExtent = 0.49; // 49% for most devices (increased from 46%)
    
    // For very tall/narrow screens (like iPhone 14 Pro Max), reduce slightly
    if (screenHeight / screenWidth > 2.2) {
      baseExtent = 0.45; // Increased from 0.42
    }
    // For shorter/wider screens (like iPad landscape), keep at base
    else if (screenHeight / screenWidth < 1.5) {
      baseExtent = 0.49; // Increased from 0.46
    }
    
    _initialSheetExtent = baseExtent;
    // _lastSheetExtent = baseExtent;
    return baseExtent;
  }

  // For drag handle
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  double? dragStartExtent;
  // bool _isDraggingHandle = false;

  final GlobalKey _headerKey = GlobalKey();
  final GlobalKey _sectionHeaderKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey();
  double? _calculatedMinExtent;

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();
    _buildGroupedList();
    // Add listener to sheet controller for immediate scroll to Today
    _sheetController.addListener(_onSheetExtentChanged);
    _scheduleMidnightUpdate();
  }

  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    _midnightTimer = Timer(duration, () {
      _buildGroupedList();
      setState(() {});
      _scheduleMidnightUpdate(); // Reschedule for next midnight
    });
  }

  void _onSheetExtentChanged() {
    // If sheet is at the snap-back extent, immediately scroll to Today (no animation)
    final snapBackExtent = _getSnapBackExtent();
    if ((_sheetController.size - snapBackExtent).abs() < 0.01) {
      _scrollToTodaySection(animate: true);
    }
  }

  double _getSnapBackExtent() {
    final initialExtent = responsiveInitialExtent;
    
    // Use calculated min extent if available, otherwise use a lower snap-back extent
    if (_calculatedMinExtent != null) {
      // Ensure we never cover pinned content by using the max of calculated and initial
      // But cap it at a reasonable maximum to prevent the sheet from being too high
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      
      // Make max allowed responsive to screen size, match initial extent for consistent snap-back
      double maxAllowed = initialExtent; // Match initial extent for consistent snap-back
      if (screenHeight / screenWidth > 2.2) {
        maxAllowed = initialExtent; // Match initial extent for tall screens
      } else if (screenHeight / screenWidth < 1.5) {
        maxAllowed = initialExtent; // Match initial extent for wider screens
      }
      
      final safeExtent = (_calculatedMinExtent! > maxAllowed ? maxAllowed : _calculatedMinExtent!);
      return safeExtent.clamp(0.1, maxAllowed);
    }
    // Return initial extent to match the initial height for consistent snap-back
    return initialExtent;
  }

  void _buildGroupedList() {
    final today = DateTime.now();
    final nonPinnedPosts = controller.allPosts.where((post) => !post.isPinned).toList();
    nonPinnedPosts.sort((a, b) => a.date.compareTo(b.date));
    final Map<String, List<BulletinPost>> grouped = {};
    for (var post in nonPinnedPosts) {
      String dateHeader;
      if (isSameDay(post.date, today)) dateHeader = 'Today';
      else if (isSameDay(post.date, today.subtract(const Duration(days: 1)))) dateHeader = 'Yesterday';
      else if (isSameDay(post.date, today.add(const Duration(days: 1)))) dateHeader = 'Tomorrow';
      else dateHeader = DateFormat('EEEE, MMMM d').format(post.date);
      if (grouped[dateHeader] == null) grouped[dateHeader] = [];
      grouped[dateHeader]!.add(post);
    }
    setState(() => _groupedPosts = grouped);

    // Generate GlobalKeys for each section header to track their positions
    _sectionKeys.clear();
    for (String sectionKey in grouped.keys) {
      _sectionKeys[sectionKey] = GlobalKey();
    }

    // Find the most relevant section to show (Today, Tomorrow, Yesterday, closest future, closest past)
    final keys = grouped.keys.toList();
    int? targetSectionIndex;

    // First try to find 'Today'
    targetSectionIndex = keys.indexOf('Today');
    
    // If no 'Today', try 'Tomorrow'
    if (targetSectionIndex == -1) {
      targetSectionIndex = keys.indexOf('Tomorrow');
    }
    
    // If no 'Tomorrow', try 'Yesterday'
    if (targetSectionIndex == -1) {
      targetSectionIndex = keys.indexOf('Yesterday');
    }

    // If none of the above, find the closest future date, or if no future dates, the closest past date
    if (targetSectionIndex == -1 && keys.isNotEmpty) {
      int? closestFutureIndex;
      int? closestPastIndex;
      Duration? closestFutureDifference;
      Duration? closestPastDifference;
      
      for (int i = 0; i < keys.length; i++) {
        final sectionPosts = grouped[keys[i]]!;
        if (sectionPosts.isNotEmpty) {
          final sectionDate = sectionPosts.first.date;
          final difference = sectionDate.difference(today);
          
          if (difference.inDays > 0) {
            // Future date
            if (closestFutureIndex == null || difference < closestFutureDifference!) {
              closestFutureIndex = i;
              closestFutureDifference = difference;
            }
          } else if (difference.inDays < 0) {
            // Past date
            final pastDifference = difference.abs();
            if (closestPastIndex == null || pastDifference < closestPastDifference!) {
              closestPastIndex = i;
              closestPastDifference = pastDifference;
            }
          }
        }
      }
      
      // Prefer future dates over past dates
      if (closestFutureIndex != null) {
        targetSectionIndex = closestFutureIndex;
      } else if (closestPastIndex != null) {
        targetSectionIndex = closestPastIndex;
      } else {
        targetSectionIndex = 0; // Fallback to first section
      }
    }

    // If still not found, fallback to first section
    if (targetSectionIndex < 0) {
      targetSectionIndex = 0;
    }

    _todaySectionIndex = targetSectionIndex;

    // Debug: print all section headers and their dates
    print('=== BULLETIN DEBUG INFO ===');
    print('Today is: $today');
    print('Total sections found: ${keys.length}');
    print('--- All Section Headers ---');
    for (int i = 0; i < keys.length; i++) {
      final sectionPosts = grouped[keys[i]]!;
      if (sectionPosts.isNotEmpty) {
        final sectionDate = sectionPosts.first.date;
        final daysDiff = sectionDate.difference(today).inDays;
        print('Index $i: "${keys[i]}" | Date: $sectionDate | Days from today: $daysDiff');
      }
    }
    print('--- Selection Process ---');
    print('Looking for "Today": ${keys.contains("Today") ? "FOUND" : "NOT FOUND"}');
    print('Looking for "Tomorrow": ${keys.contains("Tomorrow") ? "FOUND" : "NOT FOUND"}');
    print('Looking for "Yesterday": ${keys.contains("Yesterday") ? "FOUND" : "NOT FOUND"}');
    print('Selected target section index: $targetSectionIndex');
    if (targetSectionIndex >= 0 && targetSectionIndex < keys.length) {
      print('Selected section header: "${keys[targetSectionIndex]}"');
    }
    print('===========================');
  }

  void _onScroll() {
    if (_isAutoScrolling) return;
    _inactivityTimer?.cancel();
    
    // Make inactivity timeout responsive to device type
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Longer timeout for tablets/larger screens, shorter for phones
    Duration timeoutDuration;
    if (screenWidth > 600 || screenHeight > 900) {
      timeoutDuration = const Duration(seconds: 45); // Tablets get longer timeout
    } else {
      timeoutDuration = const Duration(seconds: 30); // Phones get standard timeout
    }
    
    _inactivityTimer = Timer(timeoutDuration, () {
      _scrollToTodaySection(animate: true);
    });
  }

  void _scrollToTodaySection({bool animate = false}) {
    print('🎯 _scrollToTodaySection called - animate: $animate');
    print('   _todaySectionIndex: $_todaySectionIndex');
    print('   _draggableSheetController: ${_draggableSheetController != null ? 'exists' : 'null'}');
    
    if (_todaySectionIndex == null || _todaySectionIndex! < 0) {
      print('❌ Invalid target section index: $_todaySectionIndex');
      return;
    }
    if (_draggableSheetController == null) {
      print('❌ Draggable sheet controller is null');
      return;
    }
    
    final keys = _groupedPosts.keys.toList();
    if (_todaySectionIndex! >= keys.length) {
      print('❌ Target index $_todaySectionIndex >= keys length ${keys.length}');
      return;
    }
    
    final targetSectionKey = keys[_todaySectionIndex!];
    final targetGlobalKey = _sectionKeys[targetSectionKey];
    
    print('   Target section key: "$targetSectionKey"');
    print('   Target GlobalKey: ${targetGlobalKey != null ? 'exists' : 'null'}');
    
    if (targetGlobalKey == null) {
      print('❌ No GlobalKey found for target section: $targetSectionKey');
      print('   Available section keys: ${_sectionKeys.keys.toList()}');
      return;
    }
    
    // Wait for next frame to ensure widgets are rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSectionWithPixelMeasurement(targetGlobalKey, targetSectionKey, animate);
    });
  }
  
  void _scrollToSectionWithPixelMeasurement(GlobalKey targetKey, String targetSectionKey, bool animate) {
    final scrollPosition = _draggableSheetController!.position;
    
    print('🔍 COLLECTING FRESH POSITION DATA:');
    print('   Target section: "$targetSectionKey" (index $_todaySectionIndex)');
    print('   Current scroll position: ${scrollPosition.pixels.toStringAsFixed(1)}px');
    print('   Max scroll extent: ${scrollPosition.maxScrollExtent.toStringAsFixed(1)}px');
    
    // Collect fresh position data from all rendered sections
    _collectFreshPositionData(targetKey, targetSectionKey, animate);
  }
  
  void _collectFreshPositionData(GlobalKey targetKey, String targetSectionKey, bool animate) {
    final scrollPosition = _draggableSheetController!.position;
    // final keys = _groupedPosts.keys.toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    
    print('📊 COLLECTING REAL POSITION DATA:');
    
    // Get the ListView's RenderBox to establish coordinate system
    final RenderBox? listViewBox = _draggableSheetController!.position.context.notificationContext?.findRenderObject() as RenderBox?;
    
    if (listViewBox == null) {
      print('❌ Could not find ListView RenderBox, falling back to estimated calculation');
      _fallbackToEstimatedScroll(targetSectionKey, animate);
      return;
    }
    
    // Get the target section's RenderBox
    final RenderBox? targetRenderBox = targetKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (targetRenderBox == null) {
      print('❌ Could not find target RenderBox for: $targetSectionKey');
      _fallbackToEstimatedScroll(targetSectionKey, animate);
      return;
    }
    
    try {
      // Get the target section's position relative to the ListView
      final Offset targetPosition = targetRenderBox.localToGlobal(Offset.zero);
      final Offset listViewPosition = listViewBox.localToGlobal(Offset.zero);
      
      // Calculate the relative position within the ListView
      final double targetOffsetInList = targetPosition.dy - listViewPosition.dy;
      
      // Account for current scroll position to get the absolute offset
      final double absoluteTargetOffset = targetOffsetInList + scrollPosition.pixels;
      
      // Add visual offset for comfortable positioning
      final double dragHandleHeight = screenWidth * 0.029 + screenWidth * 0.019 + screenWidth * 0.012;
      final double topBuffer = screenWidth * 0.02;
      final double visualOffset = dragHandleHeight + topBuffer + (screenWidth * 0.03); // Slightly more spacing
      
      // Calculate final scroll position
      final double finalOffset = (absoluteTargetOffset - visualOffset).clamp(0.0, scrollPosition.maxScrollExtent);
      
      print('📍 FRESH POSITION CALCULATION:');
      print('   Target global position: ${targetPosition.dy.toStringAsFixed(1)}px');
      print('   ListView global position: ${listViewPosition.dy.toStringAsFixed(1)}px');
      print('   Target offset in list: ${targetOffsetInList.toStringAsFixed(1)}px');
      print('   Absolute target offset: ${absoluteTargetOffset.toStringAsFixed(1)}px');
      print('   Visual offset: ${visualOffset.toStringAsFixed(1)}px');
      print('   Final scroll offset: ${finalOffset.toStringAsFixed(1)}px');
      
      if (animate) {
        _isAutoScrolling = true;
        _draggableSheetController!.animateTo(
          finalOffset,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        ).then((_) => _isAutoScrolling = false);
      } else {
        _draggableSheetController!.jumpTo(finalOffset);
      }
      
    } catch (e) {
      print('❌ Error calculating fresh positions: $e');
      print('   Falling back to estimated calculation...');
      _fallbackToEstimatedScroll(targetSectionKey, animate);
    }
  }
  
  double _calculateCardHeight(double screenWidth, bool isNarrowScreen) {
    final double cardPadding = (isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04) * 2;
    final double titleHeight = (isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.055) * 2.2;
    final double spacingBetween = isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02;
    final double subtitleHeight = isNarrowScreen ? screenWidth * 0.045 : screenWidth * 0.045;
    return cardPadding + titleHeight + spacingBetween + subtitleHeight;
  }
  
  void _fallbackToEstimatedScroll(String targetSectionKey, bool animate) {
    print('🔄 Using fallback estimated scroll for: $targetSectionKey');
    final scrollPosition = _draggableSheetController!.position;
    final keys = _groupedPosts.keys.toList();
    final double screenWidth = MediaQuery.of(context).size.width;
    
    double targetOffset = 0.0;
    
    // Calculate estimated position
    for (int i = 0; i < _todaySectionIndex!; i++) {
      targetOffset += screenWidth * 0.13; // Header height
      final cardsCount = _groupedPosts[keys[i]]!.length;
      final bool isNarrowScreen = screenWidth < 360;
      final double cardHeight = _calculateCardHeight(screenWidth, isNarrowScreen);
      final double cardMargin = isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04;
      targetOffset += cardsCount * (cardHeight + cardMargin);
    }
    
    // Add visual offset to account for drag handle and padding
    // This ensures the target section appears nicely positioned, not at the very top
    final double dragHandleHeight = screenWidth * 0.029 + screenWidth * 0.019 + screenWidth * 0.012; // top + bottom + handle height
    final double topBuffer = screenWidth * 0.02; // ListView top padding
    final double visualOffset = dragHandleHeight + topBuffer + (screenWidth * 0.02); // Extra visual spacing
    
    // Subtract the visual offset so the section appears positioned nicely
    final double adjustedOffset = (targetOffset - visualOffset).clamp(0.0, scrollPosition.maxScrollExtent);
    
    print('📍 FALLBACK SCROLL:');
    print('   Raw target offset: ${targetOffset.toStringAsFixed(1)}px');
    print('   Visual offset: ${visualOffset.toStringAsFixed(1)}px');
    print('   Final adjusted offset: ${adjustedOffset.toStringAsFixed(1)}px');
    
    if (animate) {
      _isAutoScrolling = true;
      _draggableSheetController!.animateTo(
        adjustedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ).then((_) => _isAutoScrolling = false);
    } else {
      _draggableSheetController!.jumpTo(adjustedOffset);
    }
  }

  // void _showArticleSheet(BulletinPost post) {
  //   Get.bottomSheet(
  //     ArticleDetailDraggableSheet(article: Article(
  //       title: post.title,
  //       subtitle: post.subtitle,
  //       imagePath: post.imagePath,
  //       content: post.content,
  //     )),
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     useRootNavigator: false,
  //     enableDrag: true,
  //   );
  // }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _midnightTimer?.cancel();
    _sheetController.removeListener(_onSheetExtentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinnedPosts = controller.pinnedPosts;
    final dateKeys = _groupedPosts.keys.toList();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topSpacer = screenWidth * 0.057; // ~24px at 420px width
    // final double betweenSpacer = 0; // Set to 0 to remove gap

    // Calculate dynamic minimum extent to avoid covering pinned section (always present now)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final headerBox = _headerKey.currentContext?.findRenderObject() as RenderBox?;
      final sectionHeaderBox = _sectionHeaderKey.currentContext?.findRenderObject() as RenderBox?;
      final carouselBox = _carouselKey.currentContext?.findRenderObject() as RenderBox?;
      if (headerBox != null && sectionHeaderBox != null && carouselBox != null) {
        final double totalHeight =
          headerBox.size.height +
          topSpacer +
          sectionHeaderBox.size.height +
          carouselBox.size.height +
          screenWidth * 0.038; // Add small buffer (~16px at 420px width)
        final double calculatedMin = (totalHeight / screenHeight).clamp(0.1, 0.5);
        if (_calculatedMinExtent != calculatedMin) {
          setState(() {
            _calculatedMinExtent = calculatedMin;
          });
        }
      }
    });

    final double effectiveMinExtent = _getSnapBackExtent();
    final double effectiveInitialExtent = responsiveInitialExtent;
    
    // Ensure minChildSize <= initialChildSize to prevent Flutter assertion error
    final double safeMinExtent = (effectiveMinExtent > effectiveInitialExtent ? effectiveInitialExtent : effectiveMinExtent) * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0), // Deep blue
                  Color(0xFF1976D2), // Blue
                  Color(0xFF42A5F5), // Light blue
                  Color(0xFF90CAF9), // Very light blue
                  Color(0xFFF2F2F7), // Transition to background
                  Color(0xFFF2F2F7), // Background
                ],
                stops: [0.0, 0.10, 0.22, 0.32, 0.45, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main header and pinned carousel always visible
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SharedHeader(title: 'Bulletin'),
              SizedBox(height: topSpacer),
              _buildSectionHeader("Pinned", key: _sectionHeaderKey),
              if (pinnedPosts.isNotEmpty) 
                _buildPinnedCarousel(pinnedPosts, key: _carouselKey)
              else
                _buildEmptyPinnedSection(key: _carouselKey),
              // Remove the betweenSpacer from the layout
              // SizedBox(height: betweenSpacer),
            ],
          ),
          // DraggableScrollableSheet overlays lower part only
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: effectiveInitialExtent,
              minChildSize: safeMinExtent,
              maxChildSize: 0.9,
              expand: false, // Allow sheet to retract from any scroll position
              builder: (context, scrollController) {
                _draggableSheetController = scrollController;
                // Ensure ListView is fully built before attempting to scroll
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Add a longer delay to ensure all widgets are rendered
                  Future.delayed(const Duration(milliseconds: 300), () {
                    print('🚀 Triggering initial scroll to today section...');
                    _scrollToTodaySection(animate: false);
                  });
                });
                scrollController.removeListener(_onScroll);
                scrollController.addListener(_onScroll);
                if (dateKeys.isEmpty) {
                  return Container(
                    // Remove the top margin to close the gap
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.057)), // ~24px at 420px width
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.076), // ~32px at 420px width
                        child: Text(
                          'No bulletin posts available.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.057)), // ~24px at 420px width
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: -5)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragStart: (details) {
                          // _isDraggingHandle = true;
                          dragStartExtent = _sheetController.size;
                        },
                        onVerticalDragUpdate: (details) {
                          if (dragStartExtent != null) {
                            final dragDelta = details.primaryDelta ?? 0.0;
                            final newExtent = (_sheetController.size - dragDelta / MediaQuery.of(context).size.height).clamp(safeMinExtent, 0.9);
                            _sheetController.jumpTo(newExtent);
                          }
                        },
                        onVerticalDragEnd: (details) {
                          // _isDraggingHandle = false;
                          dragStartExtent = null;
                          // Snap to snap-back extent if swiped down fast
                          if (details.primaryVelocity != null && details.primaryVelocity! > 500) {
                            _sheetController.animateTo(_getSnapBackExtent(), duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                          }
                          // No need to trigger scrollToTodaySection here; handled by controller listener
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: screenWidth * 0.029, bottom: screenWidth * 0.019), // ~12px, ~8px at 420px width
                          child: Center(
                            child: Container(
                              width: screenWidth * 0.086, // ~36px at 420px width
                              height: screenWidth * 0.012, // ~5px at 420px width
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(
                            top: screenWidth * 0.02, // Small buffer above first card
                            bottom: screenHeight * 0.18, // Responsive bottom padding
                          ),
                          itemCount: dateKeys.length,
                          itemBuilder: (context, index) {
                            final date = dateKeys[index];
                            final postsForDate = _groupedPosts[date]!;
                            return StickyHeader(
                              header: _buildDateHeader(date, key: _sectionKeys[date]),
                              content: Column(
                                children: postsForDate.map((post) => _BulletinEventCard(post: post)).toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      key: key,
      padding: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, screenWidth * 0.04),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildDateHeader(String date, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double screenHeight = MediaQuery.of(context).size.height;
    
    // Make header height responsive to screen size
    final double headerHeight = screenWidth * 0.13; // 13% of screen width
    final double verticalPadding = screenWidth * 0.03;
    final double horizontalPadding = screenWidth * 0.06;
    
    return Container(
      key: key, // Use the provided GlobalKey
      width: double.infinity,
      height: headerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF2F2F7),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          date,
          style: GoogleFonts.inter(
            fontSize: MediaQuery.of(context).size.width * 0.045, 
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedCarousel(List<BulletinPost> posts, {Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth * 0.56; // ~236 on 420px width, proportional
    return SizedBox(
      key: key,
      height: carouselHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.057), // ~24px at 420px width
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _PinnedPostCard(post: posts[index]);
        },
      ),
    );
  }

  Widget _buildEmptyPinnedSection({Key? key}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth * 0.56; // Same height as regular carousel
    return SizedBox(
      key: key,
      height: carouselHeight,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.057), // ~24px at 420px width
          child: Text(
            'No pinned posts at this time',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
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
      onTap: () => _showArticleSheet(post),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(screenWidth * 0.06, 0, screenWidth * 0.06, isNarrowScreen ? screenWidth * 0.03 : screenWidth * 0.04),
        padding: EdgeInsets.all(isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04),
        decoration: ShapeDecoration(
          color: Colors.white,            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: DesignConstants.get24Radius(context),
                cornerSmoothing: 1.0,
              ),
            ),
          shadows: DesignConstants.bulletinShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: GoogleFonts.inter(
                fontSize: MediaQuery.of(context).size.width * 0.045, 
                fontWeight: FontWeight.bold
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isNarrowScreen ? screenWidth * 0.015 : screenWidth * 0.02),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined, 
                  size: isNarrowScreen ? screenWidth * 0.04 : screenWidth * 0.045, 
                  color: Colors.black
                ),
                SizedBox(width: screenWidth * 0.02),
                Flexible(
                  child: Text(
                    post.subtitle,
                    style: TextStyle(
                      fontSize: isNarrowScreen ? screenWidth * 0.035 : screenWidth * 0.04,
                      color: Colors.black,
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
    );
  }
}

class _PinnedPostCard extends StatelessWidget {
  const _PinnedPostCard({required this.post});
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = DesignConstants.get32Radius(context);
    final double cardWidth = screenWidth * 0.65;
    final double imageHeight = screenWidth * 0.32;
    // final double fontSizeTitle = screenWidth * 0.045;
    final double fontSizeSubtitle = screenWidth * 0.035;
    return GestureDetector(
      onTap: () => _showArticleSheet(post),
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: screenWidth * 0.04, bottom: screenWidth * 0.01),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: cardRadius,
              cornerSmoothing: 1.0,
            ),
          ),
          shadows: DesignConstants.bulletinShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipSmoothRect(
              radius: SmoothBorderRadius.only(
                topLeft: SmoothRadius(cornerRadius: cardRadius, cornerSmoothing: 1.0),
                topRight: SmoothRadius(cornerRadius: cardRadius, cornerSmoothing: 1.0),
              ),
              child: Image.asset(
                post.imagePath!,
                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: GoogleFonts.inter(fontSize: MediaQuery.of(context).size.width * 0.045, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    post.subtitle,
                    style: TextStyle(fontSize: fontSizeSubtitle, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.01),
          ],
        ),
      ),
    );
  }
}