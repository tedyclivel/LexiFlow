import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/widgets/animated_letter_tile.dart';
import 'package:search_word/widgets/selection_painter.dart';

class LetterGrid extends ConsumerWidget {
  final Level level;

  const LetterGrid({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We only watch foundation elements that don't change every frame
    final grid = ref.watch(gameControllerProvider(level).select((s) => s.state.grid));
    final foundCells = ref.watch(gameControllerProvider(level).select((s) => s.state.foundCells));
    final selectedCells = ref.watch(gameControllerProvider(level).select((s) => s.state.selectedCells));
    final isError = ref.watch(gameControllerProvider(level).select((s) => s.state.isError));
    final isFeverMode = ref.watch(gameControllerProvider(level).select((s) => s.state.isFeverMode));
    final frozenCells = ref.watch(gameControllerProvider(level).select((s) => s.state.frozenCells));

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / level.cols;
        final cellHeight = constraints.maxHeight / level.rows;

        return Stack(
          children: [
            // 1. Static Grid (Letters)
            GestureDetector(
              onPanStart: (details) {
                final r = (details.localPosition.dy / cellHeight).floor();
                final c = (details.localPosition.dx / cellWidth).floor();
                if (r >= 0 && r < level.rows && c >= 0 && c < level.cols) {
                  ref.read(gameControllerProvider(level)).startSelection(r, c);
                }
              },
              onPanUpdate: (details) {
                final r = (details.localPosition.dy / cellHeight).floor();
                final c = (details.localPosition.dx / cellWidth).floor();
                if (r >= 0 && r < level.rows && c >= 0 && c < level.cols) {
                  if (ref.read(gameControllerProvider(level)).updateSelection(r, c)) {
                    final length = ref.read(gameControllerProvider(level)).state.selectedCells.length;
                    SoundService.vibrateSelection(length);
                  }
                }
              },
              onPanEnd: (_) {
                ref.read(gameControllerProvider(level)).endSelection();
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: level.rows * level.cols,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: level.cols,
                  childAspectRatio: cellWidth / cellHeight,
                ),
                itemBuilder: (context, index) {
                  final r = index ~/ level.cols;
                  final c = index % level.cols;
                  final point = Point(r, c);
                  final letter = grid.isNotEmpty ? grid[r][c] : '';
                  final isFound = foundCells.contains(point);
                  final isFrozen = frozenCells.contains(point);

                  return _GridTile(
                    letter: letter,
                    isFound: isFound,
                    isFrozen: isFrozen,
                    isChaos: level.mode == GameMode.chaos,
                  );
                },
              ),
            ),

            // 2. Optimized Selection Overlay
            IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: SelectionPainter(
                    selectedCells: selectedCells,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                    isError: isError,
                    isFeverMode: isFeverMode,
                    color: LexiColors.primaryBlueLight,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final String letter;
  final bool isFound;
  final bool isFrozen;
  final bool isChaos;

  const _GridTile({
    required this.letter,
    required this.isFound,
    required this.isFrozen,
    required this.isChaos,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = isFound 
        ? LexiColors.accentTeal 
        : (isFrozen ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white);
    Color textColor = isFound ? Colors.white : const Color(0xFF0F172A);

    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isFrozen ? Border.all(color: Colors.blue.withOpacity(0.5), width: 2) : null,
        boxShadow: (!isFound && !isFrozen) ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ] : null,
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Center(
            child: AnimatedLetterTile(
              letter: letter,
              textColor: isFrozen ? textColor.withOpacity(0.3) : textColor,
              isSubtle: !isFound && !isFrozen,
              isChaos: isChaos,
              isFound: isFound,
              isSelected: false,
            ),
          ),
          if (isFrozen)
            const Center(
              child: Icon(Icons.ac_unit, color: Colors.blue, size: 24),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 2.seconds),
        ],
      ),
    ).animate(target: isFound ? 1 : 0)
     .shimmer(duration: 800.ms, color: Colors.white30);
  }
}
