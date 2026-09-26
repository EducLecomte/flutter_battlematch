// Tests unitaires du calculateur de synthèse (moyenne et delta max-min) pour la matrice.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_metawar/logic/matrix_score_summary.dart';
import 'package:flutter_metawar/models/models.dart';

void main() {
  group('MatrixScoreSummaryCalculator', () {
    test('renvoie hasData = false et valeurs nulles pour une liste vide', () {
      final summary = MatrixScoreSummaryCalculator.summarize([]);
      expect(summary.hasData, isFalse);
      expect(summary.count, 0);
      expect(summary.average, isNull);
      expect(summary.delta, isNull);
    });

    test('ignore les estimations nulles ou sans score', () {
      final estimWithoutScore = Estim(
        joueurId: 'j1',
        teamId: 't1',
        adversaireTeamId: 't2',
        teamMetaId: 'opp1',
        choixId: 'c1',
      );
      final summary = MatrixScoreSummaryCalculator.summarize([
        null,
        estimWithoutScore,
      ]);
      expect(summary.hasData, isFalse);
      expect(summary.count, 0);
    });

    test('calcule correctement la moyenne et le delta pour un seul score', () {
      final estim = Estim(
        joueurId: 'j1',
        teamId: 't1',
        adversaireTeamId: 't2',
        teamMetaId: 'opp1',
        choixId: 'c1',
        scoreMin: 12,
        scoreMax: 12,
      );
      final summary = MatrixScoreSummaryCalculator.summarize([estim]);
      expect(summary.hasData, isTrue);
      expect(summary.count, 1);
      expect(summary.average, 12.0);
      expect(summary.delta, 0.0);
    });

    test('calcule la moyenne et le delta (amplitude max - min) sur plusieurs estimations', () {
      final estim1 = Estim(
        joueurId: 'j1',
        teamId: 't1',
        adversaireTeamId: 't2',
        teamMetaId: 'opp1',
        choixId: 'c1',
        scoreMin: 6,
        scoreMax: 8, // midpoint: 7.0
      );
      final estim2 = Estim(
        joueurId: 'j1',
        teamId: 't1',
        adversaireTeamId: 't2',
        teamMetaId: 'opp2',
        choixId: 'c2',
        scoreMin: 10,
        scoreMax: 10, // midpoint: 10.0
      );
      final estim3 = Estim(
        joueurId: 'j1',
        teamId: 't1',
        adversaireTeamId: 't2',
        teamMetaId: 'opp3',
        choixId: 'c3',
        scoreMin: 12,
        scoreMax: 14, // midpoint: 13.0
      );

      // midpoints: 7.0, 10.0, 13.0 -> sum: 30.0 -> average: 10.0, max: 13.0, min: 7.0, delta: 6.0
      final summary = MatrixScoreSummaryCalculator.summarize([estim1, estim2, estim3]);
      expect(summary.hasData, isTrue);
      expect(summary.count, 3);
      expect(summary.average, 10.0);
      expect(summary.delta, 6.0);
    });
  });
}
