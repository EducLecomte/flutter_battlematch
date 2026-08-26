// ===========================================================================
// Dialogue de création / modification d'une armée (admin_armee_edit_dialog.dart)
// Gère ses propres contrôleurs de texte ; les valeurs validées sont
// renvoyées à [onSave] après fermeture du dialogue.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

Future<void> showArmeeEditDialog({
  required BuildContext dialogContext,
  required Armee? existingArmee,
  required Future<void> Function(String nom, String short) onSave,
}) async {
  final TextEditingController nomController =
      TextEditingController(text: existingArmee?.nom ?? '');
  final TextEditingController shortController =
      TextEditingController(text: existingArmee?.short ?? '');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final bool valid = (await showDialog<bool>(
    context: dialogContext,
    builder: (context) => AlertDialog(
      title: Text(existingArmee == null
          ? "Ajouter une armée"
          : "Modifier l'armée"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: "Nom de l'armée",
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Obligatoire"
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: shortController,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Initiales (ex : BH)",
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Obligatoire"
                  : null,
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
    ),
  ) ??
      false);

  final String nomEnregistre = nomController.text;
  final String shortEnregistre = shortController.text;
  nomController.dispose();
  shortController.dispose();
  if (valid) {
    await onSave(nomEnregistre, shortEnregistre);
  }
}
