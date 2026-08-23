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
}
