// ===========================================================================
// Contrôleur de la gestion d'équipe (team_management_controller.dart)
// Détient l'état courant : équipes, sélection, membres, profil et recherche.
// ===========================================================================

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamManagementController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Liste des équipes associées à l'utilisateur
  List<Team> teams = [];

  // Équipe actuellement sélectionnée pour affichage/gestion
  Team? selectedTeam;

  // Liste des membres de l'équipe sélectionnée
  List<Map<String, dynamic>> members = [];

  // Profil du joueur actuellement connecté
  Joueur? currentUserProfile;

  // Résultats de la recherche de joueurs à inviter
  List<Joueur> searchResults = [];

  // Indique si une recherche de joueurs est en cours
  bool isSearching = false;

  // Rencontres de l'équipe sélectionnée
  List<Rencontre> encounters = [];

  // Adversaires par rencontre
  Map<String, List<MetaAdv>> opponentsByEncounter = {};

  // Appariements par rencontre
  Map<String, List<Matched>> matchedByEncounter = {};

  // Charge le profil du joueur connecté et ses équipes.
  Future<String?> loadInitialData() async {
    try {
      final profile = await _pocketbaseService.getCurrentJoueurProfile();
      if (profile != null) {
        currentUserProfile = profile;
        final list = await _pocketbaseService.getTeamsForUser(profile.id);
        teams = list;
        selectedTeam = list.isEmpty ? null : list.first;
        await loadMembersForSelectedTeam();
        await loadEncountersForSelectedTeam();
      }
      return null;
    } catch (loadError) {
      return loadError.toString();
    }
  }

  // Charge les rencontres, adversaires et appariements de l'équipe sélectionnée.
  Future<String?> loadEncountersForSelectedTeam() async {
    final selectedTeam = this.selectedTeam;
    if (selectedTeam == null) return null;
    try {
      encounters = await _pocketbaseService.getRencontres(
        selectedTeam.tournoiId,
        selectedTeam.id,
      );
      opponentsByEncounter = {};
      matchedByEncounter = {};
      for (final encounter in encounters) {
        final opponents = await _pocketbaseService.getOpponents(encounter.id);
        opponentsByEncounter[encounter.id] = opponents;
        final matched = await _pocketbaseService.getMatched(encounter.id);
        matchedByEncounter[encounter.id] = matched;
      }
      return null;
    } catch (encountersError) {
      return encountersError.toString();
    }
  }

  // Charge les membres de l'équipe sélectionnée.
  Future<String?> loadMembersForSelectedTeam() async {
    final selectedTeamId = selectedTeam?.id;
    if (selectedTeamId == null) return null;
    try {
      members = await _pocketbaseService.getTeamMembres(selectedTeamId);
      return null;
    } catch (membersError) {
      return membersError.toString();
    }
  }

  // Recherche des joueurs à inviter, en excluant les membres actuels.
  Future<void> searchPlayers(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      return;
    }

    isSearching = true;
    try {
      final results = await _pocketbaseService.searchJoueurs(query);
      searchResults = results
          .where((player) =>
              !members.any((member) =>
                  (member['joueur'] as Joueur).id == player.id))
          .toList();
    } catch (_) {
      // Recherche sans résultat : on ignore l'erreur réseau.
    } finally {
      isSearching = false;
    }
  }

  // Envoie une invitation au joueur donné.
  Future<String?> sendInvite(String playerId) async {
    final selectedTeamId = selectedTeam?.id;
    if (selectedTeamId == null) return null;
    try {
      await _pocketbaseService.inviteJoueurToTeam(selectedTeamId, playerId);
      searchResults = [];
      await loadMembersForSelectedTeam();
      return null;
    } catch (inviteError) {
      return inviteError.toString();
    }
  }

  // Bascule l'appariement joueur ↔ adversaire pour une rencontre.
  // Retourne false si l'appariement est impossible (contrainte unique).
  Future<bool> toggleMatched(
    Rencontre encounter,
    Joueur player,
    MetaAdv opponent,
  ) async {
    try {
      await _pocketbaseService.toggleMatched(
        encounter.id,
        player.id,
        opponent.id,
      );
      // Recharge les appariements pour cette rencontre.
      final updatedMatched =
          await _pocketbaseService.getMatched(encounter.id);
      matchedByEncounter[encounter.id] = updatedMatched;
      return true;
    } catch (pairingError) {
      return false;
    }
  }

  // Vérifie si l'utilisateur connecté est capitaine de l'équipe sélectionnée.
  bool isCaptain() {
    if (selectedTeam == null || currentUserProfile == null) return false;
    return selectedTeam!.capitaineId == currentUserProfile!.id;
  }

  // Vérifie si l'utilisateur courant peut retirer ce membre.
  bool canRemoveMember(Map<String, dynamic> member) {
    if (currentUserProfile == null) return false;
    if (isCaptain()) return member['role'] != 'captain';
    final Joueur player = member['joueur'];
    return player.id == currentUserProfile!.id;
  }

  // Vérifie si l'utilisateur courant peut nommer ce candidat capitaine.
  bool canNominateCaptain(Joueur candidate) {
    if (!isCaptain()) return false;
    final String? currentUserId = currentUserProfile?.id;
    if (currentUserId == null || candidate.id == currentUserId) return false;

    return members.any((member) {
      final Joueur memberPlayer = member['joueur'];
      return memberPlayer.id == candidate.id &&
          member['role'] != 'captain' &&
          member['statut'] == 'accepted';
    });
  }

  // Liste des membres acceptés pouvant devenir capitaine.
  List<Joueur> get captainCandidates => members
      .where((member) =>
          member['role'] != 'captain' && member['statut'] == 'accepted')
      .map((member) => member['joueur'] as Joueur)
      .toList();

  // Remplace une équipe dans la liste et met à jour la sélection.
  void replaceTeam(Team updatedTeam) {
    final int teamIndex = teams.indexWhere((team) => team.id == updatedTeam.id);
    if (teamIndex >= 0) {
      teams[teamIndex] = updatedTeam;
    } else {
      teams.add(updatedTeam);
    }
    if (selectedTeam?.id == updatedTeam.id) {
      selectedTeam = updatedTeam;
    }
  }
}
