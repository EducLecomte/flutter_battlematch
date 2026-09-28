// ===========================================================================
// Cellule de synthèse de la matrice (team_dashboard_matrix_summary_cell.dart)
// Carte flottante (détachée de la grille) affichant sur deux lignes la
// moyenne des estimations et le delta (max - min).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../logic/matrix_score_summary.dart';

class MatrixSummaryCell extends StatelessWidget {
  static const double cellHeight = 64;
  static const double cardVerticalInset = 5;
  static const double cardHorizontalInset = 3;
  static const double cornerRadius = 10;
  static const double averageFontSize = 13;
  static const double deltaFontSize = 10;
  static const double lineSpacing = 2;

  final MatrixScoreSummary summary;

  /// Affiche la moyenne inverse (score maximum - moyenne) au lieu de la
  /// moyenne brute. Le delta affiché est inchangé : l'amplitude max - min est
  /// invariante par inversion sur l'échelle 0-20.
  final bool inverseAverage;

  const MatrixSummaryCell({
    super.key,
    required this.summary,
    this.inverseAverage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String averageText;
    final String deltaText;

    if (summary.hasData) {
      final double displayedAverage = inverseAverage
          ? MatrixScoreSummaryCalculator.invertedAverage(summary.average)!
          : summary.average!;
      averageText = displayedAverage.toStringAsFixed(scoreSummaryDecimalPlaces);
      deltaText =
          'Δ ${summary.delta!.toStringAsFixed(scoreSummaryDecimalPlaces)}';
    } else {
      averageText = '-';
      deltaText = '-';
    }

    final accentColor = theme.colorScheme.primary;

    return Tooltip(
      message: summary.hasData
          ? (inverseAverage
                ? "Moyenne inverse ($estimScoreMaximum - moyenne) : $averageText\nDelta (max - min) : $deltaText"
                : "Moyenne : $averageText\nDelta (max - min) : $deltaText")
          : "Aucune estimation renseignée",
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: cardVerticalInset,
          horizontal: cardHorizontalInset,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              averageText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: averageFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: lineSpacing),
            Text(
              deltaText,
              style: TextStyle(
                fontSize: deltaFontSize,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color ?? Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
