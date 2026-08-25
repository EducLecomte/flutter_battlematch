import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/tournament_text_import_service.dart';
import 'tournament_text_import_dialog.dart';

Future<TournamentTextImportSummary?> showTournamentTextImportDialog({
  required BuildContext context,
  required String tournoiId,
  required String targetTeamId,
  required String targetTeamName,
  required Future<List<Armee>> Function() loadReferenceArmies,
}) async {
  final List<Armee> referenceArmies = await loadReferenceArmies();
  if (!context.mounted) return null;

  TournamentTextImportSummary? importSummary;
  await showDialog(
    context: context,
    builder: (dialogContext) => TournamentTextImportDialog(
      tournoiId: tournoiId,
      targetTeamId: targetTeamId,
      targetTeamName: targetTeamName,
      referenceArmies: referenceArmies,
      onImportCompleted: (summary) => importSummary = summary,
    ),
  );

  return importSummary;
}
