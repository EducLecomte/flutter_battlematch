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

  // Équipes adverses de l'équipe sélectionnée
  List<Team> opponentTeams = [];

  // Adversaires (team_meta) par équipe adverse
  Map<String, List<TeamMeta>> opponentsByOpponentTeamId = {};

  // Appariements par équipe adverse
  Map<String, List<Matched>> matchedByOpponentTeamId = {};

  // Mapping tournoi ID → nom du tournoi
  Map<String, String> tournoiNameById = {};

  // Charge le profil du joueur connecté et ses équipes.
  Future<String?> loadInitialData() async {
    try {
      final profile = await _pocketbaseService.getCurrentJoueurProfile();
      if (profile != null) {
        currentUserProfile = profile;
        final list = await _pocketbaseService.getTeamsForUser(profile.id);
        teams = list;
        // Charge les noms des tournois associés aux équipes
        final uniqueTournoiIds = list.map((t) => t.tournoiId).toSet();
        for (final tournoiId in uniqueTournoiIds) {
          try {
            final tournoi = await _pocketbaseService.getTournoi(tournoiId);
            tournoiNameById[tournoiId] = tournoi.nom;
          } catch (_) {
            // Tournoi non trouvé, skip
          }
        }
        // Conserve l'équipe sélectionnée si elle figure encore dans la
        // liste, afin que le rafraîchissement (changement d'onglet, bouton
        // de l'AppBar) ne réinitialise pas la sélection sur la première.
        final Team? equipePrecedente = selectedTeam;
        Team? equipeConservee;
        for (final team in list) {
          if (team.id == equipePrecedente?.id) {
            equipeConservee = team;
            break;
          }
        }
        selectedTeam = equipeConservee ?? (list.isEmpty ? null : list.first);
        await loadMembersForSelectedTeam();
        await loadOpponentsForSelectedTeam();
      }
      return null;
    } catch (loadError) {
      return loadError.toString();
    }
  }

  // Charge les équipes adverses, listes et appariements de l'équipe sélectionnée.
  Future<String?> loadOpponentsForSelectedTeam() async {
    final selectedTeam = this.selectedTeam;
    if (selectedTeam == null) return null;
    try {
      final List<Team> allTeams = await _pocketbaseService.getTeamsForTournoi(
        selectedTeam.tournoiId,
      );
      final List<Team> opponentTeamsToDisplay = [];
      final Map<String, List<TeamMeta>> loadedOpponents = {};
      final Map<String, List<Matched>> loadedMatched = {};
      for (final Team opponentTeam in allTeams) {
        if (opponentTeam.id == selectedTeam.id) continue;
        final List<TeamMeta> opponents = await _pocketbaseService.getTeamMeta(
          opponentTeam.id,
        );
        if (opponents.isEmpty) continue;
        opponentTeamsToDisplay.add(opponentTeam);
        loadedOpponents[opponentTeam.id] = opponents;
        loadedMatched[opponentTeam.id] = await _pocketbaseService.getMatched(
          selectedTeam.id,
          opponentTeam.id,
        );
      }
      opponentTeams = opponentTeamsToDisplay;
      opponentsByOpponentTeamId = loadedOpponents;
      matchedByOpponentTeamId = loadedMatched;
      return null;
    } catch (opponentsError) {
      return opponentsError.toString();
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
          .where(
            (player) => !members.any(
              (member) => (member['joueur'] as Joueur).id == player.id,
            ),
          )
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

  // Bascule l'appariement joueur ↔ adversaire pour une équipe adverse.
  // Retourne false si l'appariement est impossible (contrainte unique).
  Future<bool> toggleMatched(
    Team opponentTeam,
    Joueur player,
    TeamMeta opponent,
  ) async {
    final selectedTeam = this.selectedTeam;
    if (selectedTeam == null) return false;
    try {
      await _pocketbaseService.toggleMatched(
        selectedTeam.id,
        opponentTeam.id,
        player.id,
        opponent.id,
      );
      // Recharge les appariements pour cette équipe adverse.
      final updatedMatched = await _pocketbaseService.getMatched(
        selectedTeam.id,
        opponentTeam.id,
      );
      matchedByOpponentTeamId[opponentTeam.id] = updatedMatched;
      return true;
    } catch (_) {
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
    if (isCaptain()) {
      // Le capitaine ne peut pas se retirer (transfert de capitainerie requis).
      final Joueur memberPlayer = member['joueur'];
      return memberPlayer.id != selectedTeam!.capitaineId;
    }
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
          memberPlayer.id != selectedTeam!.capitaineId &&
          member['statut'] == 'accepted';
    });
  }

  // Liste des membres acceptés pouvant devenir capitaine.
  List<Joueur> get captainCandidates => members
      .where(
        (member) =>
            (member['joueur'] as Joueur).id != selectedTeam?.capitaineId &&
            member['statut'] == 'accepted',
      )
      .map((member) => member['joueur'] as Joueur)
      .toList();

  // Met à jour le rôle d'un membre (joueur ↔ coach). Retourne un message
  // d'erreur, ou null en cas de succès.
  Future<String?> changeMemberRole(Joueur player, String role) async {
    final selectedTeamId = selectedTeam?.id;
    if (selectedTeamId == null || !isCaptain()) return null;
    try {
      await _pocketbaseService.mettreAJourRoleMembre(
        selectedTeamId,
        player.id,
        role,
      );
      await loadMembersForSelectedTeam();
      return null;
    } catch (roleError) {
      return roleError.toString();
    }
  }

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
