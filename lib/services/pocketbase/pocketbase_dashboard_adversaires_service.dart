// ===========================================================================
// Adversaires d’une équipe MetaWar (collection meta_adv) :
// listing, flux temps réel, création manuelle et suppression.
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

  String _filtreParEquipes(String teamId, String adversaireTeamId) =>
      'team_id = "${_holder.echapperFiltrePocketBase(teamId)}" '
      '&& adversaire_team_id = "${_holder.echapperFiltrePocketBase(adversaireTeamId)}"';

  /// Récupère les adversaires d’un duo d’équipes.
  Future<List<MetaAdv>> getOpponents(
    String teamId,
    String adversaireTeamId,
  ) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameMetaAdv)
              .getFullList(
                filter: _filtreParEquipes(teamId, adversaireTeamId),
                sort: 'created',
              );
      return records.map(MetaAdv.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des adversaires : $exception');
      return [];
    }
  }

  /// Flux temps réel des adversaires d’un duo d’équipes.
  Stream<List<MetaAdv>> streamOpponents(
    String teamId,
    String adversaireTeamId,
  ) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameMetaAdv,
          filtre: _filtreParEquipes(teamId, adversaireTeamId),
          tri: 'created',
        )
        .map((records) => records.map(MetaAdv.fromPocketBaseRecord).toList());
  }

  /// Ajoute un adversaire manuellement.
  Future<MetaAdv> createOpponent(
    String teamId,
    String adversaireTeamId,
    String armeeId,
    String nomJoAdv,
    String listeAdv,
  ) async {
    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameMetaAdv)
        .create(body: {
      'team_id': teamId,
      'adversaire_team_id': adversaireTeamId,
      'armee_id': armeeId,
      'nom_jo_adv': nomJoAdv,
      'liste_adv': listeAdv,
    });
    return MetaAdv.fromPocketBaseRecord(record);
  }

  /// Supprime un adversaire (estimations et appariements purgés en cascade).
  Future<void> deleteOpponent(String opponentId) async {
    await _holder.clientPocketBase
        .collection(collectionNameMetaAdv)
        .delete(opponentId);
  }
}
