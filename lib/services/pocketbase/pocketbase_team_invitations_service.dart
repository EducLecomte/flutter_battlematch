// ===========================================================================
// Invitations d'équipe MetaWar (collection team_membres) : invitations en
// attente, invitation d'un joueur, acceptation et refus / retrait.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';
import 'pocketbase_team_membres_service.dart';

class PocketbaseTeamInvitationsService {
  static final PocketbaseTeamInvitationsService instance =
      PocketbaseTeamInvitationsService._internal();

  PocketbaseTeamInvitationsService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Rôle d'un joueur invité par le capitaine.
  static const String roleJoueur = PocketbaseTeamMembresService.roleJoueur;

  /// Statut d'une invitation en attente de réponse.
  static const String statutEnAttente = 'pending';

  /// Récupère les invitations en attente pour un joueur.
  /// Retourne une liste de maps : {'role', 'statut', 'team'}.
  Future<List<Map<String, dynamic>>> getPendingInvitations(String userId) async {
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase
              .collection(collectionNameTeamMembres)
              .getFullList(
                filter:
                    'joueur_id = "${_holder.echapperFiltrePocketBase(userId)}" '
                    '&& statut = "$statutEnAttente"',
                expand: 'team_id',
              );

      return records.map((RecordModel record) {
        return <String, dynamic>{
          'role': record.get<String>('role'),
          'statut': record.get<String>('statut'),
          'team': Team.fromPocketBaseRecord(
              record.get<RecordModel>('expand.team_id')),
        };
      }).toList();
    } catch (exception) {
      debugPrint('Erreur de chargement des invitations : $exception');
      return [];
    }
  }

  /// Invite un joueur dans l'équipe (rôle 'player', statut 'pending').
  Future<void> inviteJoueurToTeam(String teamId, String joueurId) async {
    await _holder.clientPocketBase.collection(collectionNameTeamMembres).create(
      body: {
        'team_id': teamId,
        'joueur_id': joueurId,
        'role': roleJoueur,
        'statut': statutEnAttente,
      },
    );
  }

  /// Accepte une invitation d'équipe (le joueur invité bascule son statut).
  Future<void> acceptTeamInvite(String teamId, String joueurId) async {
    final RecordModel recordMembre =
        await _trouverEnregistrementTeamMembre(teamId, joueurId);

    await _holder.clientPocketBase.collection(collectionNameTeamMembres).update(
      recordMembre.id,
      body: {'statut': PocketbaseTeamMembresService.statutAccepte},
    );
  }

  /// Refuse ou retire une invitation / appartenance d'équipe.
  Future<void> declineOrRemoveTeamInvite(String teamId, String joueurId) async {
    final RecordModel recordMembre =
        await _trouverEnregistrementTeamMembre(teamId, joueurId);

    await _holder.clientPocketBase
        .collection(collectionNameTeamMembres)
        .delete(recordMembre.id);
  }

  /// Localise l'enregistrement team_membres unique d'un couple équipe/joueur.
  Future<RecordModel> _trouverEnregistrementTeamMembre(
    String teamId,
    String joueurId,
  ) async {
    final List<RecordModel> resultats =
        await _holder.clientPocketBase.collection(collectionNameTeamMembres).getFullList(
              filter:
                  'team_id = "${_holder.echapperFiltrePocketBase(teamId)}" '
                  '&& joueur_id = "${_holder.echapperFiltrePocketBase(joueurId)}"',
            );

    if (resultats.isEmpty) {
      throw Exception(
        "Aucune appartenance trouvée pour ce joueur dans cette équipe.",
      );
    }
    return resultats.first;
  }
}
