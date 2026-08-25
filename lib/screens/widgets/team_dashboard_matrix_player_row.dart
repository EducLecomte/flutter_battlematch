// ===========================================================================
// Ligne joueur de la matrice (team_dashboard_matrix_player_row.dart)
// Fabrique le TableRow d'un joueur : nom puis cellules de matchup par
// adversaire. Les indices de recherche O(1) sont fournis par la matrice.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import '../team_dashboard_estim_actions.dart';
import 'team_dashboard_matrix_matchup_cell.dart';

class MatrixPlayerRow {
  final Joueur player;
  final List<MetaAdv> opponents;
  final TeamDashboardEstimActions estimActions;
  final Map<String, Estim> estimParJoueurEtAdversaire;
  final Map<String, Choix> choixParId;
  final Set<String> joueurIdsApparies;
  final Set<String> adversaireIdsApparies;
  final Set<String> pairesJoueurAdversaireAppariees;
  final Color playerColumnColor;

  MatrixPlayerRow({
    required this.player,
    required this.opponents,
    required this.estimActions,
    required this.estimParJoueurEtAdversaire,
    required this.choixParId,
    required this.joueurIdsApparies,
    required this.adversaireIdsApparies,
    required this.pairesJoueurAdversaireAppariees,
    required this.playerColumnColor,
  });

  TableRow build(BuildContext context) {
    final bool isPlayerMatched = joueurIdsApparies.contains(player.id);

    return TableRow(
      children: [
        // Nom du joueur (colonne 1)
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            color: playerColumnColor,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 8,
            ),
            child: Text(
              player.nom,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPlayerMatched ? Colors.grey : null,
                decoration: isPlayerMatched
                    ? TextDecoration.lineThrough
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Les cellules de matchup pour ce joueur
        for (final opponent in opponents)
          _buildMatchupCell(context, player, opponent),
      ],
    );
  }

  Widget _buildMatchupCell(
    BuildContext context,
    Joueur player,
    MetaAdv opponent,
  ) {
    // Estimation réelle de ce joueur sur cet adversaire (null si vide)
    final existingEstim = estimParJoueurEtAdversaire[
      '${player.id}$dashboardEstimKeySeparator${opponent.id}'
    ];

    return MatrixMatchupCell(
      existingEstim: existingEstim,
      selectedChoice:
          existingEstim == null ? null : choixParId[existingEstim.choixId],
      isThisMatched: pairesJoueurAdversaireAppariees.contains(
        '${player.id}$dashboardEstimKeySeparator${opponent.id}',
      ),
      isPlayerMatchedElsewhere: joueurIdsApparies.contains(player.id),
      isOpponentMatchedElsewhere:
          adversaireIdsApparies.contains(opponent.id),
      onCellTap: (currentEstim) =>
          estimActions.handleCellTap(context, player, opponent, currentEstim),
      onCellLongPress: (existingEstim) => estimActions.handleCellLongPress(
          context, player, opponent, existingEstim),
    );
  }
}
