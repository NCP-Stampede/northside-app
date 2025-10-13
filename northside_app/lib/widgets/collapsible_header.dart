// lib/widgets/collapsible_header.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_constants.dart';

class CollapsibleHeader extends StatelessWidget {
  final String title;
  final bool showProfileIcon;
  final double expandedHeight;
  final Color? backgroundColor;
  final Widget? backgroundImage;

  const CollapsibleHeader({
    super.key,
    required this.title,
    this.showProfileIcon = true,
    this.expandedHeight = 200.0,
    this.backgroundColor,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: backgroundColor ?? const Color(0xFFF2F2F7),
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate collapse progress (0.0 = fully expanded, 1.0 = fully collapsed)
          final double appBarHeight = constraints.biggest.height;
          final double statusBarHeight = MediaQuery.of(context).padding.top;
          final double toolbarHeight = kToolbarHeight;
          final double minHeight = statusBarHeight + toolbarHeight;
          
          // Progress from 0.0 (expanded) to 1.0 (collapsed)
          final double collapseProgress = ((expandedHeight + statusBarHeight - appBarHeight) / 
              (expandedHeight - toolbarHeight)).clamp(0.0, 1.0);
          
          return FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background image or color
                if (backgroundImage != null) 
                  backgroundImage!
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF2F2F7),
                          const Color(0xFFFFFFFF),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                
                // Inverted blur fade effect (fades out at bottom instead of top)
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [
                        Colors.black,       // Full blur at top
                        Colors.black,       // Keep full blur
                        Colors.transparent, // Gradual fade out
                        Colors.transparent, // No blur at bottom
                      ],
                      stops: const [0.0, 0.2, 0.5, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFFFFFFF).withOpacity(0.8),
                              const Color(0xFFF9F9F9).withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Container(
              width: double.infinity,
              height: double.infinity,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.057),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer to push content down
                      Expanded(
                        flex: (collapseProgress * 100).round().clamp(1, 100),
                        child: Container(),
                      ),
                      
                      // Header content that transitions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Title with smooth opacity transition
                          Opacity(
                            opacity: (1.0 - collapseProgress * 1.5).clamp(0.0, 1.0),
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          
                          // Profile icon with fade
                          if (showProfileIcon)
                            Opacity(
                              opacity: (1.0 - collapseProgress).clamp(0.0, 1.0),
                              child: Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: screenWidth * 0.06,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Bottom spacer
                      SizedBox(height: screenWidth * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      
      // Collapsed state title (shows when fully collapsed)
      title: Builder(
        builder: (context) {
          return LayoutBuilder(
            builder: (context, constraints) {
              // This title shows when the app bar is collapsed
              return Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              );
            },
          );
        },
      ),
      centerTitle: false,
    );
  }
}