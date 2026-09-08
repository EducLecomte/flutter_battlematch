// ===========================================================================
// Tests unitaires des modèles de données MetaWar.
// Vérifie les conversions RecordModel PocketBase ↔ objets Dart.
// ===========================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:flutter_metawar/models/models.dart';

import 'package:flutter_metawar/services/tournament_team_import_service.dart';

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
      final record = RecordModel({'id': 'team1234567890a', 'nom': 'trc2'});

      final team = Team.fromPocketBaseRecord(record);

      expect(team.capitaineId, isNull);
    });
  });

  group('Tournoi', () {
    test('valeurs par défaut des champs optionnels', () {
      final record = RecordModel({
        'id': 'tournois000001ab',
        'nom': 'training trc2',
      });

      final tournoi = Tournoi.fromPocketBaseRecord(record);

      expect(tournoi.nom, 'training trc2');
      expect(tournoi.createdBy, isNull);
      expect(tournoi.importEffectue, isFalse);
    });
  });

  group('Estim', () {
    test('scores optionnels et confiance par défaut', () {
      final record = RecordModel({
        'id': 'estims00000001ab',
        'joueur_id': 'abc123def456ghi',
        'team_id': 'team000001ab',
        'adversaire_team_id': 'adversaire0001ab',
         'team_meta_id': 'metaadv000001ab',
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
        'team_id': 'team000001ab',
        'adversaire_team_id': 'adversaire0001ab',
        'joueur_id': 'abc123def456ghi',
         'team_meta_id': 'metaadv000001ab',
      });

      final matched = Matched.fromPocketBaseRecord(record);

      expect(matched.joueurId, 'abc123def456ghi');
      expect(matched.teamMetaId, 'metaadv000001ab');
    });
  });

  group('TournamentTeamImportService', () {
    test('regroupe les joueurs par équipe pour l import complet', () {
      final importedPlayers = [
        {
          'teamName': 'Alpha',
          'playerName': 'Alice',
          'armyName': 'Empire of Sonnstahl',
          'listText': 'Liste Alice',
        },
        {
          'teamName': 'Beta',
          'playerName': 'Bob',
          'armyName': 'Vampire Covenant',
          'listText': 'Liste Bob',
        },
        {
          'teamName': 'Alpha',
          'playerName': 'Alicia',
          'armyName': 'Empire of Sonnstahl',
          'listText': 'Liste Alicia',
        },
      ];

      final byTeam = TournamentTeamImportService.instance
          .groupPlayersByTeamName(importedPlayers);

      expect(byTeam.keys, containsAll(['Alpha', 'Beta']));
      expect(byTeam['Alpha'], hasLength(2));
      expect(byTeam['Beta']!.single['playerName'], 'Bob');
    });
  });
}
