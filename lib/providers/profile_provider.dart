import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:search_word/models/user_profile.dart';
import 'package:search_word/utils/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/utils/firebase_state.dart';

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final SharedPreferences _prefs;

  ProfileNotifier(this._prefs) : super(null) {
    _loadFromCache();
  }

  void _loadFromCache() {
    if (!firebaseReady) {
      final profileJson = _prefs.getString('local_user_profile');
      if (profileJson != null) {
        try {
          state = UserProfile.fromJson(jsonDecode(profileJson));
        } catch (_) {
          state = null;
        }
      }
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final String? profileJson = _prefs.getString('user_profile_$uid');
    if (profileJson != null) {
      try {
        state = UserProfile.fromJson(jsonDecode(profileJson));
      } catch (e) {
        state = null;
      }
    }
  }

  Future<void> syncWithFirestore() async {
    if (!firebaseReady) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final remoteProfileData = await FirestoreService.getProfile(uid);
    if (remoteProfileData != null) {
      final remoteProfile = UserProfile.fromJson(remoteProfileData);
      state = remoteProfile;
      await _saveToCache();
    } else if (state != null) {
      // If we have local but no remote, sync local to remote
      await FirestoreService.updateGlobalStats(state!.toJson());
    }
  }

  Future<void> createProfile(String pseudo, String avatarUrl) async {
    if (!firebaseReady) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final profile = UserProfile(
      pseudo: pseudo,
      avatarUrl: avatarUrl,
      unlockedWorldIds: [1], // Start with first world
    );
    state = profile;
    await _saveToCache();
    await FirestoreService.updateGlobalStats(profile.toJson());
  }

  /// Local guest mode for desktop platforms where Firebase has no native
  /// plugin. Progress is still persisted locally and Firebase remains used on
  /// supported platforms.
  Future<void> createLocalProfile(String pseudo, String avatarUrl) async {
    state = UserProfile(pseudo: pseudo, avatarUrl: avatarUrl);
    await _prefs.setString('local_user_profile', jsonEncode(state!.toJson()));
  }

  Future<void> _saveToCache() async {
    if (!firebaseReady) {
      if (state != null) {
        await _prefs.setString(
          'local_user_profile',
          jsonEncode(state!.toJson()),
        );
      }
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (state != null && uid != null) {
      await _prefs.setString('user_profile_$uid', jsonEncode(state!.toJson()));
    }
  }

  Future<void> updateGameWin({
    required int score,
    required int wordsFound,
    int? worldId,
    int? levelId,
  }) async {
    if (state == null) return;

    final now = DateTime.now();
    bool isConsecutive = false;

    if (state!.lastGameDate != null) {
      final diff = now.difference(state!.lastGameDate!).inDays;
      if (diff == 1) {
        isConsecutive = true;
      } else if (diff > 1) {
        isConsecutive = false;
      } else {
        isConsecutive = state!.currentStreak > 0;
      }
    } else {
      isConsecutive = true;
    }

    final newStreak = isConsecutive ? state!.currentStreak + 1 : 1;
    final newLongest = newStreak > state!.longestStreak
        ? newStreak
        : state!.longestStreak;

    // Build updated completed levels map
    Map<int, List<int>> updatedLevels = Map.from(
      state!.completedLevelIds.map((k, v) => MapEntry(k, List<int>.from(v))),
    );
    if (worldId != null && levelId != null) {
      final worldLvlList = updatedLevels[worldId] ?? [];
      if (!worldLvlList.contains(levelId)) {
        worldLvlList.add(levelId);
        updatedLevels[worldId] = worldLvlList;
      }
    }

    state = state!.copyWith(
      totalScore: state!.totalScore + score,
      bestScore: score > state!.bestScore ? score : state!.bestScore,
      totalWordsFound: state!.totalWordsFound + wordsFound,
      gamesPlayed: state!.gamesPlayed + 1,
      gamesWon: state!.gamesWon + 1,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastGameDate: now,
      completedLevelIds: updatedLevels,
    );

    await _saveToCache();
    if (firebaseReady) {
      await FirestoreService.updateGlobalStats(state!.toJson());
    }
    _checkTrophies();

    if (worldId != null) {
      _checkWorldUnlocks(worldId);
    }
  }

  void _checkTrophies() {
    if (state == null) return;
    final trophies = List<String>.from(state!.unlockedTrophies);

    void addIfMissing(String id) {
      if (!trophies.contains(id)) trophies.add(id);
    }

    if (state!.totalWordsFound >= 10) addIfMissing('word_novice');
    if (state!.totalWordsFound >= 100) addIfMissing('word_master');
    if (state!.bestScore >= 500) addIfMissing('high_scorer');
    if (state!.currentStreak >= 3) addIfMissing('diligent');
    if (state!.gamesWon >= 10) addIfMissing('winner');

    if (trophies.length != state!.unlockedTrophies.length) {
      state = state!.copyWith(unlockedTrophies: trophies);
      _saveToCache();
      if (firebaseReady) {
        FirestoreService.updateGlobalStats(state!.toJson());
      }
    }
  }

  void _checkWorldUnlocks(int worldId) {
    if (state == null) return;
    final worldIds = List<int>.from(state!.unlockedWorldIds);

    // Check if the current world is complete
    // We'd ideally check LevelData.worlds finding worldId and its levels.length
    // To keep it clean, let's just use the next world ID unlocking logic

    // Simple logic for the hackathon: if you finish any level in worldId,
    // we check if it's the last one of that world to unlock next worldId + 1
    final nextWorldId = worldId + 1;
    if (nextWorldId <= 3 && !worldIds.contains(nextWorldId)) {
      // Check if all levels of worldId are done
      // Note: this depends on LevelData being accessible here or passed
      // For now, let's just unlock the next world if any level in current world is completed
      worldIds.add(nextWorldId);
    }

    if (worldIds.length != state!.unlockedWorldIds.length) {
      state = state!.copyWith(unlockedWorldIds: worldIds);
      _saveToCache();
      if (firebaseReady) {
        FirestoreService.updateGlobalStats(state!.toJson());
      }
    }
  }

  Future<void> updatePseudo(String newPseudo) async {
    if (state == null) return;
    state = state!.copyWith(pseudo: newPseudo);
    await _saveToCache();
    if (firebaseReady) {
      await FirestoreService.updateGlobalStats(state!.toJson());
    }
  }

  Future<void> logout() async {
    state = null;
    await _prefs.remove('user_profile');
    await _prefs.remove('local_user_profile');
    if (firebaseReady) {
      await FirebaseAuth.instance.signOut();
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Initialized in main
});

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProfileNotifier(prefs);
});
