import 'package:flutter/material.dart';

import '../models/models.dart';
import 'team_dashboard_screen.dart';
import 'teams_screen_actions.dart';
import 'teams_screen_controller.dart';
import 'teams_screen_invite_player_dialog.dart';
import 'teams_screen_team_access_actions.dart';
import 'widgets/teams_screen_opponent_list.dart';
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
  late final TeamsScreenActions _actions;
  late final TeamsScreenTeamAccessActions _teamAccessActions;

  @override
  void initState() {
    super.initState();
    _controller = TeamsScreenController();
    _actions = TeamsScreenActions(_controller);
    _teamAccessActions = TeamsScreenTeamAccessActions(_controller);
    _controller.bindTournoi(widget.tournoi.id);
    _loadTeams();
  }

  Future<void> _loadTeams() {
    return _actions.loadTeams(context, _refreshUserInterface);
  }

  void _refreshUserInterface() {
    if (mounted) setState(() {});
  }

  void _openOpponentDashboard(Team opponentTeam) {
    final Team? activeTeam = _controller.activeTeam;
    if (activeTeam == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (dashboardContext) => TeamDashboardScreen(
          team: activeTeam,
          adversaireTeam: opponentTeam,
        ),
      ),
    );
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
          if (_controller.isCaptainOfActiveTeam)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: "Inviter un joueur",
              onPressed: () =>
                  showTeamsScreenInvitePlayerDialog(context, _controller),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeams,
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
                  TeamsScreenTeamSelector(activeTeam: _controller.activeTeam),
                  const SizedBox(height: 24),
                  Text(
                    "Équipes adverses du tournoi",
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TeamsScreenOpponentList(
                      activeTeam: _controller.activeTeam,
                      opponentTeams: _controller.opponentTeams,
                      onOpponentTeamSelected: _openOpponentDashboard,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
