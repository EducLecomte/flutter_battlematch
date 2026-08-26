// ===========================================================================
// Référentiels statiques MetaWar : armées T9A et choix d'estimation
// (collections publiques, lecture seule côté application).
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseReferentielsService {
  static final PocketbaseReferentielsService instance =
      PocketbaseReferentielsService._internal();

  PocketbaseReferentielsService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Charge les 16 armées du référentiel.
  Future<List<Armee>> getArmees() async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameArmees)
              .getFullList(sort: 'nom');
      return records.map(Armee.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des armées : $exception');
      return [];
    }
  }

  /// Charge les 6 choix d'estimation du référentiel.
  Future<List<Choix>> getChoix() async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameChoix)
              .getFullList(sort: 'id');
      return records.map(Choix.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des choix : $exception');
      return [];
    }
  }

  // -------------------------------------------------------------------
  // CRUD d'administration (règles PocketBase : `@request.auth.admin`)
  // -------------------------------------------------------------------

  /// Crée une armée dans le référentiel.
  Future<Armee> createArmee(String nom, String short) async {
    final RecordModel recordArmee = await _holder.clientPocketBase
        .collection(collectionNameArmees)
        .create(body: {'nom': nom, 'short': short});
    return Armee.fromPocketBaseRecord(recordArmee);
  }

  /// Modifie le nom ou l'initiale d'une armée.
  Future<Armee> updateArmee(String armeeId, String nom, String short) async {
    final RecordModel recordArmee = await _holder.clientPocketBase
        .collection(collectionNameArmees)
        .update(armeeId, body: {'nom': nom, 'short': short});
    return Armee.fromPocketBaseRecord(recordArmee);
  }

  /// Supprime une armée du référentiel.
  Future<void> deleteArmee(String armeeId) async {
    await _holder.clientPocketBase.collection(collectionNameArmees).delete(armeeId);
  }

  /// Crée un choix d'estimation dans le référentiel.
  Future<Choix> createChoix(
      String libelle, String short, String couleurHex) async {
    final RecordModel recordChoix = await _holder.clientPocketBase
        .collection(collectionNameChoix)
        .create(
            body: {'libelle': libelle, 'short': short, 'couleur_hex': couleurHex});
    return Choix.fromPocketBaseRecord(recordChoix);
  }

  /// Modifie le libellé, l'initiale ou la couleur d'un choix.
  Future<Choix> updateChoix(String choixId, String libelle, String short,
      String couleurHex) async {
    final RecordModel recordChoix = await _holder.clientPocketBase
        .collection(collectionNameChoix)
        .update(choixId,
            body: {
              'libelle': libelle,
              'short': short,
              'couleur_hex': couleurHex,
            });
    return Choix.fromPocketBaseRecord(recordChoix);
  }

  /// Supprime un choix du référentiel.
  Future<void> deleteChoix(String choixId) async {
    await _holder.clientPocketBase.collection(collectionNameChoix).delete(choixId);
  }
}
