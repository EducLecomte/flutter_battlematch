import 'package:flutter/material.dart';

Future<void> showTeamManagementCreateTeamDialog({
  required BuildContext dialogContext,
  required TextEditingController teamNameController,
  required VoidCallback onCreateTeamPressed,
}) {
  return showDialog<void>(
    context: dialogContext,
    builder: (context) {
      return AlertDialog(
        title: const Text("Créer une équipe"),
        content: TextFormField(
          controller: teamNameController,
          decoration: const InputDecoration(
            labelText: "Nom de l'équipe",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: onCreateTeamPressed,
            child: const Text("Créer"),
          ),
        ],
      );
    },
  );
}
