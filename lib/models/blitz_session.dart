import 'package:flutter/foundation.dart';

/// Represents a single grid result in a Blitz session
@immutable
class BlitzGridResult {
  final int gridIndex;
  final int score;
  final int timeUsed; // Seconds used to complete grid
  final int wordsFound;
  final int totalWords;
  final bool completed;
  final DateTime timestamp;

  const BlitzGridResult({
    required this.gridIndex,
    required this.score,
    required this.timeUsed,
    required this.wordsFound,
    required this.totalWords,
    required this.completed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'gridIndex': gridIndex,
        'score': score,
        'timeUsed': timeUsed,
        'wordsFound': wordsFound,
        'totalWords': totalWords,
        'completed': completed,
        'timestamp': timestamp.toIso8601String(),
      };

  factory BlitzGridResult.fromJson(Map<String, dynamic> json) {
    return BlitzGridResult(
      gridIndex: json['gridIndex'] as int,
      score: json['score'] as int,
      timeUsed: json['timeUsed'] as int,
      wordsFound: json['wordsFound'] as int,
      totalWords: json['totalWords'] as int,
      completed: json['completed'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Represents a complete Blitz mode session
@immutable
class BlitzSession {
  final String sessionId;
  final int currentGridIndex;
  final int totalScore;
  final int gridsCompleted;
  final DateTime startTime;
  final DateTime? endTime;
  final List<BlitzGridResult> gridResults;
  final bool isActive;

  const BlitzSession({
    required this.sessionId,
    required this.currentGridIndex,
    required this.totalScore,
    required this.gridsCompleted,
    required this.startTime,
    this.endTime,
    required this.gridResults,
    required this.isActive,
  });

  /// Create a new session
  factory BlitzSession.create() {
    return BlitzSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      currentGridIndex: 0,
      totalScore: 0,
      gridsCompleted: 0,
      startTime: DateTime.now(),
      endTime: null,
      gridResults: [],
      isActive: true,
    );
  }

  /// Add a grid result and update session
  BlitzSession addGridResult(BlitzGridResult result) {
    return BlitzSession(
      sessionId: sessionId,
      currentGridIndex: currentGridIndex + 1,
      totalScore: totalScore + result.score,
      gridsCompleted: result.completed ? gridsCompleted + 1 : gridsCompleted,
      startTime: startTime,
      endTime: endTime,
      gridResults: [...gridResults, result],
      isActive: isActive,
    );
  }

  /// End the session
  BlitzSession end() {
    return BlitzSession(
      sessionId: sessionId,
      currentGridIndex: currentGridIndex,
      totalScore: totalScore,
      gridsCompleted: gridsCompleted,
      startTime: startTime,
      endTime: DateTime.now(),
      gridResults: gridResults,
      isActive: false,
    );
  }

  /// Calculate session duration in seconds
  int get durationSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  /// Calculate average time per grid
  double get averageTimePerGrid {
    if (gridResults.isEmpty) return 0;
    final totalTime = gridResults.fold<int>(0, (sum, result) => sum + result.timeUsed);
    return totalTime / gridResults.length;
  }

  /// Get best grid performance
  BlitzGridResult? get bestGrid {
    if (gridResults.isEmpty) return null;
    return gridResults.reduce((a, b) => a.score > b.score ? a : b);
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'currentGridIndex': currentGridIndex,
        'totalScore': totalScore,
        'gridsCompleted': gridsCompleted,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'gridResults': gridResults.map((r) => r.toJson()).toList(),
        'isActive': isActive,
      };

  factory BlitzSession.fromJson(Map<String, dynamic> json) {
    return BlitzSession(
      sessionId: json['sessionId'] as String,
      currentGridIndex: json['currentGridIndex'] as int,
      totalScore: json['totalScore'] as int,
      gridsCompleted: json['gridsCompleted'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      gridResults: (json['gridResults'] as List)
          .map((r) => BlitzGridResult.fromJson(r as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool,
    );
  }
}
