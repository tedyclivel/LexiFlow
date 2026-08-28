import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:search_word/utils/ip_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<void> saveGameResult({
    required int score,
    required String levelName,
    required int timeTaken,
    required bool isWin,
    required int wordsFound,
  }) async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      debugPrint('FirestoreService: Starting saveGameResult for $uid...');

      String ipAddress = '0.0.0.0';
      try {
        ipAddress = await IPService.getExternalIP().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('FirestoreService: IP retrieval failed or timed out: $e');
      }

      final playerDoc = _db.collection('players').doc(uid);
      
      await playerDoc.set({
        'userId': uid,
        'lastIp': ipAddress,
        'lastActive': FieldValue.serverTimestamp(),
        'totalScore': FieldValue.increment(score),
        'gamesPlayed': FieldValue.increment(1),
        'platform': Platform.isAndroid ? 'Android' : 'iOS',
      }, SetOptions(merge: true));

      await playerDoc.collection('sessions').add({
        'levelName': levelName,
        'score': score,
        'timeTaken': timeTaken,
        'isWin': isWin,
        'wordsFound': wordsFound,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAtSession': ipAddress,
      });

      debugPrint('FirestoreService: Game session logged successfully.');

    } catch (e) {
      debugPrint('Error saving to Firestore: $e');
    }
  }

  static Future<void> updateGlobalStats(Map<String, dynamic> profileData) async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      await _db.collection('players').doc(uid).set({
        'profile': profileData,
        'playerName': profileData['pseudo'] ?? profileData['playerName'],
        'avatarUrl': profileData['avatarUrl'],
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error syncing profile to Firestore: $e');
    }
  }

  static Future<Map<String, dynamic>?> getProfile(String uid) async {
    try {
      final doc = await _db.collection('players').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['profile'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getLeaderboard({String field = 'elo', int limit = 50}) async {
    final snapshot = await _db.collection('players')
        .orderBy(field, descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  static Future<void> updateELO(String userId, int newElo) async {
    await _db.collection('players').doc(userId).update({
      'elo': newElo,
    });
  }
  
  static Future<void> updateBlitzHighScore(String userId, int score) async {
    final doc = await _db.collection('players').doc(userId).get();
    final currentBest = doc.data()?['bestBlitzScore'] ?? 0;
    if (score > currentBest) {
      await _db.collection('players').doc(userId).update({
        'bestBlitzScore': score,
      });
    }
  }

  static String get _currentWeekId {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysSinceFirstDay = now.difference(firstDayOfYear).inDays;
    final weekNumber = (daysSinceFirstDay / 7).floor() + 1;
    return 'tournament_${now.year}_$weekNumber';
  }

  static Future<void> updateTournamentPoints({
    required String userId,
    required String playerName,
    required String? avatarUrl,
    required int points,
  }) async {
    try {
      final tournamentDoc = _db.collection('tournaments').doc(_currentWeekId);
      final playerRankingDoc = tournamentDoc.collection('rankings').doc(userId);

      await playerRankingDoc.set({
        'userId': userId,
        'playerName': playerName,
        'avatarUrl': avatarUrl,
        'tp': FieldValue.increment(points),
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('FirestoreService: Tournament points updated (+$points TP).');
    } catch (e) {
      debugPrint('Error updating tournament points: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTournamentRankings({int limit = 50}) async {
    try {
      final snapshot = await _db.collection('tournaments')
          .doc(_currentWeekId)
          .collection('rankings')
          .orderBy('tp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error fetching tournament rankings: $e');
      return [];
    }
  }

  static Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _db.collection('players').doc(userId).set({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  static Future<Map<String, dynamic>?> findPlayerByPseudo(String pseudo) async {
    try {
      final snapshot = await _db.collection('players')
          .where('playerName', isEqualTo: pseudo)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return {
          'userId': snapshot.docs.first.id,
          ...snapshot.docs.first.data(),
        };
      }
    } catch (e) {
      debugPrint('Error searching player: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getOnlinePlayers({int limit = 20}) async {
    try {
      final snapshot = await _db.collection('players')
          .where('isOnline', isEqualTo: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => {
        'userId': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      debugPrint('Error fetching online players: $e');
      return [];
    }
  }
}
