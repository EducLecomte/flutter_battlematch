// ===========================================================================
// Boîte de dialogue de détail d'un adversaire
// (opponent_details_dialog.dart)
// Liste d'armée complète + suppression (réservée au capitaine).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

Future<void> showOpponentDetailsDialog(
  BuildContext context, {
  required MetaAdv opponent,
  required Armee army,
  required bool canDelete,
  required Future<void> Function() onDelete,
}) {
  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          "${opponent.nomJoAdv ?? 'Joueur'} (${army.nom})",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Liste d'armée :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opponent.listeAdv.isNotEmpty
                        ? opponent.listeAdv
                        : "Aucune liste saisie.",
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (canDelete)
            TextButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: dialogContext,
                  builder: (confirmationContext) => AlertDialog(
                    title: const Text("Supprimer l'adversaire ?"),
                    content: const Text(
                      "Cette action effacera également toutes les estimations des joueurs sur ce matchup.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(confirmationContext).pop(false),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(confirmationContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text("Supprimer"),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  Navigator.of(dialogContext).pop(); // Fermer la modale actuelle
                  await onDelete();
                }
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text(
                "Supprimer",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Fermer"),
          ),
        ],
      );
    },
  );
}
