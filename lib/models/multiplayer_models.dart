import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a player's request to join a match
class MultiplayerPlayer {
  final String userId;
  final String pseudo;
  final String avatarUrl;
  final int score;
  final bool isReady;

  MultiplayerPlayer({
    required this.userId,
    required this.pseudo,
    required this.avatarUrl,
    this.score = 0,
    this.isReady = false,
  });

  factory MultiplayerPlayer.fromJson(Map<String, dynamic> data) {
    return MultiplayerPlayer(
      userId: data['userId'] ?? '',
      pseudo: data['pseudo'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      score: data['score'] ?? 0,
      isReady: data['isReady'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'pseudo': pseudo,
    'avatarUrl': avatarUrl,
    'score': score,
    'isReady': isReady,
  };
}

/// Represents an active or finished multiplayer duel
class DuelMatch {
  final String id;
  final String player1Id;
  final String player2Id;
  final String player1Name;
  final String player2Name;
  final String status; // 'starting', 'active', 'finished'
  final int levelId;
  final List<String> p1Progress;
  final List<String> p2Progress;
  final String? winnerId;
  final DateTime? startTime;
  final String? p1Attack;
  final String? p2Attack;

  DuelMatch({
    required this.id,
    required this.player1Id,
    required this.player2Id,
    required this.player1Name,
    required this.player2Name,
    required this.status,
    required this.levelId,
    required this.p1Progress,
    required this.p2Progress,
    this.winnerId,
    this.startTime,
    this.p1Attack,
    this.p2Attack,
  });

  factory DuelMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DuelMatch(
      id: doc.id,
      player1Id: data['player1Id'] ?? '',
      player2Id: data['player2Id'] ?? '',
      player1Name: data['player1Name'] ?? '',
      player2Name: data['player2Name'] ?? '',
      status: data['status'] ?? 'starting',
      levelId: data['levelId'] ?? 0,
      p1Progress: List<String>.from(data['p1_progress'] ?? []),
      p2Progress: List<String>.from(data['p2_progress'] ?? []),
      winnerId: data['winnerId'],
      startTime: (data['startTime'] as Timestamp?)?.toDate(),
      p1Attack: data['p1Attack'],
      p2Attack: data['p2Attack'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'player1Id': player1Id,
      'player2Id': player2Id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'status': status,
      'levelId': levelId,
      'p1_progress': p1Progress,
      'p2_progress': p2Progress,
      'winnerId': winnerId,
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'p1Attack': p1Attack,
      'p2Attack': p2Attack,
    };
  }

  int get p1Score => p1Progress.length;
  int get p2Score => p2Progress.length;
}
