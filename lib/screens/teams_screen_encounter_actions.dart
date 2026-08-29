// ===========================================================================
// Actions des rencontres de l'écran d'équipes (teams_screen_encounter_actions.dart)
// Opérations de données : chargement des équipes et des rencontres,
// création d'une rencontre, import texte de tournoi, suppression.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../services/tournament_text_import_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen_controller.dart';
import 'widgets/rencontre_delete_confirmation.dart';
import 'widgets/tournament_text_import_launcher.dart';

class TeamsScreenEncounterActions {
  final TeamsScreenController controller;

  TeamsScreenEncounterActions(this.controller);

  // Charge les équipes de l'utilisateur connecté.
  Future<void> loadTeams(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
    try {
      await controller.loadTeamsForUser(
        PocketbaseDataService.instance.currentUserId,
      );
    } catch (exceptionLoading) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur de chargement: $exceptionLoading");
      }
    }
    if (context.mounted) onStateChanged();
  }

  // Recharge les rencontres de l'équipe active.
  Future<void> loadEncounters(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
    try {
      await controller.loadEncountersForActiveTeam();
      if (context.mounted) onStateChanged();
    } catch (exceptionLoading) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur rencontres : $exceptionLoading");
      }
    }
  }

  // Crée une rencontre (match / ronde) pour l'équipe active.
  Future<void> createEncounter(
    BuildContext context,
    String opponentName,
    VoidCallback onStateChanged,
  ) async {
    try {
      await controller.createEncounter(opponentName);
      if (context.mounted) {
        onStateChanged();
        showSnackBar(context, "Rencontre ajoutée !",
            backgroundColor: Colors.green);
      }
    } catch (exceptionAdding) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur d'ajout : $exceptionAdding");
      }
    }
  }

  // Lance l'import texte d'un tournoi pour l'équipe active, puis recharge
  // la liste des rencontres.
  Future<void> importTournamentText(
    BuildContext context,
    VoidCallback onStateChanged,
  ) async {
    final Team? activeTeam = controller.activeTeam;
    if (activeTeam == null) {
      showErrorSnackBar(context, "Aucune équipe active pour importer le tournoi.");
      return;
    }

    try {
      final TournamentTextImportSummary? importSummary =
          await showTournamentTextImportDialog(
        context: context,
        tournoiId: controller.tournoiId,
        targetTeamId: activeTeam.id,
        targetTeamName: activeTeam.nom,
        loadReferenceArmies: controller.loadReferenceArmies,
      );

      if (!context.mounted || importSummary == null) return;
      await loadEncounters(context, onStateChanged);
      if (context.mounted) {
        showSnackBar(
          context,
          _formatImportSummary(importSummary),
          backgroundColor: importSummary.unknownArmyCount > 0
              ? Colors.amber
              : Colors.green,
        );
      }
    } catch (exceptionImport) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur d'import : $exceptionImport");
      }
    }
  }
  String _formatImportSummary(TournamentTextImportSummary importSummary) {
    final String doublonsMessage =
        importSummary.skippedDuplicateEncounterCount > 0
            ? " ${importSummary.skippedDuplicateEncounterCount} doublon(s) ignoré(s)."
            : "";
    return "Import terminé : ${importSummary.createdEncounterCount} "
        "rencontre(s), ${importSummary.createdOpponentCount} joueur(s), "
        "${importSummary.unknownArmyCount} armée(s) inconnue(s)."
        "$doublonsMessage";
  }
  // Supprime la rencontre après confirmation puis rafraîchit la liste.
  Future<void> deleteEncounter(
    BuildContext context,
    Rencontre selectedEncounter,
    VoidCallback onStateChanged,
  ) async {
    final bool confirmationReceived =
        await showDeleteEncounterConfirmation(context);
    if (!confirmationReceived) return;

    try {
      await controller.deleteEncounter(selectedEncounter.id);
      if (context.mounted) {
        onStateChanged();
        showSnackBar(context, "Rencontre supprimée.",
            backgroundColor: Colors.green);
      }
    } catch (exceptionDeleting) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur de suppression : $exceptionDeleting");
      }
    }
  }

  // Affiche un SnackBar sur l'écran courant.
  void showSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.redAccent,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: snackBarDisplayDuration,
      ),
    );
  }
}
