// ===========================================================================
// Méthode A : appel direct de l'API New Recruit depuis le navigateur
// (authentification basique, sous réserve des autorisations CORS du serveur).
// ===========================================================================

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'new_recruit_json_extractor.dart';

class NewRecruitApiClient {
  /// URL racine de l'API publique New Recruit.
  static const String newRecruitApiBaseUrl = 'https://newrecruit.eu';

  /// Chemin de l'endpoint retournant les données d'un tournoi d'équipe.
  static const String newRecruitTournamentEndpointPath = '/api/tournament';

  /// Timeout appliqué aux appels HTTP vers New Recruit.
  static const Duration delaiMaximumAppelApi = Duration(seconds: 30);

  /// Appelle directement l'API New Recruit avec les identifiants fournis et
  /// retourne la liste structurée des joueurs adverse de tout le tournoi.
  ///
  /// Lance une exception en cas d'échec réseau, CORS ou authentification :
  /// l'appelant propose alors la méthode B (copier/coller manuel).
  Future<List<Map<String, dynamic>>> fetchTournamentPlayers({
    required String tournamentId,
    required String login,
    required String password,
  }) async {
    final Uri uriTournoi = Uri.parse(
      '$newRecruitApiBaseUrl$newRecruitTournamentEndpointPath/$tournamentId',
    );

    final String credentialsBase64 =
        base64Encode(utf8.encode('$login:$password'));

    final http.Response reponse = await http.get(
      uriTournoi,
      headers: <String, String>{
        'Authorization': 'Basic $credentialsBase64',
        'Accept': 'application/json',
      },
    ).timeout(delaiMaximumAppelApi);

    if (reponse.statusCode != 200) {
      throw Exception(
        "L'API New Recruit a répondu ${reponse.statusCode} "
        '(identifiants invalides ou tournoi inaccessible).',
      );
    }

    final dynamic contenuDecode = jsonDecode(reponse.body);
    if (contenuDecode is! Map<String, dynamic>) {
      throw Exception('Format de réponse inattendu de l\'API New Recruit.');
    }

    return extractPlayersFromTournamentJson(contenuDecode);
  }
}
