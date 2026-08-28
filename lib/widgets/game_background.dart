import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:search_word/utils/design_system.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  final bool showElements;

  const GameBackground({
    super.key,
    required this.child,
    this.showElements = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LexiColors.backgroundGradient,
          ),
        ),

        // 2. Animated Floating Elements
        if (showElements)
          const Positioned.fill(
            child: _FloatingElementsLayer(),
          ),

        // 3. The Content
        child,
      ],
    );
  }
}

class _FloatingElementsLayer extends StatefulWidget {
  const _FloatingElementsLayer();

  @override
  State<_FloatingElementsLayer> createState() => _FloatingElementsLayerState();
}

class _FloatingElementsLayerState extends State<_FloatingElementsLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingElement> _elements = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate some initial elements
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _elements.add(_FloatingElement(
        offset: Offset(random.nextDouble(), random.nextDouble()),
        size: 20 + random.nextDouble() * 40,
        speed: 0.5 + random.nextDouble(),
        rotationSpeed: random.nextDouble() * 2,
        isLetter: random.nextBool(),
        letter: String.fromCharCode(65 + random.nextInt(26)),
        opacity: 0.05 + random.nextDouble() * 0.1,
      ));
    }
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
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingElementsPainter(
            elements: _elements,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _FloatingElement {
  final Offset offset; // normalized 0..1
  final double size;
  final double speed;
  final double rotationSpeed;
  final bool isLetter;
  final String letter;
  final double opacity;

  _FloatingElement({
    required this.offset,
    required this.size,
    required this.speed,
    required this.rotationSpeed,
    required this.isLetter,
    required this.letter,
    required this.opacity,
  });
}

class _FloatingElementsPainter extends CustomPainter {
  final List<_FloatingElement> elements;
  final double progress;

  _FloatingElementsPainter({required this.elements, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var element in elements) {
      // Calculate animated position
      double y = (element.offset.dy - (progress * element.speed * 0.2)) % 1.0;
      double x = element.offset.dx;
      double rotation = progress * element.rotationSpeed * math.pi;

      final pos = Offset(x * size.width, y * size.height);
      
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);

      if (element.isLetter) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: element.letter,
            style: TextStyle(
              color: Colors.white.withOpacity(element.opacity),
              fontSize: element.size,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      } else {
        // Draw a hexagon
        final hexPath = Path();
        final radius = element.size / 2;
        for (int i = 0; i < 6; i++) {
          double angle = (i * 60) * math.pi / 180;
          double hx = radius * math.cos(angle);
          double hy = radius * math.sin(angle);
          if (i == 0) hexPath.moveTo(hx, hy);
          else hexPath.lineTo(hx, hy);
        }
        hexPath.close();
        canvas.drawPath(hexPath, paint..color = Colors.white.withOpacity(element.opacity));
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingElementsPainter oldDelegate) => true;
}
