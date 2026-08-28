enum TaskType {
  findWords,
  winDuels,
  completeBlitz,
  completeChaos,
  totalScore
}

class DailyTask {
  final String id;
  final String title;
  final TaskType type;
  final int target;
  final int progress;
  final int rewardCoins;
  final bool isClaimed;

  DailyTask({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    this.progress = 0,
    required this.rewardCoins,
    this.isClaimed = false,
  });

  DailyTask copyWith({
    int? progress,
    bool? isClaimed,
  }) {
    return DailyTask(
      id: id,
      title: title,
      type: type,
      target: target,
      progress: progress ?? this.progress,
      rewardCoins: rewardCoins,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  bool get isCompleted => progress >= target;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.index,
        'target': target,
        'progress': progress,
        'rewardCoins': rewardCoins,
        'isClaimed': isClaimed,
      };

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'],
      title: json['title'],
      type: TaskType.values[json['type']],
      target: json['target'],
      progress: json['progress'],
      rewardCoins: json['rewardCoins'],
      isClaimed: json['isClaimed'],
    );
  }
}
