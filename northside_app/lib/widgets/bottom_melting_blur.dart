import 'dart:ui';
import 'package:flutter/material.dart';

/// The background blur component only. 
/// Place this behind your Nav Bar in a Stack.
class BottomMeltingBlur extends StatelessWidget {
  const BottomMeltingBlur({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        // Ensures this layer doesn't block taps to the nav bar or list
        child: ShaderMask(
          // This mask fades the blur effect itself out as it moves UP
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black,       // Fully visible (blurred) at the bottom edge
                Colors.black,       // Keep blur consistent for a bit
                Colors.transparent, // Fade blur to nothing at the top of the container
              ],
              stops: [0.0, 0.4, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ClipRRect(
            child: BackdropFilter(
              // The "Liquid" blur strength
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                height: 200, // Height of the "melting" transition zone
                decoration: BoxDecoration(
                  // The background color gradient (adjust Color to match your app theme)
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF030308).withOpacity(0.7), // Opaque at bottom
                      const Color(0xFF030308).withOpacity(0.3),
                      Colors.transparent,                       // Transparent at top
                    ],
                  ),
                  // Optional: Subtle top rim for the glass floor
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
