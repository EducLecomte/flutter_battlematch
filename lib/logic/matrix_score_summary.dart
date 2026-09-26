// ===========================================================================
// Agrégats d'estimations pour les lignes et colonnes de la matrice
// (matrix_score_summary.dart)
// ===========================================================================

import '../models/models.dart';
import 'estim_score_calculator.dart';

/// Résumé statistique d'une série d'estimations (moyenne et amplitude max-min).
class MatrixScoreSummary {
  final int count;
  final double? average;
  final double? delta;

  const MatrixScoreSummary({
    required this.count,
    required this.average,
    required this.delta,
  });

  bool get hasData => count > 0 && average != null && delta != null;
}

/// Calcule la moyenne et le delta (amplitude max - min) d'une série d'estimations.
abstract final class MatrixScoreSummaryCalculator {
  /// Calcule le résumé pour une séquence d'estimations (éventuellement nulles ou sans score).
  static MatrixScoreSummary summarize(Iterable<Estim?> estims) {
    final midpoints = <double>[];

    for (final estim in estims) {
      final midpoint = EstimScoreCalculator.midpointScore(estim);
      if (midpoint != null) {
        midpoints.add(midpoint);
      }
    }

    if (midpoints.isEmpty) {
      return const MatrixScoreSummary(
        count: 0,
        average: null,
        delta: null,
      );
    }

    var min = midpoints.first;
    var max = midpoints.first;
    var sum = 0.0;

    for (final score in midpoints) {
      if (score < min) min = score;
      if (score > max) max = score;
      sum += score;
    }

    final average = sum / midpoints.length;
    final delta = max - min;

    return MatrixScoreSummary(
      count: midpoints.length,
      average: average,
      delta: delta,
    );
  }
}
