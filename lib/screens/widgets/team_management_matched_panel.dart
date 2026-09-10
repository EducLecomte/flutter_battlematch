import 'package:flutter/material.dart';

import '../../logic/estim_score_calculator.dart';
import '../../models/models.dart';
import '../../utils/error_snack_bar_presenter.dart';
import '../../utils/hex_color_parser.dart';
import '../team_management_controller.dart';

/// Panel « Appariements » de la gestion d'équipe.
///
/// Les équipes adverses, leurs joueurs et les appariements sont chargés à
/// la demande (point 6 MEMO) : au lieu d'un panneau « Équipes adverses &
/// Appariements » chargé systématiquement (plusieurs requêtes par équipe
/// adverse), l'écran ne déclenche ces requêtes que quand l'utilisateur
/// affiche la section.
///
/// Affichage (point 6.1 MEMO) : le panneau n'affiche que les appariements de
/// l'utilisateur courant. Chaque appariement est présenté sous forme de tuile
/// dépliable nommée d'après l'équipe adverse, listant l'adversaire apparié
/// (pseudo et liste d'armée) ainsi que le score d'estimation correspondant.
/// S'il n'y a aucun appariement, rien n'est affiché. Le panneau est en lecture
/// seule : l'appariement et l'annulation se font depuis la matrice du tableau
/// de bord (tap sur une cellule, `toggleMatched`).
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
    final String? errorMessage = await controller
        .loadOpponentsForSelectedTeam();
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
    final Map<String, ({Joueur joueur, Team team, TeamMeta meta})>
    uniqueEntries = {};
    final Joueur? currentPlayer = controller.currentUserProfile;

    for (final member in controller.members) {
      final Joueur player = member['joueur'];
      if (currentPlayer != null && player.id != currentPlayer.id) {
        continue;
      }

      for (final Team opponentTeam in controller.opponentTeams) {
        final List<Matched> matched =
            controller.matchedByOpponentTeamId[opponentTeam.id] ?? [];
        for (final pairing in matched) {
          if (pairing.joueurId != player.id) continue;

          final List<TeamMeta> opponents =
              controller.opponentsByOpponentTeamId[opponentTeam.id] ?? [];
          for (final TeamMeta opponent in opponents) {
            if (opponent.id != pairing.teamMetaId) continue;

            final key = '${player.id}::${opponentTeam.id}::${opponent.id}';
            uniqueEntries.putIfAbsent(
              key,
              () => (joueur: player, team: opponentTeam, meta: opponent),
            );
          }
        }
      }
    }

    final entries = uniqueEntries.values.toList();
    entries.sort((a, b) {
      final comparePlayer = a.joueur.nom.toLowerCase().compareTo(
        b.joueur.nom.toLowerCase(),
      );
      if (comparePlayer != 0) return comparePlayer;
      return a.team.nom.toLowerCase().compareTo(b.team.nom.toLowerCase());
    });
    return entries;
  }

  // Libellé de l'adversaire apparié : pseudo, liste d'armée (si renseignée)
  // et équipe adverse.
  String _formatOpponent(Team opponentTeam, TeamMeta opponent) {
    final String nom = opponent.nomJo.isNotEmpty
        ? opponent.nomJo
        : "Adversaire";
    final String liste = opponent.listeJo.isNotEmpty
        ? " \n${opponent.listeJo}"
        : "";
    return "$nom$liste ";
  }

  // Indique l'état du chargement automatique des appariements.
  Widget _buildLoadingCard() {
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
        leading: const Icon(Icons.error_outline),
        title: const Text("Impossible de charger les appariements"),
        subtitle: Text(controller.opponentsLoadError ?? "Erreur inconnue"),
      ),
    );
  }

  String _formatEstimationSummary(
    Team team,
    List<({Joueur joueur, Team team, TeamMeta meta})> group,
  ) {
    final estimationsByKey =
        controller.estimationsByOpponentTeamId[team.id] ?? const {};
    final estimations = <Estim>[];

    double totalScore = 0;

    for (final entry in group) {
      final key = '${entry.joueur.id}::${entry.meta.id}';
      final estim = estimationsByKey[key];
      if (estim == null) continue;
      estimations.add(estim);
      final midpoint = EstimScoreCalculator.midpointScore(estim);
      if (midpoint == null) continue;
      totalScore += midpoint;
    }

    if (estimations.isEmpty) {
      return 'Aucune estimation';
    }

    final scoredEstimations = estimations
        .where((estim) => EstimScoreCalculator.midpointScore(estim) != null)
        .toList();
    final averageScore = scoredEstimations.isEmpty
        ? null
        : totalScore / scoredEstimations.length;
    final firstEstimation = estimations.first;
    final choice = AppreciationScale.choiceById(
      controller.choiceList,
      firstEstimation.choixId,
    );
    final appreciation = choice?.short ?? AppreciationScale.unknownLabel;
    final averageLabel = averageScore?.toStringAsFixed(1) ?? '-';
    return '$appreciation • moyenne $averageLabel • confiance ${firstEstimation.confiance}';
  }

  Color? _estimationColor(
    Team team,
    List<({Joueur joueur, Team team, TeamMeta meta})> group,
  ) {
    final estimationsByKey =
        controller.estimationsByOpponentTeamId[team.id] ?? const {};
    for (final entry in group) {
      final key = '${entry.joueur.id}::${entry.meta.id}';
      final estimation = estimationsByKey[key];
      final choice = AppreciationScale.choiceById(
        controller.choiceList,
        estimation?.choixId,
      );
      final color = HexColorParser.parseHexadecimalColor(
        choice?.couleurHex ?? '',
      );
      if (color != null) return color;
    }
    return null;
  }

  IconData _estimationIcon(
    Team team,
    List<({Joueur joueur, Team team, TeamMeta meta})> group,
  ) {
    final estimationsByKey =
        controller.estimationsByOpponentTeamId[team.id] ?? const {};
    for (final entry in group) {
      final key = '${entry.joueur.id}::${entry.meta.id}';
      final estimation = estimationsByKey[key];
      final choice = AppreciationScale.choiceById(
        controller.choiceList,
        estimation?.choixId,
      );
      switch (choice?.short) {
        case '--':
          return Icons.sentiment_very_dissatisfied;
        case '-':
          return Icons.sentiment_dissatisfied;
        case '=-':
          return Icons.remove_circle_outline;
        case '=':
          return Icons.sentiment_neutral;
        case '=+':
          return Icons.add_circle_outline;
        case '+':
          return Icons.sentiment_satisfied;
        case '++':
          return Icons.sentiment_very_satisfied;
      }
    }
    return Icons.help_outline;
  }

  // Une fois les données chargées : liste des appariements de l'utilisateur
  // courant, regroupés par équipe adverse, avec l'adversaire correspondant
  // (point 6.1 MEMO). Rien n'est affiché s'il n'y a aucun appariement.
  List<Widget> _buildPairedPlayerCards(BuildContext context) {
    final List<({Joueur joueur, Team team, TeamMeta meta})> entries =
        _buildPairedEntries();

    if (entries.isEmpty) {
      return const [];
    }

    final Map<String, List<({Joueur joueur, Team team, TeamMeta meta})>>
    grouped = {};
    for (final entry in entries) {
      final key = '${entry.team.id}::${entry.meta.id}';
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final orderedKeys = grouped.keys.toList()
      ..sort(
        (a, b) => grouped[a]!.first.team.nom.toLowerCase().compareTo(
          grouped[b]!.first.team.nom.toLowerCase(),
        ),
      );

    return [
      Card(
        child: Column(
          children: [
            for (final adversaireKey in orderedKeys)
              Builder(
                builder: (context) {
                  final group = grouped[adversaireKey]!;
                  final estimationColor = _estimationColor(
                    group.first.team,
                    group,
                  );
                  return ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: estimationColor ?? Colors.grey.shade300,
                      child: Icon(
                        _estimationIcon(group.first.team, group),
                        size: 20,
                        color: estimationColor == null
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ),
                    title: Text(
                      group.first.team.nom,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _formatEstimationSummary(group.first.team, group),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    children: [
                      for (final entry in group)
                        ListTile(
                          dense: true,
                          title: Text(
                            _formatOpponent(entry.team, entry.meta),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!controller.opponentsLoaded &&
        !controller.opponentsLoadRequested &&
        !controller.isLoadingOpponents) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          _handleLoadOpponentsTap(context);
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appariements",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (controller.opponentsLoaded)
          ..._buildPairedPlayerCards(context)
        else
          _buildLoadingCard(),
      ],
    );
  }
}
