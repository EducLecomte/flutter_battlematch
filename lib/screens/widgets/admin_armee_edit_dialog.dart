// ===========================================================================
// Dialogue de création / modification d'une armée (admin_armee_edit_dialog.dart)
// Les contrôleurs de texte appartiennent au State, qui les libère dans
// dispose() ; les valeurs validées sont renvoyées à [onSave] après
// fermeture du dialogue.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Valeurs saisies dans le dialogue d'armée, renvoyées via Navigator.pop.
class ArmeeEditResult {
  final String nom;
  final String short;

  const ArmeeEditResult({required this.nom, required this.short});
}

/// Ouvre le dialogue d'armée ; [onSave] est appelé avec les valeurs validées.
Future<void> showArmeeEditDialog({
  required BuildContext dialogContext,
  required Armee? existingArmee,
  required Future<void> Function(String nom, String short) onSave,
}) async {
  final ArmeeEditResult? result = await showDialog<ArmeeEditResult>(
    context: dialogContext,
    builder: (context) => ArmeeEditDialog(existingArmee: existingArmee),
  );
  if (result == null) return;
  await onSave(result.nom, result.short);
}

/// Formulaire d'armée ; le State possède et libère les contrôleurs.
class ArmeeEditDialog extends StatefulWidget {
  final Armee? existingArmee;

  const ArmeeEditDialog({super.key, this.existingArmee});

  @override
  State<ArmeeEditDialog> createState() => _ArmeeEditDialogState();
}

class _ArmeeEditDialogState extends State<ArmeeEditDialog> {
  late final TextEditingController _nomController =
      TextEditingController(text: widget.existingArmee?.nom ?? '');
  late final TextEditingController _shortController =
      TextEditingController(text: widget.existingArmee?.short ?? '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomController.dispose();
    _shortController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(ArmeeEditResult(
        nom: _nomController.text,
        short: _shortController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingArmee == null
          ? "Ajouter une armée"
          : "Modifier l'armée"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomController,
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
              controller: _shortController,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
