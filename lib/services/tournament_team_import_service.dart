// ===========================================================================
// Import des équipes d'un tournoi MetaWar depuis un contenu New Recruit déjà
// parsé. Crée les équipes manquantes puis marque le tournoi comme importé.
// ===========================================================================

import '../models/models.dart';
import 'pocketbase/pocketbase_teams_service.dart';
import 'pocketbase/pocketbase_tournois_service.dart';
import 'tournament_text_import_service.dart';

class TournamentTeamImportSummary {
  final int createdTeamCount;
  final int skippedExistingTeamCount;
  final int totalTeamCount;
  final int createdOpponentCount;
  final int unknownArmyCount;

  const TournamentTeamImportSummary({
    required this.createdTeamCount,
    required this.skippedExistingTeamCount,
    required this.totalTeamCount,
    this.createdOpponentCount = 0,
    this.unknownArmyCount = 0,
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
    required List<Armee> referenceArmies,
  }) async {
    final List<Team> equipesExistantes = await _serviceTeams.getTeamsForTournoi(
      tournoiId,
    );
    final Map<String, Team> equipesParNom = {
      for (final Team equipeExistante in equipesExistantes)
        equipeExistante.nom.trim().toLowerCase(): equipeExistante,
    };

    final Map<String, List<Map<String, dynamic>>> joueursParEquipe =
        groupPlayersByTeamName(importedPlayers);
    final List<String> nomsEquipesUniques = joueursParEquipe.keys.toList();
    if (nomsEquipesUniques.isEmpty) {
      throw Exception("Aucune équipe détectée dans le contenu importé.");
    }

    int createdTeamCount = 0;
    int skippedExistingTeamCount = 0;
    int createdOpponentCount = 0;
    int unknownArmyCount = 0;

    for (final String nomEquipe in nomsEquipesUniques) {
      final String cleEquipe = nomEquipe.trim().toLowerCase();
      final Team? teamExiste = equipesParNom[cleEquipe];
      final Team equipeCible;
      if (teamExiste != null) {
        skippedExistingTeamCount++;
        equipeCible = teamExiste;
      } else {
        equipeCible = await _serviceTeams.createTeamForTournoi(
          tournoiId,
          nomEquipe,
        );
        equipesParNom[cleEquipe] = equipeCible;
        createdTeamCount++;
      }

      final TournamentTextImportSummary summary =
          await TournamentTextImportService.instance.importTournamentText(
            tournoiId: tournoiId,
            targetTeamId: equipeCible.id,
            targetTeamName: equipeCible.nom,
            importedPlayers: importedPlayers,
            referenceArmies: referenceArmies,
          );
      createdOpponentCount += summary.createdOpponentCount;
      unknownArmyCount += summary.unknownArmyCount;
    }

    await _serviceTournois.markTournoiImportEffectue(tournoiId);

    return TournamentTeamImportSummary(
      createdTeamCount: createdTeamCount,
      skippedExistingTeamCount: skippedExistingTeamCount,
      totalTeamCount: nomsEquipesUniques.length,
      createdOpponentCount: createdOpponentCount,
      unknownArmyCount: unknownArmyCount,
    );
  }

  Map<String, List<Map<String, dynamic>>> groupPlayersByTeamName(
    List<Map<String, dynamic>> importedPlayers,
  ) {
    final Map<String, List<Map<String, dynamic>>> joueursParEquipe = {};
    for (final Map<String, dynamic> importedPlayer in importedPlayers) {
      final String teamName = (importedPlayer['teamName'] as String? ?? '')
          .trim();
      if (teamName.isEmpty) continue;
      joueursParEquipe
          .putIfAbsent(teamName, () => <Map<String, dynamic>>[])
          .add(importedPlayer);
    }
    return joueursParEquipe;
  }
}
