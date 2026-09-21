// ===========================================================================
// Tests du point 11 du MEMO — section « Paramètres » du profil.
// Vérifie la bascule clair/sombre, le dialog « À propos » et la
// re-visualisation du tutoriel. Le thème est piloté par le singleton
// ThemeController, réinitialisé à chaque test via les valeurs mockées.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_metawar/screens/widgets/profile_settings_section.dart';
import 'package:flutter_metawar/services/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('point 11 MEMO — section Paramètres du profil', () {
    Future<void> pomperSection(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      await ThemeController.instance.init();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProfileSettingsSection())),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('présente la bascule thème, l\'à-propos et le tutoriel', (
      tester,
    ) async {
      await pomperSection(tester);

      // Bascule « Mode sombre » présente, désactivée (mode clair par défaut).
      final SwitchListTile bascule = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(bascule.value, isFalse);

      expect(find.text('À propos de Battle match'), findsOneWidget);
      expect(find.text('Revoir le tutoriel'), findsOneWidget);
    });

    testWidgets('la bascule passe l\'application en mode sombre', (
      tester,
    ) async {
      await pomperSection(tester);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(ThemeController.instance.themeMode, ThemeMode.dark);
      final SwitchListTile bascule = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );
      expect(bascule.value, isTrue);
    });

    testWidgets('re-visionne le tutoriel de bienvenue', (tester) async {
      await pomperSection(tester);

      await tester.tap(find.text('Revoir le tutoriel'));
      await tester.pumpAndSettle();

      expect(find.text('Bienvenue sur Battle match !'), findsOneWidget);
    });

    testWidgets('ouvre le dialog « À propos »', (tester) async {
      await pomperSection(tester);

      await tester.tap(find.text('À propos de Battle match'));
      await tester.pumpAndSettle();

      // La version de l'application est propre au dialog « À propos ».
      expect(find.text('1.0.0'), findsOneWidget);
    });
  });
}
