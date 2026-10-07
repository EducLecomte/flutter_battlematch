import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../team_management_controller.dart';
import 'team_management_matched_panel.dart';
import 'team_management_team_members_panel.dart';
import 'team_management_team_invite_panel.dart';
import 'team_management_team_settings_panel.dart';

class TeamManagementTeamDetailPanel extends StatelessWidget {
  final TeamManagementController controller;
  final TextEditingController searchController;
  final VoidCallback onStateChanged;
  final ValueChanged<String> onSearchTextChanged;
  final ValueChanged<String> onSendInvite;
  final ValueChanged<Joueur> onRemoveMember;
  final ValueChanged<Team> onDeleteTeam;
  final ValueChanged<String> onUpdateMotDePasse;
  final ValueChanged<Joueur> onNominateCaptain;
  final void Function(Joueur player, String role) onMemberRoleChanged;
  final void Function(
    bool membresVoirSynthese,
    bool membresMatcher,
    bool membresEditerEstims,
  ) onUpdateOptions;

  const TeamManagementTeamDetailPanel({
    super.key,
    required this.controller,
    required this.searchController,
    required this.onStateChanged,
    required this.onSearchTextChanged,
    required this.onSendInvite,
    required this.onRemoveMember,
    required this.onDeleteTeam,
    required this.onUpdateMotDePasse,
    required this.onNominateCaptain,
    required this.onMemberRoleChanged,
    required this.onUpdateOptions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTeam = controller.selectedTeam!;
    // La zone de détail défile verticalement (point 7 MEMO) : le contenu
    // (paramètres, appariements, membres, invitations) peut dépasser la
    // hauteur de l'écran — une Column fixe provoquait des RenderFlex
    // overflowed (Axis.vertical).
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => onDeleteTeam(selectedTeam),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            if (controller.isCaptain()) ...[
              TeamManagementTeamSettingsPanel(
                key: ValueKey(selectedTeam.id),
                controller: controller,
                onUpdateMotDePasse: onUpdateMotDePasse,
                onNominateCaptain: onNominateCaptain,
                onUpdateOptions: onUpdateOptions,
              ),
              const SizedBox(height: 16),
            ],
            // Panneau léger : les adversaires ne sont chargés qu'à la demande.
            TeamManagementMatchedPanel(
              controller: controller,
              onStateChanged: onStateChanged,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final membersPanel = TeamManagementTeamMembersPanel(
                  members: controller.members,
                  captainId: selectedTeam.capitaineId,
                  canChangeRole: controller.isCaptain(),
                  canRemoveMember: controller.canRemoveMember,
                  onRemoveMember: onRemoveMember,
                  onRoleChanged: onMemberRoleChanged,
                );
                final invitePanel = TeamManagementTeamInvitePanel(
                  searchController: searchController,
                  searchResults: controller.searchResults,
                  isSearching: controller.isSearching,
                  onSearchTextChanged: onSearchTextChanged,
                  onSendInvite: onSendInvite,
                );

                if (constraints.maxWidth < 760) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      membersPanel,
                      if (controller.isCaptain()) ...[
                        const SizedBox(height: 16),
                        invitePanel,
                      ],
                    ],
                  );
                }

                // Les deux colonnes prennent leur hauteur naturelle (lists
                // shrinkWrap) ; la page gère le défilement.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: membersPanel),
                    const SizedBox(width: 16),
                    if (controller.isCaptain())
                      Expanded(flex: 2, child: invitePanel),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
