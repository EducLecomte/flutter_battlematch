import 'package:flutter/material.dart';
import '../../models/models.dart';

class TeamManagementTeamListSidebar extends StatelessWidget {
  final List<Team> teams;
  final String? selectedTeamId;
  final ValueChanged<Team> onTeamSelected;
  final VoidCallback onCreateTeamPressed;

  const TeamManagementTeamListSidebar({
    super.key,
    required this.teams,
    required this.selectedTeamId,
    required this.onTeamSelected,
    required this.onCreateTeamPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: onCreateTeamPressed,
              icon: const Icon(Icons.add),
              label: const Text("Créer équipe"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ),
          Expanded(
            child: teams.isEmpty
                ? const Center(
                    child: Text(
                      "Aucune équipe",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isSelected = selectedTeamId == team.id;
                      return ListTile(
                        title: Text(
                          team.nom,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onTap: () => onTeamSelected(team),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
