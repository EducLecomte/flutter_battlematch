import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamsScreenController {
  final PocketbaseDataService _pocketbaseService = PocketbaseDataService.instance;

  List<Team> availableUserTeams = [];
  Team? activeTeam;
  List<Rencontre> availableEncounters = [];
  bool isLoadingTeams = false;

  List<Armee>? _cachedReferenceArmies;

  Future<void> loadTeamsForUser(String? userId) async {
    isLoadingTeams = true;
    try {
      if (userId != null) {
        availableUserTeams = await _pocketbaseService.getTeamsForUser(userId);
        activeTeam = availableUserTeams.isNotEmpty ? availableUserTeams.first : null;
        if (activeTeam != null) {
          await loadEncountersForActiveTeam();
        }
      }
    } finally {
      isLoadingTeams = false;
    }
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
