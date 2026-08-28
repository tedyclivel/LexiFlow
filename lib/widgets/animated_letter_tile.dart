import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/utils/design_system.dart';

class AnimatedLetterTile extends StatelessWidget {
  final String letter;
  final Color textColor;
  final bool isChaos;
  final bool isFound;
  final bool isSelected;
  final bool isSubtle;

  const AnimatedLetterTile({
    super.key,
    required this.letter,
    required this.textColor,
    this.isChaos = false,
    this.isFound = false,
    this.isSelected = false,
    this.isSubtle = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Opacity(
      opacity: isSubtle ? 0.6 : 1.0,
      child: Text(
        letter,
        style: (isFound || isSelected)
            ? GoogleFonts.bungee(fontSize: R.fs(context, 22), color: textColor)
            : GoogleFonts.outfit(
                fontSize: R.fs(context, 22),
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
      ),
    );

    if (!isChaos || isFound || isSelected) {
      return Center(child: content);
    }

    // Chaos Mode animations: VERY subtle drift to maintain performance
    return content
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .move(
          duration: 4000.ms,
          begin: const Offset(-1, -0.5),
          end: const Offset(1, 0.5),
          curve: Curves.easeInOut,
        )
        .rotate(
          duration: 6000.ms,
          begin: -0.02,
          end: 0.02,
          curve: Curves.easeInOut,
        );
  }
}
