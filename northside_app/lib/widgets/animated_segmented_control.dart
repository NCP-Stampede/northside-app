import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'dart:ui';
import '../core/design_constants.dart';
import '../core/utils/app_colors.dart';

class AnimatedSegmentedControl extends StatefulWidget {
  final List<String> segments;
  final String selectedSegment;
  final Function(String) onSelectionChanged;
  final Duration animationDuration;
  final Curve animationCurve;
  /// When true, uses a more subtle style without backdrop blur (for use inside headers)
  final bool compact;

  const AnimatedSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedSegment,
    required this.onSelectionChanged,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.compact = false,
  });

  @override
  State<AnimatedSegmentedControl> createState() => _AnimatedSegmentedControlState();
}

class _AnimatedSegmentedControlState extends State<AnimatedSegmentedControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.segments.indexOf(widget.selectedSegment);
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: _selectedIndex.toDouble(),
      end: _selectedIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    ));
  }

  @override
  void didUpdateWidget(AnimatedSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = widget.segments.indexOf(widget.selectedSegment);
    if (newIndex != _selectedIndex && newIndex >= 0) {
      _selectedIndex = newIndex;
      _slideAnimation = Tween<double>(
        begin: _slideAnimation.value,
        end: newIndex.toDouble(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cornerRadius = widget.compact 
        ? DesignConstants.get24Radius(context) 
        : DesignConstants.get32Radius(context);
    final double containerPadding = widget.compact 
        ? screenWidth * 0.008 
        : screenWidth * 0.01;
    final double verticalPadding = widget.compact 
        ? screenWidth * 0.022 
        : screenWidth * 0.035;
    final double fontSize = widget.compact 
        ? screenWidth * 0.035 
        : screenWidth * 0.04;
    
    // The inner content (shared between compact and normal modes)
    Widget innerContent = Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: ShapeDecoration(
        // Use solid color for compact mode, gradient for normal
        color: widget.compact ? Colors.white.withOpacity(0.4) : null,
        gradient: widget.compact
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.25),
                  Colors.white.withOpacity(0.12),
                ],
              ),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: 1.0,
          ),
          side: BorderSide(
            color: Colors.white.withOpacity(widget.compact ? 0.3 : 0.2), 
            width: widget.compact ? 1 : 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Animated sliding background
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth - (containerPadding * 2);
                    final segmentWidth = availableWidth / widget.segments.length;
                    
                    return Stack(
                      children: [
                        Positioned(
                          left: containerPadding + (_slideAnimation.value * segmentWidth) + (containerPadding * 0.2) + (_slideAnimation.value * containerPadding * 0.3),
                          top: containerPadding,
                          bottom: containerPadding,
                          width: segmentWidth - (containerPadding * 1.6),
                          child: Container(
                            decoration: ShapeDecoration(
                              // Solid color for the selected tab indicator
                              color: widget.compact 
                                  ? Colors.white.withOpacity(0.55)
                                  : null,
                              gradient: widget.compact
                                  ? null
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.4),
                                        Colors.white.withOpacity(0.25),
                                      ],
                                    ),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: widget.compact 
                                      ? DesignConstants.get20Radius(context)
                                      : DesignConstants.get28Radius(context),
                                  cornerSmoothing: 1.0,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(widget.compact ? 0.4 : 0.3), 
                                  width: widget.compact ? 1 : 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          // Segment buttons
          Row(
            children: widget.segments.map((segment) {
              final index = widget.segments.indexOf(segment);
              final isSelected = index == _selectedIndex;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (index != _selectedIndex) {
                      widget.onSelectionChanged(segment);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding),
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                      ),
                      child: Text(
                        segment,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
    
    // In compact mode, add blur for glassy effect
    if (widget.compact) {
      return ClipSmoothRect(
        radius: SmoothBorderRadius(
          cornerRadius: cornerRadius,
          cornerSmoothing: 1.0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: innerContent,
        ),
      );
    }
    
    // Normal mode with backdrop blur
    return ClipSmoothRect(
      radius: SmoothBorderRadius(
        cornerRadius: cornerRadius,
        cornerSmoothing: 1.0,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: innerContent,
      ),
    );
  }
}

class AnimatedContentSwitcher extends StatefulWidget {
  final Widget child;
  final String switchKey;
  final Duration duration;
  final Curve curve;

  const AnimatedContentSwitcher({
    super.key,
    required this.child,
    required this.switchKey,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedContentSwitcher> createState() => _AnimatedContentSwitcherState();
}

class _AnimatedContentSwitcherState extends State<AnimatedContentSwitcher> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.duration,
      switchInCurve: widget.curve,
      switchOutCurve: widget.curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // More subtle slide transition like modern iOS
        final slideIn = SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0), // Much smaller offset for subtlety
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: widget.curve,
          )),
          child: child,
        );
        
        // Quick fade for snappy feel
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: widget.curve,
          ),
          child: slideIn,
        );
      },
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        // Stack the current and previous children for overlapping transitions
        return Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Container(
        key: ValueKey<String>(widget.switchKey),
        child: widget.child,
      ),
    );
  }
}
