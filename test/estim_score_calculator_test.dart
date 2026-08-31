// Tests unitaires du calcul de score d'une estimation.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/logic/estim_score_calculator.dart';
import 'package:flutter_metawar/models/models.dart';

void main() {
  group('EstimScoreCalculator', () {
    test('calcule le point médian du score', () {
      final estim = Estim(
        joueurId: 'joueur00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        metaAdvId: 'adversaire00001',
        choixId: 'choix00001',
        scoreMin: 8,
        scoreMax: 12,
      );

      expect(EstimScoreCalculator.midpointScore(estim), 10);
    });

    test('renvoie null si un score est absent', () {
      final incompleteEstim = Estim(
        joueurId: 'joueur00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        metaAdvId: 'adversaire00001',
        choixId: 'choix00001',
        scoreMin: 8,
      );

      expect(EstimScoreCalculator.midpointScore(incompleteEstim), isNull);
      expect(EstimScoreCalculator.midpointScore(null), isNull);
    });

    test('formate le libellé du score', () {
      final rangeEstim = Estim(
        joueurId: 'joueur00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        metaAdvId: 'adversaire00001',
        choixId: 'choix00001',
        scoreMin: 8,
        scoreMax: 12,
      );
      final fixedEstim = Estim(
        joueurId: 'joueur00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        metaAdvId: 'adversaire00001',
        choixId: 'choix00001',
        scoreMin: 10,
        scoreMax: 10,
      );

      expect(EstimScoreCalculator.scoreRangeLabel(rangeEstim), '8-12');
      expect(EstimScoreCalculator.scoreRangeLabel(fixedEstim), '10');
      expect(EstimScoreCalculator.scoreRangeLabel(null), isNull);
    });
  });
}
