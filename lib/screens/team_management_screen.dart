// ===========================================================================
// Écran de Gestion d'Équipe (team_management_screen.dart)
// Permet de créer des équipes, lister ses membres et inviter d'autres joueurs.
// ===========================================================================

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'team_management_controller.dart';
import 'widgets/team_management_team_list_sidebar.dart';
import 'widgets/team_management_team_detail_panel.dart';
import 'widgets/team_management_create_team_dialog.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final TeamManagementController _controller = TeamManagementController();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Charge le profil du joueur connecté et ses équipes
  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    final errorMessage = await _controller.loadInitialData();
    if (!mounted) return;
    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de chargement : $errorMessage")),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Crée une nouvelle équipe depuis la boîte de dialogue
  Future<void> _createNewTeam() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isEmpty) return;
    final errorMessage = await _controller.createNewTeam(teamName);
    if (!mounted) return;
    _teamNameController.clear();
    setState(() {}); // Rafraîchit la liste des équipes
    Navigator.of(context).pop(); // Ferme la boîte de dialogue
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage == null
              ? "Équipe créée avec succès !"
              : "Erreur de création : $errorMessage",
        ),
        backgroundColor: errorMessage == null ? Colors.green : Colors.redAccent,
      ),
    );
  }

  // Envoie une invitation et notifie l'utilisateur
  Future<void> _sendInvite(String playerId) async {
    final errorMessage = await _controller.sendInvite(playerId);
    if (!mounted) return;
    if (errorMessage == null) _searchController.clear();
    setState(() {}); // Rafraîchit la liste des membres
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage == null
              ? "Invitation envoyée !"
              : "Erreur d'invitation : $errorMessage",
        ),
        backgroundColor: errorMessage == null ? Colors.green : Colors.redAccent,
      ),
    );
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
              setState(() {});
              await _controller.loadMembersForSelectedTeam();
              if (mounted) setState(() {});
            },
            onCreateTeamPressed: () => showTeamManagementCreateTeamDialog(
              dialogContext: context,
              teamNameController: _teamNameController,
              onCreateTeamPressed: _createNewTeam,
            ),
          ),
          Expanded(
            child: _controller.selectedTeam == null
                ? const Center(
                    child: Text(
                      "Sélectionnez ou créez une équipe pour commencer.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : TeamManagementTeamDetailPanel(
                    controller: _controller,
                    searchController: _searchController,
                    onSearchTextChanged: (query) async {
                      await _controller.searchPlayers(query);
                      if (mounted) setState(() {});
                    },
                    onSendInvite: _sendInvite,
                    onRemoveMember: (player) async {
                      final errorMessage =
                          await _controller.removeMember(context, player);
                      if (mounted) setState(() {}); // Rafraîchit les membres
                      if (errorMessage != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur de retrait : $errorMessage"),
                          ),
                        );
                      }
                    },
                    onDeleteTeam: (team) async {
                      final errorMessage =
                          await _controller.deleteTeam(context, team);
                      if (mounted) setState(() {}); // Rafraîchit les équipes
                      if (errorMessage != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Erreur de suppression : $errorMessage"),
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
