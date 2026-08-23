// ===========================================================================
// Contrôleur du tableau de bord d'équipe (team_dashboard_controller.dart)
// Détient les données de référence, les flux temps réel et les règles
// métier (rôles capitaine/joueur, appariements, estimations).
// ===========================================================================

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamDashboardController {
  final Tournoi tournoi;
  final Team team;
  final Rencontre rencontre;
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Profil de l'utilisateur actuellement connecté
  Joueur? currentUserProfile;

  // Listes de référence statiques chargées au démarrage
  List<Armee> armies = [];
  List<Choix> choiceList = [];

  // Liste des membres acceptés dans l'équipe
  List<Joueur> teamMembers = [];

  // Flux temps réel créés UNE seule fois : des streams récréés à chaque
  // rebuild forceraient des résouscriptions SSE et des refetchs en cascade.
  late final Stream<List<MetaAdv>> opponentsStream =
      _pocketbaseService.streamOpponents(rencontre.id);
  late final Stream<List<Estim>> estimsStream =
      _pocketbaseService.streamEstims(rencontre.id);
  late final Stream<List<Matched>> matchedStream =
      _pocketbaseService.streamMatched(rencontre.id);

  TeamDashboardController({
    required this.tournoi,
    required this.team,
    required this.rencontre,
  });

  // Charge le profil connecté, les armées, les choix et les membres
  // acceptés. Retourne un message d'erreur, ou null en cas de succès.
  Future<String?> loadReferenceAndTeamData() async {
    try {
      currentUserProfile =
          await _pocketbaseService.getCurrentJoueurProfile();
      armies = await _pocketbaseService.getArmees();
      choiceList = await _pocketbaseService.getChoix();

      final memberRecords =
          await _pocketbaseService.getTeamMembres(team.id);
      teamMembers = memberRecords
          .where((memberRecord) => memberRecord['statut'] == 'accepted')
          .map<Joueur>((memberRecord) => memberRecord['joueur'] as Joueur)
          .toList();
      return null;
    } catch (loadError) {
      return loadError.toString();
    }
  }

  // Ajoute un adversaire manuellement à la rencontre.
  Future<void> addOpponent(
    String opponentName,
    String armyList,
    Armee army,
  ) async {
    await _pocketbaseService.createOpponent(
      rencontre.id,
      army.id,
      opponentName,
      armyList,
    );
  }

  // Supprime un adversaire de la rencontre.
  Future<void> deleteOpponent(String opponentId) async {
    await _pocketbaseService.deleteOpponent(opponentId);
  }

  // Résout l'armée de référence d'un adversaire.
  Armee armyForOpponent(MetaAdv opponent, {String fallbackName = 'Inconnue'}) {
    return armies.firstWhere(
      (army) => army.id == opponent.armeeId,
      orElse: () => Armee(id: '', nom: fallbackName, short: '???'),
    );
  }

  // Vérifie si l'utilisateur connecté est le capitaine.
  bool isCaptain() {
    if (currentUserProfile == null) return false;
    return team.capitaineId == currentUserProfile!.id;
  }

  // Vérifie si l'utilisateur courant a le droit d'éditer l'estimation de
  // ce joueur : chaque joueur édite les siennes, le capitaine édite celles
  // de toute son équipe.
  bool canEditEstimateOf(Joueur player) {
    if (currentUserProfile == null) return false;
    if (currentUserProfile!.id == player.id) return true;
    return isCaptain();
  }

  // Verrouille/déverrouille l'appariement. Retourne false si l'appariement
  // est impossible (joueur ou adversaire déjà apparié ailleurs).
  Future<bool> toggleMatched(Joueur player, MetaAdv opponent) async {
    try {
      await _pocketbaseService.toggleMatched(
        rencontre.id,
        player.id,
        opponent.id,
      );
      return true;
    } catch (pairingError) {
      return false;
    }
  }

}
