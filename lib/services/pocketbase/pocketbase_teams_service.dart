// ===========================================================================
// Équipes MetaWar : création d'équipe (avec capitaine auto-accepté),
// listing des équipes acceptées par utilisateur et suppression.
// La gestion des membres et invitations est dans
// pocketbase_team_membres_service.dart.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';
import 'pocketbase_team_membres_service.dart';

class PocketbaseTeamsService {
  static final PocketbaseTeamsService instance =
      PocketbaseTeamsService._internal();

  PocketbaseTeamsService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Crée une équipe et inscrit son créateur comme capitaine accepté.
  Future<Team> createTeam(String nom) async {
    final String? capitaineId = _holder.currentUserId;
    if (capitaineId == null) throw Exception("Non authentifié");

    // 1. Insertion de la Team
    final RecordModel recordEquipe = await _holder.clientPocketBase
        .collection(collectionNameTeams)
        .create(body: {
      'nom': nom,
      'capitaine_id': capitaineId,
    });

    final Team team = Team.fromPocketBaseRecord(recordEquipe);

    // 2. Ajout du capitaine dans team_membres comme membre accepté
    await PocketbaseTeamMembresService.instance
        .inscrireMembreAccepte(team.id, capitaineId, 'captain');

    return team;
  }

  /// Récupère les équipes dont l'utilisateur est membre ayant ACCEPTÉ.
  Future<List<Team>> getTeamsForUser(String userId) async {
    try {
      final List<RecordModel> recordsMembres =
          await _holder.clientPocketBase
              .collection(collectionNameTeamMembres)
              .getFullList(
                filter:
                    'joueur_id = "${_holder.echapperFiltrePocketBase(userId)}" '
                    '&& statut = "accepted"',
                expand: 'team_id',
              );

      return recordsMembres.map((RecordModel recordMembre) {
        final RecordModel recordEquipe =
            recordMembre.get<RecordModel>('expand.team_id');
        return Team.fromPocketBaseRecord(recordEquipe);
      }).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des équipes : $exception');
      return [];
    }
  }

  /// Supprime une équipe (les membres et rencontres sont purgés en cascade).
  Future<void> deleteTeam(String teamId) async {
    await _holder.clientPocketBase.collection(collectionNameTeams).delete(teamId);
  }
}
