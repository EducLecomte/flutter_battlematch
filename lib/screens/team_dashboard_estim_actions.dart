// ===========================================================================
// Interactions d'estimation du tableau de bord (team_dashboard_estim_actions.dart)
// Orchestration des modales d'estimation : ouverture des dialogues et
// feuilles de détails, gestion des appuis sur les cellules de la matrice.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import 'team_dashboard_controller.dart';
import 'widgets/estim_dialog.dart';
import 'widgets/estim_details_sheet.dart';

class TeamDashboardEstimActions {
  final TeamDashboardController dashboardController;
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  TeamDashboardEstimActions(this.dashboardController);

  // Ouvre le dialog d'édition (ou de création) d'une estimation.
  void openEstimDialog(
    BuildContext context,
    Joueur player,
    MetaAdv opponent,
    Estim? currentEstim,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return EstimDialog(
          joueur: player,
          opponent: opponent,
          listChoix: dashboardController.choiceList,
          currentEstim: currentEstim,
           onSave: (newEstim) async {
             await _pocketbaseService.saveEstim(newEstim);
             return null;
           },
        );
      },
    );
  }

  // Ouvre la feuille de détails d'une estimation existante.
  void openEstimDetailsSheet(
    BuildContext context,
    Joueur player,
    MetaAdv opponent,
    Estim estim,
  ) {
    final choice = AppreciationScale.choiceById(
      dashboardController.choiceList,
      estim.choixId,
    );
    showEstimDetailsSheet(
      context,
      joueur: player,
      opponent: opponent,
      estim: estim,
      choix: choice,
      canEdit: dashboardController.canEditEstimateOf(player),
      onEdit: () => openEstimDialog(context, player, opponent, estim),
    );
  }

  // Gère le clic sur une cellule de la matrice : le capitaine
  // verrouille/déverrouille l'appariement, un joueur normal édite son
  // estimation sur sa propre ligne.
  Future<void> handleCellTap(
    BuildContext context,
    Joueur player,
    MetaAdv opponent,
    Estim? currentEstim,
  ) async {
    if (dashboardController.currentUserProfile == null) return;

    if (dashboardController.isCaptain()) {
      final pairingSucceeded =
          await dashboardController.toggleMatched(player, opponent);
      if (!pairingSucceeded && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Action impossible : joueur ou adversaire déjà apparié dans un autre duel !",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else if (dashboardController.canEditEstimateOf(player)) {
      openEstimDialog(context, player, opponent, currentEstim);
    }
  }

  // Gère l'appui long sur une cellule : détails de l'estimation existante,
  // ou création directe si le joueur peut l'éditer.
  void handleCellLongPress(
    BuildContext context,
    Joueur player,
    MetaAdv opponent,
    Estim? existingEstim,
  ) {
    if (existingEstim != null) {
      openEstimDetailsSheet(context, player, opponent, existingEstim);
    } else if (dashboardController.canEditEstimateOf(player)) {
      openEstimDialog(context, player, opponent, null);
    }
  }
}
