// ===========================================================================
// Appariements capitaine ↔ adversaire MetaWar (collection matched) :
// bascule d’appariement, listing et flux temps réel par duo d’équipes.
// Les index uniques PocketBase garantissent un appariement unique par
// joueur et par adversaire au sein du même duo d’équipes.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseDashboardMatchedService {
  static final PocketbaseDashboardMatchedService instance =
      PocketbaseDashboardMatchedService._internal();

  PocketbaseDashboardMatchedService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  String _filtreParEquipes(String teamId, String adversaireTeamId) =>
      'team_id = "${_holder.echapperFiltrePocketBase(teamId)}" '
      '&& adversaire_team_id = "${_holder.echapperFiltrePocketBase(adversaireTeamId)}"';

  /// Active/désactive l’appariement capitaine ↔ adversaire d’une case.
  Future<void> toggleMatched(
    String teamId,
    String adversaireTeamId,
    String joueurId,
    String metaAdvId,
  ) async {
    final List<RecordModel> existants =
        await _holder.clientPocketBase.collection(collectionNameMatched).getFullList(
              filter:
                  '${_filtreParEquipes(teamId, adversaireTeamId)} '
                  '&& joueur_id = "${_holder.echapperFiltrePocketBase(joueurId)}" '
                  '&& meta_adv_id = "${_holder.echapperFiltrePocketBase(metaAdvId)}"',
            );

    if (existants.isNotEmpty) {
      // Déjà apparié sur cette case précise -> suppression (déverrouillage)
      await _holder.clientPocketBase
          .collection(collectionNameMatched)
          .delete(existants.first.id);
    } else {
      // Non apparié -> création (les index uniques bloquent les doublons
      // joueur ou adversaire déjà engagés ailleurs, erreur propagée à l’écran)
      await _holder.clientPocketBase.collection(collectionNameMatched).create(
        body: {
          'team_id': teamId,
          'adversaire_team_id': adversaireTeamId,
          'joueur_id': joueurId,
          'meta_adv_id': metaAdvId,
        },
      );
    }
  }

  /// Récupère les appariements validés d’un duo d’équipes.
  Future<List<Matched>> getMatched(
    String teamId,
    String adversaireTeamId,
  ) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameMatched)
              .getFullList(
                filter: _filtreParEquipes(teamId, adversaireTeamId),
              );
      return records.map(Matched.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des appariements : $exception');
      return [];
    }
  }

  /// Flux temps réel des appariements validés d’un duo d’équipes.
  Stream<List<Matched>> streamMatched(
    String teamId,
    String adversaireTeamId,
  ) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameMatched,
          filtre: _filtreParEquipes(teamId, adversaireTeamId),
          tri: 'created',
        )
        .map((records) => records.map(Matched.fromPocketBaseRecord).toList());
  }
}
