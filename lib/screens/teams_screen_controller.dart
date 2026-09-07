import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamsScreenController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  List<Team> availableUserTeams = [];
  List<Team> availableTournoiTeams = [];
  Team? activeTeam;
  bool isLoadingTeams = false;

  // Résultats de la recherche de joueurs à inviter (bouton capitaine).
  List<Joueur> searchResults = [];

  // Indique si une recherche de joueurs est en cours.
  bool isSearching = false;

  // Identifiants des membres actuels de l'équipe active : sert à exclure les
  // joueurs déjà membres des résultats de recherche.
  Set<String> _activeTeamMemberIds = {};

  List<Armee>? _cachedReferenceArmies;

  List<Team> get opponentTeams =>
      availableTournoiTeams.where((team) => team.id != activeTeam?.id).toList();

  bool get utilisateurSansEquipe => availableUserTeams.isEmpty;

  // Indique si l'utilisateur connecté est le capitaine de l'équipe active.
  bool get isCaptainOfActiveTeam {
    final String? currentUserId = _pocketbaseService.currentUserId;
    if (currentUserId == null || activeTeam == null) return false;
    return activeTeam!.capitaineId == currentUserId;
  }

  String _tournoiId = '';

  String get tournoiId => _tournoiId;

  Future<void> loadTeamsForUser(String? userId) async {
    isLoadingTeams = true;
    try {
      if (userId != null) {
        final List<Team> toutesEquipesUtilisateur = await _pocketbaseService
            .getTeamsForUser(userId);
        availableUserTeams = toutesEquipesUtilisateur
            .where((team) => team.tournoiId == _tournoiId)
            .toList();
      }
      if (_tournoiId.isNotEmpty) {
        availableTournoiTeams = await _pocketbaseService.getTeamsForTournoi(
          _tournoiId,
        );
      }
      _selectDefaultActiveTeam();
      await loadActiveTeamMembers();
    } finally {
      isLoadingTeams = false;
    }
  }

  void _selectDefaultActiveTeam() {
    activeTeam = availableUserTeams.isEmpty ? null : availableUserTeams.first;
  }

  // Charge les membres de l'équipe active pour en retenir les identifiants
  // (exclusion de la recherche de joueurs à inviter).
  Future<void> loadActiveTeamMembers() async {
    final activeTeamId = activeTeam?.id;
    if (activeTeamId == null) {
      _activeTeamMemberIds = {};
      return;
    }
    try {
      final List<Map<String, dynamic>> members =
          await _pocketbaseService.getTeamMembres(activeTeamId);
      _activeTeamMemberIds =
          members.map((member) => (member['joueur'] as Joueur).id).toSet();
    } catch (_) {
      _activeTeamMemberIds = {};
    }
  }

  Future<Team> claimTeam(String teamId) =>
      _pocketbaseService.reclamerEquipeEnCapitaine(teamId);

  Future<Team> joinTeamWithPassword(String teamId, String motDePasse) =>
      _pocketbaseService.rejoindreEquipeAvecMotDePasse(teamId, motDePasse);

  // Recherche des joueurs à inviter, en excluant les membres actuels de
  // l'équipe active.
  Future<void> searchPlayers(String query) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      return;
    }

    isSearching = true;
    try {
      final results = await _pocketbaseService.searchJoueurs(query);
      searchResults = results
          .where((player) => !_activeTeamMemberIds.contains(player.id))
          .toList();
    } catch (_) {
      searchResults = [];
    } finally {
      isSearching = false;
    }
  }

  // Envoie une invitation au joueur donné dans l'équipe active. Retourne un
  // message d'erreur, ou null en cas de succès.
  Future<String?> sendInvite(String playerId) async {
    final activeTeamId = activeTeam?.id;
    if (activeTeamId == null || !isCaptainOfActiveTeam) return null;
    try {
      await _pocketbaseService.inviteJoueurToTeam(activeTeamId, playerId);
      searchResults = [];
      await loadActiveTeamMembers();
      return null;
    } catch (inviteError) {
      return inviteError.toString();
    }
  }

  Future<List<Armee>> loadReferenceArmies() async {
    _cachedReferenceArmies ??= await _pocketbaseService.getArmees();
    return _cachedReferenceArmies!;
  }

  void bindTournoi(String tournoiId) {
    _tournoiId = tournoiId;
  }
}
