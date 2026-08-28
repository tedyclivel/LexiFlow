import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/utils/design_system.dart';

class GameHeader extends ConsumerWidget {
  final Level level;

  const GameHeader({super.key, required this.level});

  String _formatTime(int seconds) {
    if (level.mode == GameMode.zen) return "--:--";
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(gameControllerProvider(level));
    final gameState = controller.state;
    final double progress = gameState.words.isEmpty 
        ? 0 
        : gameState.foundWords.length / gameState.words.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.sp(context, 20), vertical: R.sp(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Level Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name.toUpperCase(),
                    style: LexiTextStyles.heading(
                      fontSize: R.fs(context, 18),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "LOGIQUE • NIV ${level.id}",
                    style: LexiTextStyles.label(
                      fontSize: R.fs(context, 10),
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              
              // Timer (if not Zen)
              if (level.mode != GameMode.zen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: (level.mode != GameMode.classic && gameState.timeRemaining < 15) ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: R.sp(context, 18),
                        color: (level.mode != GameMode.classic && gameState.timeRemaining < 15) ? Colors.redAccent : Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(gameState.timeRemaining),
                        style: LexiTextStyles.button(
                          fontSize: R.fs(context, 16),
                          color: (level.mode != GameMode.classic && gameState.timeRemaining < 15) ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${gameState.score}",
                    style: LexiTextStyles.heading(
                      fontSize: R.fs(context, 24),
                      color: LexiColors.accentTeal,
                    ),
                  ),
                  Text(
                    "SCORE",
                    style: LexiTextStyles.label(
                      fontSize: R.fs(context, 8),
                      color: LexiColors.accentTeal.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 6,
                width: MediaQuery.of(context).size.width * 0.8 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2DD4BF), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
