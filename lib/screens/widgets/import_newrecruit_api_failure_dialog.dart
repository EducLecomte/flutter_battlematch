import 'package:flutter/material.dart';

/// Affiche la boîte de dialogue explicite en cas d'échec de l'API
/// New Recruit (identifiants erronés ou compte non autorisé).
Future<void> showImportNewRecruitApiFailureDialog(
  BuildContext context,
) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Échec de l'API"),
      content: Text(
        "L'API a échoué. Cause probable : identifiants erronés ou compte non autorisé par l'admin New Recruit.\n\n"
        "Veuillez utiliser l'onglet 'Copier/Coller (Manuel)' pour importer directement sans clé API.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
