// ===========================================================================
// Membres d'équipe MetaWar (collection team_membres) : inscription d'un
// membre accepté et listing des membres avec leurs profils.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseTeamMembresService {
  static final PocketbaseTeamMembresService instance =
      PocketbaseTeamMembresService._internal();

  PocketbaseTeamMembresService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Rôle du créateur d'équipe dans team_membres.
  static const String roleCapitaine = 'captain';

  /// Statut d'un membre ayant rejoint l'équipe.
  static const String statutAccepte = 'accepted';

  /// Insère un membre d'équipe avec un rôle et un statut donnés.
  Future<void> inscrireMembreAccepte(
    String teamId,
    String joueurId,
    String role,
  ) async {
    await _holder.clientPocketBase.collection(collectionNameTeamMembres).create(
      body: {
        'team_id': teamId,
        'joueur_id': joueurId,
        'role': role,
        'statut': statutAccepte,
      },
    );
  }

  /// Récupère la liste des membres d'une équipe avec leurs profils.
  /// Retourne une liste de maps : {'role', 'statut', 'joueur'}.
  Future<List<Map<String, dynamic>>> getTeamMembres(String teamId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameTeamMembres)
              .getFullList(
                filter:
                    'team_id = "${_holder.echapperFiltrePocketBase(teamId)}"',
                expand: 'joueur_id',
              );

      return records.map((RecordModel record) {
        return <String, dynamic>{
          'role': record.get<String>('role'),
          'statut': record.get<String>('statut'),
          'joueur': Joueur.fromPocketBaseRecord(
              record.get<RecordModel>('expand.joueur_id')),
        };
      }).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des membres : $exception');
      return [];
    }
  }
}
