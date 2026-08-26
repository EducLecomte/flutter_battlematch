import 'package:flutter/material.dart';
import '../models/models.dart';
import 'team_dashboard_screen.dart';
import 'teams_screen_controller.dart';
import 'teams_screen_encounter_actions.dart';
import 'widgets/add_encounter_dialog.dart';
import 'widgets/teams_screen_encounter_list.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = TeamsScreenController();
    _actions = TeamsScreenEncounterActions(_controller);
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

  Future<void> _handleTeamSelected(Team selectedTeam) async {
    _controller.setActiveTeam(selectedTeam);
    await _actions.loadEncounters(context, _refreshUserInterface);
  }

  void _showAddEncounterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddEncounterDialog(
        onCreateEncounter: (opponentName) => _actions.createEncounter(
          context,
          opponentName,
          _refreshUserInterface,
        ),
      ),
    );
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
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: _controller.activeTeam == null
                ? null
                : () => _actions.importTournamentText(
                      context, _refreshUserInterface),
            tooltip: "Importer le tournoi depuis un texte",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEncounters,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      floatingActionButton: _controller.activeTeam == null
          ? null
          : FloatingActionButton(
              onPressed: _showAddEncounterDialog,
              tooltip: "Ajouter un match / ronde",
              child: const Icon(Icons.add),
            ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeamsScreenTeamSelector(
              activeTeam: _controller.activeTeam,
              selectableTeams: _controller.selectableTeams,
              onTeamSelected: _handleTeamSelected,
            ),
            const SizedBox(height: 24),
            Text(
              "Rencontres / Rondes du tournoi",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TeamsScreenEncounterList(
                activeTeam: _controller.activeTeam,
                availableEncounters: _controller.availableEncounters,
                onEncounterSelected: _openEncounterDashboard,
                onDeleteRequested: (selectedEncounter) => _actions
                    .deleteEncounter(context, selectedEncounter,
                        _refreshUserInterface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
