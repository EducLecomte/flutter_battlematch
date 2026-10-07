// ===========================================================================
// Corps du tableau de bord d'équipe (team_dashboard_body.dart)
// Empile les flux temps réel (adversaires, estimations, appariements)
// et compose le bandeau de mode et la matrice.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../logic/matched_score_summary.dart';
import '../../models/models.dart';
import '../team_dashboard_controller.dart';
import '../team_dashboard_estim_actions.dart';
import 'opponent_details_dialog.dart';
import 'team_dashboard_matrix.dart';
import 'team_dashboard_mode_banner.dart';
import 'team_dashboard_score_summary.dart';

class TeamDashboardBody extends StatelessWidget {
  final TeamDashboardController controller;
  final TeamDashboardEstimActions estimActions;
  final bool isCaptain;
  final bool canViewSummary;
  final bool canToggleMatched;
  final Future<void> Function(TeamMeta opponent) onOpponentDeleted;

  const TeamDashboardBody({
    super.key,
    required this.controller,
    required this.estimActions,
    required this.isCaptain,
    required this.canViewSummary,
    required this.canToggleMatched,
    required this.onOpponentDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamMeta>>(
      stream: controller.opponentsStream,
      builder: (context, opponentsSnapshot) {
        final opponents = opponentsSnapshot.data ?? [];

        return StreamBuilder<List<Estim>>(
          stream: controller.estimsStream,
          builder: (context, estimsSnapshot) {
            final estims = estimsSnapshot.data ?? [];

            return StreamBuilder<List<Matched>>(
              stream: controller.matchedStream,
              builder: (context, matchedSnapshot) {
                if (opponentsSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    opponents.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final matches = matchedSnapshot.data ?? [];
                final estimsByKey = {
                  for (final estim in estims)
                    '${estim.joueurId}$dashboardEstimKeySeparator${estim.teamMetaId}':
                        estim,
                };
                final matchedScoreSummary =
                    MatchedScoreSummaryCalculator.summarize(
                      matches,
                      estimsByKey,
                      dashboardEstimKeySeparator,
                    );

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TeamDashboardModeBanner(
                        isCaptain: isCaptain,
                        canToggleMatched: canToggleMatched,
                        canViewSummary: canViewSummary,
                        canEditEstims: controller.isCaptainOrCanEditEstims(),
                      ),
                      const SizedBox(height: 16),
                      TeamDashboardScoreSummary(summary: matchedScoreSummary),
                      if (matchedScoreSummary.matchedCount > 0)
                        const SizedBox(height: 16),
                      Expanded(
                        child: TeamDashboardMatrix(
                          controller: controller,
                          estimActions: estimActions,
                          opponents: opponents,
                          estims: estims,
                          matches: matches,
                          showSummary: canViewSummary,
                          onOpponentHeaderTap: (opponent) =>
                              showOpponentDetailsDialog(
                                context,
                                opponent: opponent,
                                army: controller.armyForOpponent(opponent),
                                canDelete: isCaptain,
                                onDelete: () => onOpponentDeleted(opponent),
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
