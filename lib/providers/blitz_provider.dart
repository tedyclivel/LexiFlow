import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/blitz_session.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/data/level_data.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/models/daily_task_model.dart';

import 'package:search_word/providers/daily_challenge_provider.dart';
import 'package:search_word/providers/tournament_provider.dart';

/// Provider for Blitz mode state management
final blitzProvider = StateNotifierProvider<BlitzNotifier, BlitzState>((ref) {
  return BlitzNotifier(ref);
});

/// Blitz mode state
class BlitzState {
  final BlitzSession? session;
  final int timeRemaining; // Seconds remaining for current grid
  final bool isTimerRunning;
  final Level? currentLevel;

  const BlitzState({
    this.session,
    this.timeRemaining = 60,
    this.isTimerRunning = false,
    this.currentLevel,
  });

  BlitzState copyWith({
    BlitzSession? session,
    int? timeRemaining,
    bool? isTimerRunning,
    Level? currentLevel,
  }) {
    return BlitzState(
      session: session ?? this.session,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }
}

/// Blitz mode state notifier
class BlitzNotifier extends StateNotifier<BlitzState> {
  Timer? _timer;
  static const int gridTimeLimit = 60; // Seconds per grid
  final Ref _ref;

  BlitzNotifier(this._ref) : super(const BlitzState());

  /// Start a new Blitz session
  void startNewSession() {
    final session = BlitzSession.create();
    final firstLevel = _generateLevel(0);
    
    state = BlitzState(
      session: session,
      timeRemaining: gridTimeLimit,
      isTimerRunning: false,
      currentLevel: firstLevel,
    );
  }

  /// Start the countdown timer
  void startTimer() {
    if (state.isTimerRunning) return;
    
    state = state.copyWith(isTimerRunning: true);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        // Time's up!
        _handleTimeout();
      }
    });
  }

  /// Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  /// Reset timer for new grid
  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      timeRemaining: gridTimeLimit,
      isTimerRunning: false,
    );
  }

  /// Handle grid completion
  void completeGrid({
    required int score,
    required int wordsFound,
    required int totalWords,
    required bool allWordsFound,
  }) {
    if (state.session == null) return;

    final timeUsed = gridTimeLimit - state.timeRemaining;
    
    final result = BlitzGridResult(
      gridIndex: state.session!.currentGridIndex,
      score: score,
      timeUsed: timeUsed,
      wordsFound: wordsFound,
      totalWords: totalWords,
      completed: allWordsFound,
      timestamp: DateTime.now(),
    );

    final updatedSession = state.session!.addGridResult(result);
    
    // Load next grid
    final nextLevel = _generateLevel(updatedSession.currentGridIndex);
    
    _timer?.cancel(); // Fix: Stop the timer before updating state
    
    state = BlitzState(
      session: updatedSession,
      timeRemaining: gridTimeLimit,
      isTimerRunning: false,
      currentLevel: nextLevel,
    );

    // Daily Challenge: completeBlitz
    _ref.read(dailyChallengeProvider.notifier).incrementProgress(TaskType.completeBlitz);
    
    // Tournament TP
    _ref.read(tournamentProvider.notifier).addTP(5);
  }

  /// Handle timeout (time ran out)
  void _handleTimeout() {
    pauseTimer();
    
    if (state.session == null) return;

    // Record incomplete grid
    final result = BlitzGridResult(
      gridIndex: state.session!.currentGridIndex,
      score: 0,
      timeUsed: gridTimeLimit,
      wordsFound: 0,
      totalWords: state.currentLevel?.words.length ?? 0,
      completed: false,
      timestamp: DateTime.now(),
    );

    final updatedSession = state.session!.addGridResult(result).end();
    
    state = state.copyWith(
      session: updatedSession,
      timeRemaining: 0,
    );
  }

  /// End the session manually
  void endSession() {
    pauseTimer();
    
    if (state.session != null) {
      final endedSession = state.session!.end();
      state = state.copyWith(session: endedSession);
    }
  }

  /// Word pool for extra words in Blitz escalation
  static const List<String> _blitzExtraWords = [
    'RAPIDE', 'VIF', 'CHRONO', 'ACTION', 'TEMPS', 'FLUX', 'DEFIS', 'VITESSE',
    'EXPERT', 'ZIGZAG', 'ESPRIT', 'LOGIQUE', 'LETTRE', 'CIBLE', 'REUSSITE',
    'RECORD', 'ELITE', 'POINT', 'CROWN', 'MASTER', 'ULTRA', 'POWER', 'COMBO'
  ];

  /// Generate a level based on difficulty (grid index)
  Level _generateLevel(int difficulty) {
    // Predefined levels for Blitz Mode (10 levels total)
    final List<Map<String, dynamic>> predefinedLevels = [
      {
        'name': 'Échauffement',
        'rows': 7, 'cols': 7,
        'words': ['CHAT', 'CHIEN', 'LOUP', 'LION', 'OISEAU'],
        'time': 45
      },
      {
        'name': 'Forêt Calme',
        'rows': 8, 'cols': 8,
        'words': ['ARBRE', 'FLEUR', 'HERBE', 'BOIS', 'FORET', 'VERT'],
        'time': 50
      },
      {
        'name': 'Ciel Bleu',
        'rows': 8, 'cols': 8,
        'words': ['AVION', 'NUAGE', 'SOLEIL', 'PLUIE', 'BLEU', 'VENT'],
        'time': 50
      },
      {
        'name': 'Océan Profond',
        'rows': 9, 'cols': 9,
        'words': ['REQUIN', 'BALEINE', 'CRABE', 'ALGUE', 'POISSON', 'EAU'],
        'time': 60
      },
      {
        'name': 'Espace Infini',
        'rows': 9, 'cols': 9,
        'words': ['MARS', 'LUNE', 'ASTRE', 'ETOILE', 'COMETE', 'SOLEIL'],
        'time': 60
      },
      {
        'name': 'Ville Animée',
        'rows': 10, 'cols': 10,
        'words': ['ROUTE', 'BUS', 'METRO', 'PARC', 'ECOLE', 'MAISON', 'RUE'],
        'time': 70
      },
    ];

    final int index = difficulty % predefinedLevels.length;
    final data = predefinedLevels[index];
    
    // ESCALATION LOGIC: Increase words after each grid
    // For every level of difficulty, add ~1 word
    final List<String> words = List<String>.from(data['words']);
    int extraWordsCount = (difficulty ~/ 2); // Add 1 word every 2 grids
    
    final random = Random();
    final usedExtraIndices = <int>{};
    for (int i = 0; i < extraWordsCount; i++) {
      int extraIndex = random.nextInt(_blitzExtraWords.length);
      // Try to avoid duplicates in the same level
      int safety = 0;
      while (usedExtraIndices.contains(extraIndex) && safety < 10) {
        extraIndex = random.nextInt(_blitzExtraWords.length);
        safety++;
      }
      usedExtraIndices.add(extraIndex);
      words.add(_blitzExtraWords[extraIndex]);
    }

    // Adjust grid size if word count is high
    int rows = data['rows'];
    int cols = data['cols'];
    if (words.length > 8) {
      rows = (rows + 1).clamp(6, 12);
      cols = (cols + 1).clamp(6, 12);
    }

    return Level(
      id: 999000 + difficulty,
      name: 'Blitz : ${data['name']}',
      rows: rows,
      cols: cols,
      words: words,
      timeLimit: 35, // Blitz grids always have fixed timer or use the countdown
      mode: GameMode.blitz,
      worldId: 999,
      worldName: 'Mode Blitz',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
