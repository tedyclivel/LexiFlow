import 'package:flutter/material.dart';
import 'dart:math' as math;

class WorldThemeImage extends StatelessWidget {
  final int worldId;
  final double width;
  final double height;

  const WorldThemeImage({
    super.key,
    required this.worldId,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _WorldThemePainter(worldId: worldId),
    );
  }
}

class _WorldThemePainter extends CustomPainter {
  final int worldId;
  _WorldThemePainter({required this.worldId});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(worldId);

    if (worldId == 1) {
      // NATURE: Leaves and grass
      _drawNature(canvas, size, paint, random);
    } else if (worldId == 2) {
      // SPACE: Stars and planets
      _drawSpace(canvas, size, paint, random);
    } else {
      // HISTORY: Pyramids and ancient pillars
      _drawHistory(canvas, size, paint, random);
    }
  }

  void _drawNature(Canvas canvas, Size size, Paint paint, math.Random random) {
    // Draw hills
    paint.color = Colors.teal.shade900.withOpacity(0.5);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 1.1), size.width * 0.8, paint);
    paint.color = Colors.teal.shade800.withOpacity(0.5);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 1.2), size.width * 0.9, paint);

    // Draw stylized trees/leaves
    for (int i = 0; i < 10; i++) {
       double x = random.nextDouble() * size.width;
       double y = random.nextDouble() * size.height * 0.6 + size.height * 0.2;
       double s = 20 + random.nextDouble() * 30;
       paint.color = Colors.tealAccent.withOpacity(0.2);
       canvas.drawCircle(Offset(x, y), s, paint);
       canvas.drawCircle(Offset(x + s*0.5, y - s*0.3), s*0.8, paint);
    }
  }

  void _drawSpace(Canvas canvas, Size size, Paint paint, math.Random random) {
    // Large planet
    paint.color = Colors.indigoAccent.withOpacity(0.3);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), size.width * 0.4, paint);
    
    // Rings
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.white24;
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.7, size.height * 0.3), width: size.width * 0.9, height: size.width * 0.2), paint);

    // Stars
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 30; i++) {
       double x = random.nextDouble() * size.width;
       double y = random.nextDouble() * size.height;
       double s = random.nextDouble() * 2;
       paint.color = Colors.white.withOpacity(random.nextDouble() * 0.5);
       canvas.drawCircle(Offset(x, y), s, paint);
    }
  }

  void _drawHistory(Canvas canvas, Size size, Paint paint, math.Random random) {
    // Pyramid
    paint.color = Colors.orange.shade900.withOpacity(0.4);
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.1, size.height * 0.9);
    path.lineTo(size.width * 0.9, size.height * 0.9);
    path.close();
    canvas.drawPath(path, paint);

    // Sun
    paint.color = Colors.amber.withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.1), size.width * 0.2, paint);

    // Columns
    paint.color = Colors.white10;
    for (int i = 0; i < 5; i++) {
       canvas.drawRect(Rect.fromLTWH(i * (size.width/5) + 10, size.height * 0.7, 15, size.height * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
