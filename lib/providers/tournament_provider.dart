import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:search_word/models/tournament_models.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class TournamentState {
  final List<TournamentEntry> rankings;
  final bool isLoading;
  final Duration timeRemaining;
  final String? error;

  TournamentState({
    this.rankings = const [],
    this.isLoading = false,
    this.timeRemaining = Duration.zero,
    this.error,
  });

  TournamentState copyWith({
    List<TournamentEntry>? rankings,
    bool? isLoading,
    Duration? timeRemaining,
    String? error,
  }) {
    return TournamentState(
      rankings: rankings ?? this.rankings,
      isLoading: isLoading ?? this.isLoading,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      error: error ?? this.error,
    );
  }
}

class TournamentNotifier extends StateNotifier<TournamentState> {
  Timer? _timer;
  final Ref _ref;

  TournamentNotifier(this._ref) : super(TournamentState()) {
    _startCountdown();
    loadRankings();
  }

  void _startCountdown() {
    _timer?.cancel();
    _updateTimeRemaining();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    // Calculate next Sunday midnight
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) daysUntilSunday += 7;
    
    final nextSunday = DateTime(now.year, now.month, now.day + daysUntilSunday);
    final resetTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 0, 0);
    
    state = state.copyWith(timeRemaining: resetTime.difference(now));
  }

  Future<void> loadRankings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await FirestoreService.getTournamentRankings();
      final entries = data.asMap().entries.map((e) => TournamentEntry.fromFirestore(e.value, e.key + 1)).toList();
      state = state.copyWith(rankings: entries, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTP(int points) async {
    final profile = _ref.read(profileProvider);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (profile == null || uid == null) return;

    await FirestoreService.updateTournamentPoints(
      userId: uid,
      playerName: profile.pseudo,
      avatarUrl: profile.avatarUrl,
      points: points,
    );
    loadRankings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final tournamentProvider = StateNotifierProvider<TournamentNotifier, TournamentState>((ref) {
  return TournamentNotifier(ref);
});
