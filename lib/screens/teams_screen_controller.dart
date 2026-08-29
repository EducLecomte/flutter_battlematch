import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamsScreenController {
  final PocketbaseDataService _pocketbaseService = PocketbaseDataService.instance;

  List<Team> availableUserTeams = [];
  List<Team> availableTournoiTeams = [];
  Team? activeTeam;
  List<Rencontre> availableEncounters = [];
  bool isLoadingTeams = false;

  List<Armee>? _cachedReferenceArmies;

  List<Team> get opponentTeams =>
      availableTournoiTeams.where((team) => team.id != activeTeam?.id).toList();

  bool get utilisateurSansEquipe => availableUserTeams.isEmpty;

  Rencontre? getEncounterForOpponentName(String opponentName) {
    final String cleanOpponentName = opponentName.trim().toLowerCase();
    for (final encounter in availableEncounters) {
      if (encounter.nomAdversaire.trim().toLowerCase() == cleanOpponentName) {
        return encounter;
      }
    }
    return null;
  }

  Future<Rencontre> getOrCreateEncounterForOpponent(String opponentName) async {
    if (activeTeam == null) {
      throw Exception("Aucune équipe active.");
    }
    final existing = getEncounterForOpponentName(opponentName);
    if (existing != null) return existing;

    final created = await _pocketbaseService.createRencontre(
      _tournoiId,
      activeTeam!.id,
      opponentName.trim(),
    );
    await loadEncountersForActiveTeam();
    return created;
  }

  Future<void> loadTeamsForUser(String? userId) async {
    isLoadingTeams = true;
    try {
      if (userId != null) {
        final List<Team> toutesEquipesUtilisateur =
            await _pocketbaseService.getTeamsForUser(userId);
        availableUserTeams = toutesEquipesUtilisateur
            .where((team) => team.tournoiId == _tournoiId)
            .toList();
      }
      if (_tournoiId.isNotEmpty) {
        availableTournoiTeams =
            await _pocketbaseService.getTeamsForTournoi(_tournoiId);
      }
      _selectDefaultActiveTeam();
      await loadEncountersForActiveTeam();
    } finally {
      isLoadingTeams = false;
    }
  }

  void _selectDefaultActiveTeam() {
    activeTeam = availableUserTeams.isEmpty ? null : availableUserTeams.first;
  }

  Future<void> loadEncountersForActiveTeam() async {
    if (activeTeam == null) return;
    availableEncounters = await _pocketbaseService.getRencontres(
      _tournoiId,
      activeTeam!.id,
    );
  }

  String _tournoiId = '';

  String get tournoiId => _tournoiId;

  Future<Team> claimTeam(String teamId) =>
      _pocketbaseService.reclamerEquipeEnCapitaine(teamId);

  Future<Team> joinTeamWithPassword(String teamId, String motDePasse) =>
      _pocketbaseService.rejoindreEquipeAvecMotDePasse(teamId, motDePasse);

  Future<void> createEncounter(String opponentName) async {
    if (activeTeam == null || opponentName.trim().isEmpty) return;
    await _pocketbaseService.createRencontre(
      _tournoiId,
      activeTeam!.id,
      opponentName.trim(),
    );
    await loadEncountersForActiveTeam();
  }

  Future<void> deleteEncounter(String encounterId) async {
    await _pocketbaseService.deleteRencontre(encounterId);
    await loadEncountersForActiveTeam();
  }

  Future<List<Armee>> loadReferenceArmies() async {
    _cachedReferenceArmies ??= await _pocketbaseService.getArmees();
    return _cachedReferenceArmies!;
  }

  void bindTournoi(String tournoiId) {
    _tournoiId = tournoiId;
  }
}
