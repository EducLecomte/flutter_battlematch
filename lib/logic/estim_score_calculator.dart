// Calculs de score applicables à une estimation MetaWar.

import '../models/models.dart';

/// Calcule la valeur comptabilisée et le libellé lisible d'un score.
abstract final class EstimScoreCalculator {
  static const int scoreMidpointDivisor = 2;

  /// Renvoie `(scoreMin + scoreMax) / 2`, ou `null` si l'un des deux scores
  /// est absent.
  static double? midpointScore(Estim? estim) {
    final minimumScore = estim?.scoreMin;
    final maximumScore = estim?.scoreMax;
    if (minimumScore == null || maximumScore == null) {
      return null;
    }
    return (minimumScore + maximumScore) / scoreMidpointDivisor;
  }

  /// Renvoie le libellé compact du score : `12`, `8-12`, ou `null`.
  static String? scoreRangeLabel(Estim? estim) {
    final minimumScore = estim?.scoreMin;
    final maximumScore = estim?.scoreMax;
    if (minimumScore == null || maximumScore == null) {
      return null;
    }
    if (minimumScore == maximumScore) {
      return '$minimumScore';
    }
    return '$minimumScore-$maximumScore';
  }
}
