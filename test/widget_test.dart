// ===========================================================================
// Tests unitaires des modèles de données MetaWar.
// Vérifie les conversions RecordModel PocketBase ↔ objets Dart.
// ===========================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:flutter_metawar/models/models.dart';

void main() {
  group('Joueur', () {
    test('convertit un enregistrement PocketBase complet', () {
      final record = RecordModel({
        'id': 'abc123def456ghi',
        'email': 'gus@pedagogeek.fr',
        'nom': 'Augustin',
        'admin': true,
      });

      final joueur = Joueur.fromPocketBaseRecord(record);

      expect(joueur.id, 'abc123def456ghi');
      expect(joueur.email, 'gus@pedagogeek.fr');
      expect(joueur.nom, 'Augustin');
      expect(joueur.admin, true);
    });
  });

  group('Team', () {
    test('accepte un capitaine présent', () {
      final record = RecordModel({
        'id': 'team1234567890a',
        'nom': 'trc2',
        'capitaine_id': 'abc123def456ghi',
      });

      final team = Team.fromPocketBaseRecord(record);

      expect(team.nom, 'trc2');
      expect(team.capitaineId, 'abc123def456ghi');
    });

    test('accepte une équipe sans capitaine renseigné', () {
      final record = RecordModel({
        'id': 'team1234567890a',
        'nom': 'trc2',
      });

      final team = Team.fromPocketBaseRecord(record);

      expect(team.capitaineId, isNull);
    });
  });

  group('Tournoi', () {
    test('valeur lien_nr absente ramenée à chaîne vide', () {
      final record = RecordModel({
        'id': 'tournois000001ab',
        'nom': 'training trc2',
      });

      final tournoi = Tournoi.fromPocketBaseRecord(record);

      expect(tournoi.lienNr, '');
      expect(tournoi.createdBy, isNull);
    });
  });

  group('Estim', () {
    test('scores optionnels et confiance par défaut', () {
      final record = RecordModel({
        'id': 'estims00000001ab',
        'joueur_id': 'abc123def456ghi',
        'rencontre_id': 'rencontre00001ab',
        'meta_adv_id': 'metaadv000001ab',
        'choix_id': 'choix00000001ab',
      });

      final estim = Estim.fromPocketBaseRecord(record);

      expect(estim.scoreMin, isNull);
      expect(estim.scoreMax, isNull);
      expect(estim.confiance, 'moyen');
      expect(estim.commentaire, isNull);
    });
  });

  group('Matched', () {
    test('convertit un appariement verrouillé', () {
      final record = RecordModel({
        'id': 'matched000001ab',
        'rencontre_id': 'rencontre00001ab',
        'joueur_id': 'abc123def456ghi',
        'meta_adv_id': 'metaadv000001ab',
      });

      final matched = Matched.fromPocketBaseRecord(record);

      expect(matched.joueurId, 'abc123def456ghi');
      expect(matched.metaAdvId, 'metaadv000001ab');
    });
  });
}
