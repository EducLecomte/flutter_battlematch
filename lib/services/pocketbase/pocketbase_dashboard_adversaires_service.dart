// ===========================================================================
// Méta des équipes MetaWar (collection team_meta) : listing, flux temps réel,
// création, mise à jour et suppression d'un joueur d'équipe.
// Une seule ligne par joueur dans le tournoi, indépendante des rencontres.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseDashboardAdversairesService {
  static final PocketbaseDashboardAdversairesService instance =
      PocketbaseDashboardAdversairesService._internal();

  PocketbaseDashboardAdversairesService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  String _filtreParEquipe(String teamId) =>
      'team_id = "${_holder.echapperFiltrePocketBase(teamId)}"';

  /// Récupère la méta (joueurs + armées + listes) d'une équipe.
  Future<List<TeamMeta>> getTeamMeta(String teamId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameTeamMeta)
              .getFullList(
                filter: _filtreParEquipe(teamId),
                sort: 'created',
              );
      return records.map(TeamMeta.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement de la méta d\'équipe : $exception');
      return [];
    }
  }

  /// Nombre de joueurs importés dans la méta d'une équipe : c'est la taille
  /// d'équipe du tournoi (une ligne team_meta = un joueur importé).
  Future<int> compterTeamMeta(String teamId) async {
    final List<RecordModel> records =
        await _holder.clientPocketBase
            .collection(collectionNameTeamMeta)
            .getFullList(filter: _filtreParEquipe(teamId));
    return records.length;
  }

  /// Flux temps réel de la méta (joueurs + armées + listes) d'une équipe.
  Stream<List<TeamMeta>> streamTeamMeta(String teamId) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameTeamMeta,
          filtre: _filtreParEquipe(teamId),
          tri: 'created',
        )
        .map((records) => records.map(TeamMeta.fromPocketBaseRecord).toList());
  }

  /// Ajoute un joueur à la méta d'une équipe.
  Future<TeamMeta> createTeamMeta(
    String teamId,
    String armeeId,
    String nomJo,
    String listeJo,
  ) async {
    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameTeamMeta)
        .create(body: {
      'team_id': teamId,
      'armee_id': armeeId,
      'nom_jo': nomJo,
      'liste_jo': listeJo,
    });
    return TeamMeta.fromPocketBaseRecord(record);
  }

  /// Met à jour un joueur de la méta d'une équipe.
  Future<TeamMeta> updateTeamMeta(
    String id, {
    String? armeeId,
    String? nomJo,
    String? listeJo,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{};
    if (armeeId != null) body['armee_id'] = armeeId;
    if (nomJo != null) body['nom_jo'] = nomJo;
    if (listeJo != null) body['liste_jo'] = listeJo;

    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameTeamMeta)
        .update(id, body: body);
    return TeamMeta.fromPocketBaseRecord(record);
  }

  /// Supprime un joueur de la méta d'une équipe
  /// (estimations et appariements purgés en cascade).
  Future<void> deleteTeamMeta(String id) async {
    await _holder.clientPocketBase
        .collection(collectionNameTeamMeta)
        .delete(id);
  }
}
