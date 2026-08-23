import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'rencontre_list_tile.dart';

class TeamsScreenEncounterList extends StatelessWidget {
  final Team? activeTeam;
  final List<Rencontre> availableEncounters;
  final ValueChanged<Rencontre> onEncounterSelected;
  final ValueChanged<Rencontre> onImportTournamentText;
  final ValueChanged<Rencontre> onDeleteRequested;

  const TeamsScreenEncounterList({
    super.key,
    required this.activeTeam,
    required this.availableEncounters,
    required this.onEncounterSelected,
    required this.onImportTournamentText,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    if (activeTeam == null) {
      return const Center(child: Text("Sélectionnez d'abord une équipe."));
    }

    if (availableEncounters.isEmpty) {
      return const Center(
        child: Text("Aucun match créé pour le moment.",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: availableEncounters.length,
      itemBuilder: (context, index) {
        final Rencontre selectedEncounter = availableEncounters[index];
        return RencontreListTile(
          encounter: selectedEncounter,
          onOpenDashboard: () => onEncounterSelected(selectedEncounter),
          onImportTournamentText: () => onImportTournamentText(selectedEncounter),
          onDeleteRequested: () => onDeleteRequested(selectedEncounter),
        );
      },
    );
  }
}
