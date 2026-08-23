import 'package:flutter/material.dart';

class TournamentTextImportTeamSelector extends StatelessWidget {
  final List<String> availableTeamNames;
  final String? selectedTeamName;
  final int playerCountForSelectedTeam;
  final ValueChanged<String?> onTeamChanged;

  const TournamentTextImportTeamSelector({
    super.key,
    required this.availableTeamNames,
    required this.selectedTeamName,
    required this.playerCountForSelectedTeam,
    required this.onTeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedTeamName,
          isExpanded: true,
          hint: const Text('Choisir une équipe'),
          items: availableTeamNames
              .map((teamName) =>
                  DropdownMenuItem(value: teamName, child: Text(teamName)))
              .toList(),
          onChanged: onTeamChanged,
        ),
        const SizedBox(height: 8),
        Text('$playerCountForSelectedTeam joueur(s) prêt(s) à importer'),
      ],
    );
  }
}
