// ===========================================================================
// Tableau de bord de l'équipe (team_dashboard_screen.dart)
// Écran principal affichant la matrice d'estimations et d'appariement.
// La logique métier vit dans TeamDashboardController ; le rendu dans
// lib/screens/widgets/team_dashboard_*.dart.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import 'team_dashboard_controller.dart';
import 'team_dashboard_estim_actions.dart';
import 'widgets/add_opponent_dialog.dart';
import 'widgets/team_dashboard_body.dart';

class TeamDashboardScreen extends StatefulWidget {
  final Tournoi tournoi;
  final Team team;
  final Rencontre rencontre;

  const TeamDashboardScreen({
    super.key,
    required this.tournoi,
    required this.team,
    required this.rencontre,
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
      tournoi: widget.tournoi,
      team: widget.team,
      rencontre: widget.rencontre,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement: $loadError")),
      );
    }
  }

  Future<void> _deleteOpponent(MetaAdv opponent) async {
    try {
      await _controller.deleteOpponent(opponent.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Adversaire supprimé.")));
      }
    } catch (deleteError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur de suppression : ${deleteError.toString()}"),
          ),
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
        title: Text("Ronde : ${widget.rencontre.nomAdversaire}"),
        actions: [
          if (isCaptain)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: "Ajouter un adversaire",
              onPressed: () => showAddOpponentDialog(context, _controller),
            ),
        ],
      ),
      body: TeamDashboardBody(
        controller: _controller,
        estimActions: _estimActions,
        isCaptain: isCaptain,
        onOpponentDeleted: _deleteOpponent,
      ),
    );
  }
}
