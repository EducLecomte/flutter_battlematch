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

  // Contrôleurs des champs de modification du profil
  final TextEditingController nomController = TextEditingController();
  final TextEditingController shortController = TextEditingController();

  // Profil de l'utilisateur connecté
  Joueur? joueur;

  // Liste des invitations d'équipe reçues
  List<Map<String, dynamic>> invitations = [];

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
        shortController.text = joueurCourant.short;

        invitations =
            await _pocketbaseService.getPendingInvitations(joueurCourant.id);
      }
      return null;
    } catch (loadError) {
      return "Erreur de chargement: ${loadError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Sauvegarde les modifications de profil puis recharge les données.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> saveProfile({required VoidCallback onStateChanged}) async {
    if (nomController.text.trim().isEmpty ||
        shortController.text.trim().isEmpty) {
      return "Les champs ne peuvent pas être vides";
    }

    isSaving = true;
    onStateChanged();

    try {
      await _pocketbaseService.updateJoueurProfileFields(
        nom: nomController.text.trim(),
        short: shortController.text.trim().toUpperCase(),
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

  // Libère les contrôleurs de texte.
  void dispose() {
    nomController.dispose();
    shortController.dispose();
  }
}
