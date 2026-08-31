import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:flutter_metawar/models/models.dart';

/// Point 8 MEMO : la collection `rencontres` est supprimée.
/// Les métas, estimations et appariements sont ancrés directement sur le
/// duo d'équipes `team_id` + `adversaire_team_id`. Ces tests de garde
/// vérifient que les modèles exposent ce duo et ne connaissent plus
/// aucun `rencontre_id`.
void main() {
  group('point 8 — suppression de la collection rencontres', () {
    test('MetaAdv est ancré sur team_id + adversaire_team_id sans rencontre_id',
        () {
      final MetaAdv metaAdv = MetaAdv.fromPocketBaseRecord(RecordModel({
        'id': 'meta000000000001',
        'team_id': 'equipe0000000001',
        'adversaire_team_id': 'equipe0000000002',
        'armee_id': 'armee0000000001',
        'nom_jo_adv': 'Adversaire1',
        'liste_adv': 'Liste d\'armée adverse',
      }));

      expect(metaAdv.teamId, 'equipe0000000001');
      expect(metaAdv.adversaireTeamId, 'equipe0000000002');

      final Map<String, dynamic> donnees = metaAdv.toJson();
      expect(donnees.containsKey('team_id'), isTrue);
      expect(donnees.containsKey('adversaire_team_id'), isTrue);
      expect(donnees.containsKey('rencontre_id'), isFalse);
    });

    test(
        'Estim est ancré sur team_id + adversaire_team_id sans rencontre_id',
        () {
      final Estim estim = Estim.fromPocketBaseRecord(RecordModel({
        'joueur_id': 'joueur000000001',
        'team_id': 'equipe0000000001',
        'adversaire_team_id': 'equipe0000000002',
        'meta_adv_id': 'meta000000000001',
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
        'meta_adv_id': 'meta000000000001',
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
