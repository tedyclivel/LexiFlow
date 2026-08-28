import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;
  final int rank;
  final String? avatarUrl;
  final String? model;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.score,
    required this.rank,
    this.avatarUrl,
    this.model,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc, int rank) {
    final data = doc.data() as Map<String, dynamic>;
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    return LeaderboardEntry(
      userId: doc.id,
      name: profile['pseudo'] ?? 'Anonyme',
      score: data['totalScore'] ?? 1000,
      rank: rank,
      avatarUrl: profile['avatarUrl'],
      model: data['model'],
    );
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data, int rank, String scoreField) {
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    return LeaderboardEntry(
      userId: data['id'] ?? '',
      name: profile['pseudo'] ?? data['playerName'] ?? 'Anonyme',
      score: data[scoreField] ?? 0,
      rank: rank,
      avatarUrl: profile['avatarUrl'],
      model: data['model'],
    );
  }
}
