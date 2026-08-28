// ===========================================================================
// Écran de Gestion d'Équipe (team_management_screen.dart)
// Liste les équipes de l'utilisateur et permet de gérer membres,
// invitations, mot de passe et capitainerie.
// ===========================================================================

import 'package:flutter/material.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'profile_screen.dart';
import 'team_management_controller.dart';
import 'team_management_team_actions.dart';
import 'widgets/team_management_team_list_sidebar.dart';
import 'widgets/team_management_team_detail_panel.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final TeamManagementController _controller = TeamManagementController();
  final TeamManagementTeamActions _teamActions = TeamManagementTeamActions();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshUserInterface() {
    if (mounted) setState(() {});
  }

  // Charge le profil du joueur connecté et ses équipes
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    final errorMessage = await _controller.loadInitialData();
    if (!mounted) return;
    if (errorMessage != null) {
      showErrorSnackBar(context, "Erreur de chargement : $errorMessage");
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Envoie une invitation et notifie l'utilisateur
  Future<void> _sendInvite(String playerId) async {
    final errorMessage = await _controller.sendInvite(playerId);
    if (!mounted) return;
    if (errorMessage == null) _searchController.clear();
    setState(() {}); // Rafraîchit la liste des membres
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invitation envoyée !"), backgroundColor: Colors.green),
      );
    } else {
      showErrorSnackBar(context, "Erreur d'invitation : $errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Équipes"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (dialogContext) => const ProfileScreen()),
            ).then((_) => _loadInitialData()), // Recharge au retour
            icon: const Icon(Icons.person_outline),
            tooltip: "Mon profil & invitations",
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeamManagementTeamListSidebar(
            teams: _controller.teams,
            selectedTeamId: _controller.selectedTeam?.id,
            onTeamSelected: (team) async {
              _controller.selectedTeam = team;
              _refreshUserInterface();
              await _controller.loadMembersForSelectedTeam();
              await _controller.loadEncountersForSelectedTeam();
              _refreshUserInterface();
            },
          ),
          Expanded(
            child: _controller.selectedTeam == null
                ? const Center(
                    child: Text(
                      "Sélectionnez une équipe pour commencer.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : TeamManagementTeamDetailPanel(
                    controller: _controller,
                    searchController: _searchController,
                    onStateChanged: _refreshUserInterface,
                    onSearchTextChanged: (query) async {
                      await _controller.searchPlayers(query);
                      if (mounted) setState(() {});
                    },
                    onSendInvite: _sendInvite,
                    onRemoveMember: (player) => _teamActions.removeMember(
                      context,
                      _controller,
                      player,
                      _refreshUserInterface,
                    ),
                    onDeleteTeam: (team) => _teamActions.deleteTeam(
                      context,
                      _controller,
                      team,
                      _refreshUserInterface,
                    ),
                    onUpdateMotDePasse: (motDePasse) => _teamActions
                        .updateTeamMotDePasse(
                          context,
                          _controller,
                          motDePasse,
                          _refreshUserInterface,
                        ),
                    onNominateCaptain: (candidate) => _teamActions
                        .nominateNewCaptain(
                          context,
                          _controller,
                          candidate,
                          _refreshUserInterface,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}
