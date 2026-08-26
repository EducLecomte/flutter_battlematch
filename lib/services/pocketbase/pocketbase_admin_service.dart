// ===========================================================================
// Administration MetaWar : opérations réservées aux comptes joueurs marqués
// `admin` (listing des joueurs, bascule du rôle admin, suppression de compte).
// Les CRUD des référentiels (armées, choix) restent dans
// pocketbase_referentiels_service.dart.
// ===========================================================================

import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseAdminService {
  static final PocketbaseAdminService instance =
      PocketbaseAdminService._internal();

  PocketbaseAdminService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Charge l'ensemble des profils joueurs (accessibles par tout compte
  /// authentifié, filtrage par admin côté interface uniquement).
  Future<List<Joueur>> listJoueurs() async {
    final List<RecordModel> records =
        await _holder.clientPocketBase
            .collection(collectionNameJoueurs)
            .getFullList(sort: 'nom');
    return records.map(Joueur.fromPocketBaseRecord).toList();
  }

  /// Active ou retire le rôle `admin` d'un joueur.
  Future<Joueur> setJoueurAdmin(String joueurId, bool admin) async {
    final RecordModel recordJoueur = await _holder.clientPocketBase
        .collection(collectionNameJoueurs)
        .update(joueurId, body: {'admin': admin});
    return Joueur.fromPocketBaseRecord(recordJoueur);
  }

  /// Supprime définitivement un compte joueur.
  Future<void> deleteJoueur(String joueurId) async {
    await _holder.clientPocketBase
        .collection(collectionNameJoueurs)
        .delete(joueurId);
  }
}
