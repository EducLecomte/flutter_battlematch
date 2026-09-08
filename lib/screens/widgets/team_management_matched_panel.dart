import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/error_snack_bar_presenter.dart';
import '../team_management_controller.dart';

/// Panel « Appariements » de la gestion d'équipe.
///
/// Les équipes adverses, leurs joueurs et les appariements sont chargés à
/// la demande (point 6 MEMO) : au lieu d'un panneau « Équipes adverses &
/// Appariements » chargé systématiquement (plusieurs requêtes par équipe
/// adverse), l'écran ne déclenche ces requêtes que quand l'utilisateur
/// affiche la section.
///
/// Affichage (point 6.1 MEMO) : le panneau liste les joueurs de l'équipe
/// qui sont appariés, avec l'adversaire avec lequel ils le sont (pseudo et
/// liste d'armée). Un joueur sans appariement n'apparaît pas ; s'il n'y a
/// aucun appariement, rien n'est affiché. Le panneau est en lecture seule :
/// l'appariement et l'annulation se font depuis la matrice du tableau de
/// bord (tap sur une cellule, `toggleMatched`).
class TeamManagementMatchedPanel extends StatelessWidget {
  final TeamManagementController controller;
  final VoidCallback onStateChanged;

  const TeamManagementMatchedPanel({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  // Déclenche le chargement paresseux des adversaires, puis notifie
  // l'écran du changement d'état.
  Future<void> _handleLoadOpponentsTap(BuildContext context) async {
    final String? errorMessage =
        await controller.loadOpponentsForSelectedTeam();
    if (!context.mounted) return;
    onStateChanged();
    if (errorMessage != null) {
      showErrorSnackBar(
        context,
        "Erreur de chargement des adversaires : $errorMessage",
      );
    }
  }

  // Un joueur peut être apparié avec un adversaire par équipe adverse
  // (index unique PB par (team, adversaire_team, joueur)) : retourne toutes
  // les paires (joueur de l'équipe, équipe adverse, adversaire apparié),
  // dans l'ordre de l'effectif.
  List<({Joueur joueur, Team team, TeamMeta meta})> _buildPairedEntries() {
    final List<({Joueur joueur, Team team, TeamMeta meta})> entries = [];
    for (final member in controller.members) {
      final Joueur player = member['joueur'];
      for (final Team opponentTeam in controller.opponentTeams) {
        final List<Matched> matched =
            controller.matchedByOpponentTeamId[opponentTeam.id] ?? [];
        for (final pairing in matched) {
          if (pairing.joueurId != player.id) continue;
          final List<TeamMeta> opponents =
              controller.opponentsByOpponentTeamId[opponentTeam.id] ?? [];
          for (final TeamMeta opponent in opponents) {
            if (opponent.id == pairing.teamMetaId) {
              entries.add((joueur: player, team: opponentTeam, meta: opponent));
            }
          }
        }
      }
    }
    return entries;
  }

  // Libellé de l'adversaire apparié : pseudo, liste d'armée (si renseignée)
  // et équipe adverse.
  String _formatOpponent(Team opponentTeam, TeamMeta opponent) {
    final String nom =
        opponent.nomJo.isNotEmpty ? opponent.nomJo : "Adversaire";
    final String liste =
        opponent.listeJo.isNotEmpty ? " — ${opponent.listeJo}" : "";
    return "$nom$liste (${opponentTeam.nom})";
  }

  // Carte affichée tant que les adversaires ne sont pas chargés :
  // spinner pendant le chargement, sinon le bouton de chargement à la demande.
  Widget _buildLoadCard(BuildContext context) {
    if (controller.isLoadingOpponents) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link),
        title: const Text("Afficher les appariements"),
        subtitle: const Text(
          "Charge les équipes adverses au besoin ; affiche les appariements "
          "de vos joueurs.",
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _handleLoadOpponentsTap(context),
      ),
    );
  }

  // Une fois les données chargées : liste des joueurs de l'équipe qui sont
  // appariés, avec l'adversaire correspondant (point 6.1 MEMO). Rien n'est
  // affiché s'il n'y a aucun appariement.
  List<Widget> _buildPairedPlayerCards(BuildContext context) {
    final List<({Joueur joueur, Team team, TeamMeta meta})> entries =
        _buildPairedEntries();

    if (entries.isEmpty) {
      return const [];
    }

    return [
      Card(
        child: Column(
          children: [
            for (final entry in entries)
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person, size: 20),
                ),
                title: Text(
                  entry.joueur.nom,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _formatOpponent(entry.team, entry.meta),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appariements",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (controller.opponentsLoaded) ..._buildPairedPlayerCards(context)
        else _buildLoadCard(context),
      ],
    );
  }
}
