// Bandeau d'agrégats des appariements du tableau de bord d'équipe.

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../logic/matched_score_summary.dart';

/// Affiche le nombre d'appariements, le score total et la moyenne.
class TeamDashboardScoreSummary extends StatelessWidget {
  static const double summaryHorizontalPadding = 12;
  static const double summaryVerticalPadding = 8;
  static const double summaryBorderRadius = 8;
  static const double summaryItemSpacing = 16;
  static const double summaryRunSpacing = 4;

  final MatchedScoreSummary summary;

  const TeamDashboardScoreSummary({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.matchedCount == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final totalScoreLabel =
        summary.totalScore.toStringAsFixed(scoreSummaryDecimalPlaces);
    final averageScoreLabel =
        summary.averageScore.toStringAsFixed(scoreSummaryDecimalPlaces);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: summaryHorizontalPadding,
        vertical: summaryVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(summaryBorderRadius),
      ),
      child: Wrap(
        spacing: summaryItemSpacing,
        runSpacing: summaryRunSpacing,
        children: [
          Text(
            'Appariements : ${summary.matchedCount}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Score total : $totalScoreLabel'),
          Text('Moyenne : $averageScoreLabel'),
        ],
      ),
    );
  }
}
