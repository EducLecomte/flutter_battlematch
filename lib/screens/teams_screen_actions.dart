// ===========================================================================
// Actions de l’écran d’équipes (teams_screen_actions.dart) :
// chargement des équipes de l’utilisateur connecté.
// ===========================================================================

import 'package:flutter/material.dart';

import '../services/pocketbase_data_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen_controller.dart';

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
}
