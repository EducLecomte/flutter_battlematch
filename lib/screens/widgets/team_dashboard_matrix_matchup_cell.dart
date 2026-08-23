// ===========================================================================
// Cellule de matchup de la matrice (team_dashboard_matrix_matchup_cell.dart)
// Affiche pour un couple (joueur, adversaire) : le verrou d'appariement,
// le blocage d'un partenaire déjà apparié, ou l'estimation colorée.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class MatrixMatchupCell extends StatelessWidget {
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

    // Style de la cellule
    Color cellColor = Colors.transparent;
    String textToShow = '-';
    Color textColor =
        theme.textTheme.bodyMedium?.color ?? Colors.white;

    if (isThisMatched) {
      // Cas 1 : Appariement validé par le capitaine -> Cellule noire
      cellColor = Colors.black87;
      textToShow = "MATCH";
      textColor = Colors.white;
    } else if (isPlayerMatchedElsewhere || isOpponentMatchedElsewhere) {
      // Cas 2 : Le joueur ou l'adversaire est apparié dans un autre duel
      // -> Case grisée/bloquée
      cellColor = theme.disabledColor.withValues(alpha: 0.05);
      textToShow = '';
      textColor = Colors.grey;
    } else if (existingEstim != null && selectedChoice != null) {
      // Cas 3 : Une estimation valide existe -> On colore la cellule
      final choice = selectedChoice!;
      cellColor = Color(
        int.parse(choice.couleurHex.replaceFirst('#', '0xFF')),
      );
      textToShow = choice.short;
      textColor = Colors.white;
    }

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Material(
        color: cellColor,
        child: InkWell(
          onTap: () => onCellTap(existingEstim),
          onLongPress: () => onCellLongPress(existingEstim),
          child: Container(
            height: 48,
            alignment: Alignment.center,
            child: isThisMatched
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "MATCH",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    textToShow,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
