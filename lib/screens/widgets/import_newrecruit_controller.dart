// ===========================================================================
// Contrôleur du dialogue d'importation New Recruit
// (import_newrecruit_controller.dart)
// Détient l'état d'import (équipes détectées, chargement) et pilote les
// flux d'import API / manuel et l'insertion PocketBase finale.
// ===========================================================================

import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../../services/new_recruit_import_service.dart';
import '../../services/pocketbase_data_service.dart';

// Erreur dédiée : échec de l'appel à l'API New Recruit (identifiants ou
// autorisation). Le dialogue affiche alors un message explicite.
class ImportNewRecruitApiImportError implements Exception {
  const ImportNewRecruitApiImportError();
}

class ImportNewRecruitController {
  final NewRecruitImportService _importService =
      NewRecruitImportService.instance;
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Liste des joueurs importés (regroupés par équipe)
  List<Map<String, dynamic>> importedPlayers = [];

  // Équipes distinctes trouvées dans l'import
  List<String> detectedTeams = [];

  // Équipe actuellement sélectionnée pour l'import final
  String? selectedTeamToImport;

  // États de chargement
  bool isLoading = false;
  String statusText = '';

  // Joueurs appartenant à l'équipe sélectionnée
  List<Map<String, dynamic>> playersOfSelectedTeam() {
    final selectedTeam = selectedTeamToImport;
    if (selectedTeam == null) return const [];
    return importedPlayers
        .where((player) => player['teamName'] == selectedTeam)
        .toList();
  }

  // Traite la liste brute importée pour regrouper les équipes.
  // Retourne false si aucun joueur n'a été détecté.
  bool processImportedList(List<Map<String, dynamic>> players) {
    if (players.isEmpty) return false;

    // Extraire les noms d'équipes uniques
    final teams = players
        .map<String>((player) => player['teamName'] as String)
        .toSet()
        .toList();
    teams.sort();

    importedPlayers = players;
    detectedTeams = teams;
    if (teams.isNotEmpty) {
      selectedTeamToImport = teams.first;
    }
    return true;
  }

  // Retourne au mode d'import initial (étape 1)
  void resetToStepOne() {
    detectedTeams = [];
    importedPlayers = [];
    selectedTeamToImport = null;
  }

  // Lance l'importation automatique via l'API.
  // Retourne null en succès, un message d'erreur, ou
  // ImportNewRecruitApiImportError en cas d'échec de l'API.
  Future<Object?> runApiImport({
    required String tournamentId,
    required String login,
    required String password,
    required VoidCallback onStateChanged,
  }) async {
    if (tournamentId.isEmpty || login.isEmpty || password.isEmpty) {
      return "Veuillez renseigner tous les champs d'API";
    }

    isLoading = true;
    statusText = "Appel de l'API New Recruit...";
    onStateChanged();

    try {
      // Appel direct de l'API New Recruit depuis le navigateur
      final players = await _importService
          .fetchTournamentPlayersFromNewRecruitApi(
            tournamentId: tournamentId,
            login: login,
            password: password,
          );

      if (!processImportedList(players)) {
        return "Aucun joueur ou équipe détecté dans le contenu fourni";
      }
      return null;
    } catch (importError) {
      statusText = '';
      return const ImportNewRecruitApiImportError();
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Lance l'importation via le copier-coller manuel (JSON ou Texte).
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> runManualImport({
    required String content,
    required List<Armee> armeesReference,
    required VoidCallback onStateChanged,
  }) async {
    if (content.isEmpty) return null;

    isLoading = true;
    statusText = "Analyse et traitement du contenu collé...";
    onStateChanged();

    try {
      final players =
          _importService.parseNewRecruitContent(content, armeesReference);
      if (!processImportedList(players)) {
        return "Aucun joueur ou équipe détecté dans le contenu fourni";
      }
      return null;
    } catch (importError) {
      return "Erreur de traitement : ${importError.toString()}";
    } finally {
      isLoading = false;
      statusText = '';
      onStateChanged();
    }
  }

  // Valide l'importation finale de l'équipe sélectionnée.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> confirmImport({
    required String rencontreId,
    required List<Armee> armeesReference,
    required VoidCallback onImportCompleted,
    required VoidCallback onStateChanged,
  }) async {
    if (selectedTeamToImport == null || importedPlayers.isEmpty) return null;

    isLoading = true;
    statusText = "Insertion des adversaires dans PocketBase...";
    onStateChanged();

    int importedPlayerCount = 0;

    try {
      for (final player in playersOfSelectedTeam()) {
        // Résolution de l'armée par le nom fourni par New Recruit
        final Armee? armeeResolue = _importService.findArmeeByName(
          player['armyName'] as String,
          armeesReference,
        );

        if (armeeResolue == null) {
          // Aucune correspondance dans le référentiel : joueur ignoré et signalé
          debugPrint(
            "Armée non reconnue pour ${player['playerName']} "
            "(${player['armyName']}) : insertion ignorée.",
          );
          continue;
        }

        await _pocketbaseService.createOpponent(
          rencontreId,
          armeeResolue.id,
          player['playerName'] as String,
          player['listText'] as String,
        );
        importedPlayerCount += 1;
      }

      if (importedPlayerCount == 0) {
        return 'Aucune liste importée : toutes les armées sont inconnues.';
      }

      onImportCompleted();
      return null;
    } catch (recordError) {
      return "Erreur d'enregistrement : ${recordError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }
}
