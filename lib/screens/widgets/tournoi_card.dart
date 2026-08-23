// ===========================================================================
// Carte d'un Tournoi (tournoi_card.dart)
// Affiche le nom et le lien New Recruit d'un tournoi, avec actions
// d'ouverture (vers les rencontres) et de suppression confirmée.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class TournoiCard extends StatelessWidget {
  final Tournoi tournoi;
  final ValueChanged<String> onDeleteTournoi;
  final VoidCallback onOpenTournoi;

  const TournoiCard({
    super.key,
    required this.tournoi,
    required this.onDeleteTournoi,
    required this.onOpenTournoi,
  });

  // Demande la confirmation avant de déclencher la suppression
  Future<void> _confirmDeletion(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer le tournoi ?"),
        content: const Text(
          "Cette action supprimera également toutes les équipes, "
          "rencontres et estimations associées.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      onDeleteTournoi(tournoi.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String lienNewRecruit = tournoi.lienNr;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(
          tournoi.nom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: lienNewRecruit.isNotEmpty
            ? Text(
                "Lien: $lienNewRecruit",
                style: const TextStyle(color: Colors.blueAccent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text("Aucun lien New Recruit"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _confirmDeletion(context),
        ),
        onTap: onOpenTournoi,
      ),
    );
  }
}
