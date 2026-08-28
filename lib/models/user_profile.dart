class UserProfile {
  final String pseudo;
  final String avatarUrl;
  final int totalWordsFound;
  final int totalScore;
  final int bestScore;
  final int gamesPlayed;
  final int gamesWon;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastGameDate;
  final List<String> unlockedTrophies;
  final List<int> unlockedWorldIds;
  final Map<int, List<int>> completedLevelIds; // {worldId: [levelId1, levelId2, ...]}

  UserProfile({
    required this.pseudo,
    required this.avatarUrl,
    this.totalWordsFound = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastGameDate,
    this.unlockedTrophies = const [],
    this.unlockedWorldIds = const [1],
    this.completedLevelIds = const {},
  });

  UserProfile copyWith({
    String? pseudo,
    String? avatarUrl,
    int? totalWordsFound,
    int? totalScore,
    int? bestScore,
    int? gamesPlayed,
    int? gamesWon,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastGameDate,
    List<String>? unlockedTrophies,
    List<int>? unlockedWorldIds,
    Map<int, List<int>>? completedLevelIds,
  }) {
    return UserProfile(
      pseudo: pseudo ?? this.pseudo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastGameDate: lastGameDate ?? this.lastGameDate,
      unlockedTrophies: unlockedTrophies ?? this.unlockedTrophies,
      unlockedWorldIds: unlockedWorldIds ?? this.unlockedWorldIds,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'pseudo': pseudo,
    'avatarUrl': avatarUrl,
    'totalWordsFound': totalWordsFound,
    'totalScore': totalScore,
    'bestScore': bestScore,
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastGameDate': lastGameDate?.toIso8601String(),
    'unlockedTrophies': unlockedTrophies,
    'unlockedWorldIds': unlockedWorldIds,
    'completedLevelIds': completedLevelIds.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Map<int, List<int>> completedLevels = {};
    if (json['completedLevelIds'] != null) {
      (json['completedLevelIds'] as Map).forEach((k, v) {
        completedLevels[int.parse(k.toString())] = List<int>.from(v);
      });
    }

    return UserProfile(
      pseudo: json['pseudo'] ?? 'Joueur',
      avatarUrl: json['avatarUrl'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=Lexi',
      totalWordsFound: json['totalWordsFound'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastGameDate: json['lastGameDate'] != null ? DateTime.parse(json['lastGameDate']) : null,
      unlockedTrophies: List<String>.from(json['unlockedTrophies'] ?? []),
      unlockedWorldIds: List<int>.from(json['unlockedWorldIds'] ?? [1]),
      completedLevelIds: completedLevels,
    );
  }
}
