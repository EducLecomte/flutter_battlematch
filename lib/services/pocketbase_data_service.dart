// ===========================================================================
// Façade de données MetaWar : conserve la surface d'API historique de
// l'ancien service Supabase afin de laisser les écrans intacts. Toute la
// logique réelle est déléguée aux sous-services de lib/services/pocketbase/.
// ===========================================================================

import '../models/models.dart';
import 'pocketbase/pocketbase_auth_service.dart';
import 'pocketbase/pocketbase_client_holder.dart';
import 'pocketbase/pocketbase_dashboard_adversaires_service.dart';
import 'pocketbase/pocketbase_dashboard_estims_service.dart';
import 'pocketbase/pocketbase_dashboard_matched_service.dart';
import 'pocketbase/pocketbase_referentiels_service.dart';
import 'pocketbase/pocketbase_team_invitations_service.dart';
import 'pocketbase/pocketbase_team_membres_service.dart';
import 'pocketbase/pocketbase_teams_service.dart';
import 'pocketbase/pocketbase_tournois_service.dart';

class PocketbaseDataService {
  static final PocketbaseDataService instance =
      PocketbaseDataService._internal();

  final PocketbaseAuthService _serviceAuth = PocketbaseAuthService.instance;
  final PocketbaseTeamsService _serviceTeams = PocketbaseTeamsService.instance;
  final PocketbaseTeamMembresService _serviceTeamMembres =
      PocketbaseTeamMembresService.instance;
  final PocketbaseTeamInvitationsService _serviceTeamInvitations =
      PocketbaseTeamInvitationsService.instance;
  final PocketbaseTournoisService _serviceTournois =
      PocketbaseTournoisService.instance;
  final PocketbaseReferentielsService _serviceReferentiels =
      PocketbaseReferentielsService.instance;
  final PocketbaseDashboardAdversairesService _serviceDashboardAdversaires =
      PocketbaseDashboardAdversairesService.instance;
  final PocketbaseDashboardEstimsService _serviceDashboardEstims =
      PocketbaseDashboardEstimsService.instance;
  final PocketbaseDashboardMatchedService _serviceDashboardMatched =
      PocketbaseDashboardMatchedService.instance;

  PocketbaseDataService._internal();

  Future<void> ensureInitialized() =>
      PocketbaseClientHolder.instance.ensureInitialized();

  String? get currentUserId => _serviceAuth.currentUserId;

  Stream<bool> get authStateChanges => _serviceAuth.authStateChanges;

  Future<void> signUp(
          {required String email,
          required String password,
          required String nom,
          required String short}) =>
      _serviceAuth.signUp(
          email: email, password: password, nom: nom, short: short);

  Future<void> signIn(
          {required String email, required String password}) =>
      _serviceAuth.signIn(email: email, password: password);

  Future<void> signOut() => _serviceAuth.signOut();

  Future<Joueur?> getCurrentJoueurProfile() =>
      _serviceAuth.getCurrentJoueurProfile();

  Future<Joueur?> getJoueurProfile(String userId) =>
      _serviceAuth.getJoueurProfile(userId);

  Future<void> updateJoueurProfileFields(
          {required String nom, required String short}) =>
      _serviceAuth.updateJoueurProfileFields(nom: nom, short: short);

  Future<List<Joueur>> searchJoueurs(String query) =>
      _serviceAuth.searchJoueurs(query);
  Future<Team> createTeam(String nom) => _serviceTeams.createTeam(nom);

  Future<List<Team>> getTeamsForUser(String userId) =>
      _serviceTeams.getTeamsForUser(userId);

  Future<List<Map<String, dynamic>>> getTeamMembres(String teamId) =>
      _serviceTeamMembres.getTeamMembres(teamId);

  Future<List<Map<String, dynamic>>> getPendingInvitations(String userId) =>
      _serviceTeamInvitations.getPendingInvitations(userId);

  Future<void> inviteJoueurToTeam(String teamId, String joueurId) =>
      _serviceTeamInvitations.inviteJoueurToTeam(teamId, joueurId);

  Future<void> acceptTeamInvite(String teamId, String joueurId) =>
      _serviceTeamInvitations.acceptTeamInvite(teamId, joueurId);

  Future<void> declineOrRemoveTeamInvite(String teamId, String joueurId) =>
      _serviceTeamInvitations.declineOrRemoveTeamInvite(teamId, joueurId);

  Future<void> deleteTeam(String teamId) => _serviceTeams.deleteTeam(teamId);
  Future<List<Tournoi>> getTournois() => _serviceTournois.getTournois();

  Future<Tournoi> createTournoi(String nom, String? lienNr) =>
      _serviceTournois.createTournoi(nom, lienNr);

  Future<void> deleteTournoi(String tournoiId) =>
      _serviceTournois.deleteTournoi(tournoiId);

  Future<Rencontre> createRencontre(String tournoiId, String teamId,
          String nomAdversaire) =>
      _serviceTournois.createRencontre(tournoiId, teamId, nomAdversaire);

  Future<List<Rencontre>> getRencontres(String tournoiId, String teamId) =>
      _serviceTournois.getRencontres(tournoiId, teamId);

  Future<void> deleteRencontre(String rencontreId) =>
      _serviceTournois.deleteRencontre(rencontreId);

  Future<List<Armee>> getArmees() => _serviceReferentiels.getArmees();

  Future<List<Choix>> getChoix() => _serviceReferentiels.getChoix();

  Future<List<MetaAdv>> getOpponents(String rencontreId) =>
      _serviceDashboardAdversaires.getOpponents(rencontreId);

  Stream<List<MetaAdv>> streamOpponents(String rencontreId) =>
      _serviceDashboardAdversaires.streamOpponents(rencontreId);

  Future<MetaAdv> createOpponent(String rencontreId, String armeeId,
          String nomJoAdv, String listeAdv) =>
      _serviceDashboardAdversaires
          .createOpponent(rencontreId, armeeId, nomJoAdv, listeAdv);

  Future<void> deleteOpponent(String opponentId) =>
      _serviceDashboardAdversaires.deleteOpponent(opponentId);

  Future<void> saveEstim(Estim estim) => _serviceDashboardEstims.saveEstim(estim);

  Future<void> deleteEstim(String joueurId, String rencontreId,
          String metaAdvId) =>
      _serviceDashboardEstims.deleteEstim(joueurId, rencontreId, metaAdvId);

  Future<List<Estim>> getEstims(String rencontreId) =>
      _serviceDashboardEstims.getEstims(rencontreId);

  Stream<List<Estim>> streamEstims(String rencontreId) =>
      _serviceDashboardEstims.streamEstims(rencontreId);

  Future<void> toggleMatched(String rencontreId, String joueurId,
          String metaAdvId) =>
      _serviceDashboardMatched.toggleMatched(rencontreId, joueurId, metaAdvId);

  Future<List<Matched>> getMatched(String rencontreId) =>
      _serviceDashboardMatched.getMatched(rencontreId);

  Stream<List<Matched>> streamMatched(String rencontreId) =>
      _serviceDashboardMatched.streamMatched(rencontreId);
}
