// ===========================================================================
// Contrôleur de l'écran de Profil & Invitations (profile_controller.dart)
// Détient l'état du profil, les invitations reçues et pilote les opérations
// de chargement, de sauvegarde et de réponse aux invitations.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class ProfileController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Contrôleur du champ pseudo (le champ d'initiales a été retiré,
  // `short` est régénéré automatiquement à partir du nom).
  final TextEditingController nomController = TextEditingController();

  // Profil de l'utilisateur connecté
  Joueur? joueur;

  // Liste des invitations d'équipe reçues
  List<Map<String, dynamic>> invitations = [];

  // Équipes acceptées de l'utilisateur
  List<Team> userTeams = [];

  // Tournois distincts associés aux équipes de l'utilisateur
  Map<String, Tournoi> userTournois = {};

  // États de chargement / sauvegarde
  bool isLoading = false;
  bool isSaving = false;

  // Charge les données de profil et les invitations depuis PocketBase.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> loadProfileAndInvitations({
    required VoidCallback onStateChanged,
  }) async {
    isLoading = true;
    onStateChanged();

    try {
      final Joueur? joueurCourant =
          await _pocketbaseService.getCurrentJoueurProfile();
      if (joueurCourant != null) {
        joueur = joueurCourant;
        nomController.text = joueurCourant.nom;

        invitations =
            await _pocketbaseService.getPendingInvitations(joueurCourant.id);
        userTeams =
            await _pocketbaseService.getTeamsForUser(joueurCourant.id);
        await _loadUserTournois();
      }
      return null;
    } catch (loadError) {
      return "Erreur de chargement: ${loadError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Charge les tournois distincts associés aux équipes de l'utilisateur.
  Future<void> _loadUserTournois() async {
    userTournois = {};
    final Set<String> tournoiIds = userTeams
        .map((team) => team.tournoiId)
        .where((tournoiId) => tournoiId.isNotEmpty)
        .toSet();

    for (final String tournoiId in tournoiIds) {
      try {
        final Tournoi tournoi =
            await _pocketbaseService.getTournoi(tournoiId);
        userTournois[tournoiId] = tournoi;
      } catch (_) {
        // Tournoi introuvable : on ignore silencieusement.
      }
    }
  }

  // Sauvegarde les modifications de profil puis recharge les données.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> saveProfile({required VoidCallback onStateChanged}) async {
    if (nomController.text.trim().isEmpty) {
      return "Le pseudo ne peut pas être vide";
    }

    isSaving = true;
    onStateChanged();

    try {
      await _pocketbaseService.updateJoueurProfileFields(
        nom: nomController.text.trim(),
      );
      await loadProfileAndInvitations(onStateChanged: onStateChanged);
      return null;
    } catch (saveError) {
      return "Erreur de sauvegarde : ${saveError.toString()}";
    } finally {
      isSaving = false;
      onStateChanged();
    }
  }

  // Répond à une invitation (accepter ou refuser) puis recharge les données.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> respondToInvite(
    String teamId,
    bool accept, {
    required VoidCallback onStateChanged,
  }) async {
    final String? currentUserId = _pocketbaseService.currentUserId;
    if (currentUserId == null) return null;

    try {
      if (accept) {
        await _pocketbaseService.acceptTeamInvite(teamId, currentUserId);
      } else {
        await _pocketbaseService
            .declineOrRemoveTeamInvite(teamId, currentUserId);
      }
      await loadProfileAndInvitations(onStateChanged: onStateChanged);
      return null;
    } catch (inviteError) {
      return "Erreur : ${inviteError.toString()}";
    }
  }

  // Déconnecte l'utilisateur.
  Future<void> signOut() async {
    await _pocketbaseService.signOut();
  }

  // Supprime définitivement le compte courant, purge les contenus
  // possédés puis déconnecte l'utilisateur.
  Future<String?> deleteAccount() async {
    try {
      await _pocketbaseService.deleteCurrentAccount();
      await _pocketbaseService.signOut();
      return null;
    } catch (deleteError) {
      return "Erreur de suppression : ${deleteError.toString()}";
    }
  }

  // Libère les contrôleurs de texte.
  void dispose() {
    nomController.dispose();
  }
}
