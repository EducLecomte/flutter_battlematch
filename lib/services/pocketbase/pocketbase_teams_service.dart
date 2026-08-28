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

  /// Crée une équipe rattachée à un tournoi sans capitaine.
  Future<Team> createTeamForTournoi(String tournoiId, String nomEquipe) async {
    final String nomNettoye = nomEquipe.trim();
    if (nomNettoye.isEmpty) {
      throw Exception("Le nom de l'équipe est obligatoire.");
    }
    final RecordModel recordEquipe = await _holder.clientPocketBase
        .collection(collectionNameTeams)
        .create(body: {
       'nom': nomNettoye,
       'tournoi_id': tournoiId,
     });
    return Team.fromPocketBaseRecord(recordEquipe);
  }

  /// Récupère une équipe par son identifiant PocketBase.
  Future<Team> getTeam(String teamId) async {
    final RecordModel recordEquipe = await _holder.clientPocketBase
        .collection(collectionNameTeams)
        .getOne(teamId);
    return Team.fromPocketBaseRecord(recordEquipe);
  }

  /// Récupère toutes les équipes rattachées à un tournoi.
  Future<List<Team>> getTeamsForTournoi(String tournoiId) async {
    try {
      final List<RecordModel> recordsEquipes =
          await _holder.clientPocketBase
              .collection(collectionNameTeams)
              .getFullList(
                filter:
                    'tournoi_id = "${_holder.echapperFiltrePocketBase(tournoiId)}"',
                sort: 'nom',
              );
      return recordsEquipes.map(Team.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des équipes du tournoi : $exception');
      return [];
    }
  }

  /// Met à jour le mot de passe d'accès d'une équipe.
  Future<Team> updateTeamMotDePasse(String teamId, String motDePasse) async {
    if (motDePasse.length > teamPasswordMaxLength) {
      throw Exception(
        "Le mot de passe ne peut dépasser $teamPasswordMaxLength caractères.",
      );
    }
    await _holder.clientPocketBase.collection(collectionNameTeams).update(
      teamId,
      body: {'mot_de_passe': motDePasse},
    );
    return getTeam(teamId);
  }

  /// Met à jour l'identifiant du capitaine d'une équipe.
  Future<Team> updateTeamCapitaineId(String teamId, String capitaineId) async {
    await _holder.clientPocketBase.collection(collectionNameTeams).update(
      teamId,
      body: {'capitaine_id': capitaineId},
    );
    return getTeam(teamId);
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
