import 'package:flutter/material.dart';
import '../../models/models.dart';

class TeamsScreenTeamSelector extends StatelessWidget {
  final Team? activeTeam;

  const TeamsScreenTeamSelector({
    super.key,
    required this.activeTeam,
  });

  @override
  Widget build(BuildContext context) {
    final Team? currentTeam = activeTeam;
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
              child: currentTeam == null
                  ? const Text(
                      "Vous ne faites partie d'aucune équipe. Créez-en une sur l'onglet équipes.",
                      style: TextStyle(color: Colors.redAccent),
                    )
                  : Text(
                      currentTeam.nom,
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
