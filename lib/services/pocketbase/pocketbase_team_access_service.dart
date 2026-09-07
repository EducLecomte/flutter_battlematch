// ===========================================================================
// Accès aux équipes MetaWar : claim d'une équipe sans capitaine, adhésion
// par mot de passe et nomination d'un nouveau capitaine.
// ===========================================================================

import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';
import 'pocketbase_team_membres_service.dart';
import 'pocketbase_teams_service.dart';

class PocketbaseTeamAccessService {
  static final PocketbaseTeamAccessService instance =
      PocketbaseTeamAccessService._internal();

  PocketbaseTeamAccessService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  final PocketbaseTeamsService _serviceTeams = PocketbaseTeamsService.instance;

  final PocketbaseTeamMembresService _serviceTeamMembres =
      PocketbaseTeamMembresService.instance;

  /// Transforme l'utilisateur connecté en capitaine d'une équipe sans capitaine.
  Future<Team> reclamerEquipeEnCapitaine(String teamId) async {
    final String? joueurId = _holder.currentUserId;
    if (joueurId == null) throw Exception("Non authentifié");

    final Team equipe = await _serviceTeams.getTeam(teamId);
    if (!_estSansCapitaine(equipe)) {
      throw Exception("Cette équipe a déjà un capitaine.");
    }

    await _serviceTeams.updateTeamCapitaineId(teamId, joueurId);
    await _serviceTeamMembres.inscrireMembreAccepte(
      teamId,
      joueurId,
      PocketbaseTeamMembresService.roleCapitaine,
    );
    return await _serviceTeams.getTeam(teamId);
  }

  /// Admet l'utilisateur connecté dans une équipe protégée par mot de passe.
  Future<Team> rejoindreEquipeAvecMotDePasse(
    String teamId,
    String motDePasse,
  ) async {
    final String? joueurId = _holder.currentUserId;
    if (joueurId == null) throw Exception("Non authentifié");
    if (motDePasse.length > teamPasswordMaxLength) {
      throw Exception(
        "Le mot de passe ne peut dépasser $teamPasswordMaxLength caractères.",
      );
    }

    final Team equipe = await _serviceTeams.getTeam(teamId);
    if (equipe.motDePasse.isEmpty) {
      throw Exception("Cette équipe n’accepte pas d’adhésion par mot de passe.");
    }
    if (await _serviceTeamMembres.aDejaUneAppartenance(teamId, joueurId)) {
      throw Exception("Vous êtes déjà membre de cette équipe.");
    }

    await _serviceTeamMembres.inscrireMembreParMotDePasse(teamId, motDePasse);
    return await _serviceTeams.getTeam(teamId);
  }

  /// Transfère le rôle de capitaine à un membre accepté de l'équipe.
  Future<Team> nommerNouveauCapitaine(
    String teamId,
    String nouveauCapitaineJoueurId,
  ) async {
    final String? capitaineIdActuel = _holder.currentUserId;
    if (capitaineIdActuel == null) throw Exception("Non authentifié");
    if (capitaineIdActuel == nouveauCapitaineJoueurId) {
      throw Exception("Vous êtes déjà capitaine de cette équipe.");
    }

    final RecordModel? nouveauMembre = await _serviceTeamMembres
        .getTeamMembreRecord(teamId, nouveauCapitaineJoueurId);
    if (nouveauMembre == null) {
      throw Exception("Ce joueur n’est pas membre de cette équipe.");
    }
    final String statutNouveauMembre = nouveauMembre.get<String>('statut');
    if (statutNouveauMembre != PocketbaseTeamMembresService.statutAccepte) {
      throw Exception("Ce joueur n’a pas accepté cette équipe.");
    }

    // L'ancien capitaine redevient un joueur s'il jouait ; s'il n'était que
    // coach, il conserve son rôle de coach.
    final RecordModel? recordAncienCapitaine =
        await _serviceTeamMembres.getTeamMembreRecord(
      teamId,
      capitaineIdActuel,
    );
    final String roleAncienCapitaine = recordAncienCapitaine?.get<String>(
          'role',
        ) ??
        PocketbaseTeamMembresService.roleJoueur;
    final String roleAncienCapitaineAPres =
        PocketbaseTeamMembresService.estRouleJoueur(roleAncienCapitaine)
            ? PocketbaseTeamMembresService.roleJoueur
            : PocketbaseTeamMembresService.roleCoach;
    await _serviceTeamMembres.mettreAJourRoleMembre(
      teamId,
      capitaineIdActuel,
      roleAncienCapitaineAPres,
    );
    await _serviceTeamMembres.mettreAJourRoleMembre(
      teamId,
      nouveauCapitaineJoueurId,
      PocketbaseTeamMembresService.roleCapitaine,
    );
    return await _serviceTeams.updateTeamCapitaineId(
      teamId,
      nouveauCapitaineJoueurId,
    );
  }

  bool _estSansCapitaine(Team equipe) =>
      equipe.capitaineId == null || equipe.capitaineId!.isEmpty;
}
