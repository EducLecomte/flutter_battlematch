// ===========================================================================
// Dialogue de création / modification d'une appréciation
// (admin_choix_edit_dialog.dart)
// Gère ses propres contrôleurs de texte, dont l'aperçu de couleur en direct ;
// les valeurs validées sont renvoyées à [onSave] après fermeture.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';

/// Taille de l'échantillon de couleur affiché dans le dialogue.
const double adminCouleurSwatchTaille = 40.0;

Future<void> showChoixEditDialog({
  required BuildContext dialogContext,
  required Choix? existingChoix,
  required Future<void> Function(
      String libelle, String short, String couleurHex) onSave,
}) async {
  final TextEditingController libelleController =
      TextEditingController(text: existingChoix?.libelle ?? '');
  final TextEditingController shortController =
      TextEditingController(text: existingChoix?.short ?? '');
  final TextEditingController couleurController =
      TextEditingController(text: existingChoix?.couleurHex ?? '');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final bool valid = (await showDialog<bool>(
    context: dialogContext,
    builder: (context) {
      return StatefulBuilder(
        builder: (statefulContext, updateDialogState) {
          final Color? couleurApercu =
              HexColorParser.parseHexadecimalColor(couleurController.text);
          return AlertDialog(
            title: Text(existingChoix == null
                ? "Ajouter une appréciation"
                : "Modifier l'appréciation"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: libelleController,
                    decoration: const InputDecoration(
                      labelText: "Libellé (ex : Entre 8 et 12)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? "Obligatoire"
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: shortController,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: "Initiales (ex : 8-12)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? "Obligatoire"
                            : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: couleurController,
                          decoration: const InputDecoration(
                            labelText: "Couleur hexadécimale (ex : #FBC02D)",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => updateDialogState(() {}),
                          validator: (value) =>
                              HexColorParser.normalizeHexadecimalColor(
                                      value ?? '') ==
                                  null
                                  ? "Format #RRGGBB attendu"
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: adminCouleurSwatchTaille,
                        height: adminCouleurSwatchTaille,
                        decoration: BoxDecoration(
                          color: couleurApercu ?? Colors.transparent,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text("Enregistrer"),
              ),
            ],
          );
        },
      );
    },
  ) ??
      false);

  final String libelleEnregistre = libelleController.text;
  final String shortEnregistre = shortController.text;
  final String couleurEnregistree = couleurController.text;
  libelleController.dispose();
  shortController.dispose();
  couleurController.dispose();
  if (valid) {
    await onSave(libelleEnregistre, shortEnregistre, couleurEnregistree);
  }
}
