import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// The "iOS 26" Liquid Mesh Background
/// Use this as the bottom layer of a Stack in your HomeScreen.
class LiquidMeshBackground extends StatefulWidget {
  const LiquidMeshBackground({super.key});

  @override
  State<LiquidMeshBackground> createState() => _LiquidMeshBackgroundState();
}

class _LiquidMeshBackgroundState extends State<LiquidMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 20-30 seconds makes the movement feel "living" and organic rather than frantic
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _LiquidMeshPainter(progress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _LiquidMeshPainter extends CustomPainter {
  final double progress;
  _LiquidMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Draw the base background (Deep Navy/Black)
    canvas.drawRect(rect, Paint()..color = const Color(0xFF020205));

    // 2. Setup the Paint with BlendMode.screen
    // This makes overlapping colors "glow" and brighten (essential for the look)
    final blobPaint = Paint()..blendMode = BlendMode.screen;

    // 3. Draw the 4 specific color blobs from the "iOS 26" aesthetic
    // Deep Indigo
    _drawBlob(canvas, size, blobPaint, const Color(0xFF3A0CA3), 
        speed: 0.3, scaleX: 1.4, scaleY: 0.9, offset: 0.0);
    
    // Royal Blue
    _drawBlob(canvas, size, blobPaint, const Color(0xFF4361EE), 
        speed: 0.5, scaleX: 0.8, scaleY: 1.3, offset: 2.0);
    
    // Violet/Purple
    _drawBlob(canvas, size, blobPaint, const Color(0xFF7209B7), 
        speed: 0.4, scaleX: 1.1, scaleY: 1.1, offset: 4.0);
    
    // Neon Pink
    _drawBlob(canvas, size, blobPaint, const Color(0xFFF72585), 
        speed: 0.6, scaleX: 0.9, scaleY: 0.7, offset: 1.5);
  }

  void _drawBlob(
    Canvas canvas, 
    Size size, 
    Paint paint, 
    Color color, {
    required double speed, 
    required double scaleX, 
    required double scaleY, 
    required double offset,
  }) {
    final double t = progress * 2 * math.pi * speed + offset;

    // Organic "Liquid" movement logic
    // Using sin/cos combinations ensures the blobs drift across the screen irregularly
    final double x = size.width / 2 + 
        (math.sin(t) * (size.width * 0.35)) * math.cos(t * 0.4);
    final double y = size.height / 2 + 
        (math.cos(t * 0.7) * (size.height * 0.30)) * math.sin(t * 0.5);

    final double baseRadius = size.width * 0.6;
    // Slight pulsing effect
    final double radius = baseRadius * (1.0 + math.sin(t * 1.5) * 0.05);

    // Radial gradient creates the soft "misty" edge for the mesh look
    paint.shader = RadialGradient(
      colors: [
        color.withOpacity(0.4), // Low opacity + Screen mode = vibrant glow
        Colors.transparent,
      ],
      stops: const [0.0, 0.8],
    ).createShader(Rect.fromCircle(center: Offset(x, y), radius: radius));

    // Draw an oval instead of a circle for a more natural fluid shape
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y), 
        width: radius * 2 * scaleX, 
        height: radius * 2 * scaleY
      ), 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidMeshPainter oldDelegate) => true;
}
