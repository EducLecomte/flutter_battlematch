// ===========================================================================
// Matrice d'estimations du tableau de bord (team_dashboard_matrix.dart)
// Tableau joueur×adversaire : en-têtes adversaires, lignes de joueurs,
// cellules de matchup. Indices O(1) pour le rendu.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import '../team_dashboard_controller.dart';
import '../team_dashboard_estim_actions.dart';
import 'team_dashboard_matrix_opponent_header_cell.dart';
import 'team_dashboard_matrix_player_row.dart';

class TeamDashboardMatrix extends StatelessWidget {
  final TeamDashboardController controller;
  final TeamDashboardEstimActions estimActions;
  final List<MetaAdv> opponents;
  final List<Estim> estims;
  final List<Matched> matches;
  final void Function(MetaAdv opponent) onOpponentHeaderTap;

  const TeamDashboardMatrix({
    super.key,
    required this.controller,
    required this.estimActions,
    required this.opponents,
    required this.estims,
    required this.matches,
    required this.onOpponentHeaderTap,
  });

  @override
  Widget build(BuildContext context) {
    if (opponents.isEmpty) {
      return const Center(
        child: Text(
          "Aucun adversaire n'est enregistré pour le moment.\nUtilisez 'Adversaire' ou 'New Recruit' pour configurer la ronde.",
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
        '${estim.joueurId}$dashboardEstimKeySeparator${estim.metaAdvId}':
            estim,
    };
    final Set<String> joueurIdsApparies = {
      for (final appariement in matches) appariement.joueurId,
    };
    final Set<String> adversaireIdsApparies = {
      for (final appariement in matches) appariement.metaAdvId,
    };
    final Set<String> pairesJoueurAdversaireAppariees = {
      for (final appariement in matches)
        '${appariement.joueurId}$dashboardEstimKeySeparator${appariement.metaAdvId}',
    };
    final Map<String, Choix> choixParId = {
      for (final choix in controller.choiceList) choix.id: choix,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          // Largeur des colonnes (première colonne Joueurs fixe,
          // les autres identiques)
          defaultColumnWidth: const FixedColumnWidth(100),
          columnWidths: const {
            0: FixedColumnWidth(140), // Colonne pour nos joueurs
          },
          border: TableBorder.all(color: theme.dividerColor),
          children: [
            // 1. Ligne d'en-tête (Adversaires / Armées)
            TableRow(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              children: [
                // Cellule d'angle
                const TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Text(
                      "Joueurs",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Les en-têtes adverses
                for (final opponent in opponents)
                  MatrixOpponentHeaderCell(
                    opponent: opponent,
                    army:
                        controller.armyForOpponent(opponent, fallbackName: '?'),
                    onOpponentTap: onOpponentHeaderTap,
                  ),
              ],
            ),

            // 2. Les lignes de nos joueurs
            for (final player in controller.teamMembers)
              MatrixPlayerRow(
                player: player,
                opponents: opponents,
                estimActions: estimActions,
                estimParJoueurEtAdversaire: estimParJoueurEtAdversaire,
                choixParId: choixParId,
                joueurIdsApparies: joueurIdsApparies,
                adversaireIdsApparies: adversaireIdsApparies,
                pairesJoueurAdversaireAppariees: pairesJoueurAdversaireAppariees,
                playerColumnColor: theme.cardColor,
              ).build(context),
          ],
        ),
      ),
    );
  }
}
