import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_word/providers/economy_provider.dart';
import 'package:search_word/providers/profile_provider.dart';

class DailyRewardState {
  final DateTime? lastClaimed;
  final int streak;
  final bool canClaim;

  DailyRewardState({this.lastClaimed, required this.streak, required this.canClaim});
}

class DailyRewardNotifier extends StateNotifier<DailyRewardState> {
  final SharedPreferences _prefs;
  final Ref _ref;

  DailyRewardNotifier(this._prefs, this._ref) : super(DailyRewardState(streak: 0, canClaim: false)) {
    _checkClaimStatus();
  }

  void _checkClaimStatus() {
    final lastClaimedStr = _prefs.getString('last_reward_claim');
    final streak = _prefs.getInt('reward_streak') ?? 0;
    
    if (lastClaimedStr == null) {
      state = DailyRewardState(streak: streak, canClaim: true);
      return;
    }

    final lastClaimed = DateTime.parse(lastClaimedStr);
    final now = DateTime.now();
    final difference = now.difference(lastClaimed).inDays;

    if (difference >= 1) {
      // Check if streak is broken (more than 1 day missed)
      final isStreakBroken = difference > 1;
      state = DailyRewardState(
        lastClaimed: lastClaimed, 
        streak: isStreakBroken ? 0 : streak, 
        canClaim: true
      );
    } else {
      state = DailyRewardState(lastClaimed: lastClaimed, streak: streak, canClaim: false);
    }
  }

  Future<void> claimReward() async {
    if (!state.canClaim) return;

    final newStreak = state.streak + 1;
    final reward = 50 + (newStreak * 10); // Escalating reward

    await _ref.read(economyProvider.notifier).addCoins(reward);
    
    final now = DateTime.now();
    await _prefs.setString('last_reward_claim', now.toIso8601String());
    await _prefs.setInt('reward_streak', newStreak);

    state = DailyRewardState(lastClaimed: now, streak: newStreak, canClaim: false);
  }
}

final dailyRewardProvider = StateNotifierProvider<DailyRewardNotifier, DailyRewardState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyRewardNotifier(prefs, ref);
});
