import 'package:cloud_firestore/cloud_firestore.dart';

enum LeagueTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond
}

class TournamentEntry {
  final String userId;
  final String playerName;
  final int tp; // Tournament Points
  final int rank;
  final DateTime lastUpdate;

  TournamentEntry({
    required this.userId,
    required this.playerName,
    required this.tp,
    required this.rank,
    required this.lastUpdate,
  });

  factory TournamentEntry.fromFirestore(Map<String, dynamic> data, int rank) {
    return TournamentEntry(
      userId: data['userId'] ?? '',
      playerName: data['playerName'] ?? 'Joueur',
      tp: (data['tp'] ?? 0) as int,
      rank: rank,
      lastUpdate: (data['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  LeagueTier get league {
    if (rank <= 10) return LeagueTier.diamond;
    if (rank <= 50) return LeagueTier.platinum;
    if (rank <= 150) return LeagueTier.gold;
    if (rank <= 500) return LeagueTier.silver;
    return LeagueTier.bronze;
  }
}
