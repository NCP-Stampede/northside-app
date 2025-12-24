// lib/widgets/webview_sheet.dart

import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/design_constants.dart';
import '../core/utils/haptic_feedback_helper.dart';
import '../core/utils/logger.dart';

class WebViewSheet extends StatefulWidget {
  const WebViewSheet({super.key, required this.url});
  final String url;

  @override
  State<WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<WebViewSheet> 
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller with iOS-style duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly longer for more gradual feel
      vsync: this,
    );

    // Create more gradual iOS-style animation with custom curve
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn, // More gradual deceleration than easeOut
    );

    // Start the animation when the sheet is created
    _animationController.forward();
    
    _controller = WebViewController()
      // This line is for native mobile apps (iOS/Android) and enables JavaScript.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // This delegate is for native mobile apps to show a loading indicator.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            AppLogger.debug('Webview Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // Clean up the WebView controller and animation when the widget is disposed
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchInExternalBrowser() async {
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.warning('Could not launch URL: ${widget.url}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open link in external browser'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error launching URL in external browser', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error opening link in external browser'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360; // Check for S9 and similar devices
    
    // Get safe area padding to respect notch/status bar
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    // Adaptive sizing based on screen dimensions
    final double initialChildSize = isNarrowScreen ? 0.85 : 0.9;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.85 : 0.9;
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsets.only(top: padding.top),
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: minChildSize,
              maxChildSize: maxChildSize,
              builder: (_, controller) {
                return ClipSmoothRect(
                  radius: SmoothBorderRadius.only(
                    topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                    topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.18),
                          ],
                        ),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius.only(
                            topLeft: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                            topRight: SmoothRadius(cornerRadius: DesignConstants.get24Radius(context), cornerSmoothing: 1.0),
                          ),
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // WebView content (positioned below header)
                          Positioned(
                            top: screenWidth * 0.26,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ClipSmoothRect(
                              radius: SmoothBorderRadius.only(
                                bottomLeft: SmoothRadius(cornerRadius: 12, cornerSmoothing: 1.0),
                                bottomRight: SmoothRadius(cornerRadius: 12, cornerSmoothing: 1.0),
                              ),
                              child: Stack(
                                children: [
                                  WebViewWidget(controller: _controller),
                                  if (_isLoading)
                                    const Center(child: CircularProgressIndicator()),
                                ],
                              ),
                            ),
                          ),
                          // Melting header overlay
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.7, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                                  child: Container(
                                    height: screenWidth * 0.30,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0xFF030308).withOpacity(1.0),
                                          const Color(0xFF030308).withOpacity(0.85),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Header content (on top of blur)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Drag handle
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      width: 40,
                                      height: 5,
                                      decoration: ShapeDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        shape: SmoothRectangleBorder(
                                          borderRadius: SmoothBorderRadius(
                                            cornerRadius: DesignConstants.get10Radius(context),
                                            cornerSmoothing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Web View',
                                                style: GoogleFonts.inter(
                                                  fontSize: screenWidth * 0.055,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.5,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Browse external content',
                                                style: GoogleFonts.inter(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.white.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () { HapticFeedbackHelper.buttonPress(); _launchInExternalBrowser(); },
                                          icon: const Icon(Icons.open_in_new),
                                          tooltip: 'Open in external browser',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.white.withOpacity(0.2),
                                            foregroundColor: const Color(0xFF007AFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
