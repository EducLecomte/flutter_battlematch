// ===========================================================================
// Opérations d'import des équipes d'un tournoi (tournoi_team_import_actions.dart)
// Charge les armées de référence, ouvre le dialogue d'import, affiche le
// résumé en SnackBar puis délègue le rechargement via [onImportCompleted].
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../services/tournament_team_import_service.dart';
import 'widgets/tournoi_team_import_dialog.dart';

/// Ouvre le dialogue d'import des équipes d'un tournoi et affiche le résumé.
Future<void> showTournoiTeamImportDialog({
  required BuildContext context,
  required Tournoi tournoi,
  required Future<void> Function() onImportCompleted,
}) async {
  final List<Armee> referenceArmies = await PocketbaseDataService.instance
      .getArmees();
  if (!context.mounted) return;

  TournamentTeamImportSummary? importSummary;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => TournoiTeamImportDialog(
      tournoiId: tournoi.id,
      tournoiNom: tournoi.nom,
      referenceArmies: referenceArmies,
      onImportCompleted: (summary) => importSummary = summary,
    ),
  );
  if (!context.mounted) return;

  final TournamentTeamImportSummary? completedImportSummary = importSummary;
  if (completedImportSummary == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Import terminé : ${completedImportSummary.createdTeamCount} "
        "équipe(s) créée(s), "
        "${completedImportSummary.createdOpponentCount} liste(s) adverse(s) ajoutée(s), "
        "${completedImportSummary.skippedExistingTeamCount} équipe(s) ignorée(s).",
      ),
      backgroundColor: Colors.green,
      duration: snackBarDisplayDuration,
    ),
  );
  await onImportCompleted();
}
