// ===========================================================================
// Actions de l’écran d’équipes (teams_screen_actions.dart) :
// chargement des équipes et import texte d’un tournoi.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../services/tournament_text_import_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen_controller.dart';
import 'widgets/tournament_text_import_launcher.dart';

class TeamsScreenActions {
  final TeamsScreenController controller;

  TeamsScreenActions(this.controller);

  // Charge les équipes de l’utilisateur connecté.
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
        showErrorSnackBar(context, "Erreur de chargement : $exceptionLoading");
      }
    }
    if (context.mounted) onStateChanged();
  }

  // Lance l’import texte d’un tournoi pour l’équipe active, puis recharge
  // les équipes du tournoi.
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
      await loadTeams(context, onStateChanged);
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
        showErrorSnackBar(context, "Erreur d’import : $exceptionImport");
      }
    }
  }

  String _formatImportSummary(TournamentTextImportSummary importSummary) {
    final String doublonsMessage =
        importSummary.skippedDuplicateTeamCount > 0
            ? " ${importSummary.skippedDuplicateTeamCount} équipe(s) déjà renseignée(s)."
            : "";
    return "Import terminé : ${importSummary.createdOpponentTeamCount} "
        "équipe(s) adverse(s), ${importSummary.createdOpponentCount} joueur(s), "
        "${importSummary.unknownArmyCount} armée(s) inconnue(s).$doublonsMessage";
  }

  // Affiche un SnackBar sur l’écran courant.
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
