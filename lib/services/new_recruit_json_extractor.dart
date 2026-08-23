// ===========================================================================
// Extraction des joueurs du JSON retourné par l'endpoint /api/tournament
// de New Recruit. Structure attendue :
// {teams: [{name, players: [{name, lists: [{text, faction}]}]}]}.
// Logique partagée entre la méthode A (appel API) et la méthode B
// (JSON copié-collé manuellement).
// ===========================================================================

/// Décompose le JSON d'un tournoi New Recruit en une liste de joueurs
/// adverse au format `{teamName, playerName, armyName, listText}`.
List<Map<String, dynamic>> extractPlayersFromTournamentJson(
  Map<String, dynamic> parsedJson,
) {
  final List<Map<String, dynamic>> importedPlayers = [];
  final dynamic teamsBrutes = parsedJson['teams'];

  if (teamsBrutes == null || teamsBrutes is! List) {
    return importedPlayers;
  }

  for (final dynamic teamItem in teamsBrutes) {
    if (teamItem is! Map<String, dynamic>) continue;

    final String teamName = teamItem['name'] as String? ?? 'Équipe Inconnue';
    final dynamic playersList = teamItem['players'];
    if (playersList == null || playersList is! List) continue;

    for (final dynamic playerItem in playersList) {
      if (playerItem is! Map<String, dynamic>) continue;

      final String playerName = playerItem['name'] as String? ?? 'Joueur adverse';
      final dynamic lists = playerItem['lists'];

      String listText = '';
      String armyName = '';
      if (lists != null && lists is List && lists.isNotEmpty) {
        final dynamic firstList = lists.first;
        if (firstList is Map<String, dynamic>) {
          listText = firstList['text'] as String? ?? '';
          armyName = firstList['faction'] as String? ?? '';
        }
      }

      importedPlayers.add(<String, dynamic>{
        'teamName': teamName,
        'playerName': playerName,
        'armyName': armyName,
        'listText': listText,
      });
    }
  }
  return importedPlayers;
}
