// ===========================================================================
// Tournois MetaWar : listing, création, modification et suppression des
// tournois. Les rencontres sont gérées par pocketbase_rencontres_service.dart.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseTournoisService {
  static final PocketbaseTournoisService instance =
      PocketbaseTournoisService._internal();

  PocketbaseTournoisService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Récupère la liste de tous les tournois (du plus récent au plus ancien).
  Future<List<Tournoi>> getTournois() async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameTournois)
              .getFullList(sort: '-created');
      return records.map(Tournoi.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des tournois : $exception');
      return [];
    }
  }

  /// Crée un tournoi au nom de l'administrateur connecté.
  Future<Tournoi> createTournoi(String nom, String lienNr) async {
    final String? createdById = _holder.currentUserId;
    if (createdById == null) throw Exception("Non authentifié");
    final String nomNettoye = nom.trim();
    final String lienNrNettoye = lienNr.trim();
    if (nomNettoye.isEmpty) {
      throw Exception("Le nom du tournoi est obligatoire.");
    }
    if (lienNrNettoye.isEmpty) {
      throw Exception("Le lien New Recruit du tournoi est obligatoire.");
    }

    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameTournois)
        .create(body: {
       'nom': nomNettoye,
       'lien_nr': lienNrNettoye,
       'created_by': createdById,
     });
    return Tournoi.fromPocketBaseRecord(record);
  }

  /// Récupère un tournoi par son identifiant PocketBase.
  Future<Tournoi> getTournoi(String tournoiId) async {
    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameTournois)
        .getOne(tournoiId);
    return Tournoi.fromPocketBaseRecord(record);
  }

  /// Modifie le nom et le lien New Recruit d'un tournoi.
  Future<Tournoi> updateTournoi(String tournoiId, String nom, String lienNr) async {
    final String nomNettoye = nom.trim();
    final String lienNrNettoye = lienNr.trim();
    if (nomNettoye.isEmpty) {
      throw Exception("Le nom du tournoi est obligatoire.");
    }
    if (lienNrNettoye.isEmpty) {
      throw Exception("Le lien New Recruit du tournoi est obligatoire.");
    }

    final RecordModel record = await _holder.clientPocketBase
        .collection(collectionNameTournois)
        .update(tournoiId, body: {
      'nom': nomNettoye,
      'lien_nr': lienNrNettoye,
    });
    return Tournoi.fromPocketBaseRecord(record);
  }

  /// Marque le tournoi comme ayant reçu son import d'équipes.
  Future<void> markTournoiImportEffectue(String tournoiId) async {
    await _holder.clientPocketBase.collection(collectionNameTournois).update(
      tournoiId,
      body: {'import_effectue': true},
    );
  }

  /// Supprime un tournoi (équipes/rencontres purgées en cascade).
  Future<void> deleteTournoi(String tournoiId) async {
    await _holder.clientPocketBase
        .collection(collectionNameTournois)
        .delete(tournoiId);
  }
}
