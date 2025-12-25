import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// A Flutter implementation of the "Top-Down Melting Glass" header.
/// The header is most opaque at the top and gradients to total transparency at the bottom.
class LiquidMeltingHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double topPadding;

  LiquidMeltingHeader({
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.topPadding = 44.0, // Default safe area, will be overridden with actual MediaQuery value
  });

  @override
  double get minExtent => topPadding + 56.0; // Safe area + minimal content height (increased)
  @override
  double get maxExtent => topPadding + 70.0; // Safe area + comfortable content height (increased)

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 at maxExtent, 1.0 at minExtent
    final double shrinkPercentage = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. THE TOP-DOWN MELTING GLASS LAYER
        // We use a ShaderMask to fade the actual Blur effect out at the bottom
        ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black, // Fully visible (blurred) at top
                Colors.black, // Stay blurred through most of header
                Colors.black, // Continue blur
                Colors.transparent, // Smooth fade out at the bottom
              ],
              stops: [0.0, 0.5, 0.75, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                decoration: BoxDecoration(
                  // The background color also gradients from semi-opaque to transparent
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030308).withOpacity(1.0), // Full opacity at top
                      const Color(0xFF030308).withOpacity(0.9),
                      const Color(0xFF030308).withOpacity(0.5),
                      Colors.transparent, // Completely transparent at bottom
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. HEADER CONTENT - Back button (optional) + title
        Padding(
          padding: EdgeInsets.only(left: showBackButton ? 8 : 24, right: 24, top: topPadding + 4, bottom: 4),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(CupertinoIcons.back, color: Colors.white, size: 28),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (showBackButton) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: lerpDouble(36, 30, shrinkPercentage),
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
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant LiquidMeltingHeader oldDelegate) => true;
}
