import 'package:flutter/material.dart';

Future<bool> showProfileDeleteAccountConfirmation(
  BuildContext buildContext,
) {
  return showDialog<bool>(
    context: buildContext,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Supprimer votre compte ?'),
      content: const Text(
        'Cette action est définitive. Votre compte, vos tournois et vos '
        'équipes en tant que capitaine seront supprimés.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text(
            'Supprimer définitivement',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  ).then((confirmationResult) => confirmationResult ?? false);
}
