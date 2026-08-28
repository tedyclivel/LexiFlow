import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/level_model.dart';
import 'package:search_word/providers/economy_provider.dart';
import 'package:search_word/providers/daily_challenge_provider.dart';
import 'package:search_word/providers/tournament_provider.dart';
import 'package:search_word/models/daily_task_model.dart';
import 'package:search_word/utils/grid_generator.dart';
import 'package:search_word/utils/sound_service.dart';
import 'package:search_word/utils/haptic_service.dart';
import 'package:search_word/providers/profile_provider.dart';

class GameState {
  final Level level;
  final List<List<String>> grid;
  final List<Word> words;
  final List<String> foundWords;
  final int score;
  final int timeRemaining;
  final bool isGameOver;
  final bool isWin;
  
  // Advanced Scoring logic
  final int comboMultiplier;
  final DateTime? lastWordFoundTime;
  final int comboCount;
  final int errorCount;
  final int speedBonus;
  
  // Chaos Mode
  final int shuffleCountdown;
  
  // Selection state
  final Point<int>? startPoint;
  final Point<int>? currentPoint;
  final List<Point<int>> selectedCells;

  // Found cells to keep highlighted
  final Set<Point<int>> foundCells;
  final int hintsRemaining;
  final bool isError;
  final bool isFeverMode;
  final Set<Point<int>> frozenCells;

  GameState({
    required this.level,
    required this.grid,
    required this.words,
    this.foundWords = const [],
    this.score = 0,
    this.timeRemaining = 0,
    this.isGameOver = false,
    this.isWin = false,
    this.startPoint,
    this.currentPoint,
    this.selectedCells = const [],
    this.foundCells = const {},
    this.hintsRemaining = 3,
    this.isError = false,
    this.comboMultiplier = 1,
    this.lastWordFoundTime,
    this.comboCount = 0,
    this.errorCount = 0,
    this.speedBonus = 0,
    this.shuffleCountdown = 30, // Default to 30s
    this.isFeverMode = false,
    this.frozenCells = const {},
  });

  GameState copyWith({
    Level? level,
    List<List<String>>? grid,
    List<Word>? words,
    List<String>? foundWords,
    int? score,
    int? timeRemaining,
    bool? isGameOver,
    bool? isWin,
    Point<int>? startPoint,
    Point<int>? currentPoint,
    List<Point<int>>? selectedCells,
    Set<Point<int>>? foundCells,
    int? hintsRemaining,
    bool? isError,
    int? comboMultiplier,
    DateTime? lastWordFoundTime,
    int? comboCount,
    int? errorCount,
    int? speedBonus,
    int? shuffleCountdown,
    bool? isFeverMode,
    Set<Point<int>>? frozenCells,
  }) {
    return GameState(
      level: level ?? this.level,
      grid: grid ?? this.grid,
      words: words ?? this.words,
      foundWords: foundWords ?? this.foundWords,
      score: score ?? this.score,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isGameOver: isGameOver ?? this.isGameOver,
      isWin: isWin ?? this.isWin,
      startPoint: startPoint ?? this.startPoint,
      currentPoint: currentPoint ?? this.currentPoint,
      selectedCells: selectedCells ?? this.selectedCells,
      foundCells: foundCells ?? this.foundCells,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      isError: isError ?? this.isError,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      lastWordFoundTime: lastWordFoundTime ?? this.lastWordFoundTime,
      comboCount: comboCount ?? this.comboCount,
      errorCount: errorCount ?? this.errorCount,
      speedBonus: speedBonus ?? this.speedBonus,
      shuffleCountdown: shuffleCountdown ?? this.shuffleCountdown,
      isFeverMode: isFeverMode ?? this.isFeverMode,
      frozenCells: frozenCells ?? this.frozenCells,
    );
  }
}

class GameController extends ChangeNotifier {
  late GameState state;
  Timer? _timer;
  Timer? _feverTimer;
  int _chaosTicks = 0;
  final Ref _ref;

  GameController(Level level, this._ref) {
    _initGame(level);
    _startTimer();
  }

  void _initGame(Level level) {
    GridData gridData;
    int attempts = 0;
    
    // Rule 2.1: Automatic validation before game start
    // Retry until all words are successfully placed
    do {
      gridData = GridGenerator.generate(level.rows, level.cols, level.words, level.mode);
      attempts++;
    } while (gridData.placedWords.length < level.words.length && attempts < 5);

    // If still fails (highly unlikely with 10x5 internal retries), use what we have
    // but ensure we only use successfully placed words in the game state
    final wordsList = gridData.placedWords.map((w) => Word(text: w)).toList();

    state = GameState(
      level: level,
      grid: gridData.grid.isEmpty 
          ? List.generate(level.rows, (_) => List.filled(level.cols, ' ')) 
          : gridData.grid,
      words: wordsList,
      // Blitz starts with 35s countdown; everything else counts up from 0
      timeRemaining: level.mode == GameMode.blitz ? 35 : 0,
      frozenCells: _initializeFrozenCells(level),
      shuffleCountdown: 30,
    );
  }

  Set<Point<int>> _initializeFrozenCells(Level level) {
    if (level.mode != GameMode.hard && level.mode != GameMode.chaos) return {};
    final random = Random();
    final Set<Point<int>> frozen = {};
    int count = (level.rows * level.cols) ~/ 15; // Freeze ~6% of grid
    while (frozen.length < count) {
      frozen.add(Point(random.nextInt(level.rows), random.nextInt(level.cols)));
    }
    return frozen;
  }

  void pauseTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    if (state.isGameOver || state.isWin) return;
    _startTimer();
  }

  void _startTimer() {
    if (state.level.mode == GameMode.zen || 
        state.level.mode == GameMode.multiplayer) return;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isGameOver || state.isWin) {
        timer.cancel();
        return;
      }

      // ── BLITZ: Count DOWN ──────────────────────────────────────────────
      if (state.level.mode == GameMode.blitz) {
        if (state.timeRemaining > 0) {
          state = state.copyWith(timeRemaining: state.timeRemaining - 1);
          // Urgent tick in last 5 seconds
          if (state.timeRemaining <= 5) {
            SoundService.playTimerTick();
          }
          if (state.timeRemaining <= 0) {
            timer.cancel();
            state = state.copyWith(isGameOver: true, isWin: false);
          }
        } else {
          timer.cancel();
          state = state.copyWith(isGameOver: true, isWin: false);
        }
        notifyListeners();
        return;
      }

      // ── ALL OTHER MODES: Count UP from 00:00 ─────────────────────────
      state = state.copyWith(timeRemaining: state.timeRemaining + 1);

      // Chaos Mode: shuffle periodically
      if (state.level.mode == GameMode.chaos) {
        int nextCountdown = state.shuffleCountdown - 1;
        if (nextCountdown <= 0) {
          shuffleGrid();
          nextCountdown = 30;
        }
        state = state.copyWith(shuffleCountdown: nextCountdown);
      }

      notifyListeners();
    });
  }

  void shuffleGrid() {
    if (state.isGameOver) return;
    SoundService.playError(); // repurpose error sound for shuffle alert
    
    // Get currently unfound words
    final unfoundWords = state.words.where((w) => !w.found).map((w) => w.text).toList();
    if (unfoundWords.isEmpty) return;
    
    // Regenerate grid with unfound words
    // Note: Found letters will be "lost" from their positions, 
    // but the words are already marked as found in the list.
    // In search word, we usually keep found lines. 
    // Here, let's keep it simple: new grid, old progress kept.
    final newGrid = GridGenerator.generate(state.level.rows, state.level.cols, unfoundWords, state.level.mode);
    
    // Clear current selection to avoid confusion
    state = state.copyWith(
      grid: newGrid.grid,
      startPoint: null,
      currentPoint: null,
      selectedCells: [],
      // Keep foundCells for visual feedback of words already discovered
      // But wait: if grid moves, existing foundCells don't match letters anymore.
      // So we MUST clear foundCells OR re-find the found words on new grid.
      // Easiest for Chaos: found words stay found but their highlights vanish OR they are re-highlighted.
      foundCells: {}, // Pure chaos: you keep the score but lose the highlights!
      shuffleCountdown: 30,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _feverTimer?.cancel();
    super.dispose();
  }

  void startSelection(int r, int c) {
    if (state.isGameOver || state.frozenCells.contains(Point(r, c))) return; 
    state = state.copyWith(
      startPoint: Point(r, c),
      currentPoint: Point(r, c),
      selectedCells: [Point(r, c)],
    );
    notifyListeners();
  }

  bool updateSelection(int r, int c) {
    if (state.startPoint == null || state.isGameOver) return false;
    
    final currentPos = Point(r, c);
    if (state.frozenCells.contains(currentPos)) return false; // Can't select frozen
    if (state.selectedCells.isNotEmpty && state.selectedCells.last == currentPos) return false;
    
    // Check if r,c is within grid bounds
    if (r < 0 || r >= state.level.rows || c < 0 || c >= state.level.cols) return false;

    List<Point<int>> newSelection = List.from(state.selectedCells);
    
    // Logic for Snake selection (Hard/Expert) vs Linear (Normal/Easy)
    bool isSnake = state.level.mode == GameMode.hard || state.level.mode == GameMode.chaos; 
    // Actually user said for High difficulty. Let's check LevelData difficulty or mode.
    // For now let's apply it if mode is hard or chaos.

    if (isSnake) {
      // Snake Selection: Must be adjacent to the last selected cell
      if (newSelection.isEmpty) {
        newSelection.add(currentPos);
      } else {
        final last = newSelection.last;
        final dr = (r - last.x).abs();
        final dc = (c - last.y).abs();
        
        // Adjacent means dr+dc == 1 (orthogonal) or dr==1 && dc==1 (diagonal)
        // User said "virage à 90 degrés" which implies orthogonal mostly, but let's allow diagonal too for fun
        if (dr <= 1 && dc <= 1 && (dr != 0 || dc != 0)) {
          // If we are moving back to the previous cell, treat as "undo" one step
          if (newSelection.length > 1 && newSelection[newSelection.length - 2] == currentPos) {
            newSelection.removeLast();
          } else if (!newSelection.contains(currentPos)) {
            newSelection.add(currentPos);
          }
        } else {
          // Not adjacent, ignore or try to jump? Let's stay strict for snake.
          return false; 
        }
      }
    } else {
      // Linear Selection (Original Logic)
      Point<int> start = state.startPoint!;
      Point<int> end = currentPos;
      int dr = end.x - start.x;
      int dc = end.y - start.y;
      newSelection = [];
      if (dr == 0) {
        int step = dc > 0 ? 1 : -1;
        for (int i = 0; i <= (dc).abs(); i++) newSelection.add(Point(start.x, start.y + i * step));
      } else if (dc == 0) {
        int step = dr > 0 ? 1 : -1;
        for (int i = 0; i <= (dr).abs(); i++) newSelection.add(Point(start.x + i * step, start.y));
      } else if (dr.abs() == dc.abs()) {
        int stepR = dr > 0 ? 1 : -1;
        int stepC = dc > 0 ? 1 : -1;
        for (int i = 0; i <= dr.abs(); i++) newSelection.add(Point(start.x + i * stepR, start.y + i * stepC));
      } else return false;
    }
    
    if (newSelection.isEmpty) return false;
    if (newSelection.length == state.selectedCells.length && newSelection.last == state.selectedCells.last) return false;
    
    // Dynamic pitch: increase pitch by 0.1 for each letter, starting at 1.0, max 2.0
    double pitch = (1.0 + (newSelection.length - 1) * 0.1).clamp(1.0, 2.0);
    
    state = state.copyWith(currentPoint: currentPos, selectedCells: newSelection);
    SoundService.playLetterSelect(pitch: pitch);
    SoundService.vibrateSelection(newSelection.length);
    notifyListeners();
    return true;
  }

  void useHint() {
    if (state.hintsRemaining <= 0 || state.isGameOver) return;
    SoundService.playHint();
    final unfoundWords = state.words.where((w) => !w.found).toList();
    if (unfoundWords.isEmpty) return;
    final randomWord = unfoundWords[Random().nextInt(unfoundWords.length)];
    List<Point<int>> wordPos = _findWordOnGrid(randomWord.text);
    if (wordPos.isNotEmpty) {
      state = state.copyWith(
        hintsRemaining: state.hintsRemaining - 1,
        foundCells: {...state.foundCells, wordPos.first},
      );
      notifyListeners();
    }
  }

  List<Point<int>> _findWordOnGrid(String word) {
    int rows = state.level.rows;
    int cols = state.level.cols;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int dr = 0; int dc = 0;
        for (int dir = 0; dir < 8; dir++) {
             switch (dir) {
               case 0: dr = 0; dc = 1; break;
               case 1: dr = 1; dc = 1; break;
               case 2: dr = 1; dc = 0; break;
               case 3: dr = 1; dc = -1; break;
               case 4: dr = 0; dc = -1; break;
               case 5: dr = -1; dc = -1; break;
               case 6: dr = -1; dc = 0; break;
               case 7: dr = -1; dc = 1; break;
             }
             bool match = true;
             List<Point<int>> path = [];
             for (int i = 0; i < word.length; i++) {
               int nr = r + dr * i;
               int nc = c + dc * i;
               if (nr < 0 || nr >= rows || nc < 0 || nc >= cols || state.grid[nr][nc] != word[i]) {
                 match = false;
                 break;
               }
               path.add(Point(nr, nc));
             }
             if (match) return path;
        }
      }
    }
    return [];
  }

  void endSelection() {
    if (state.selectedCells.isEmpty || state.isGameOver) return;
    
    String builtWord = state.selectedCells.map((p) => state.grid[p.x][p.y]).join();
    String reversedWord = builtWord.split('').reversed.join();
    Word? matchedWord;
    
    try { 
      matchedWord = state.words.firstWhere((w) => !w.found && (w.text == builtWord || w.text == reversedWord)); 
    } catch (e) { 
      matchedWord = null; 
    }

    if (matchedWord != null) {
      final now = DateTime.now();
      int newComboMultiplier = 1;
      int newComboCount = state.comboCount + 1;
      
      if (state.lastWordFoundTime != null) {
        final difference = now.difference(state.lastWordFoundTime!).inSeconds;
        if (difference <= 5) {
          // Rapid find! Increase multiplier every 2 consecutive words, max 5x
          newComboMultiplier = min(5, state.comboMultiplier + 1);
          
          if (newComboCount >= 3 && !state.isFeverMode) {
            _startFeverMode();
          }
        } else {
          newComboMultiplier = 1;
          newComboCount = 1;
        }
      }

      if (state.isFeverMode) {
        newComboMultiplier *= 3; // Fever Mode triples everything!
      }

      final updatedWords = state.words.map((w) => w.text == matchedWord!.text ? Word(text: w.text, hint: w.hint, found: true, foundIndices: []) : w).toList();
      final updatedFoundWords = [...state.foundWords, matchedWord.text];
      
      // Daily Challenge: findWords
      _ref.read(dailyChallengeProvider.notifier).incrementProgress(TaskType.findWords);
      
      final newFoundCells = {...state.foundCells, ...state.selectedCells};
      
      // Calculate points: base (length * 10) * combo
      int pointsEarned = (matchedWord.text.length * 10) * newComboMultiplier;
      int newScore = state.score + pointsEarned;
      
      // Chrono Survival: Blitz mode gains time
      int newTime = state.timeRemaining;
      if (state.level.mode == GameMode.blitz) {
        newTime += 3 + Random().nextInt(3); // +3 to +5 seconds
      }

      bool win = updatedFoundWords.length == state.words.length;
      
      if (win) {
        // Daily Challenge: completeChaos
        if (state.level.mode == GameMode.chaos) {
          _ref.read(dailyChallengeProvider.notifier).incrementProgress(TaskType.completeChaos);
        }
        
        // Tournament TP
        int tpEarned = state.level.mode == GameMode.chaos ? 25 : 10;
        _ref.read(tournamentProvider.notifier).addTP(tpEarned);

        // Speed Bonus: 2 points per remaining second
        int calculatedSpeedBonus = state.timeRemaining * 2;
        newScore += calculatedSpeedBonus;

        // Update user profile with completion
        _ref.read(profileProvider.notifier).updateGameWin(
          score: newScore,
          wordsFound: updatedFoundWords.length,
          worldId: state.level.worldId,
          levelId: state.level.id,
        );

        SoundService.playVictory();
        SoundService.stopTimerTick();
        HapticService.success();
        
        state = state.copyWith(
          words: updatedWords, 
          foundWords: updatedFoundWords, 
          foundCells: newFoundCells, 
          score: newScore, 
          selectedCells: [], 
          startPoint: null, 
          currentPoint: null, 
          isWin: win, 
          isGameOver: win,
          timeRemaining: newTime,
          comboMultiplier: newComboMultiplier,
          comboCount: newComboCount,
          lastWordFoundTime: now,
          speedBonus: calculatedSpeedBonus,
        );
      } else {
        SoundService.playValidation();
        HapticService.medium();
        state = state.copyWith(
          words: updatedWords, 
          foundWords: updatedFoundWords, 
          foundCells: newFoundCells, 
          score: newScore, 
          selectedCells: [], 
          startPoint: null, 
          currentPoint: null, 
          isWin: win, 
          isGameOver: win,
          timeRemaining: newTime,
          comboMultiplier: newComboMultiplier,
          comboCount: newComboCount,
          lastWordFoundTime: now,
        );
      }

      if (state.level.mode == GameMode.chaos) {
        _applyGravity(state.selectedCells);
      }
      
      _checkThaw(state.selectedCells);
    } else {
      // Error Penalty: -5 points, but don't go below 0
      int newScore = max(0, state.score - 5);
      state = state.copyWith(isError: true, score: newScore, errorCount: state.errorCount + 1, comboMultiplier: 1, comboCount: 0);
      SoundService.playError();
      HapticService.error();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.isError) {
          state = state.copyWith(isError: false, selectedCells: [], startPoint: null, currentPoint: null);
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  void _startFeverMode() {
    _feverTimer?.cancel();
    state = state.copyWith(isFeverMode: true);
    SoundService.playFeverStart();
    
    _feverTimer = Timer(const Duration(seconds: 5), () {
      state = state.copyWith(isFeverMode: false);
      notifyListeners();
    });
    notifyListeners();
  }

  void _applyGravity(List<Point<int>> clearedPoints) {
    if (state.grid.isEmpty) return;
    
    List<List<String>> newGrid = state.grid.map((row) => List<String>.from(row)).toList();
    
    // 1. Clear found cells in this word
    for (var p in clearedPoints) {
      newGrid[p.x][p.y] = '';
    }
    
    // 2. Apply gravity (column by column)
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    
    for (int c = 0; c < state.level.cols; c++) {
      int writeIdx = state.level.rows - 1;
      for (int r = state.level.rows - 1; r >= 0; r--) {
        if (newGrid[r][c].isNotEmpty) {
          newGrid[writeIdx][c] = newGrid[r][c];
          if (writeIdx != r) newGrid[r][c] = '';
          writeIdx--;
        }
      }
      // 3. Fill top with new letters
      for (int r = writeIdx; r >= 0; r--) {
        newGrid[r][c] = chars[random.nextInt(chars.length)];
      }
    }
    
    // Note: foundCells (historical highlights) will be misaligned. 
    // Usually in search word with gravity, we clear old highlights or just don't use them.
    // Let's clear highlights that were part of the gravity-affected columns to be safe?
    // Actually, user said "changeant ainsi la configuration de la grille".
    // Let's just clear ALL found highlights on the grid but keep the found words list.
    state = state.copyWith(grid: newGrid, foundCells: {}); 
    notifyListeners();
  }


  void _checkThaw(List<Point<int>> path) {
    if (state.frozenCells.isEmpty) return;
    
    final Set<Point<int>> thawed = Set.from(state.frozenCells);
    bool changed = false;
    
    for (var cell in path) {
      // Check neighbors of each cell in the found word
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final neighbor = Point(cell.x + dr, cell.y + dc);
          if (thawed.contains(neighbor)) {
            thawed.remove(neighbor);
            changed = true;
          }
        }
      }
    }
    
    if (changed) {
      state = state.copyWith(frozenCells: thawed);
      SoundService.playThaw();
      notifyListeners();
    }
  }

  void markWordAsFoundByOpponent(String wordText) {
    if (state.foundWords.contains(wordText)) return;
    
    // Find where the word is on the grid to mark cells as well
    List<Point<int>> wordPath = _findWordOnGrid(wordText);

    final updatedWords = state.words.map((w) => w.text == wordText ? Word(text: w.text, hint: w.hint, found: true, foundIndices: []) : w).toList();
    final updatedFoundWords = [...state.foundWords, wordText];
    
    state = state.copyWith(
      words: updatedWords,
      foundWords: updatedFoundWords,
      foundCells: {...state.foundCells, ...wordPath},
    );
    notifyListeners();
  }
}

final gameControllerProvider = ChangeNotifierProvider.family<GameController, Level>((ref, level) {
  return GameController(level, ref);
});
