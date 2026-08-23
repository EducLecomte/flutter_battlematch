import '../models/models.dart';
import 'new_recruit_import_service.dart';

/// Analyse un texte de tournoi au format :
/// ligne équipe, ligne joueur (Nom - Armée), lignes d'unités, ligne total.
class TournamentTextImportParser {
  const TournamentTextImportParser();

  List<Map<String, dynamic>> parseTournamentText(
    String rawContent,
    List<Armee> referenceArmies,
  ) {
    final List<Map<String, dynamic>> importedPlayers = [];
    String currentTeamName = '';
    String pendingPlayerName = '';
    String currentPlayerName = '';
    String currentArmyName = '';
    final List<String> currentListLines = [];
    bool hasActivePlayer = false;

    void finalizePlayer() {
      if (hasActivePlayer && currentPlayerName.isNotEmpty) {
        final Armee? mappedArmy = NewRecruitImportService.instance
            .findArmeeByName(currentArmyName, referenceArmies);

        importedPlayers.add(<String, dynamic>{
          'teamName':
              currentTeamName.isEmpty ? 'Équipe Importée' : currentTeamName,
          'playerName': currentPlayerName,
          'armyName': mappedArmy?.nom ?? currentArmyName,
          'listText': currentListLines.join('\n'),
        });
      }

      currentPlayerName = '';
      currentArmyName = '';
      currentListLines.clear();
      hasActivePlayer = false;
    }

    for (final String rawLine in rawContent.split('\n')) {
      final String line = rawLine.trim();

      if (line.isEmpty) {
        finalizePlayer();
        pendingPlayerName = '';
        continue;
      }

      if (_isTotalLine(line)) {
        if (hasActivePlayer) currentListLines.add(line);
        continue;
      }

      if (!hasActivePlayer) {
        if (_isListLine(line)) {
          hasActivePlayer = true;
          currentListLines.add(line);
          continue;
        }

        final (String? leftPart, String? rightPart) = _splitDash(line);

        if (leftPart != null && rightPart != null) {
          if (_isPlayerDashLine(leftPart, rightPart, referenceArmies)) {
            currentPlayerName = leftPart;
            currentArmyName = rightPart;
            hasActivePlayer = true;
          } else {
            currentTeamName = leftPart;
            pendingPlayerName = rightPart;
            currentPlayerName = rightPart;
          }
        } else if (pendingPlayerName.isNotEmpty) {
          currentArmyName = line;
          hasActivePlayer = true;
        } else {
          currentTeamName = line;
        }
      } else {
        currentListLines.add(line);
      }
    }

    finalizePlayer();
    return importedPlayers;
  }

  bool _isTotalLine(String line) => RegExp(r'^\d{1,4}$').hasMatch(line);

  bool _isListLine(String line) => RegExp(r'^\d+\s*-\s*.+').hasMatch(line);

  (String?, String?) _splitDash(String line) {
    final RegExpMatch? match =
        RegExp(r'^\s*(.+?)\s+[-–—]\s+(.+?)\s*$').firstMatch(line);
    if (match == null) return (null, null);
    return (match.group(1)!.trim(), match.group(2)!.trim());
  }

  bool _isPlayerDashLine(
    String leftPart,
    String rightPart,
    List<Armee> referenceArmies,
  ) {
    if (rightPart.contains('/')) return false;
    if (leftPart.contains('(')) return true;
    return _isArmy(rightPart, referenceArmies);
  }

  bool _isArmy(String candidateArmyName, List<Armee> referenceArmies) =>
      NewRecruitImportService.instance
              .findArmeeByName(candidateArmyName, referenceArmies) !=
          null;
}
