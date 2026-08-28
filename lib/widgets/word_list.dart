import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/utils/design_system.dart';

class WordList extends ConsumerWidget {
  final Level level;

  const WordList({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameControllerProvider(level));
    final gameState  = controller.state;
    final wordCount  = gameState.words.length;

    // Adaptive styling based on word count and screen width
    final double baseFontSize = wordCount <= 8  ? 15
                               : wordCount <= 15 ? 12
                               : wordCount <= 20 ? 10
                               : 9;
    final double fontSize = R.fs(context, baseFontSize);
    final EdgeInsets padding  = wordCount <= 8
        ? EdgeInsets.symmetric(horizontal: R.sp(context, 14), vertical: R.sp(context, 8))
        : wordCount <= 15
            ? EdgeInsets.symmetric(horizontal: R.sp(context, 10), vertical: R.sp(context, 6))
            : EdgeInsets.symmetric(horizontal: R.sp(context, 8), vertical: R.sp(context, 5));
    final double spacing      = wordCount <= 8 ? R.sp(context, 8) : wordCount <= 15 ? R.sp(context, 6) : R.sp(context, 4);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: gameState.words.map((word) {
            final isFound = word.found;
            return Container(
              padding: padding,
              decoration: BoxDecoration(
                color: isFound
                    ? LexiColors.accentTeal.withOpacity(0.3)
                    : Colors.white.withAlpha(18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFound ? LexiColors.accentTeal : Colors.white24,
                  width: isFound ? 1.5 : 1,
                ),
                boxShadow: isFound
                    ? [BoxShadow(color: LexiColors.accentTeal.withOpacity(0.2), blurRadius: 8)]
                    : null,
              ),
              child: Text(
                word.text,
                style: GoogleFonts.outfit(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: isFound ? Colors.white : Colors.white.withOpacity(0.85),
                  decoration: isFound ? TextDecoration.lineThrough : null,
                  decorationThickness: 2,
                  decorationColor: Colors.white54,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
