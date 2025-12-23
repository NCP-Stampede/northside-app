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

  LiquidMeltingHeader({
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  double get minExtent => 90.0; // The height when fully scrolled up
  @override
  double get maxExtent => 100.0; // The height when at the top

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
                Colors.black, // Stay blurred through the middle
                Colors.transparent, // Fade out the blur at the bottom
              ],
              stops: [0.0, 0.6, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  // The background color also gradients from semi-opaque to transparent
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF030308).withOpacity(0.95), // Much darker at top
                      const Color(0xFF030308).withOpacity(0.6),
                      Colors.transparent, // Completely transparent at bottom
                    ],
                    stops: const [0.0, 0.7, 1.0],
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
