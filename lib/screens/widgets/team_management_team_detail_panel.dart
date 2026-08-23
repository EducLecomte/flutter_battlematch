import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../team_management_controller.dart';
import 'team_management_team_members_panel.dart';
import 'team_management_team_invite_panel.dart';

class TeamManagementTeamDetailPanel extends StatelessWidget {
  final TeamManagementController controller;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchTextChanged;
  final ValueChanged<String> onSendInvite;
  final ValueChanged<Joueur> onRemoveMember;
  final ValueChanged<Team> onDeleteTeam;

  const TeamManagementTeamDetailPanel({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onSearchTextChanged,
    required this.onSendInvite,
    required this.onRemoveMember,
    required this.onDeleteTeam,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTeam = controller.selectedTeam!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  selectedTeam.nom,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (controller.isCaptain())
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onDeleteTeam(selectedTeam),
                ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: TeamManagementTeamMembersPanel(
                    members: controller.members,
                    canRemoveMember: controller.canRemoveMember,
                    onRemoveMember: onRemoveMember,
                  ),
                ),
                const SizedBox(width: 16),
                if (controller.isCaptain())
                  Expanded(
                    flex: 2,
                    child: TeamManagementTeamInvitePanel(
                      searchController: searchController,
                      searchResults: controller.searchResults,
                      isSearching: controller.isSearching,
                      onSearchTextChanged: onSearchTextChanged,
                      onSendInvite: onSendInvite,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
