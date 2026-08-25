// Agrégats de scores pour les appariements d'une rencontre.

import '../models/models.dart';
import 'estim_score_calculator.dart';

/// Récapitulatif des scores des appariements verrouillés.
class MatchedScoreSummary {
  final int matchedCount;
  final int scoredCount;
  final double totalScore;
  final double averageScore;

  const MatchedScoreSummary({
    required this.matchedCount,
    required this.scoredCount,
    required this.totalScore,
    required this.averageScore,
  });
}

/// Calcule le total et la moyenne des appariements disposant d'un score.
abstract final class MatchedScoreSummaryCalculator {
  static const double zeroScore = 0;

  static MatchedScoreSummary summarize(
    List<Matched> matchedList,
    Map<String, Estim> estimByKey,
    String keySeparator,
  ) {
    var scoredCount = 0;
    var totalScore = zeroScore;

    for (final matched in matchedList) {
      final estimKey =
          '${matched.joueurId}$keySeparator${matched.metaAdvId}';
      final midpoint = EstimScoreCalculator.midpointScore(estimByKey[estimKey]);
      if (midpoint != null) {
        scoredCount++;
        totalScore += midpoint;
      }
    }

    final averageScore =
        scoredCount == 0 ? zeroScore : totalScore / scoredCount;

    return MatchedScoreSummary(
      matchedCount: matchedList.length,
      scoredCount: scoredCount,
      totalScore: totalScore,
      averageScore: averageScore,
    );
  }
}
