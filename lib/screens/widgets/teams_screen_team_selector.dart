import 'package:flutter/material.dart';
import '../../models/models.dart';

class TeamsScreenTeamSelector extends StatelessWidget {
  final Team? activeTeam;
  final List<Team> selectableTeams;
  final ValueChanged<Team> onTeamSelected;

  const TeamsScreenTeamSelector({
    super.key,
    required this.activeTeam,
    required this.selectableTeams,
    required this.onTeamSelected,
  });

  @override
  Widget build(BuildContext context) {
    final Team? currentSelectableTeam = _resolveCurrentSelectableTeam();
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.group_outlined, color: Colors.blueAccent),
            const SizedBox(width: 12),
            const Text('Équipe active :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 16),
            Expanded(
              child: currentSelectableTeam == null
                  ? const Text(
                      "Aucune équipe connue dans ce tournoi. Créez-en une sur l'onglet équipes.",
                      style: TextStyle(color: Colors.redAccent),
                    )
                  : DropdownButton<Team>(
                      value: currentSelectableTeam,
                      borderRadius: BorderRadius.circular(8),
                      items: [
                        for (final Team team in selectableTeams)
                          DropdownMenuItem<Team>(
                            value: team,
                            child: Text(
                              team.nom,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (Team? selectedTeam) {
                        if (selectedTeam != null) {
                          onTeamSelected(selectedTeam);
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Team? _resolveCurrentSelectableTeam() {
    final Team? currentActiveTeam = activeTeam;
    if (currentActiveTeam == null) return null;
    for (final Team team in selectableTeams) {
      if (team.id == currentActiveTeam.id) return team;
    }
    return selectableTeams.isEmpty ? null : selectableTeams.first;
  }
}
