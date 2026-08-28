import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/models/multiplayer_models.dart';
import 'package:search_word/providers/game_controller.dart';
import 'package:search_word/providers/multiplayer_provider.dart';
import 'package:search_word/widgets/game_header.dart';
import 'package:search_word/widgets/letter_grid.dart';
import 'package:search_word/widgets/word_list.dart';
import 'package:search_word/utils/design_system.dart';
import 'package:search_word/data/level_data.dart';
import 'package:search_word/widgets/word_pop_particles.dart';
import 'package:search_word/widgets/success_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:search_word/utils/sound_service.dart';

class DuelGameScreen extends ConsumerStatefulWidget {
  final DuelMatch match;

  const DuelGameScreen({super.key, required this.match});

  @override
  ConsumerState<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends ConsumerState<DuelGameScreen> {
  Level? _level;
  Offset? _particlePosition;
  int _particleKey = 0;
  String? _activeAttack;
  bool _isGelActive = false;
  bool _isEarthquakeActive = false;

  @override
  void initState() {
    super.initState();
    _level = LevelData.getLevelById(widget.match.levelId);
  }

  void _onWordFound(String word) {
    ref.read(multiplayerProvider.notifier).updateProgress(word);
  }

  @override
  void dispose() {
    SoundService.stopAllScreenSounds();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_level == null) {
      return const Scaffold(body: Center(child: Text("Erreur de niveau")));
    }

    final controller = ref.watch(gameControllerProvider(_level!));
    final gameState = controller.state;
    final multiState = ref.watch(multiplayerProvider);
    final currentMatch = multiState.activeMatch ?? widget.match;

    // Listen for words found to sync with multiplayer
    ref.listen(gameControllerProvider(_level!).select((c) => c.state), (previous, next) {
      if (next.foundWords.length > (previous?.foundWords.length ?? 0)) {
        final newWord = next.foundWords.last;
        _onWordFound(newWord);
        
        // Visual Juice: Word Pop
        if (previous != null && previous.selectedCells.isNotEmpty) {
           _triggerParticles();
        }
      }
    });

    // Listen for Multiplayer Events (Finish, Sync, Attacks)
    ref.listen(multiplayerProvider, (previous, next) {
      final match = next.activeMatch;
      if (match == null) return;

      // 1. Finish Dialog
      if (match.status == 'finished' && previous?.activeMatch?.status != 'finished') {
        _showMatchResultDialog(match);
      }

      final myUid = FirebaseAuth.instance.currentUser?.uid;
      if (myUid == null) return;

      final isP1 = match.player1Id == myUid;

      // 2. Sync words found by opponent
      final opponentProgress = isP1 ? match.p2Progress : match.p1Progress;
      for (final word in opponentProgress) {
        final localController = ref.read(gameControllerProvider(_level!).notifier);
        if (!localController.state.foundWords.contains(word)) {
          localController.markWordAsFoundByOpponent(word);
        }
      }

      // 3. Special Attacks handling
      final myAttack = isP1 ? match.p1Attack : match.p2Attack;
      if (myAttack != null && myAttack != _activeAttack) {
        _handleIncomingAttack(myAttack);
      }
    });

    final comboMultiplier = controller.state.comboMultiplier;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LexiColors.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Duel Header
                  _buildDuelHeader(currentMatch),
                  
                  const SizedBox(height: 10),
                  
                  // Game Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              // Word Grid
                              Expanded(
                                flex: 3,
                                child: Stack(
                                  children: [
                                    IgnorePointer(
                                      ignoring: _isGelActive,
                                      child: LetterGrid(level: _level!),
                                    ).animate(target: _isEarthquakeActive ? 1 : 0)
                                     .shake(duration: 500.ms, hz: 10, offset: const Offset(4, 4)),
                                    
                                    if (_activeAttack == 'ink')
                                      Positioned.fill(
                                        child: _buildInkOverlay(),
                                      ),
                                    
                                    if (_isGelActive)
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.blue.withOpacity(0.2),
                                          child: const Center(
                                            child: Icon(Icons.ac_unit, color: Colors.white, size: 80),
                                          ),
                                        ).animate().fadeIn(),
                                      ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Word List
                              Expanded(
                                flex: 1,
                                child: WordList(level: _level!),
                              ),
                            ],
                          ),
                          
                          // Combo Overlay
                          if (comboMultiplier > 1)
                            Positioned(
                              top: 20,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: LexiColors.accentOrange,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
                                  ],
                                ),
                                child: Text(
                                  "X$comboMultiplier",
                                  style: GoogleFonts.bungee(fontSize: 28, color: Colors.white),
                                ),
                              ).animate(key: ValueKey(comboMultiplier))
                               .scale(duration: 300.ms, curve: Curves.elasticOut)
                               .shimmer()
                               .shake(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (_particlePosition != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: WordPopParticles(
                        key: ValueKey(_particleKey),
                        position: Offset.zero,
                        color: LexiColors.accentTeal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchResultDialog(DuelMatch match) {
    if (mounted) {
      final myId = match.player2Id; // Based on createInvite logic
      final isWinner = match.winnerId == myId;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessDialog(
          score: isWinner ? 100 : 20, // Points for participation
          timeUsed: "MATCH",
          wordsFound: match.p2Progress.length,
          totalWords: _level?.words.length ?? 0,
          speedBonus: isWinner ? 50 : 0,
          onNext: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Back to lobby
          },
          onMenu: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  void _triggerParticles() {
    setState(() {
      _particlePosition = const Offset(0, 0);
      _particleKey++;
    });
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _particlePosition = null);
    });
  }

  Widget _buildDuelHeader(DuelMatch match) {
    final p1Progress = match.p1Progress.length;
    final p2Progress = match.p2Progress.length;
    final totalWords = _level?.words.length ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player 1
              _buildPlayerInfo(match.player1Name, p1Progress, totalWords, LexiColors.accentTeal),
              
              const Column(
                children: [
                  Text("VS", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 18)),
                  Icon(Icons.bolt, color: Colors.orange, size: 24),
                ],
              ),
              
              // Player 2 (Local Player usually)
              _buildPlayerInfo(match.player2Name, p2Progress, totalWords, LexiColors.accentOrange),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: p1Progress,
                    child: Container(color: LexiColors.accentTeal),
                  ),
                  Expanded(
                    flex: (totalWords - p1Progress - p2Progress).clamp(0, totalWords),
                    child: Container(color: Colors.white12),
                  ),
                  Expanded(
                    flex: p2Progress,
                    child: Container(color: LexiColors.accentOrange),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String name, int progress, int total, Color color) {
    return Column(
      children: [
        Text(name, style: LexiTextStyles.label(color: Colors.white70)),
        Text("$progress/$total", style: LexiTextStyles.heading(color: color, fontSize: 24)),
      ],
    );
  }

  void _handleIncomingAttack(String type) {
    setState(() {
      _activeAttack = type;
      if (type == 'gel') _isGelActive = true;
      if (type == 'earthquake') {
        _isEarthquakeActive = true;
        // Shuffle local grid (just for visual effect or real?)
        // Actually grid is generated on both sides, so we can't easily sync shuffle.
        // But we can trigger a visual earthquake.
        ref.read(gameControllerProvider(_level!).notifier).shuffleGrid();
      }
    });

    // Clear attack flag in Firestore so we don't repeat
    ref.read(multiplayerProvider.notifier).clearAttack();

    // Auto-clear visual effects
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeAttack = null;
          _isGelActive = false;
          _isEarthquakeActive = false;
        });
      }
    });
    
    SoundService.playError(); // Use as generic "attack" sound
  }

  Widget _buildInkOverlay() {
    return Stack(
      children: List.generate(5, (i) {
        final random = Random();
        return Positioned(
          top: random.nextDouble() * 300,
          left: random.nextDouble() * 300,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ).animate().scale(duration: 300.ms).blur(begin: const Offset(0, 0), end: const Offset(10, 10)),
        );
      }),
    );
  }
}
