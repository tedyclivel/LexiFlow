import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WordPopParticles extends StatelessWidget {
  final Offset position;
  final Color color;

  const WordPopParticles({
    super.key,
    required this.position,
    this.color = const Color(0xFF2DD4BF),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(12, (index) {
        final angle = (index * 30) * pi / 180;
        final distance = 40.0 + Random().nextDouble() * 40;
        final targetX = cos(angle) * distance;
        final targetY = sin(angle) * distance;

        return Positioned(
          left: position.dx,
          top: position.dy,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          )
              .animate()
              .move(
                end: Offset(targetX, targetY),
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              )
              .fadeOut(duration: 600.ms)
              .scale(begin: const Offset(1, 1), end: const Offset(0, 0)),
        );
      }),
    );
  }
}
