import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_word/models/daily_task_model.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/providers/economy_provider.dart';

class DailyChallengeState {
  final List<DailyTask> tasks;
  final DateTime lastReset;

  DailyChallengeState({
    required this.tasks,
    required this.lastReset,
  });

  DailyChallengeState copyWith({
    List<DailyTask>? tasks,
    DateTime? lastReset,
  }) {
    return DailyChallengeState(
      tasks: tasks ?? this.tasks,
      lastReset: lastReset ?? this.lastReset,
    );
  }

  Map<String, dynamic> toJson() => {
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'lastReset': lastReset.toIso8601String(),
      };

  factory DailyChallengeState.fromJson(Map<String, dynamic> json) {
    return DailyChallengeState(
      tasks: (json['tasks'] as List).map((t) => DailyTask.fromJson(t)).toList(),
      lastReset: DateTime.parse(json['lastReset']),
    );
  }
}

class DailyChallengeNotifier extends StateNotifier<DailyChallengeState> {
  final SharedPreferences _prefs;
  final Ref _ref;

  DailyChallengeNotifier(this._prefs, this._ref)
      : super(DailyChallengeState(tasks: [], lastReset: DateTime.fromMillisecondsSinceEpoch(0))) {
    _init();
  }

  void _init() {
    final cached = _prefs.getString('daily_challenges');
    if (cached != null) {
      final state = DailyChallengeState.fromJson(jsonDecode(cached));
      if (_isNewDay(state.lastReset)) {
        _generateNewChallenges();
      } else {
        this.state = state;
      }
    } else {
      _generateNewChallenges();
    }
  }

  bool _isNewDay(DateTime lastReset) {
    final now = DateTime.now();
    return now.day != lastReset.day || now.month != lastReset.month || now.year != lastReset.year;
  }

  void _generateNewChallenges() {
    final now = DateTime.now();
    final newTasks = [
      DailyTask(
        id: 'task_words_${now.millisecondsSinceEpoch}',
        title: 'Trouver 20 mots',
        type: TaskType.findWords,
        target: 20,
        rewardCoins: 50,
      ),
      DailyTask(
        id: 'task_blitz_${now.millisecondsSinceEpoch}',
        title: 'Compléter 3 grilles Blitz',
        type: TaskType.completeBlitz,
        target: 3,
        rewardCoins: 100,
      ),
      DailyTask(
        id: 'task_chaos_${now.millisecondsSinceEpoch}',
        title: 'Survivre à 1 niveau Chaos',
        type: TaskType.completeChaos,
        target: 1,
        rewardCoins: 150,
      ),
    ];
    state = DailyChallengeState(tasks: newTasks, lastReset: now);
    _save();
  }

  void _save() {
    _prefs.setString('daily_challenges', jsonEncode(state.toJson()));
  }

  void incrementProgress(TaskType type, {int amount = 1}) {
    final updatedTasks = state.tasks.map((task) {
      if (task.type == type && !task.isClaimed) {
        return task.copyWith(progress: (task.progress + amount).clamp(0, task.target));
      }
      return task;
    }).toList();
    state = state.copyWith(tasks: updatedTasks);
    _save();
  }

  Future<void> claimReward(String taskId) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.tasks[taskIndex];
    if (task.isCompleted && !task.isClaimed) {
      final updatedTasks = List<DailyTask>.from(state.tasks);
      updatedTasks[taskIndex] = task.copyWith(isClaimed: true);
      state = state.copyWith(tasks: updatedTasks);
      _save();

      // Add rewards to economy
      await _ref.read(economyProvider.notifier).addCoins(task.rewardCoins);
    }
  }
}

final dailyChallengeProvider = StateNotifierProvider<DailyChallengeNotifier, DailyChallengeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyChallengeNotifier(prefs, ref);
});
