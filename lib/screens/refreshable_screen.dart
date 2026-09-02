// ===========================================================================
// Base commune aux écrans du shell principal (refreshable_screen.dart)
// HomeShell conserve tous les onglets en vie via un IndexedStack : leur
// initState ne court qu'une fois. Pour éviter d'afficher des données
// périmées après une navigation dans la barre du bas, le shell rappelle
// refreshOnTabActivated() sur l'écran qui devient visible.
// ===========================================================================

import 'package:flutter/material.dart';

/// Base commune aux states des écrans affichés dans le shell principal.
///
/// `HomeShell` (main.dart) détient une [GlobalKey] vers le state de chaque
/// écran et appelle [refreshOnTabActivated] sur l'écran qui vient de
/// devenir actif dans la barre de navigation du bas.
abstract class RefreshableScreenState<T extends StatefulWidget> extends State<T> {
  /// Recharge les données de l'écran.
  ///
  /// Appelé par `HomeShell` à l'activation de l'onglet correspondant
  /// (navigation dans la barre du bas, y compris en retapant l'onglet
  /// déjà actif).
  void refreshOnTabActivated() {}
}
