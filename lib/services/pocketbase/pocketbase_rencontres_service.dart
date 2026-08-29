// ===========================================================================
// Rencontres MetaWar (pocketbase_rencontres_service.dart)
// CRUD des rencontres (rondes contre adversaires) d'un tournoi pour une
// équipe, extrait du service tournois pour une responsabilité par fichier.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseRencontresService {
  static final PocketbaseRencontresService instance =
      PocketbaseRencontresService._internal();

  PocketbaseRencontresService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Crée une rencontre (ronde contre une équipe adverse).
  Future<Rencontre> createRencontre(
    String tournoiId,
    String teamId,
    String nomAdversaire,
  ) async {
    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameRencontres)
        .create(body: {
      'tournoi_id': tournoiId,
      'team_id': teamId,
      'nom_adversaire': nomAdversaire,
    });
    return Rencontre.fromPocketBaseRecord(record);
  }

  /// Récupère les rencontres d'une équipe pour un tournoi spécifique.
  Future<List<Rencontre>> getRencontres(String tournoiId, String teamId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameRencontres)
              .getFullList(
                filter:
                    'tournoi_id = "${_holder.echapperFiltrePocketBase(tournoiId)}" '
                    '&& team_id = "${_holder.echapperFiltrePocketBase(teamId)}"',
                sort: 'created',
              );
      return records.map(Rencontre.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des rencontres : $exception');
      return [];
    }
  }

  /// Récupère les équipes ayant au moins une rencontre dans le tournoi.
  Future<List<Team>> getTeamsParticipatingInTournoi(String tournoiId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameRencontres)
              .getFullList(
                filter:
                    'tournoi_id = "${_holder.echapperFiltrePocketBase(tournoiId)}"',
                expand: 'team_id',
                sort: 'created',
              );
      final Map<String, Team> equipesUniques = {};
      for (final RecordModel record in records) {
        final RecordModel expandedTeam =
            record.get<RecordModel>('expand.team_id');
        equipesUniques.putIfAbsent(
          expandedTeam.id,
          () => Team.fromPocketBaseRecord(expandedTeam),
        );
      }
      return equipesUniques.values.toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des équipes du tournoi : $exception');
      return [];
    }
  }

  /// Supprime une rencontre (adversaires/estims/matched purgés en cascade).
  Future<void> deleteRencontre(String rencontreId) async {
    await _holder.clientPocketBase
        .collection(collectionNameRencontres)
        .delete(rencontreId);
  }
}
