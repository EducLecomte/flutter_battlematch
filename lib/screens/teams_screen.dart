import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'team_dashboard_screen.dart';
import 'teams_screen_controller.dart';
import 'teams_screen_encounter_actions.dart';
import 'teams_screen_team_access_actions.dart';
import 'widgets/teams_screen_encounter_list.dart';
import 'widgets/teams_screen_team_access_panel.dart';
import 'widgets/teams_screen_team_selector.dart';

class TeamsScreen extends StatefulWidget {
  final Tournoi tournoi;

  const TeamsScreen({super.key, required this.tournoi});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  late final TeamsScreenController _controller;
  late final TeamsScreenEncounterActions _actions;
  late final TeamsScreenTeamAccessActions _teamAccessActions;

  @override
  void initState() {
    super.initState();
    _controller = TeamsScreenController();
    _actions = TeamsScreenEncounterActions(_controller);
    _teamAccessActions = TeamsScreenTeamAccessActions(_controller);
    _controller.bindTournoi(widget.tournoi.id);
    _loadTeams();
  }

  Future<void> _loadTeams() {
    return _actions.loadTeams(context, _refreshUserInterface);
  }

  Future<void> _loadEncounters() {
    return _actions.loadEncounters(context, _refreshUserInterface);
  }

  void _refreshUserInterface() {
    if (mounted) setState(() {});
  }

  void _openEncounterDashboard(Rencontre selectedEncounter) {
    if (_controller.activeTeam == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (dashboardContext) => TeamDashboardScreen(
          tournoi: widget.tournoi,
          team: _controller.activeTeam!,
          rencontre: selectedEncounter,
        ),
      ),
    );
  }

  Future<void> _handleOpponentTeamSelected(Team opponentTeam) async {
    try {
      final Rencontre encounter =
          await _controller.getOrCreateEncounterForOpponent(opponentTeam.nom);
      if (mounted) {
        _openEncounterDashboard(encounter);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Erreur : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoadingTeams) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournoi.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEncounters,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _controller.utilisateurSansEquipe
            ? TeamsScreenTeamAccessPanel(
                equipesTournoi: _controller.availableTournoiTeams,
                isLoading: _controller.isLoadingTeams,
                onClaimTeam: (team) {
                  _teamAccessActions.claimTeam(
                    context,
                    team,
                    _refreshUserInterface,
                  );
                },
                onJoinTeam: (team, motDePasse) {
                  _teamAccessActions.joinTeam(
                    context,
                    team,
                    motDePasse,
                    _refreshUserInterface,
                  );
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TeamsScreenTeamSelector(
                    activeTeam: _controller.activeTeam,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Rencontres / Équipes adverses du tournoi",
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TeamsScreenEncounterList(
                      activeTeam: _controller.activeTeam,
                      opponentTeams: _controller.opponentTeams,
                      availableEncounters: _controller.availableEncounters,
                      onEncounterSelected: _openEncounterDashboard,
                      onOpponentTeamSelected: _handleOpponentTeamSelected,
                      onDeleteRequested: (selectedEncounter) =>
                          _actions.deleteEncounter(
                            context,
                            selectedEncounter,
                            _refreshUserInterface,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
