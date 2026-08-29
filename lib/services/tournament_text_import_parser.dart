import '../models/models.dart';
import 'new_recruit_import_service.dart';

/// Analyse un texte de tournoi au format New Recruit ou standard T9A :
/// bloc équipe, bloc joueur (Nom - Armée), lignes d'unités, ligne total.
class TournamentTextImportParser {
  const TournamentTextImportParser();

  List<Map<String, dynamic>> parseTournamentText(
    String rawContent,
    List<Armee> referenceArmies,
  ) {
    final String trimmed = rawContent.trim();
    if (trimmed.isEmpty) return [];

    final rawBlocks = trimmed.split(RegExp(r'\n\s*\n+'));
    final List<String> blocks = rawBlocks
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final List<Map<String, dynamic>> importedPlayers = [];
    String currentTeamName = '';

    for (final String block in blocks) {
      final List<String> lines = block
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;

      // Détecte si le bloc contient des lignes d'unités d'armée (ex: "785 - Necromancer...")
      final bool hasUnitLines =
          lines.any((l) => RegExp(r'^\d+\s*-\s*.+').hasMatch(l));

      if (!hasUnitLines) {
        // C'est un bloc d'en-tête d'équipe
        currentTeamName = lines.join(' ').trim();
        continue;
      }

      // Bloc de liste d'armée : séparation des en-têtes et des unités
      final List<String> headerLines = [];
      final List<String> listLines = [];
      bool inUnitList = false;

      for (final String line in lines) {
        if (!inUnitList && RegExp(r'^\d+\s*-\s*.+').hasMatch(line)) {
          inUnitList = true;
        }
        if (inUnitList) {
          listLines.add(line);
        } else {
          headerLines.add(line);
        }
      }

      String playerName = '';
      String armyNameCandidate = '';

      if (headerLines.length == 1) {
        final String header = headerLines.first;
        final Iterable<RegExpMatch> dashMatches =
            RegExp(r'\s+[-–—]\s+').allMatches(header);

        if (dashMatches.isNotEmpty) {
          final RegExpMatch lastMatch = dashMatches.last;
          final String left = header.substring(0, lastMatch.start).trim();
          final String right = header.substring(lastMatch.end).trim();

          final Armee? matchedArmy = NewRecruitImportService.instance
              .findArmeeByName(right, referenceArmies);

          if (matchedArmy != null) {
            armyNameCandidate = matchedArmy.nom;
            // Vérifie si la partie gauche contient "Équipe - Joueur"
            final Iterable<RegExpMatch> subDashes =
                RegExp(r'\s+[-–—]\s+').allMatches(left);
            if (subDashes.isNotEmpty) {
              final RegExpMatch firstMatch = subDashes.first;
              final String teamPart =
                  left.substring(0, firstMatch.start).trim();
              final String playerPart =
                  left.substring(firstMatch.end).trim();
              if (currentTeamName.isEmpty) currentTeamName = teamPart;
              playerName = playerPart;
            } else {
              playerName = left;
            }
          } else {
            playerName = left;
            armyNameCandidate = right;
          }
        } else {
          playerName = header;
        }
      } else if (headerLines.length >= 2) {
        final String line1 = headerLines[0];
        final String line2 = headerLines[1];

        final Armee? armyLine2 = NewRecruitImportService.instance
            .findArmeeByName(line2, referenceArmies);
        final Armee? armyLine1 = NewRecruitImportService.instance
            .findArmeeByName(line1, referenceArmies);

        if (armyLine2 != null) {
          armyNameCandidate = armyLine2.nom;
          final Iterable<RegExpMatch> subDashes =
              RegExp(r'\s+[-–—]\s+').allMatches(line1);
          if (subDashes.isNotEmpty) {
            final RegExpMatch lastDash = subDashes.last;
            final String teamPart =
                line1.substring(0, lastDash.start).trim();
            final String playerPart =
                line1.substring(lastDash.end).trim();
            if (currentTeamName.isEmpty ||
                currentTeamName.toLowerCase() == teamPart.toLowerCase()) {
              currentTeamName = teamPart;
            }
            playerName = playerPart;
          } else if (line1.contains('/')) {
            final List<String> parts = line1.split('/');
            if (currentTeamName.isEmpty) currentTeamName = parts[0].trim();
            playerName = parts.length > 1 ? parts[1].trim() : line1;
          } else {
            playerName = line1;
          }
        } else if (armyLine1 != null) {
          armyNameCandidate = armyLine1.nom;
          playerName = line2;
        } else {
          final RegExpMatch? dashMatchLine2 =
              RegExp(r'\s+[-–—]\s+').firstMatch(line2);
          final RegExpMatch? dashMatchLine1 =
              RegExp(r'\s+[-–—]\s+').firstMatch(line1);

          if (dashMatchLine2 != null) {
            currentTeamName = line1;
            playerName = line2.substring(0, dashMatchLine2.start).trim();
            armyNameCandidate = line2.substring(dashMatchLine2.end).trim();
          } else if (dashMatchLine1 != null) {
            playerName = line1.substring(0, dashMatchLine1.start).trim();
            armyNameCandidate = line1.substring(dashMatchLine1.end).trim();
          } else {
            playerName = line1;
            armyNameCandidate = line2;
          }
        }
      }

      if (playerName.isEmpty) {
        playerName = 'Joueur inconnu';
      }

      final Armee? resolvedArmy = NewRecruitImportService.instance
          .findArmeeByName(armyNameCandidate, referenceArmies);

      importedPlayers.add(<String, dynamic>{
        'teamName':
            currentTeamName.isEmpty ? 'Équipe Importée' : currentTeamName,
        'playerName': playerName,
        'armyName': resolvedArmy?.nom ?? armyNameCandidate,
        'listText': listLines.join('\n'),
      });
    }

    return importedPlayers;
  }
}
