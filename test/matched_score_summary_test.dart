// Tests unitaires des agrégats de scores des appariements verrouillés.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:flutter_metawar/logic/matched_score_summary.dart';
import 'package:flutter_metawar/models/models.dart';

void main() {
  group('MatchedScoreSummaryCalculator', () {
    test('totalise et moyennne uniquement les appariements scorés', () {
      final matchedPlayer = Matched(
        id: 'matched00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        joueurId: 'joueur00001',
        teamMetaId: 'adversaire00001',
      );
      final unmatchedScoredPlayer = Matched(
        id: 'matched00002',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        joueurId: 'joueur00002',
        teamMetaId: 'adversaire00002',
      );
      final scoredEstim = Estim(
        joueurId: 'joueur00001',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        teamMetaId: 'adversaire00001',
        choixId: 'choix00001',
        scoreMin: 8,
        scoreMax: 12,
      );
      final unscoredEstim = Estim(
        joueurId: 'joueur00002',
        teamId: 'team00001',
        adversaireTeamId: 'adversaireTeam00001',
        teamMetaId: 'adversaire00002',
        choixId: 'choix00001',
      );

      final estimByKey = {
        'joueur00001${dashboardEstimKeySeparator}adversaire00001':
            scoredEstim,
        'joueur00002${dashboardEstimKeySeparator}adversaire00002':
            unscoredEstim,
      };

      final summary = MatchedScoreSummaryCalculator.summarize(
        [matchedPlayer, unmatchedScoredPlayer],
        estimByKey,
        dashboardEstimKeySeparator,
      );

      expect(summary.matchedCount, 2);
      expect(summary.scoredCount, 1);
      expect(summary.totalScore, 10);
      expect(summary.averageScore, 10);
    });

    test('renvoie zéro pour une équipe adverse sans appariement', () {
      final summary = MatchedScoreSummaryCalculator.summarize(
        [],
        {},
        dashboardEstimKeySeparator,
      );

      expect(summary.matchedCount, 0);
      expect(summary.scoredCount, 0);
      expect(summary.totalScore, 0);
      expect(summary.averageScore, 0);
    });
  });
}
