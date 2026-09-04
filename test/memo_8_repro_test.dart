import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:flutter_metawar/models/models.dart';

/// Point 8 MEMO : la collection `rencontres` est supprimée.
/// Les estimations et appariements sont ancrés sur le duo d'équipes
/// `team_id` + `adversaire_team_id` (référence `team_meta_id`), tandis que
/// la méta (`team_meta`) est ancrée uniquement sur son `team_id`. Ces tests
/// de garde vérifient que les modèles ne connaissent plus aucun
/// `rencontre_id`.
void main() {
  group('point 8 — suppression de la collection rencontres', () {
    test('TeamMeta est ancré sur team_id sans adversaire_team_id ni rencontre_id',
        () {
      final TeamMeta teamMeta = TeamMeta.fromPocketBaseRecord(RecordModel({
        'id': 'meta000000000001',
        'team_id': 'equipe0000000001',
        'armee_id': 'armee0000000001',
        'nom_jo': 'Adversaire1',
        'liste_jo': 'Liste d\'armée adverse',
      }));

      expect(teamMeta.teamId, 'equipe0000000001');

      final Map<String, dynamic> donnees = teamMeta.toJson();
      expect(donnees.containsKey('team_id'), isTrue);
      expect(donnees.containsKey('adversaire_team_id'), isFalse);
      expect(donnees.containsKey('rencontre_id'), isFalse);
    });

    test(
        'Estim est ancré sur team_id + adversaire_team_id sans rencontre_id',
        () {
      final Estim estim = Estim.fromPocketBaseRecord(RecordModel({
        'joueur_id': 'joueur000000001',
        'team_id': 'equipe0000000001',
        'adversaire_team_id': 'equipe0000000002',
         'team_meta_id': 'meta000000000001',
        'choix_id': 'choix00000000001',
        'confiance': 'moyen',
      }));

      expect(estim.teamId, 'equipe0000000001');
      expect(estim.adversaireTeamId, 'equipe0000000002');

      final Map<String, dynamic> donnees = estim.toJson();
      expect(donnees.containsKey('team_id'), isTrue);
      expect(donnees.containsKey('adversaire_team_id'), isTrue);
      expect(donnees.containsKey('rencontre_id'), isFalse);
    });

    test(
        'Matched est ancré sur team_id + adversaire_team_id sans rencontre_id',
        () {
      final Matched appariement =
          Matched.fromPocketBaseRecord(RecordModel({
        'id': 'match00000000001',
        'team_id': 'equipe0000000001',
        'adversaire_team_id': 'equipe0000000002',
        'joueur_id': 'joueur000000001',
         'team_meta_id': 'meta000000000001',
      }));

      expect(appariement.teamId, 'equipe0000000001');
      expect(appariement.adversaireTeamId, 'equipe0000000002');

      final Map<String, dynamic> donnees = appariement.toJson();
      expect(donnees.containsKey('team_id'), isTrue);
      expect(donnees.containsKey('adversaire_team_id'), isTrue);
      expect(donnees.containsKey('rencontre_id'), isFalse);
    });
  });
}
