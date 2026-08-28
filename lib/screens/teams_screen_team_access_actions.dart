// ===========================================================================
// Actions d'accès aux équipes (teams_screen_team_access_actions.dart)
// Gère l'interface de réclamation d'équipe et de join par mot de passe.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen_controller.dart';

class TeamsScreenTeamAccessActions {
  final TeamsScreenController controller;

  TeamsScreenTeamAccessActions(this.controller);

  Future<void> claimTeam(
    BuildContext context,
    Team team,
    VoidCallback onStateChanged,
  ) async {
    try {
      await controller.claimTeam(team.id);
      await _reloadTeamsAfterAccess(onStateChanged);
      if (context.mounted) {
        _showSnackBar(context, "Vous êtes maintenant capitaine de « ${team.nom} ».");
      }
    } catch (claimError) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur de réclamation : $claimError");
      }
    }
  }

  Future<void> joinTeam(
    BuildContext context,
    Team team,
    String motDePasse,
    VoidCallback onStateChanged,
  ) async {
    try {
      await controller.joinTeamWithPassword(team.id, motDePasse);
      await _reloadTeamsAfterAccess(onStateChanged);
      if (context.mounted) {
        _showSnackBar(context, "Vous avez rejoint « ${team.nom} ».");
      }
    } catch (joinError) {
      if (context.mounted) {
        showErrorSnackBar(context, "Erreur de join : $joinError");
      }
    }
  }

  Future<void> _reloadTeamsAfterAccess(VoidCallback onStateChanged) async {
    final String? currentUserId = PocketbaseDataService.instance.currentUserId;
    await controller.loadTeamsForUser(currentUserId);
    onStateChanged();
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
