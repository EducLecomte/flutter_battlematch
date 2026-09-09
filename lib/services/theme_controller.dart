// ===========================================================================
// Contrôle du mode d'affichage (theme_controller.dart).
// Bascule clair/sombre (MEMO 11) partagée entre l'écran de profil (bascule)
// et la racine de l'application (application du thème), persistée en local.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Valeur persistée du mode clair dans [SharedPreferences].
const String themeModeClairValue = 'light';

/// Valeur persistée du mode sombre dans [SharedPreferences].
const String themeModeSombreValue = 'dark';

/// Contrôleur d'état du mode d'affichage clair/sombre (MEMO 11).
///
/// Singleton [ChangeNotifier] : la racine de l'application y est abonnée
/// (via `ListenableBuilder`) pour appliquer [ThemeMode] au [MaterialApp], et
/// la section « Paramètres » du profil modifie l'état via [setThemeMode].
/// Le choix est persisté dans [SharedPreferences] (par navigateur), sans
/// migration de schéma PocketBase.
class ThemeController extends ChangeNotifier {
  ThemeController._internal();

  /// Instance unique du contrôleur de thème.
  static final ThemeController instance = ThemeController._internal();

  ThemeMode _mode = ThemeMode.light;

  /// Mode d'affichage courant.
  ThemeMode get themeMode => _mode;

  /// Lit la valeur persistée et l'applique. À appeler impérativement dans
  /// `main()` avant `runApp()`. Sans valeur stockée (ou valeur inattendue),
  /// conserve le mode clair, qui est le comportement initial de l'application.
  Future<void> init() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? valeur = preferences.getString(sharedPreferencesKeyThemeMode);
    _mode = valeur == themeModeSombreValue ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Applique [mode], notifie les abonnés puis persiste le choix.
  ///
  /// La notification est émise avant l'écriture asynchrone : l'interface
  /// bascule immédiatement, la persistance suit (écriture locale rapide).
  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      sharedPreferencesKeyThemeMode,
      mode == ThemeMode.dark ? themeModeSombreValue : themeModeClairValue,
    );
  }
}
