// ===========================================================================
// Tests de la cellule de synthèse de la matrice
// (team_dashboard_matrix_summary_cell).
// Vérifie l'affichage de la moyenne et du delta, et en particulier la
// moyenne inverse (score maximum - moyenne) activée sur la ligne du bas.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_metawar/logic/matrix_score_summary.dart';
import 'package:flutter_metawar/screens/widgets/team_dashboard_matrix_summary_cell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCell(
    WidgetTester tester, {
    required MatrixScoreSummary summary,
    bool inverseAverage = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MatrixSummaryCell(
              summary: summary,
              inverseAverage: inverseAverage,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('MatrixSummaryCell', () {
    testWidgets('affiche la moyenne et le delta des estimations', (
      tester,
    ) async {
      await pumpCell(
        tester,
        summary: const MatrixScoreSummary(count: 3, average: 12.0, delta: 4.0),
      );

      expect(find.text('12.0'), findsOneWidget);
      expect(find.text('Δ 4.0'), findsOneWidget);
    });

    testWidgets('affiche la moyenne inverse (20 - moyenne) quand activée', (
      tester,
    ) async {
      await pumpCell(
        tester,
        summary: const MatrixScoreSummary(count: 3, average: 8.0, delta: 4.0),
        inverseAverage: true,
      );

      // Moyenne brute 8.0 -> moyenne inverse 12.0 ; le delta est invariant.
      expect(find.text('12.0'), findsOneWidget);
      expect(find.text('8.0'), findsNothing);
      expect(find.text('Δ 4.0'), findsOneWidget);
    });

    testWidgets('affiche des tirets quand aucune estimation n\'existe', (
      tester,
    ) async {
      await pumpCell(
        tester,
        summary: const MatrixScoreSummary(count: 0, average: null, delta: null),
      );

      expect(find.text('-'), findsNWidgets(2));
    });
  });
}
