// ===========================================================================
// Adversaires d'une rencontre MetaWar (collection meta_adv) :
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

  /// Récupère les adversaires d'une rencontre.
  Future<List<MetaAdv>> getOpponents(String rencontreId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameMetaAdv)
              .getFullList(
                filter:
                    'rencontre_id = "${_holder.echapperFiltrePocketBase(rencontreId)}"',
                sort: 'created',
              );
      return records.map(MetaAdv.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des adversaires : $exception');
      return [];
    }
  }

  /// Flux temps réel des adversaires d'une rencontre.
  Stream<List<MetaAdv>> streamOpponents(String rencontreId) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameMetaAdv,
          filtre:
              'rencontre_id = "${_holder.echapperFiltrePocketBase(rencontreId)}"',
          tri: 'created',
        )
        .map((records) => records.map(MetaAdv.fromPocketBaseRecord).toList());
  }

  /// Ajoute un adversaire manuellement.
  Future<MetaAdv> createOpponent(
    String rencontreId,
    String armeeId,
    String nomJoAdv,
    String listeAdv,
  ) async {
    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameMetaAdv)
        .create(body: {
      'rencontre_id': rencontreId,
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
