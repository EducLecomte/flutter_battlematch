// ===========================================================================
// Feuille de détail d'une estimation (estim_details_sheet.dart)
// Lecture seule : choix coloré, score attendu, confiance, commentaire.
// Bouton d'édition si le rôle courant est autorisé.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../logic/estim_score_calculator.dart';
import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';

void showEstimDetailsSheet(
  BuildContext context, {
  required Joueur joueur,
  required MetaAdv opponent,
  required Estim estim,
  required Choix? choix,
  required bool canEdit,
  required VoidCallback onEdit,
}) {
  final theme = Theme.of(context);
  final scoreRangeLabel = EstimScoreCalculator.scoreRangeLabel(estim);

  Color confidenceColor(String confidenceLevel) => switch (confidenceLevel) {
    estimConfianceEleve => Colors.green,
    estimConfianceMoyen => Colors.amber,
    _ => Colors.red,
  };

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
                  label: Text(choix?.libelle ?? AppreciationScale.unknownLabel),
                  backgroundColor: (
                    HexColorParser.parseHexadecimalColor(
                      choix?.couleurHex ?? '',
                    ) ??
                    theme.disabledColor
                  ).withValues(alpha: 0.2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (scoreRangeLabel != null)
              Text(
                "Score attendu (système 20-0) : $scoreRangeLabel points",
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Niveau de confiance : "),
                Text(
                  estim.confiance.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: confidenceColor(estim.confiance),
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
