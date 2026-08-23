// ===========================================================================
// Appariements capitaine ↔ adversaire MetaWar (collection matched) :
// bascule d'appariement, listing et flux temps réel par rencontre.
// Les index uniques PocketBase garantissent un appariement unique par
// joueur et par adversaire au sein d'une rencontre.
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

  /// Active/désactive l'appariement capitaine ↔ adversaire d'une case.
  Future<void> toggleMatched(
    String rencontreId,
    String joueurId,
    String metaAdvId,
  ) async {
    final List<RecordModel> existants =
        await _holder.clientPocketBase.collection(collectionNameMatched).getFullList(
              filter:
                  'rencontre_id = "${_holder.echapperFiltrePocketBase(rencontreId)}" '
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
      // joueur ou adversaire déjà engagés ailleurs, erreur propagée à l'écran)
      await _holder.clientPocketBase.collection(collectionNameMatched).create(
        body: {
          'rencontre_id': rencontreId,
          'joueur_id': joueurId,
          'meta_adv_id': metaAdvId,
        },
      );
    }
  }

  /// Récupère les appariements validés d'une rencontre.
  Future<List<Matched>> getMatched(String rencontreId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameMatched)
              .getFullList(
                filter:
                    'rencontre_id = "${_holder.echapperFiltrePocketBase(rencontreId)}"',
              );
      return records.map(Matched.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des appariements : $exception');
      return [];
    }
  }

  /// Flux temps réel des appariements validés d'une rencontre.
  Stream<List<Matched>> streamMatched(String rencontreId) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameMatched,
          filtre:
              'rencontre_id = "${_holder.echapperFiltrePocketBase(rencontreId)}"',
          tri: 'created',
        )
        .map((records) => records.map(Matched.fromPocketBaseRecord).toList());
  }
}
