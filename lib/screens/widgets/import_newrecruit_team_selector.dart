import 'package:flutter/material.dart';

import 'import_newrecruit_controller.dart';

class ImportNewRecruitTeamSelector extends StatelessWidget {
  final ImportNewRecruitController controller;
  final ValueChanged<String?> onTeamChanged;

  const ImportNewRecruitTeamSelector({
    super.key,
    required this.controller,
    required this.onTeamChanged,
  });

  @override
  Widget build(BuildContext context) {
    final teamPlayers = controller.playersOfSelectedTeam();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Équipes détectées dans le tournoi. Veuillez sélectionner l'équipe adverse :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Choisir l'équipe adverse",
            border: OutlineInputBorder(),
          ),
          initialValue: controller.selectedTeamToImport,
          items: controller.detectedTeams.map((teamName) {
            return DropdownMenuItem<String>(
              value: teamName,
              child: Text(teamName),
            );
          }).toList(),
          onChanged: onTeamChanged,
        ),
        const SizedBox(height: 16),
        Text(
          "Joueurs détectés dans cette équipe (${teamPlayers.length}) :",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: teamPlayers.length,
              itemBuilder: (context, index) {
                final player = teamPlayers[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    player['playerName'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Armée : ${player['armyName']}"),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
