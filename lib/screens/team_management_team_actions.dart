// ===========================================================================
// Actions de gestion d'équipe (team_management_team_actions.dart)
// Opérations d'écriture : retrait, suppression, mot de passe, capitainerie.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'team_management_controller.dart';

class TeamManagementTeamActions {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Retire un membre (ou quitte l'équipe) après confirmation.
  Future<void> removeMember(
    BuildContext context,
    TeamManagementController controller,
    Joueur player,
    VoidCallback onStateChanged,
  ) async {
    final Team? selectedTeam = controller.selectedTeam;
    if (selectedTeam == null) return;

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool isMyself = controller.currentUserProfile?.id == player.id;
    final String title = isMyself
        ? "Quitter l'équipe ?"
        : "Retirer ${player.nom} de l'équipe ?";
    final String details = isMyself
        ? "Vous ne ferez plus partie de cette équipe."
        : "Ce joueur ne fera plus partie de l'équipe.";

    final bool confirmed = await _showConfirmationDialog(
      context,
      title,
      details,
      "Retirer",
    );
    if (!confirmed) return;

    try {
      await _pocketbaseService.declineOrRemoveTeamInvite(
        selectedTeam.id,
        player.id,
      );
      await controller.loadMembersForSelectedTeam();
      onStateChanged();
      _showSuccessSnackBar(messenger, "Membre retiré.");
    } catch (removeError) {
      showErrorSnackBarUsingMessenger(messenger, "Erreur de retrait : $removeError");
    }
  }

  // Supprime l'équipe après confirmation.
  Future<void> deleteTeam(
    BuildContext context,
    TeamManagementController controller,
    Team team,
    VoidCallback onStateChanged,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirmed = await _showConfirmationDialog(
      context,
      "Supprimer l'équipe ?",
      "Cette action est irréversible et supprimera tous les appariements.",
      "Supprimer",
    );
    if (!confirmed) return;

    try {
      await _pocketbaseService.deleteTeam(team.id);
      await controller.loadInitialData();
      onStateChanged();
      _showSuccessSnackBar(messenger, "Équipe supprimée.");
    } catch (deleteError) {
      showErrorSnackBarUsingMessenger(
          messenger, "Erreur de suppression : $deleteError");
    }
  }

  // Met à jour le mot de passe d'accès de l'équipe sélectionnée.
  Future<void> updateTeamMotDePasse(
    BuildContext context,
    TeamManagementController controller,
    String motDePasse,
    VoidCallback onStateChanged,
  ) async {
    final Team? selectedTeam = controller.selectedTeam;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (selectedTeam == null || !controller.isCaptain()) {
      showErrorSnackBarUsingMessenger(
        messenger,
        "Seul le capitaine peut modifier le mot de passe.",
      );
      return;
    }

    try {
      final Team updatedTeam = await _pocketbaseService
          .updateTeamMotDePasse(selectedTeam.id, motDePasse);
      controller.replaceTeam(updatedTeam);
      onStateChanged();
      _showSuccessSnackBar(messenger, "Mot de passe mis à jour.");
    } catch (passwordError) {
      showErrorSnackBarUsingMessenger(
          messenger, "Erreur du mot de passe : $passwordError");
    }
  }

  // Transfère la capitainerie à un membre accepté.
  Future<void> nominateNewCaptain(
    BuildContext context,
    TeamManagementController controller,
    Joueur candidate,
    VoidCallback onStateChanged,
  ) async {
    final Team? selectedTeam = controller.selectedTeam;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (selectedTeam == null || !controller.canNominateCaptain(candidate)) {
      showErrorSnackBarUsingMessenger(
        messenger,
        "Ce joueur ne peut pas devenir capitaine.",
      );
      return;
    }

    final bool confirmed = await _showConfirmationDialog(
      context,
      "Transférer la capitainerie ?",
      "${candidate.nom} deviendra le nouveau capitaine de l'équipe.",
      "Transférer",
    );
    if (!confirmed) return;

    try {
      final Team updatedTeam = await _pocketbaseService
          .nommerNouveauCapitaine(selectedTeam.id, candidate.id);
      controller.replaceTeam(updatedTeam);
      await controller.loadMembersForSelectedTeam();
      onStateChanged();
      _showSuccessSnackBar(messenger, "Capitainerie transférée.");
    } catch (nominationError) {
      showErrorSnackBarUsingMessenger(
          messenger, "Erreur de nomination : $nominationError");
    }
  }

  Future<bool> _showConfirmationDialog(
    BuildContext context,
    String title,
    String details,
    String confirmLabel,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(details),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showSuccessSnackBar(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: snackBarDisplayDuration,
      ),
    );
  }
}
