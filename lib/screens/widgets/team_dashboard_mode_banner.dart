// ===========================================================================
// Bandeau de mode du tableau de bord (team_dashboard_mode_banner.dart)
// En-tête informatif : mode Capitaine (appariements) ou Joueur (estimations).
// ===========================================================================

import 'package:flutter/material.dart';

class TeamDashboardModeBanner extends StatelessWidget {
  final bool isCaptain;

  const TeamDashboardModeBanner({super.key, required this.isCaptain});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      color: isCaptain
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.05),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              isCaptain
                  ? Icons.security_outlined
                  : Icons.edit_note_outlined,
              color: isCaptain ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCaptain
                    ? "Mode Capitaine : Cliquez sur une cellule pour acter un appariement (match). Appui long pour voir les détails et éditer les estimations de votre équipe."
                    : "Mode Joueur : Cliquez sur votre propre ligne pour renseigner vos estimations.",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCaptain
                      ? theme.colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
