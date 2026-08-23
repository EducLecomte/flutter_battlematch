import 'package:flutter/material.dart';
import '../../models/models.dart';

class RencontreListTile extends StatelessWidget {
  final Rencontre encounter;
  final VoidCallback onOpenDashboard;
  final VoidCallback onImportTournamentText;
  final VoidCallback onDeleteRequested;

  const RencontreListTile({
    super.key,
    required this.encounter,
    required this.onOpenDashboard,
    required this.onImportTournamentText,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1F2196F3),
          child: Icon(Icons.shield_outlined, color: Colors.blueAccent),
        ),
        title: Text(encounter.nomAdversaire,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Cliquez pour ouvrir la matrice d'estimations"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.file_upload_outlined, color: Colors.blueAccent),
              onPressed: onImportTournamentText,
              tooltip: "Importer le texte du tournoi",
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDeleteRequested,
              tooltip: "Supprimer la rencontre",
            ),
          ],
        ),
        onTap: onOpenDashboard,
      ),
    );
  }
}
