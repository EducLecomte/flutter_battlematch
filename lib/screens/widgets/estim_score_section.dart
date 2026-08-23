// ===========================================================================
// Section du score estimé (estim_score_section.dart)
// Curseur double (0-20) pour le score minimum et maximum attendu.
// ===========================================================================

import 'package:flutter/material.dart';

class EstimScoreSection extends StatelessWidget {
  final int scoreMin;
  final int scoreMax;
  final void Function(int scoreMin, int scoreMax) onScoreChanged;

  const EstimScoreSection({
    super.key,
    required this.scoreMin,
    required this.scoreMax,
    required this.onScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Score estimé (0-20) :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Minimum: $scoreMin",
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              "Maximum: $scoreMax",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(scoreMin.toDouble(), scoreMax.toDouble()),
          min: 0,
          max: 20,
          divisions: 20,
          labels: RangeLabels('$scoreMin', '$scoreMax'),
          onChanged: (RangeValues values) {
            onScoreChanged(values.start.round(), values.end.round());
          },
        ),
      ],
    );
  }
}
