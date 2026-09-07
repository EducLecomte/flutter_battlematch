import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/pocketbase_data_service.dart';

class TeamManagementTeamMembersPanel extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final String? captainId;
  final bool canChangeRole;
  final bool Function(Map<String, dynamic> member) canRemoveMember;
  final ValueChanged<Joueur> onRemoveMember;
  final void Function(Joueur player, String role) onRoleChanged;

  const TeamManagementTeamMembersPanel({
    super.key,
    required this.members,
    required this.captainId,
    required this.canChangeRole,
    required this.canRemoveMember,
    required this.onRemoveMember,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Membres de l'équipe",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final Joueur player = member['joueur'];
              final String role = member['role'];
              final String status = member['statut'];
              final isPending = status == 'pending';
              final isCaptain = player.id == captainId;
              final isCoach = role == PocketbaseDataService.roleCoach;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      isCaptain
                          ? Icons.workspace_premium
                          : (isCoach
                              ? Icons.sports_score
                              : Icons.person),
                      size: 20,
                    ),
                  ),
                  title: Text(player.nom),
                  subtitle: Text(_libelleRole(isCaptain, isCoach)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canChangeRole && !isPending)
                        _buildRoleSelector(role, isCaptain, (newRole) => onRoleChanged(player, newRole)),
                      if (isPending)
                        Chip(
                          label: const Text("En attente"),
                          backgroundColor: Colors.amber.shade200,
                        )
                      else
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      if (canRemoveMember(member))
                        IconButton(
                          icon: const Icon(
                            Icons.person_remove_alt_1,
                            color: Colors.redAccent,
                          ),
                          tooltip: "Retirer de l'équipe",
                          onPressed: () => onRemoveMember(player),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Sélecteur de rôle : capitaine (joueur / coach) ou membre (joueur / coach).
  Widget _buildRoleSelector(
    String currentRole,
    bool isCaptain,
    ValueChanged<String> onChanged,
  ) {
    // Un capitaine joue sous le rôle 'captain' ; on normalise 'player' pour
    // garantir que la valeur sélectionnée existe dans la liste d'options.
    final String effectiveValue = isCaptain &&
            currentRole == PocketbaseDataService.roleJoueur
        ? PocketbaseDataService.roleCapitaine
        : currentRole;

    final List<DropdownMenuItem<String>> items = isCaptain
        ? [
            const DropdownMenuItem(
              value: PocketbaseDataService.roleCapitaine,
              child: Text('Joueur'),
            ),
            const DropdownMenuItem(
              value: PocketbaseDataService.roleCoach,
              child: Text('Coach'),
            ),
          ]
        : [
            const DropdownMenuItem(
              value: PocketbaseDataService.roleJoueur,
              child: Text('Joueur'),
            ),
            const DropdownMenuItem(
              value: PocketbaseDataService.roleCoach,
              child: Text('Coach'),
            ),
          ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: effectiveValue,
        isDense: true,
        hint: const Text('Rôle'),
        onChanged: (value) => onChanged(value ?? effectiveValue),
        items: items,
      ),
    );
  }

  String _libelleRole(bool isCaptain, bool isCoach) {
    if (isCaptain) return isCoach ? 'Capitaine · Coach' : 'Capitaine';
    return isCoach ? 'Coach' : 'Joueur';
  }
}
