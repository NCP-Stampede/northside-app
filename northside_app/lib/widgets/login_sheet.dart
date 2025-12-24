// lib/widgets/login_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/design_constants.dart';
import '../core/utils/haptic_feedback_helper.dart';
import '../core/utils/logger.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  // Controllers to manage the text in the input fields
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // --- BACKEND INTEGRATION POINT ---
    // Here, you would take the text from the controllers:
    // final email = _emailController.text;
    // final password = _passwordController.text;
    // ...and send it to your backend for authentication.
    
    // For now, we just print and close the sheet.
    AppLogger.debug('Logging in...');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrowScreen = screenWidth < 360;
    
    final EdgeInsets padding = MediaQuery.of(context).padding;
    
    final double initialChildSize = isNarrowScreen ? 0.85 : 0.9;
    final double minChildSize = isNarrowScreen ? 0.4 : 0.5;
    final double maxChildSize = isNarrowScreen ? 0.85 : 0.9;
    
    return Padding(
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
                    // Scrollable content (full height, scrolls under header)
                    Positioned.fill(
                      child: ListView(
                        controller: controller,
                        padding: EdgeInsets.only(
                          top: screenWidth * 0.28, // Space for header
                          bottom: 40,
                          left: 24,
                          right: 24,
                        ),
                        children: [
                          // Email/Username TextField
                          TextField(
                            controller: _emailController,
                            decoration: _inputDecoration('Email or Username'),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 16),
                          // Password TextField
                          TextField(
                            controller: _passwordController,
                            decoration: _inputDecoration('Password'),
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 32),
                          // Log In Button
                          GestureDetector(
                            onTap: () { HapticFeedbackHelper.buttonPress(); _handleLogin(); },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF007AFF),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: DesignConstants.get16Radius(context),
                                    cornerSmoothing: 1.0,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                              height: screenWidth * 0.32,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Link Flex Account',
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth * 0.055,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Sign in to sync your flex balance',
                                    style: GoogleFonts.inter(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.white.withOpacity(0.7),
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
    );
  }

  // Helper method for consistent text field styling
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF007AFF)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
