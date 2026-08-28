import 'package:flutter/material.dart';
import 'dart:math';
import 'package:search_word/utils/design_system.dart';

class SelectionPainter extends CustomPainter {
  final List<Point<int>> selectedCells;
  final double cellWidth;
  final double cellHeight;
  final bool isError;
  final bool isFeverMode;
  final Color color;

  SelectionPainter({
    required this.selectedCells,
    required this.cellWidth,
    required this.cellHeight,
    required this.isError,
    required this.isFeverMode,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedCells.isEmpty) return;

    final baseColor = isError 
        ? Colors.red 
        : (isFeverMode ? LexiColors.accentOrange : color);
    
    final paint = Paint()
      ..color = baseColor.withOpacity(isFeverMode ? 0.6 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = min(cellWidth, cellHeight) * 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (isFeverMode) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      // Outer glow for fever
      final glowPaint = Paint()
        ..color = Colors.orangeAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = paint.strokeWidth * 1.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      
      _drawPath(canvas, glowPaint);
    }

    _drawPath(canvas, paint);
    
    // Draw dots at each point for better connection visuals
    final dotPaint = Paint()
      ..color = baseColor.withOpacity(0.6)
      ..style = PaintingStyle.fill;
      
    for (var p in selectedCells) {
      final x = p.y * cellWidth + cellWidth / 2;
      final y = p.x * cellHeight + cellHeight / 2;
      canvas.drawCircle(Offset(x, y), min(cellWidth, cellHeight) * 0.4, dotPaint);
    }
  }

  void _drawPath(Canvas canvas, Paint paint) {
    if (selectedCells.length < 2) return;
    
    final path = Path();
    final first = selectedCells.first;
    path.moveTo(first.y * cellWidth + cellWidth / 2, first.x * cellHeight + cellHeight / 2);
    
    for (int i = 1; i < selectedCells.length; i++) {
      final p = selectedCells[i];
      path.lineTo(p.y * cellWidth + cellWidth / 2, p.x * cellHeight + cellHeight / 2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) {
    return oldDelegate.selectedCells.length != selectedCells.length ||
        (selectedCells.isNotEmpty && oldDelegate.selectedCells.last != selectedCells.last) ||
        oldDelegate.isError != isError ||
        oldDelegate.isFeverMode != isFeverMode;
  }
}
