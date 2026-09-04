import '../models/models.dart';
import 'new_recruit_import_service.dart';
import 'pocketbase_data_service.dart';

/// Résumé de l'import de la méta d'une équipe (lignes `team_meta`).
class TournamentTextImportSummary {
  final int createdTeamMetaCount;
  final int updatedTeamMetaCount;
  final int unknownArmyCount;

  const TournamentTextImportSummary({
    required this.createdTeamMetaCount,
    required this.updatedTeamMetaCount,
    required this.unknownArmyCount,
  });
}

/// Import de la méta des joueurs d'une équipe depuis un contenu New Recruit
/// déjà parsé. Crée ou met à jour une seule ligne `team_meta` par joueur,
/// de façon idempotente par `(team_id, nom_jo)`.
class TournamentTextImportService {
  static final TournamentTextImportService instance =
      TournamentTextImportService._internal();

  final PocketbaseDataService _pocketbaseDataService =
      PocketbaseDataService.instance;

  TournamentTextImportService._internal();

  Future<TournamentTextImportSummary> importTeamMeta({
    required Team team,
    required List<Map<String, dynamic>> players,
    required List<Armee> referenceArmies,
  }) async {
    final List<TeamMeta> metasExistantes =
        await _pocketbaseDataService.getTeamMeta(team.id);
    final Map<String, TeamMeta> metasParNomJo = {
      for (final TeamMeta meta in metasExistantes)
        meta.nomJo.trim().toLowerCase(): meta,
    };

    int createdTeamMetaCount = 0;
    int updatedTeamMetaCount = 0;
    int unknownArmyCount = 0;

    for (final Map<String, dynamic> importedPlayer in players) {
      final String nomJo = (importedPlayer['playerName'] as String? ?? '').trim();
      if (nomJo.isEmpty) continue;

      final Armee? resolvedArmy = NewRecruitImportService.instance
          .findArmeeByName(importedPlayer['armyName'] as String,
              referenceArmies);
      if (resolvedArmy == null) {
        unknownArmyCount++;
        continue;
      }

      final String listeJo = importedPlayer['listText'] as String;
      final TeamMeta? metaExistante =
          metasParNomJo[nomJo.trim().toLowerCase()];
      if (metaExistante == null) {
        await _pocketbaseDataService.createTeamMeta(
          team.id,
          resolvedArmy.id,
          nomJo,
          listeJo,
        );
        createdTeamMetaCount++;
      } else {
        await _pocketbaseDataService.updateTeamMeta(
          metaExistante.id,
          armeeId: resolvedArmy.id,
          nomJo: nomJo,
          listeJo: listeJo,
        );
        updatedTeamMetaCount++;
      }
    }

    return TournamentTextImportSummary(
      createdTeamMetaCount: createdTeamMetaCount,
      updatedTeamMetaCount: updatedTeamMetaCount,
      unknownArmyCount: unknownArmyCount,
    );
  }
}
