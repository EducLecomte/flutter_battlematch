// ===========================================================================
// Façade de données MetaWar : conserve la surface d'API historique de
// l'ancien service Supabase afin de laisser les écrans intacts. Toute la
// logique réelle est déléguée aux sous-services de lib/services/pocketbase/.
// ===========================================================================

import '../models/models.dart';
import 'pocketbase/pocketbase_admin_service.dart';
import 'pocketbase/pocketbase_auth_service.dart';
import 'pocketbase/pocketbase_client_holder.dart';
import 'pocketbase/pocketbase_dashboard_adversaires_service.dart';
import 'pocketbase/pocketbase_dashboard_estims_service.dart';
import 'pocketbase/pocketbase_dashboard_matched_service.dart';
import 'pocketbase/pocketbase_referentiels_service.dart';
import 'pocketbase/pocketbase_team_access_service.dart';
import 'pocketbase/pocketbase_team_invitations_service.dart';
import 'pocketbase/pocketbase_team_membres_service.dart';
import 'pocketbase/pocketbase_teams_service.dart';
import 'pocketbase/pocketbase_tournois_service.dart';
import 'tournament_team_import_service.dart';

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
  final PocketbaseAdminService _serviceAdmin = PocketbaseAdminService.instance;
  final PocketbaseTeamAccessService _serviceTeamAccess =
      PocketbaseTeamAccessService.instance;
  final TournamentTeamImportService _serviceTournamentTeamImport =
      TournamentTeamImportService.instance;

  PocketbaseDataService._internal();

  Future<void> ensureInitialized() =>
      PocketbaseClientHolder.instance.ensureInitialized();

  String? get currentUserId => _serviceAuth.currentUserId;

  Stream<bool> get authStateChanges => _serviceAuth.authStateChanges;

  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
  }) => _serviceAuth.signUp(email: email, password: password, nom: nom);

  Future<void> signIn({required String email, required String password}) =>
      _serviceAuth.signIn(email: email, password: password);

  Future<void> signOut() => _serviceAuth.signOut();

  Future<Joueur?> getCurrentJoueurProfile() =>
      _serviceAuth.getCurrentJoueurProfile();

  Future<Joueur?> getJoueurProfile(String userId) =>
      _serviceAuth.getJoueurProfile(userId);

  Future<void> updateJoueurProfileFields({required String nom}) =>
      _serviceAuth.updateJoueurProfileFields(nom: nom);

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

  Future<Tournoi> createTournoi(String nom, String lienNr) =>
      _serviceTournois.createTournoi(nom, lienNr);

  Future<Tournoi> getTournoi(String tournoiId) =>
      _serviceTournois.getTournoi(tournoiId);

  Future<void> markTournoiImportEffectue(String tournoiId) =>
      _serviceTournois.markTournoiImportEffectue(tournoiId);

  Future<Tournoi> updateTournoi(String tournoiId, String nom, String lienNr) =>
      _serviceTournois.updateTournoi(tournoiId, nom, lienNr);

  Future<void> deleteTournoi(String tournoiId) =>
      _serviceTournois.deleteTournoi(tournoiId);

  Future<Team> getTeam(String teamId) => _serviceTeams.getTeam(teamId);

  Future<List<Team>> getTeamsForTournoi(String tournoiId) =>
      _serviceTeams.getTeamsForTournoi(tournoiId);

  Future<Team> createTeamForTournoi(String tournoiId, String nomEquipe) =>
      _serviceTeams.createTeamForTournoi(tournoiId, nomEquipe);

  Future<Team> updateTeamMotDePasse(String teamId, String motDePasse) =>
      _serviceTeams.updateTeamMotDePasse(teamId, motDePasse);

  Future<Team> reclamerEquipeEnCapitaine(String teamId) =>
      _serviceTeamAccess.reclamerEquipeEnCapitaine(teamId);

  Future<Team> rejoindreEquipeAvecMotDePasse(
    String teamId,
    String motDePasse,
  ) => _serviceTeamAccess.rejoindreEquipeAvecMotDePasse(teamId, motDePasse);

  Future<Team> nommerNouveauCapitaine(
    String teamId,
    String nouveauCapitaineJoueurId,
  ) => _serviceTeamAccess.nommerNouveauCapitaine(
    teamId,
    nouveauCapitaineJoueurId,
  );

  Future<TournamentTeamImportSummary> importTeamsForTournoi({
    required String tournoiId,
    required List<Map<String, dynamic>> importedPlayers,
    required List<Armee> referenceArmies,
  }) => _serviceTournamentTeamImport.importTeamsForTournoi(
    tournoiId: tournoiId,
    importedPlayers: importedPlayers,
    referenceArmies: referenceArmies,
  );

  Future<List<Armee>> getArmees() => _serviceReferentiels.getArmees();

  Future<List<Choix>> getChoix() => _serviceReferentiels.getChoix();

  Future<List<MetaAdv>> getOpponents(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardAdversaires.getOpponents(teamId, adversaireTeamId);

  Stream<List<MetaAdv>> streamOpponents(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardAdversaires.streamOpponents(teamId, adversaireTeamId);

  Future<MetaAdv> createOpponent(
    String teamId,
    String adversaireTeamId,
    String armeeId,
    String nomJoAdv,
    String listeAdv,
  ) => _serviceDashboardAdversaires.createOpponent(
    teamId,
    adversaireTeamId,
    armeeId,
    nomJoAdv,
    listeAdv,
  );

  Future<void> deleteOpponent(String opponentId) =>
      _serviceDashboardAdversaires.deleteOpponent(opponentId);

  Future<void> saveEstim(Estim estim) =>
      _serviceDashboardEstims.saveEstim(estim);

  Future<void> deleteEstim(
    String joueurId,
    String metaAdvId,
  ) => _serviceDashboardEstims.deleteEstim(joueurId, metaAdvId);

  Future<List<Estim>> getEstims(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardEstims.getEstims(teamId, adversaireTeamId);

  Stream<List<Estim>> streamEstims(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardEstims.streamEstims(teamId, adversaireTeamId);

  Future<void> toggleMatched(
    String teamId,
    String adversaireTeamId,
    String joueurId,
    String metaAdvId,
  ) => _serviceDashboardMatched.toggleMatched(
    teamId,
    adversaireTeamId,
    joueurId,
    metaAdvId,
  );

  Future<List<Matched>> getMatched(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardMatched.getMatched(teamId, adversaireTeamId);

  Stream<List<Matched>> streamMatched(
    String teamId,
    String adversaireTeamId,
  ) => _serviceDashboardMatched.streamMatched(teamId, adversaireTeamId);

  // -------------------------------------------------------------------
  // Administration (comptes marqués `admin`)
  // -------------------------------------------------------------------

  Future<List<Joueur>> getJoueursAdministration() =>
      _serviceAdmin.listJoueurs();

  Future<void> setJoueurAdmin(String joueurId, bool admin) =>
      _serviceAdmin.setJoueurAdmin(joueurId, admin);

  Future<void> deleteJoueur(String joueurId) =>
      _serviceAdmin.deleteJoueur(joueurId);

  Future<void> deleteCurrentAccount() => _serviceAdmin.deleteCurrentAccount();

  Future<Armee> createArmee(String nom, String short) =>
      _serviceReferentiels.createArmee(nom, short);

  Future<Armee> updateArmee(String armeeId, String nom, String short) =>
      _serviceReferentiels.updateArmee(armeeId, nom, short);

  Future<void> deleteArmee(String armeeId) =>
      _serviceReferentiels.deleteArmee(armeeId);

  Future<Choix> createChoix(String libelle, String short, String couleurHex) =>
      _serviceReferentiels.createChoix(libelle, short, couleurHex);

  Future<Choix> updateChoix(
    String choixId,
    String libelle,
    String short,
    String couleurHex,
  ) => _serviceReferentiels.updateChoix(choixId, libelle, short, couleurHex);

  Future<void> deleteChoix(String choixId) =>
      _serviceReferentiels.deleteChoix(choixId);
}
