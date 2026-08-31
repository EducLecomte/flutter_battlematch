import '../models/models.dart';
import 'new_recruit_import_service.dart';
import 'pocketbase_data_service.dart';

class TournamentTextImportSummary {
  final int createdOpponentTeamCount;
  final int createdOpponentCount;
  final int unknownArmyCount;
  final int skippedDuplicateTeamCount;

  const TournamentTextImportSummary({
    required this.createdOpponentTeamCount,
    required this.createdOpponentCount,
    required this.unknownArmyCount,
    required this.skippedDuplicateTeamCount,
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
    final Map<String, List<Map<String, dynamic>>> playersByTeamName =
        _groupPlayersByTeamName(importedPlayers);
    final Map<String, Team> teamsByNormalizedName = {
      for (final Team team
          in await _pocketbaseDataService.getTeamsForTournoi(tournoiId))
        team.nom.trim().toLowerCase(): team,
    };

    int createdOpponentTeamCount = 0;
    int createdOpponentCount = 0;
    int unknownArmyCount = 0;
    int skippedDuplicateTeamCount = 0;

    for (final MapEntry<String, List<Map<String, dynamic>>> teamEntry
        in playersByTeamName.entries) {
      if (_isTargetTeam(teamEntry.key, targetTeamName)) continue;

      final String opponentTeamName = teamEntry.key.trim();
      final String normalizedName = opponentTeamName.toLowerCase();
      Team opponentTeam = teamsByNormalizedName[normalizedName] ??
          await _pocketbaseDataService.createTeamForTournoi(
            tournoiId,
            opponentTeamName,
          );
      if (teamsByNormalizedName[normalizedName] == null) {
        teamsByNormalizedName[normalizedName] = opponentTeam;
        createdOpponentTeamCount++;
      }

      final List<MetaAdv> existingOpponents =
          await _pocketbaseDataService.getOpponents(
        targetTeamId,
        opponentTeam.id,
      );
      if (existingOpponents.isNotEmpty) {
        skippedDuplicateTeamCount++;
        continue;
      }

      for (final Map<String, dynamic> importedPlayer in teamEntry.value) {
        final Armee? resolvedArmy = NewRecruitImportService.instance
            .findArmeeByName(importedPlayer['armyName'] as String,
                referenceArmies);
        if (resolvedArmy == null) {
          unknownArmyCount++;
          continue;
        }

        await _pocketbaseDataService.createOpponent(
          targetTeamId,
          opponentTeam.id,
          resolvedArmy.id,
          importedPlayer['playerName'] as String,
          importedPlayer['listText'] as String,
        );
        createdOpponentCount++;
      }
    }

    return TournamentTextImportSummary(
      createdOpponentTeamCount: createdOpponentTeamCount,
      createdOpponentCount: createdOpponentCount,
      unknownArmyCount: unknownArmyCount,
      skippedDuplicateTeamCount: skippedDuplicateTeamCount,
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupPlayersByTeamName(
    List<Map<String, dynamic>> importedPlayers,
  ) {
    final Map<String, List<Map<String, dynamic>>> playersByTeamName = {};
    for (final Map<String, dynamic> importedPlayer in importedPlayers) {
      final String teamName = (importedPlayer['teamName'] as String? ?? '')
          .trim();
      if (teamName.isEmpty) continue;
      playersByTeamName
          .putIfAbsent(teamName, () => <Map<String, dynamic>>[])
          .add(importedPlayer);
    }
    return playersByTeamName;
  }

  bool _isTargetTeam(String teamName, String targetTeamName) =>
      teamName.trim().toLowerCase() == targetTeamName.trim().toLowerCase();
}
