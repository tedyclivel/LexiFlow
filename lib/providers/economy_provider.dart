import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_word/providers/profile_provider.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:flutter/foundation.dart';

class EconomyState {
  final int coins;
  final int gems;

  const EconomyState({
    required this.coins,
    required this.gems,
  });

  EconomyState copyWith({int? coins, int? gems}) {
    return EconomyState(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
    );
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'gems': gems,
  };

  factory EconomyState.fromJson(Map<String, dynamic> json) {
    return EconomyState(
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
    );
  }
}

class EconomyNotifier extends StateNotifier<EconomyState> {
  final SharedPreferences _prefs;

  EconomyNotifier(this._prefs) : super(const EconomyState(coins: 100, gems: 5)) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final coins = _prefs.getInt('eco_coins') ?? 100;
    final gems = _prefs.getInt('eco_gems') ?? 5;
    state = EconomyState(coins: coins, gems: gems);
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setInt('eco_coins', state.coins);
    await _prefs.setInt('eco_gems', state.gems);
    
    // Sync with Firestore (Global Stats)
    await FirestoreService.updateGlobalStats({
      'coins': state.coins,
      'gems': state.gems,
      'lastSync': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addCoins(int amount) async {
    state = state.copyWith(coins: state.coins + amount);
    await _saveToPrefs();
  }

  Future<void> addGems(int amount) async {
    state = state.copyWith(gems: state.gems + amount);
    await _saveToPrefs();
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      await _saveToPrefs();
      return true;
    }
    return false;
  }

  Future<bool> spendGems(int amount) async {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
      await _saveToPrefs();
      return true;
    }
    return false;
  }
}

final economyProvider = StateNotifierProvider<EconomyNotifier, EconomyState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EconomyNotifier(prefs);
});
