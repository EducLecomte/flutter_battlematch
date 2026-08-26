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

  List<Team> get selectableTeams {
    final Map<String, Team> teamById = {};
    for (final Team team in availableTournoiTeams) {
      teamById[team.id] = team;
    }
    for (final Team team in availableUserTeams) {
      teamById.putIfAbsent(team.id, () => team);
    }
    return teamById.values.toList();
  }

  Future<void> loadTeamsForUser(String? userId) async {
    isLoadingTeams = true;
    try {
      if (userId != null) {
        availableUserTeams = await _pocketbaseService.getTeamsForUser(userId);
      }
      if (_tournoiId.isNotEmpty) {
        availableTournoiTeams = await _pocketbaseService
            .getTeamsParticipatingInTournoi(_tournoiId);
      }
      _selectDefaultActiveTeam();
      await loadEncountersForActiveTeam();
    } finally {
      isLoadingTeams = false;
    }
  }

  void _selectDefaultActiveTeam() {
    if (availableUserTeams.isNotEmpty) {
      activeTeam = availableUserTeams.first;
    } else if (availableTournoiTeams.isNotEmpty) {
      activeTeam = availableTournoiTeams.first;
    } else {
      activeTeam = null;
    }
  }

  void setActiveTeam(Team selectedTeam) {
    activeTeam = selectedTeam;
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
