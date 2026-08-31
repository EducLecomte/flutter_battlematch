import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TeamsScreenController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  List<Team> availableUserTeams = [];
  List<Team> availableTournoiTeams = [];
  Team? activeTeam;
  bool isLoadingTeams = false;

  List<Armee>? _cachedReferenceArmies;

  List<Team> get opponentTeams =>
      availableTournoiTeams.where((team) => team.id != activeTeam?.id).toList();

  bool get utilisateurSansEquipe => availableUserTeams.isEmpty;

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
    } finally {
      isLoadingTeams = false;
    }
  }

  void _selectDefaultActiveTeam() {
    activeTeam = availableUserTeams.isEmpty ? null : availableUserTeams.first;
  }

  Future<Team> claimTeam(String teamId) =>
      _pocketbaseService.reclamerEquipeEnCapitaine(teamId);

  Future<Team> joinTeamWithPassword(String teamId, String motDePasse) =>
      _pocketbaseService.rejoindreEquipeAvecMotDePasse(teamId, motDePasse);

  Future<List<Armee>> loadReferenceArmies() async {
    _cachedReferenceArmies ??= await _pocketbaseService.getArmees();
    return _cachedReferenceArmies!;
  }

  void bindTournoi(String tournoiId) {
    _tournoiId = tournoiId;
  }
}
