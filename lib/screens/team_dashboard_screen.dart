// ===========================================================================
// Tableau de bord d'équipe (team_dashboard_screen.dart)
// Écran principal affichant la matrice d'estimations et d'appariement.
// La logique métier vit dans TeamDashboardController ; le rendu dans
// lib/screens/widgets/team_dashboard_*.dart.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'team_dashboard_controller.dart';
import 'team_dashboard_estim_actions.dart';
import 'widgets/team_dashboard_body.dart';

class TeamDashboardScreen extends StatefulWidget {
  final Team team;
  final Team adversaireTeam;

  const TeamDashboardScreen({
    super.key,
    required this.team,
    required this.adversaireTeam,
  });

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  late final TeamDashboardController _controller;
  late final TeamDashboardEstimActions _estimActions;
  bool _isLoadingReferenceData = true;

  @override
  void initState() {
    super.initState();
    _controller = TeamDashboardController(
      team: widget.team,
      adversaireTeam: widget.adversaireTeam,
    );
    _estimActions = TeamDashboardEstimActions(_controller);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final loadError = await _controller.loadReferenceAndTeamData();
    if (!mounted) return;
    setState(() {
      _isLoadingReferenceData = false;
    });
    if (loadError != null) {
      showErrorSnackBar(context, "Erreur de chargement : $loadError");
    }
  }

  Future<void> _deleteOpponent(TeamMeta opponent) async {
    try {
      await _controller.deleteOpponent(opponent.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Adversaire supprimé."),
            duration: snackBarDisplayDuration,
          ),
        );
      }
    } catch (deleteError) {
      if (mounted) {
        showErrorSnackBar(
          context,
          "Erreur de suppression : ${deleteError.toString()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingReferenceData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCaptain = _controller.isCaptain();

    return Scaffold(
      appBar: AppBar(
        title: Text("vs ${widget.adversaireTeam.nom}"),
      ),
      body: TeamDashboardBody(
        controller: _controller,
        estimActions: _estimActions,
        isCaptain: isCaptain,
        canViewSummary: _controller.canViewSummary(),
        canToggleMatched: _controller.canToggleMatched(),
        onOpponentDeleted: _deleteOpponent,
      ),
    );
  }
}
