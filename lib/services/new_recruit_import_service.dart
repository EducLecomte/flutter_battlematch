// ===========================================================================
// Service d'importation des listes adverses depuis New Recruit.
// Méthode A : appel direct de l'API New Recruit (délégation au
// NewRecruitApiClient, sous réserve des autorisations CORS du serveur).
// Méthode B (fallback) : parsing local d'un contenu JSON ou textuel collé
// manuellement depuis l'interface New Recruit.
// ===========================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import 'new_recruit_api_client.dart';
import 'new_recruit_armee_name_matcher.dart';
import 'new_recruit_json_extractor.dart';
import 'tournament_text_import_parser.dart';

class NewRecruitImportService {
  // Instance singleton pour un accès global facile
  static final NewRecruitImportService instance =
      NewRecruitImportService._internal();

  NewRecruitImportService._internal();

  final NewRecruitApiClient _apiClient = NewRecruitApiClient();

  // =========================================================================
  // MÉTHODE A : IMPORTATION AUTOMATIQUE VIA L'API NEW RECRUIT
  // =========================================================================

  /// Appelle directement l'API New Recruit avec les identifiants fournis et
  /// retourne la liste structurée des joueurs adverse de tout le tournoi.
  ///
  /// Lance une exception en cas d'échec réseau, CORS ou authentification :
  /// l'appelant propose alors la méthode B (copier/coller manuel).
  Future<List<Map<String, dynamic>>> fetchTournamentPlayersFromNewRecruitApi({
    required String tournamentId,
    required String login,
    required String password,
  }) {
    return _apiClient.fetchTournamentPlayers(
      tournamentId: tournamentId,
      login: login,
      password: password,
    );
  }

  // =========================================================================
  // MÉTHODE B : PARSING LOCAL (JSON COLLÉ OU TEXTE BRUT)
  // =========================================================================

  /// Analyse un contenu collé manuellement : JSON copié depuis l'API
  /// New Recruit, ou texte brut au format classique des tournois d'équipe.
  List<Map<String, dynamic>> parseNewRecruitContent(
    String rawContent,
    List<Armee> referenceArmies,
  ) {
    final String trimmedContent = rawContent.trim();
    if (trimmedContent.isEmpty) return [];

    // --- Cas 1 : c'est un JSON copié-collé ---
    if (trimmedContent.startsWith('{')) {
      try {
        final dynamic parsedJson = jsonDecode(trimmedContent);
        if (parsedJson is Map<String, dynamic>) {
          return extractPlayersFromTournamentJson(parsedJson);
        }
      } catch (jsonParsingException) {
        debugPrint('Contenu non parsable en JSON, tentative textuelle : '
            '$jsonParsingException');
      }
    }

    return const TournamentTextImportParser().parseTournamentText(
      trimmedContent,
      referenceArmies,
    );
  }

  // =========================================================================
  // CORRESPONDANCE AVEC LE RÉFÉRENTIEL D'ARMÉES
  // =========================================================================

  /// Recherche l'armée correspondante dans le référentiel par nom approché
  /// ou intitulé court. Retourne null si aucune correspondance trouvée.
  Armee? findArmeeByName(String armyName, List<Armee> referenceArmies) {
    return matchArmeeInReference(armyName, referenceArmies);
  }
}
