// ===========================================================================
// Feuille de détail d'une estimation (estim_details_sheet.dart)
// Lecture seule : choix coloré, score attendu, confiance, commentaire.
// Bouton d'édition si le rôle courant est autorisé.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

void showEstimDetailsSheet(
  BuildContext context, {
  required Joueur joueur,
  required MetaAdv opponent,
  required Estim estim,
  required Choix choix,
  required bool canEdit,
  required VoidCallback onEdit,
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Matchup : ${joueur.nom} contre ${opponent.nomJoAdv ?? 'Adversaire'}",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Estimation globale : "),
                Chip(
                  label: Text(choix.libelle),
                  backgroundColor: Color(
                    int.parse(choix.couleurHex.replaceFirst('#', '0xFF')),
                  ).withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (estim.scoreMin != null && estim.scoreMax != null)
              Text(
                "Score attendu (système 20-0) : ${estim.scoreMin} à ${estim.scoreMax} points",
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Niveau de confiance : "),
                Text(
                  estim.confiance.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: estim.confiance == 'eleve'
                        ? Colors.green
                        : (estim.confiance == 'moyen'
                            ? Colors.amber
                            : Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Notes / Commentaires du joueur :",
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
                estim.commentaire ??
                    "Aucun commentaire rédigé par le joueur.",
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),
            if (canEdit)
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Éditer l'estimation"),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  onEdit();
                },
              ),
          ],
        ),
      );
    },
  );
}
