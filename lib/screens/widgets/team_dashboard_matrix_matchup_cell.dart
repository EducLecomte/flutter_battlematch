// ===========================================================================
// Cellule de matchup de la matrice (team_dashboard_matrix_matchup_cell.dart)
// Affiche pour un couple (joueur, adversaire) : le verrou d'appariement,
// l'appréciation générale (Dicy en gris si absente), la fourchette du score
// estimé et l'étoile de confiance. Les valeurs restent visibles même quand
// la cellule est verrouillée ou bloquée par un appariement ailleurs.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../logic/estim_score_calculator.dart';
import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';
import 'confiance_star_icon.dart';

class MatrixMatchupCell extends StatelessWidget {
  static const double matchupCellHeight = 64;
  static const double matchedLockIconSize = 14;
  static const double detailElementSpacing = 4;
  static const double detailLineSpacing = 2;
  static const double matchedScoreFontSize = 10;
  static const double appreciationFontSize = 13;
  static const double confidenceIconSize = 12;
  static const double unknownAppreciationBackgroundOpacity = 0.1;
  static const Color dicySymbolColor = Colors.grey;

  final Estim? existingEstim;
  final Choix? selectedChoice;
  final bool isThisMatched;
  final bool isPlayerMatchedElsewhere;
  final bool isOpponentMatchedElsewhere;
  final void Function(Estim? currentEstim) onCellTap;
  final void Function(Estim? existingEstim) onCellLongPress;

  const MatrixMatchupCell({
    super.key,
    this.existingEstim,
    this.selectedChoice,
    required this.isThisMatched,
    required this.isPlayerMatchedElsewhere,
    required this.isOpponentMatchedElsewhere,
    required this.onCellTap,
    required this.onCellLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentEstim = existingEstim;
    final matchedScoreLabel =
        EstimScoreCalculator.scoreRangeLabel(currentEstim);
    final hasKnownAppreciation = currentEstim != null && selectedChoice != null;
    final appreciationLabel = hasKnownAppreciation
        ? selectedChoice!.short
        : AppreciationScale.dicyLabel;
    final knownAppreciationColor = HexColorParser.parseHexadecimalColor(
      selectedChoice?.couleurHex ?? '',
    );
    final isCellBlocked =
        isPlayerMatchedElsewhere || isOpponentMatchedElsewhere;

    Color cellColor = Colors.transparent;
    Color textColor = dicySymbolColor;

    if (isThisMatched) {
      cellColor = Colors.black87;
      textColor = Colors.white;
    } else if (isCellBlocked) {
      cellColor = theme.disabledColor.withValues(alpha: 0.05);
      textColor = Colors.grey;
    } else if (hasKnownAppreciation && knownAppreciationColor != null) {
      cellColor = knownAppreciationColor;
      textColor = Colors.white;
    } else if (currentEstim != null) {
      cellColor = theme.disabledColor
          .withValues(alpha: unknownAppreciationBackgroundOpacity);
    }

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Material(
        color: cellColor,
        child: InkWell(
          onTap: () => onCellTap(currentEstim),
          onLongPress: () => onCellLongPress(currentEstim),
          child: Container(
            height: matchupCellHeight,
            alignment: Alignment.center,
            child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isThisMatched) ...[
                            Icon(
                              Icons.lock,
                              color: textColor,
                              size: matchedLockIconSize,
                            ),
                            const SizedBox(width: detailElementSpacing),
                          ],
                          Text(
                            appreciationLabel,
                            style: TextStyle(
                              color: textColor,
                              fontSize: appreciationFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentEstim != null) ...[
                            const SizedBox(width: detailElementSpacing),
                            ConfidenceStarIcon(
                              confidenceLevel: currentEstim.confiance,
                              iconSize: confidenceIconSize,
                            ),
                          ],
                        ],
                      ),
                      if (matchedScoreLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: detailLineSpacing),
                          child: Text(
                            matchedScoreLabel,
                            style: TextStyle(
                              color: textColor,
                              fontSize: matchedScoreFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
