// ===========================================================================
// Carte d'un Tournoi (tournoi_card.dart)
// Affiche le nom d'un tournoi, avec actions d'ouverture, d'import des
// équipes (admin), de modification (admin) et de suppression (admin).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class TournoiCard extends StatelessWidget {
  final Tournoi tournoi;
  final bool estAdministrateur;
  final int tailleEquipe;
  final ValueChanged<String>? onDeleteTournoi;
  final VoidCallback? onOpenTournoi;
  final VoidCallback? onImportTeams;
  final VoidCallback? onEditTournoi;

  const TournoiCard({
    super.key,
    required this.tournoi,
    required this.estAdministrateur,
    this.tailleEquipe = 0,
    this.onDeleteTournoi,
    this.onOpenTournoi,
    this.onImportTeams,
    this.onEditTournoi,
  });

  Future<void> _confirmDeletion(BuildContext context) async {
    final ValueChanged<String>? deleteHandler = onDeleteTournoi;
    if (deleteHandler == null) return;

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer le tournoi ?"),
        content: const Text(
          "Cette action supprimera également toutes les équipes, "
          "listes adverses et estimations associées.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      deleteHandler(tournoi.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool importRequis = !tournoi.importEffectue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          tournoi.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tailleEquipe > 0)
              Text(
                "Taille d'équipe : $tailleEquipe joueur${tailleEquipe == 1 ? '' : 's'}",
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            if (importRequis)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  "Import des équipes requis",
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (estAdministrateur && importRequis)
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted_add,
                  color: Colors.blueAccent,
                ),
                onPressed: onImportTeams,
                tooltip: "Importer les équipes",
              ),
            if (estAdministrateur && onEditTournoi != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEditTournoi,
                tooltip: "Modifier",
              ),
            if (estAdministrateur)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDeletion(context),
                tooltip: "Supprimer",
              ),
          ],
        ),
        onTap: onOpenTournoi,
      ),
    );
  }
}
