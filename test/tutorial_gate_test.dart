// ===========================================================================
// Tests du point 10 du MEMO — tutoriel de bienvenue à la première connexion.
// Le drapeau « tutoriel vu » est stocké en local (SharedPreferences, par
// navigateur) ; les tests utilisent les valeurs mockées (aucun réseau).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_metawar/config/app_config.dart';
import 'package:flutter_metawar/screens/widgets/tutoriel_gate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('point 10 MEMO — tutoriel à la première connexion', () {
    testWidgets('affiché à la première connexion, puis plus jamais', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        const MaterialApp(home: TutorielGate(child: SizedBox.expand())),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      // Le tutoriel est visible.
      expect(find.text('Bienvenue sur Match Maker !'), findsOneWidget);

      // La fermer (bouton) pose le drapeau local.
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(find.text('Bienvenue sur Match Maker !'), findsNothing);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool(sharedPreferencesKeyTutorielVu), isTrue);
    });

    testWidgets('non affiché quand le drapeau est déjà posé', (tester) async {
      SharedPreferences.setMockInitialValues({
        sharedPreferencesKeyTutorielVu: true,
      });

      await tester.pumpWidget(
        const MaterialApp(home: TutorielGate(child: SizedBox.expand())),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue sur Match Maker !'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
