import '../models/models.dart';
import 'new_recruit_import_service.dart';
import 'pocketbase_data_service.dart';

class TournamentTextImportSummary {
  final int createdEncounterCount;
  final int createdOpponentCount;
  final int unknownArmyCount;

  const TournamentTextImportSummary({
    required this.createdEncounterCount,
    required this.createdOpponentCount,
    required this.unknownArmyCount,
  });
}

class TournamentTextImportService {
  static final TournamentTextImportService instance =
      TournamentTextImportService._internal();

  final PocketbaseDataService _pocketbaseDataService =
      PocketbaseDataService.instance;

  TournamentTextImportService._internal();

  Future<TournamentTextImportSummary> importTournamentText({
    required String tournoiId,
    required String targetTeamId,
    required String targetTeamName,
    required List<Map<String, dynamic>> importedPlayers,
    required List<Armee> referenceArmies,
  }) async {
    final Map<String, List<Map<String, dynamic>>> playersByTeamName = {};
    for (final Map<String, dynamic> importedPlayer in importedPlayers) {
      final String teamName = importedPlayer['teamName'] as String;
      playersByTeamName
          .putIfAbsent(teamName, () => <Map<String, dynamic>>[])
          .add(importedPlayer);
    }

    int createdEncounterCount = 0;
    int createdOpponentCount = 0;
    int unknownArmyCount = 0;

    for (final MapEntry<String, List<Map<String, dynamic>>> teamEntry
        in playersByTeamName.entries) {
      if (_isTargetTeam(teamEntry.key, targetTeamName)) continue;

      final Rencontre createdEncounter = await _pocketbaseDataService
          .createRencontre(tournoiId, targetTeamId, teamEntry.key);
      createdEncounterCount++;

      for (final Map<String, dynamic> importedPlayer in teamEntry.value) {
        final Armee? resolvedArmy = NewRecruitImportService.instance
            .findArmeeByName(importedPlayer['armyName'] as String,
                referenceArmies);
        if (resolvedArmy == null) {
          unknownArmyCount++;
          continue;
        }

        await _pocketbaseDataService.createOpponent(
          createdEncounter.id,
          resolvedArmy.id,
          importedPlayer['playerName'] as String,
          importedPlayer['listText'] as String,
        );
        createdOpponentCount++;
      }
    }

    return TournamentTextImportSummary(
      createdEncounterCount: createdEncounterCount,
      createdOpponentCount: createdOpponentCount,
      unknownArmyCount: unknownArmyCount,
    );
  }

  bool _isTargetTeam(String teamName, String targetTeamName) =>
      teamName.trim().toLowerCase() == targetTeamName.trim().toLowerCase();
}
