// ===========================================================================
// Tests du point 11 du MEMO — contrôleur du mode d'affichage clair/sombre.
// Le choix est persisté en local (SharedPreferences, par navigateur) ; les
// tests utilisent les valeurs mockées (aucun réseau).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_metawar/config/app_config.dart';
import 'package:flutter_metawar/services/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('point 11 MEMO — contrôleur de thème (clair/sombre)', () {
    // Le contrôleur est un singleton : on réinitialise son état à chaque test
    // en (re)chargeant la valeur persistée mockée.
    Future<void> initialiserAvec(Map<String, Object> valeurs) async {
      SharedPreferences.setMockInitialValues(valeurs);
      await ThemeController.instance.init();
    }

    test('sans valeur stockée, le mode est clair (comportement initial)', () async {
      await initialiserAvec({});
      expect(ThemeController.instance.themeMode, ThemeMode.light);
    });

    test('la valeur sombre persistée est rétablie au démarrage', () async {
      await initialiserAvec({
        sharedPreferencesKeyThemeMode: themeModeSombreValue,
      });
      expect(ThemeController.instance.themeMode, ThemeMode.dark);
    });

    test('une valeur inattendue retombe sur le mode clair', () async {
      await initialiserAvec({
        sharedPreferencesKeyThemeMode: 'inattendu',
      });
      expect(ThemeController.instance.themeMode, ThemeMode.light);
    });

    test('setThemeMode(sombre) met à jour l\'état et persiste', () async {
      await initialiserAvec({});
      await ThemeController.instance.setThemeMode(ThemeMode.dark);

      expect(ThemeController.instance.themeMode, ThemeMode.dark);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(sharedPreferencesKeyThemeMode),
        themeModeSombreValue,
      );
    });

    test('setThemeMode(clair) met à jour l\'état et persiste', () async {
      await initialiserAvec({
        sharedPreferencesKeyThemeMode: themeModeSombreValue,
      });
      await ThemeController.instance.setThemeMode(ThemeMode.light);

      expect(ThemeController.instance.themeMode, ThemeMode.light);
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(sharedPreferencesKeyThemeMode),
        themeModeClairValue,
      );
    });
  });
}
