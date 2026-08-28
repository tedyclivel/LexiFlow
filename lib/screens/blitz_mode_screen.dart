import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/providers/blitz_provider.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/screens/game_screen.dart';
import 'package:search_word/screens/blitz_results_screen.dart';
import 'package:search_word/widgets/letter_grid.dart';
import 'package:search_word/widgets/word_list.dart';
import 'package:search_word/widgets/countdown_timer.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/widgets/success_dialog.dart';

class BlitzModeScreen extends ConsumerStatefulWidget {
  const BlitzModeScreen({super.key});

  @override
  ConsumerState<BlitzModeScreen> createState() => _BlitzModeScreenState();
}

class _BlitzModeScreenState extends ConsumerState<BlitzModeScreen> {
  bool _isInit = false;

  @override
  void dispose() {
    SoundService.stopAllScreenSounds();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Start the session on enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blitzProvider.notifier).startNewSession();
    });
  }

  void _onLevelComplete(GameState gameState) {
    // When a level is won in Blitz mode, show success dialog
    SoundService.playReward();
    _showWinDialog(gameState);
  }

  void _showWinDialog(GameState gs) {
    if (mounted) {
      final blitzNotifier = ref.read(blitzProvider.notifier);
      final blitzState = ref.read(blitzProvider);
      
      // Calculate time used for this specific grid
      int totalSecs = 60 - blitzState.timeRemaining;
      String timeUsed = "${(totalSecs ~/ 60).toString().padLeft(2, '0')}:${(totalSecs % 60).toString().padLeft(2, '0')}";

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(
          score: gs.score,
          timeUsed: timeUsed,
          wordsFound: gs.foundWords.length,
          totalWords: gs.words.length,
          speedBonus: gs.speedBonus,
          onNext: () {
            Navigator.pop(context); // Close dialog
            // Advance to next grid in Blitz
            blitzNotifier.completeGrid(
              score: gs.score,
              wordsFound: gs.foundWords.length,
              totalWords: gs.words.length,
              allWordsFound: true,
            );
          },
          onMenu: () {
            Navigator.pop(context); // Close dialog
            blitzNotifier.endSession();
            Navigator.pop(context); // Exit to menu
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blitzState = ref.watch(blitzProvider);
    
    if (blitzState.currentLevel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Use our existing GameController logic for each grid
    final controller = ref.watch(gameControllerProvider(blitzState.currentLevel!));
    final gameState = controller.state;

    // Listen for level completion
    ref.listen(gameControllerProvider(blitzState.currentLevel!).select((c) => c.state), (previous, next) {
      if (next.isWin && !(previous?.isWin ?? false)) {
        _onLevelComplete(next);
      }
    });

    // Listen for session end
    ref.listen(blitzProvider, (previous, next) {
      if (previous?.session?.isActive == true && next.session?.isActive == false) {
        if (next.session != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlitzResultsScreen(session: next.session!),
            ),
          );
        }
      }
    });

    // Start timer when level is ready
    if (!blitzState.isTimerRunning && !gameState.isGameOver && blitzState.session?.isActive == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(blitzProvider.notifier).startTimer();
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LexiColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Blitz Header
              _buildBlitzHeader(blitzState, gameState),
              
              const SizedBox(height: 20),
              
              // Countdown Timer
              CountdownTimer(
                secondsRemaining: blitzState.timeRemaining,
                isRunning: blitzState.isTimerRunning,
              ),
              
              const SizedBox(height: 20),
              
              // Game Content
              Expanded(
                child: Column(
                  children: [
                    // Word Grid
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LetterGrid(level: blitzState.currentLevel!),
                      ),
                    ),
                    
                    // Word List
                    Expanded(
                      flex: 1,
                      child: WordList(level: blitzState.currentLevel!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlitzHeader(BlitzState blitzState, GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: () {
              ref.read(blitzProvider.notifier).endSession();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          
          // Blitz Info
          Column(
            children: [
              Text(
                "BLITZ MODE",
                style: LexiTextStyles.label(color: LexiColors.accentOrange, fontSize: R.fs(context, 14)),
              ),
              Text(
                "GRID ${(blitzState.session?.currentGridIndex ?? 0) + 1}",
                style: LexiTextStyles.heading(color: Colors.white, fontSize: R.fs(context, 24)),
              ),
            ],
          ),
          
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "SCORE TOTAL",
                style: LexiTextStyles.label(color: Colors.white70, fontSize: R.fs(context, 12)),
              ),
              Text(
                "${blitzState.session?.totalScore ?? 0}",
                style: LexiTextStyles.heading(color: LexiColors.accentTeal, fontSize: R.fs(context, 24)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
