import 'package:flutter/material.dart';
import 'dart:math' as math;

class LexiFlowLogoPainter extends CustomPainter {
  final Color color;
  LexiFlowLogoPainter({this.color = Colors.indigo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a stylized hexagon background
    final hexPath = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.45;
    
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60) * math.pi / 180;
      double x = centerX + radius * math.cos(angle);
      double y = centerY + radius * math.sin(angle);
      if (i == 0) hexPath.moveTo(x, y);
      else hexPath.lineTo(x, y);
    }
    hexPath.close();
    
    canvas.drawPath(hexPath, Paint()..color = color.withOpacity(0.1));
    canvas.drawPath(hexPath, Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round);

    // Draw a stylized 'L' inside
    final lPath = Path();
    lPath.moveTo(size.width * 0.4, size.width * 0.3);
    lPath.lineTo(size.width * 0.4, size.width * 0.65);
    lPath.quadraticBezierTo(
      size.width * 0.4, size.width * 0.75,
      size.width * 0.65, size.width * 0.75
    );

    canvas.drawPath(lPath, Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round);
    
    // Add 3 decorative dots representing "flow"
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(Offset(size.width * 0.7, size.width * 0.35), size.width * 0.06, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.width * 0.5), size.width * 0.04, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LexiFlowLogo extends StatelessWidget {
  final double size;
  final Color color;
  const LexiFlowLogo({super.key, this.size = 100, this.color = Colors.indigo});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: LexiFlowLogoPainter(color: color),
    );
  }
}
