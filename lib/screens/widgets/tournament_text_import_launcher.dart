import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'tournament_text_import_dialog.dart';

Future<bool> showTournamentTextImportDialog({
  required BuildContext context,
  required String encounterId,
  required Future<List<Armee>> Function() loadReferenceArmies,
}) async {
  final List<Armee> referenceArmies = await loadReferenceArmies();
  if (!context.mounted) return false;

  bool importCompleted = false;
  await showDialog(
    context: context,
    builder: (dialogContext) => TournamentTextImportDialog(
      encounterId: encounterId,
      referenceArmies: referenceArmies,
      onImportCompleted: () => importCompleted = true,
    ),
  );

  return importCompleted;
}
