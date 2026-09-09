// ===========================================================================
// Estimations d’un duo d’équipes MetaWar (collection estims) :
// enregistrement/upsert et flux temps réel.
// ===========================================================================

import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseDashboardEstimsService {
  static final PocketbaseDashboardEstimsService instance =
      PocketbaseDashboardEstimsService._internal();

  PocketbaseDashboardEstimsService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  String _filtreParEquipes(String teamId, String adversaireTeamId) =>
      'team_id = "${_holder.echapperFiltrePocketBase(teamId)}" '
      '&& adversaire_team_id = "${_holder.echapperFiltrePocketBase(adversaireTeamId)}"';

  /// Enregistre ou met à jour une estimation (upsert guidé par l’index unique
  /// équipe + équipe adverse + joueur + méta adverse).
  Future<void> saveEstim(Estim estim) async {
    final List<RecordModel> existants =
        await _holder.clientPocketBase.collection(collectionNameEstims).getFullList(
               filter:
                   'team_id = "${_holder.echapperFiltrePocketBase(estim.teamId)}" '
                   '&& adversaire_team_id = "${_holder.echapperFiltrePocketBase(estim.adversaireTeamId)}" '
                   '&& joueur_id = "${_holder.echapperFiltrePocketBase(estim.joueurId)}" '
                   '&& team_meta_id = "${_holder.echapperFiltrePocketBase(estim.teamMetaId)}"',
             );

    if (existants.isNotEmpty) {
      await _holder.clientPocketBase.collection(collectionNameEstims).update(
        existants.first.id,
        body: estim.toJson(),
      );
    } else {
      await _holder.clientPocketBase
          .collection(collectionNameEstims)
          .create(body: estim.toJson());
    }
  }

  /// Récupère les estimations d’un duo d’équipes.
  Future<List<Estim>> getEstims(
    String teamId,
    String adversaireTeamId,
  ) async {
    final records = await _holder.clientPocketBase
        .collection(collectionNameEstims)
        .getFullList(
          filter: _filtreParEquipes(teamId, adversaireTeamId),
          sort: 'created',
        );
    return records.map(Estim.fromPocketBaseRecord).toList();
  }

  /// Flux temps réel des estimations d’un duo d’équipes.
  Stream<List<Estim>> streamEstims(
    String teamId,
    String adversaireTeamId,
  ) {
    return _holder
        .streamCollectionRecords(
          nomCollection: collectionNameEstims,
          filtre: _filtreParEquipes(teamId, adversaireTeamId),
          tri: 'created',
        )
        .map((records) => records.map(Estim.fromPocketBaseRecord).toList());
  }
}
