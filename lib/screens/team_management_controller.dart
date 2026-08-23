// ===========================================================================
// Contrôleur de la gestion d'équipe (team_management_controller.dart)
// Détient les équipes, la sélection, les membres et les règles métier
// (création, recherche de joueurs, invitations, retrait, suppression).
// ===========================================================================

import 'package:flutter/material.dart';
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

  // Charge le profil du joueur connecté et ses équipes.
  // Retourne un message d'erreur, ou null en cas de succès.
  Future<String?> loadInitialData() async {
    try {
      final profile = await _pocketbaseService.getCurrentJoueurProfile();
      if (profile != null) {
        currentUserProfile = profile;
        final list = await _pocketbaseService.getTeamsForUser(profile.id);
        teams = list;
        if (list.isNotEmpty) {
          selectedTeam = list.first;
        }
        await loadMembersForSelectedTeam();
      }
      return null;
    } catch (loadError) {
      return loadError.toString();
    }
  }

  // Charge les membres de l'équipe sélectionnée.
  // Retourne un message d'erreur, ou null en cas de succès.
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

  // Crée une nouvelle équipe et la sélectionne.
  Future<String?> createNewTeam(String teamName) async {
    try {
      final newTeam = await _pocketbaseService.createTeam(teamName);
      await loadInitialData();
      selectedTeam = teams.firstWhere(
        (team) => team.id == newTeam.id,
        orElse: () => selectedTeam!,
      );
      await loadMembersForSelectedTeam();
      return null;
    } catch (createError) {
      return createError.toString();
    }
  }

  // Effectue la recherche de joueurs à inviter, en excluant
  // les membres actuels de l'équipe sélectionnée.
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
              !members.any(
                (member) =>
                    (member['joueur'] as Joueur).id == player.id,
              ))
          .toList();
    } catch (searchError) {
      // Recherche sans résultat : on ignore l'erreur
    } finally {
      isSearching = false;
    }
  }

  // Envoie une invitation au joueur donné.
  // Retourne un message d'erreur, ou null en cas de succès.
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

  // Vérifie si l'utilisateur connecté est le capitaine de l'équipe sélectionnée
  bool isCaptain() {
    if (selectedTeam == null || currentUserProfile == null) return false;
    return selectedTeam!.capitaineId == currentUserProfile!.id;
  }

  // Vérifie si l'utilisateur courant peut retirer ce membre :
  // le capitaine retire les joueurs (pas le capitaine), un joueur se retire lui-même.
  bool canRemoveMember(Map<String, dynamic> member) {
    if (currentUserProfile == null) return false;
    if (isCaptain()) {
      return member['role'] != 'captain';
    }
    final Joueur player = member['joueur'];
    return player.id == currentUserProfile!.id;
  }

  // Retire un membre (ou quitte l'équipe) après confirmation.
  Future<String?> removeMember(BuildContext context, Joueur player) async {
    final selectedTeamId = selectedTeam?.id;
    if (selectedTeamId == null) return null;

    final bool isMyself = currentUserProfile?.id == player.id;
    final String messageTitre =
        isMyself ? "Quitter l'équipe ?" : "Retirer ${player.nom} de l'équipe ?";
    final String messageDetail = isMyself
        ? "Vous ne ferez plus partie de cette équipe."
        : "Ce joueur ne fera plus partie de l'équipe.";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(messageTitre),
        content: Text(messageDetail),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Retirer"),
          ),
        ],
      ),
    );

    if (confirm != true) return null;
    try {
      await _pocketbaseService.declineOrRemoveTeamInvite(selectedTeamId, player.id);
      await loadMembersForSelectedTeam();
      return null;
    } catch (removeError) {
      return removeError.toString();
    }
  }

  // Demande confirmation puis supprime l'équipe donnée.
  Future<String?> deleteTeam(BuildContext context, Team team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer l'équipe ?"),
        content: const Text(
          "Cette action est irréversible et supprimera tous les appariements.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm != true) return null;
    try {
      await _pocketbaseService.deleteTeam(team.id);
      await loadInitialData();
      return null;
    } catch (deleteError) {
      return deleteError.toString();
    }
  }
}
