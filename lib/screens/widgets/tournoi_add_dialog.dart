// ===========================================================================
// Boîte de dialogue d'ajout de Tournoi (tournoi_add_dialog.dart)
// Formulaire nom du tournoi obligatoire, piloté par le
// TournoiController de l'écran des tournois.
// ===========================================================================

import 'package:flutter/material.dart';

import '../tournois_controller.dart';

class TournoiAddDialog extends StatelessWidget {
  final TournoiController tournoiController;
  final VoidCallback onAddSubmitted;

  const TournoiAddDialog({
    super.key,
    required this.tournoiController,
    required this.onAddSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un tournoi"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: tournoiController.nomController,
            decoration: const InputDecoration(
              labelText: "Nom du tournoi (obligatoire)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: onAddSubmitted,
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}
