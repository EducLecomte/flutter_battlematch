// ===========================================================================
// Cellule d'en-tête adversaire de la matrice
// (team_dashboard_matrix_opponent_header_cell.dart)
// Nom du joueur adverse + sigle d'armée ; le tap ouvre les détails.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class MatrixOpponentHeaderCell extends StatelessWidget {
  final MetaAdv opponent;
  final Armee army;
  final void Function(MetaAdv opponent) onOpponentTap;

  const MatrixOpponentHeaderCell({
    super.key,
    required this.opponent,
    required this.army,
    required this.onOpponentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        onTap: () => onOpponentTap(opponent),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opponent.nomJoAdv ?? 'Adv',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                army.short,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
