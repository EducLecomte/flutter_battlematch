import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/widgets/teams_screen_team_access_panel.dart';
import 'package:flutter_metawar/screens/widgets/teams_screen_team_selector.dart';
import 'package:flutter_metawar/utils/error_snack_bar_presenter.dart';

void main() {
  group('point 7 — durée des snackbars', () {
    Future<void> pumpHostPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showErrorSnackBar(context, 'Erreur simulée'),
                  child: const Text('erreur'),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'snackbar d erreur disparaît automatiquement après la durée configurée',
      (tester) async {
        await pumpHostPage(tester);

        await tester.tap(find.text('erreur'));
        // Laisse l'animation d'entrée se terminer : le rebuild qui suit
        // AnimationStatus.completed est celui qui crée le timer de disparition.
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);

        final SnackBar shownSnackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );
        expect(shownSnackBar.duration, snackBarDisplayDuration);

        // Fait expirer le timer de disparition (marge au cas où la deadline
        // coïncide avec la fin du pump), puis laisse l'animation de sortie
        // se terminer et le SnackBar être retiré de l'arbre.
        await tester.pump(
          snackBarDisplayDuration + const Duration(milliseconds: 100),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('point 9 — sélecteur d équipe sans dropdown', () {
    testWidgets('affiche le nom de l équipe active en Text simple', (
      tester,
    ) async {
      final Team team = Team.fromPocketBaseRecord(
        RecordModel({'id': 'team1234567890a', 'nom': 'Ma Team'}),
      );

      await tester.pumpWidget(
        MaterialApp(home: TeamsScreenTeamSelector(activeTeam: team)),
      );

      expect(find.text('Ma Team'), findsOneWidget);
      expect(find.byType(DropdownButton), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('affiche le message d aide sans équipe', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TeamsScreenTeamSelector(activeTeam: null)),
      );

      expect(find.textContaining('Aucune équipe connue'), findsOneWidget);
      expect(find.byType(DropdownButton), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('carte de sélection d équipe reste lisible sur petit écran', (
    tester,
  ) async {
    final Team team = Team.fromPocketBaseRecord(
      RecordModel({
        'id': 'team1234567890a',
        'nom': 'Une équipe au nom assez long',
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            height: 600,
            child: TeamsScreenTeamAccessPanel(
              equipesTournoi: [team],
              isLoading: false,
              onClaimTeam: (_) {},
              onJoinTeam: (_, _) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Devenir capitaine'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
