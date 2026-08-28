import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/data/level_data.dart';
import 'package:search_word/widgets/game_header.dart';
import 'package:search_word/widgets/letter_grid.dart';
import 'package:search_word/widgets/word_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:confetti/confetti.dart';
import 'package:search_word/widgets/success_dialog.dart';
import 'package:search_word/widgets/game_over_dialog.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/providers/economy_provider.dart';
import 'package:search_word/widgets/tutorial_overlay.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/widgets/word_pop_particles.dart';
import 'package:flutter_animate/flutter_animate.dart';


class GameScreen extends ConsumerStatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  late ConfettiController _confettiController;
  bool _showTutorial = false;
  Offset? _particlePosition;
  int _particleKey = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _checkTutorial();
    // Stop any previous ambient, then start the correct mode-specific one
    SoundService.stopAll();
    Future.delayed(const Duration(milliseconds: 100), _startModeAmbient);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(gameControllerProvider(widget.level)).pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(gameControllerProvider(widget.level)).resumeTimer();
    }
  }

  void _startModeAmbient() {
    switch (widget.level.mode) {
      case GameMode.blitz:
        SoundService.playBlitzAmbient();
        break;
      case GameMode.chaos:
        SoundService.playChaosAmbient();
        break;
      default:
        SoundService.playGridAmbient();
        break;
    }
  }

  void _checkTutorial() {
    final prefs = ref.read(sharedPreferencesProvider);
    final completed = prefs.getBool('tutorial_completed') ?? false;
    if (!completed) {
      setState(() => _showTutorial = true);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    SoundService.stopAll();
    SoundService.playHubAmbient();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _triggerParticles(List<Point<int>> cells) {
    setState(() {
      _particlePosition = const Offset(0, 0); 
      _particleKey++;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _particlePosition = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(gameControllerProvider(widget.level));
    final gameState = controller.state;
    
    // Listen for state changes (Win, Found Words, Game Over)
    ref.listen(gameControllerProvider(widget.level).select((c) => c.state), (previous, next) {
      final nextState = next;
      final prevState = previous;

      if (nextState.isWin && !(prevState?.isWin ?? false)) {
        _confettiController.play();
        
        final profileBefore = ref.read(profileProvider);
        final unlockedBefore = profileBefore?.unlockedWorldIds.length ?? 0;

        // Update user profile with completion
        ref.read(profileProvider.notifier).updateGameWin(
          score: nextState.score,
          wordsFound: nextState.foundWords.length,
          worldId: widget.level.worldId,
          levelId: widget.level.id,
        ).then((_) {
          final profileAfter = ref.read(profileProvider);
          final unlockedAfter = profileAfter?.unlockedWorldIds.length ?? 0;
          final isNewWorldUnlocked = unlockedAfter > unlockedBefore;

          _showWinDialog(nextState.score, isNewWorldUnlocked);
        });

        // Persist win to Firestore
        FirestoreService.saveGameResult(
          score: nextState.score,
          levelName: widget.level.name,
          isWin: true,
          wordsFound: nextState.foundWords.length,
          timeTaken: (widget.level.mode == GameMode.zen) ? 0 : (widget.level.timeLimit - nextState.timeRemaining),
        );
        
        // Update Economy (Coins)
        ref.read(economyProvider.notifier).addCoins(nextState.score ~/ 10);
      } else if (nextState.foundWords.length > (prevState?.foundWords.length ?? 0)) {
        // ... (particles)
        // Word found! Trigger particle effect
        if (prevState != null && prevState.selectedCells.isNotEmpty) {
           _triggerParticles(prevState.selectedCells);
        }
      } else if (nextState.isGameOver && !nextState.isWin && !(prevState?.isGameOver ?? false)) {
        _showGameOverDialog();
      }
    });

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          SoundService.stopAll();
          SoundService.playHubAmbient();
        }
      },
      child: Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LexiColors.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  GameHeader(level: widget.level),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          if (widget.level.mode == GameMode.chaos) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: LexiColors.accentPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: LexiColors.accentPurple, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cyclone_rounded, color: LexiColors.accentPurple, size: R.sp(context, 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "MÉLANGE DANS : ${gameState.shuffleCountdown}s",
                                    style: LexiTextStyles.label(color: LexiColors.accentPurple, fontSize: R.fs(context, 14)),
                                  ),
                                ],
                              ),
                            ).animate(target: gameState.shuffleCountdown <= 3 ? 1 : 0)
                             .shimmer(color: Colors.white, duration: 1.seconds)
                             .shake(),
                          ],
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 3,
                            child: AspectRatio(
                              aspectRatio: widget.level.cols / widget.level.rows,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: LetterGrid(level: widget.level),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            flex: 1,
                            child: WordList(level: widget.level),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Lower HUD (Actions)
                  _buildLowerHUD(gameState, controller),
                ],
              ),
            ),
          ),
        ),
              
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [Color(0xFF2DD4BF), Color(0xFF1E3A8A), Colors.amber, Color(0xFFF43F5E)],
                ),
              ),
              
              if (_showTutorial)
                TutorialOverlay(
                  title: "COMMENT JOUER",
                  message: "Trouvez tous les mots cachés dans la grille en faisant glisser votre doigt sur les lettres !",
                  onNext: () async {
                    setState(() => _showTutorial = false);
                    final prefs = ref.read(sharedPreferencesProvider);
                    await prefs.setBool('tutorial_completed', true);
                  },
                ),
                
              if (_particlePosition != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: WordPopParticles(
                        key: ValueKey(_particleKey),
                        position: Offset.zero, // Positioned at center by Positioned.fill + Center
                      ),
                    ),
                  ),
                ),
          ],
        ),
    );
  }

  Widget _buildLowerHUD(GameState gameState, GameController controller) {
    final wordsLeft = gameState.words.length - gameState.foundWords.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Word Counter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$wordsLeft",
                style: LexiTextStyles.display(
                  fontSize: R.fs(context, 28),
                  color: Colors.white,
                ),
              ),
              Text(
                "RESTANTS",
                style: LexiTextStyles.label(
                  fontSize: R.fs(context, 10),
                  color: Colors.white60,
                ),
              ),
            ],
          ),

          // Action Buttons
          Row(
            children: [
              _ActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: "INDICE",
                count: gameState.hintsRemaining,
                color: Colors.amber,
                onTap: () => controller.useHint(),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.pause_rounded,
                label: "PAUSE",
                color: const Color(0xFF64748B),
                onTap: () => _showPauseDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "JEU EN PAUSE",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              SoundService.stopEverything();
              SoundService.playBack();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text("QUITTER", style: LexiTextStyles.button(color: Colors.redAccent, fontSize: 16)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LexiColors.accentTeal),
            onPressed: () => Navigator.pop(context),
            child: Text("REPRENDRE", style: LexiTextStyles.button(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showWinDialog(int score, bool isNewWorldUnlocked) {
    final controller = ref.read(gameControllerProvider(widget.level));
    final gs = controller.state;
    
    // Calculate time used
    int totalSecs = widget.level.timeLimit - gs.timeRemaining;
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
        isNewWorldUnlocked: isNewWorldUnlocked,
        onNext: () {
          final nextLevel = LevelData.getNextLevel(widget.level);
          if (nextLevel != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameScreen(level: nextLevel)),
            );
          } else {
            Navigator.pop(context);
          }
        },
        onMenu: () {
          SoundService.stopEverything();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        onRetry: () {
          Navigator.pop(context);
          ref.invalidate(gameControllerProvider(widget.level));
        },
        onMenu: () {
          SoundService.stopEverything();
          SoundService.playBack();
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? count;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 1.0,
                  ),
                ),
                if (count != null)
                  Text(
                    "$count RESTANTS",
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
