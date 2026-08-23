// ===========================================================================
// Actions des rencontres de l'écran d'équipes (teams_screen_encounter_actions.dart)
// Opérations de données : chargement des équipes et des rencontres,
// création d'une rencontre, import texte de tournoi, suppression.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
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
        showSnackBar(context, "Erreur de chargement: $exceptionLoading");
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
        showSnackBar(context, "Erreur rencontres : $exceptionLoading");
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
        showSnackBar(context, "Erreur d'ajout : $exceptionAdding");
      }
    }
  }

  // Lance l'import texte d'un tournoi pour la rencontre donnée, puis
  // recharge la liste des rencontres.
  Future<void> importTournamentText(
    BuildContext context,
    Rencontre selectedEncounter,
    VoidCallback onStateChanged,
  ) async {
    try {
      final bool importCompleted = await showTournamentTextImportDialog(
        context: context,
        encounterId: selectedEncounter.id,
        loadReferenceArmies: controller.loadReferenceArmies,
      );

      if (!context.mounted) return;
      await loadEncounters(context, onStateChanged);
      if (importCompleted && context.mounted) {
        showSnackBar(context, "Import terminé.",
            backgroundColor: Colors.green);
      }
    } catch (exceptionImport) {
      if (context.mounted) {
        showSnackBar(context, "Erreur d'import : $exceptionImport");
      }
    }
  }

  // Supprime la rencontre après confirmation.
  Future<void> deleteEncounter(
    BuildContext context,
    Rencontre selectedEncounter,
  ) async {
    final bool confirmationReceived =
        await showDeleteEncounterConfirmation(context);
    if (!confirmationReceived) return;

    try {
      await controller.deleteEncounter(selectedEncounter.id);
      if (context.mounted) {
        showSnackBar(context, "Rencontre supprimée.",
            backgroundColor: Colors.green);
      }
    } catch (exceptionDeleting) {
      if (context.mounted) {
        showSnackBar(context, "Erreur de suppression : $exceptionDeleting");
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
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
