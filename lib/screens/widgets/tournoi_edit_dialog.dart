// ===========================================================================
// Boîte de dialogue de modification de Tournoi (tournoi_edit_dialog.dart)
// Formulaire nom du tournoi ; le contrôleur de texte appartient au State,
// qui le libère dans dispose() après fermeture du dialogue.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Valeurs saisies dans le dialogue de modification, renvoyées via pop.
class TournoiEditResult {
  final String nom;

  const TournoiEditResult({required this.nom});
}

/// Ouvre le dialogue de modification ; renvoie null si annulé.
Future<TournoiEditResult?> showTournoiEditDialog({
  required BuildContext context,
  required Tournoi tournoi,
}) {
  return showDialog<TournoiEditResult>(
    context: context,
    builder: (dialogContext) => TournoiEditDialog(tournoi: tournoi),
  );
}

/// Formulaire de modification ; le State possède et libère les contrôleurs.
class TournoiEditDialog extends StatefulWidget {
  final Tournoi tournoi;

  const TournoiEditDialog({super.key, required this.tournoi});

  @override
  State<TournoiEditDialog> createState() => _TournoiEditDialogState();
}

class _TournoiEditDialogState extends State<TournoiEditDialog> {
  late final TextEditingController _nomController =
      TextEditingController(text: widget.tournoi.nom);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(TournoiEditResult(
        nom: _nomController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Modifier le tournoi"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: "Nom du tournoi (obligatoire)",
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
