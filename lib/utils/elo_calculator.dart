import 'dart:math';

class EloCalculator {
  static const int kFactor = 32;

  /// Calculates the new ELO rating for player A
  /// [ratingA] Current rating of player A
  /// [ratingB] Current rating of player B
  /// [scoreA] Actual score (1.0 for win, 0.5 for draw, 0.0 for loss)
  static int calculateNewRating(int ratingA, int ratingB, double scoreA) {
    double expectedScoreA = 1 / (1 + pow(10, (ratingB - ratingA) / 400));
    return (ratingA + kFactor * (scoreA - expectedScoreA)).round();
  }
}
