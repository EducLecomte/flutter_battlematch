// ===========================================================================
// Import des équipes d'un tournoi MetaWar depuis un contenu New Recruit déjà
// parsé. Crée les équipes manquantes puis marque le tournoi comme importé.
// ===========================================================================

import '../models/models.dart';
import 'pocketbase/pocketbase_teams_service.dart';
import 'pocketbase/pocketbase_tournois_service.dart';

class TournamentTeamImportSummary {
  final int createdTeamCount;
  final int skippedExistingTeamCount;
  final int totalTeamCount;

  const TournamentTeamImportSummary({
    required this.createdTeamCount,
    required this.skippedExistingTeamCount,
    required this.totalTeamCount,
  });
}

class TournamentTeamImportService {
  static final TournamentTeamImportService instance =
      TournamentTeamImportService._internal();

  TournamentTeamImportService._internal();

  final PocketbaseTeamsService _serviceTeams = PocketbaseTeamsService.instance;

  final PocketbaseTournoisService _serviceTournois =
      PocketbaseTournoisService.instance;

  /// Crée les équipes manquantes d'un tournoi puis marque l'import effectué.
  Future<TournamentTeamImportSummary> importTeamsForTournoi({
    required String tournoiId,
    required List<Map<String, dynamic>> importedPlayers,
  }) async {
    final List<Team> equipesExistantes =
        await _serviceTeams.getTeamsForTournoi(tournoiId);
    final Set<String> clefsEquipesExistantes = {
      for (final Team equipeExistante in equipesExistantes)
        equipeExistante.nom.trim().toLowerCase(),
    };

    final List<String> nomsEquipesUniques =
        _extraireNomsEquipesUniques(importedPlayers);
    if (nomsEquipesUniques.isEmpty) {
      throw Exception("Aucune équipe détectée dans le contenu importé.");
    }

    int createdTeamCount = 0;
    int skippedExistingTeamCount = 0;

    for (final String nomEquipe in nomsEquipesUniques) {
      final String cleEquipe = nomEquipe.toLowerCase();
      if (clefsEquipesExistantes.contains(cleEquipe)) {
        skippedExistingTeamCount++;
        continue;
      }
      await _serviceTeams.createTeamForTournoi(tournoiId, nomEquipe);
      clefsEquipesExistantes.add(cleEquipe);
      createdTeamCount++;
    }

    await _serviceTournois.markTournoiImportEffectue(tournoiId);

    return TournamentTeamImportSummary(
      createdTeamCount: createdTeamCount,
      skippedExistingTeamCount: skippedExistingTeamCount,
      totalTeamCount: nomsEquipesUniques.length,
    );
  }

  List<String> _extraireNomsEquipesUniques(
    List<Map<String, dynamic>> importedPlayers,
  ) {
    final List<String> nomsEquipesUniques = [];
    final Set<String> clefsEquipes = {};

    for (final Map<String, dynamic> importedPlayer in importedPlayers) {
      final String nomEquipe =
          (importedPlayer['teamName'] as String? ?? '').trim();
      if (nomEquipe.isEmpty) continue;

      final String cleEquipe = nomEquipe.toLowerCase();
      if (clefsEquipes.add(cleEquipe)) {
        nomsEquipesUniques.add(nomEquipe);
      }
    }

    return nomsEquipesUniques;
  }
}
