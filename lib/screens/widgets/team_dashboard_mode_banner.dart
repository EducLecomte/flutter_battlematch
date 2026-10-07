// ===========================================================================
// Bandeau de mode du tableau de bord (team_dashboard_mode_banner.dart)
// En-tête informatif : mode Capitaine (appariements) ou Joueur (estimations).
// ===========================================================================

import 'package:flutter/material.dart';

class TeamDashboardModeBanner extends StatelessWidget {
  final bool isCaptain;
  final bool canViewSummary;
  final bool canToggleMatched;
  final bool canEditEstims;

  const TeamDashboardModeBanner({
    super.key, 
    required this.isCaptain,
    required this.canViewSummary,
    required this.canToggleMatched,
    required this.canEditEstims,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Déterminer le mode d'affichage basé sur les permissions effectives
    final mode = _determineMode(
      isCaptain: isCaptain,
      canViewSummary: canViewSummary,
      canToggleMatched: canToggleMatched,
      canEditEstims: canEditEstims,
    );

    return Card(
      elevation: 1,
      color: mode.isCaptain
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : Colors.grey.withValues(alpha: 0.05),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              mode.isCaptain
                  ? Icons.security_outlined
                  : Icons.edit_note_outlined,
              color: mode.isCaptain ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mode.text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: mode.isCaptain
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

  // Détermine le mode d'affichage et le texte approprié en fonction des permissions
  _ModeInfo _determineMode({
    required bool isCaptain,
    required bool canViewSummary,
    required bool canToggleMatched,
    required bool canEditEstims,
  }) {
    // Si c'est le capitaine, mode capitan
    if (isCaptain) {
      return _ModeInfo(
        isCaptain: true,
        text: "Mode Capitaine : Cliquez sur une cellule pour acter un appariement (match). Appui long pour voir les détails et éditer les estimations de votre équipe.",
      );
    }
    
    // Si l'utilisateur a des permissions avancées, mode spécifié
    if (canViewSummary || canToggleMatched || canEditEstims) {
      final List<String> permissions = [];
      if (canViewSummary) permissions.add("voir les colonnes Moy. / Δ");
      if (canToggleMatched) permissions.add("matcher les parties");
      if (canEditEstims) permissions.add("modifier les estimations des autres");
      
      final permissionsText = permissions.join(" et ");
      return _ModeInfo(
        isCaptain: false,
        text: "Mode Membre : Vous pouvez $permissionsText.",
      );
    }
    
    // Sinon, mode joueur standard
    return _ModeInfo(
      isCaptain: false,
      text: "Mode Joueur : Cliquez sur votre propre ligne pour renseigner vos estimations.",
    );
  }
}

class _ModeInfo {
  final bool isCaptain;
  final String text;

  _ModeInfo({
    required this.isCaptain,
    required this.text,
  });
}
