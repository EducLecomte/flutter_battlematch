import 'package:flutter/material.dart';
import '../../models/models.dart';

class TeamManagementTeamMembersPanel extends StatelessWidget {
  final List<Map<String, dynamic>> members;
  final bool Function(Map<String, dynamic> member) canRemoveMember;
  final ValueChanged<Joueur> onRemoveMember;

  const TeamManagementTeamMembersPanel({
    super.key,
    required this.members,
    required this.canRemoveMember,
    required this.onRemoveMember,
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
              final isCaptain = role == 'captain';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      isCaptain ? Icons.workspace_premium : Icons.person,
                      size: 20,
                    ),
                  ),
                  title: Text(player.nom),
                  subtitle: Text(role == 'captain' ? 'Capitaine' : 'Joueur'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
}
