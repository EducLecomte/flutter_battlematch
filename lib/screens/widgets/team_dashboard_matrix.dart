// ===========================================================================
// Matrice d'estimations du tableau de bord (team_dashboard_matrix.dart)
// Tableau joueur×adversaire : en-têtes adversaires, lignes de joueurs,
// cellules de matchup. Indices O(1) pour le rendu.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../logic/matrix_score_summary.dart';
import '../../models/models.dart';
import '../team_dashboard_controller.dart';
import '../team_dashboard_estim_actions.dart';
import 'team_dashboard_matrix_opponent_header_cell.dart';
import 'team_dashboard_matrix_player_row.dart';
import 'team_dashboard_matrix_summary_cell.dart';

class TeamDashboardMatrix extends StatelessWidget {
  /// Écart entre la grille joueurs×adversaires et les blocs de synthèse
  /// détachés (colonne et ligne « Moy. / Δ »).
  static const double _summaryGap = 14;
  static const double _playerColumnWidth = 140;
  static const double _opponentColumnWidth = 100;

  final TeamDashboardController controller;
  final TeamDashboardEstimActions estimActions;
  final List<TeamMeta> opponents;
  final List<Estim> estims;
  final List<Matched> matches;
  final bool showSummary;
  final void Function(TeamMeta opponent) onOpponentHeaderTap;

  const TeamDashboardMatrix({
    super.key,
    required this.controller,
    required this.estimActions,
    required this.opponents,
    required this.estims,
    required this.matches,
    required this.showSummary,
    required this.onOpponentHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (opponents.isEmpty) {
      return const Center(
        child: Text(
          "Aucun adversaire n'est enregistré pour le moment.\nUtilisez l'import New Recruit pour configurer la ronde.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final theme = Theme.of(context);

    // Index O(1) pour le rendu de la matrice : évite les
    // firstWhere/any coûteux relancés pour chaque cellule.
    final Map<String, Estim> estimParJoueurEtAdversaire = {
      for (final estim in estims)
        '${estim.joueurId}$dashboardEstimKeySeparator${estim.teamMetaId}':
            estim,
    };
    final Set<String> joueurIdsApparies = {
      for (final appariement in matches) appariement.joueurId,
    };
    final Set<String> adversaireIdsApparies = {
      for (final appariement in matches) appariement.teamMetaId,
    };
    final Set<String> pairesJoueurAdversaireAppariees = {
      for (final appariement in matches)
        '${appariement.joueurId}$dashboardEstimKeySeparator${appariement.teamMetaId}',
    };
    final Map<String, Choix> choixParId = {
      for (final choix in controller.choiceList) choix.id: choix,
    };

    // Calculs de synthèse (moyenne et delta max - min), réservés au capitaine
    final Map<String, MatrixScoreSummary> playerSummaries = !showSummary
        ? const {}
        : {
            for (final player in controller.teamMembers)
              player.id: MatrixScoreSummaryCalculator.summarize([
                for (final opponent in opponents)
                  estimParJoueurEtAdversaire['${player.id}$dashboardEstimKeySeparator${opponent.id}'],
              ]),
          };
    final Map<String, MatrixScoreSummary> opponentSummaries = !showSummary
        ? const {}
        : {
            for (final opponent in opponents)
              opponent.id: MatrixScoreSummaryCalculator.summarize([
                for (final player in controller.teamMembers)
                  estimParJoueurEtAdversaire['${player.id}$dashboardEstimKeySeparator${opponent.id}'],
              ]),
          };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Grille joueurs×adversaires + colonne de synthèse détachée
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  // Largeur des colonnes (première colonne Joueurs fixe,
                  // les autres identiques)
                  defaultColumnWidth: const FixedColumnWidth(
                    _opponentColumnWidth,
                  ),
                  columnWidths: const {0: FixedColumnWidth(_playerColumnWidth)},
                  border: TableBorder.all(color: theme.dividerColor),
                  children: [
                    // En-tête (Adversaires / Armées)
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                      children: [
                        // Cellule d'angle
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: SizedBox(
                            height: MatrixOpponentHeaderCell.headerRowHeight,
                            child: const Center(
                              child: Text(
                                "Joueurs",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        // Les en-têtes adverses
                        for (final opponent in opponents)
                          MatrixOpponentHeaderCell(
                            opponent: opponent,
                            army: controller.armyForOpponent(
                              opponent,
                              fallbackName: '?',
                            ),
                            onOpponentTap: onOpponentHeaderTap,
                          ),
                      ],
                    ),

                    // Les lignes de nos joueurs
                    for (final player in controller.teamMembers)
                      MatrixPlayerRow(
                        player: player,
                        opponents: opponents,
                        estimActions: estimActions,
                        estimParJoueurEtAdversaire: estimParJoueurEtAdversaire,
                        choixParId: choixParId,
                        joueurIdsApparies: joueurIdsApparies,
                        adversaireIdsApparies: adversaireIdsApparies,
                        pairesJoueurAdversaireAppariees:
                            pairesJoueurAdversaireAppariees,
                        playerColumnColor: theme.cardColor,
                      ).build(context),
                  ],
                ),
                if (showSummary) ...[
                  const SizedBox(width: _summaryGap),
                  // Colonne de synthèse détachée (moyenne / delta par joueur)
                  Column(
                    children: [
                      const SizedBox(
                        width: _opponentColumnWidth,
                        height: MatrixOpponentHeaderCell.headerRowHeight,
                        child: Center(
                          child: Text(
                            "Moy. / Δ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      for (final player in controller.teamMembers)
                        SizedBox(
                          width: _opponentColumnWidth,
                          height: MatrixSummaryCell.cellHeight,
                          child: MatrixSummaryCell(
                            summary:
                                playerSummaries[player.id] ??
                                const MatrixScoreSummary(
                                  count: 0,
                                  average: null,
                                  delta: null,
                                ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),

            if (showSummary) ...[
              SizedBox(height: _summaryGap),

              // 2. Ligne de synthèse détachée (moyenne inverse / delta par
              // adversaire)
              Row(
                children: [
                  const SizedBox(
                    width: _playerColumnWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Moy. inv. / Δ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  for (final opponent in opponents)
                    SizedBox(
                      width: _opponentColumnWidth,
                      height: MatrixSummaryCell.cellHeight,
                      child: MatrixSummaryCell(
                        summary:
                            opponentSummaries[opponent.id] ??
                            const MatrixScoreSummary(
                              count: 0,
                              average: null,
                              delta: null,
                            ),
                        inverseAverage: true,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
