import 'package:flutter/material.dart';

Future<bool> showDeleteEncounterConfirmation(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Supprimer cette rencontre ?"),
      content: const Text(
        "Toutes les estimations et appariements de ce match seront effacés.",
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

  return confirmed == true;
}
