// Conversion sécurisée d'une couleur hexadécimale `#RRGGBB` en `Color`.

import 'package:flutter/material.dart';

/// Analyse une chaîne hexadécimale sans lever d'exception sur une valeur
/// mal formée.
abstract final class HexColorParser {
  static const int hexadecimalRadix = 16;
  static const int expectedHexadecimalDigitCount = 6;
  static const int fullOpacityMask = 0xFF000000;

  /// Renvoie la couleur correspondante, ou `null` si la valeur est invalide.
  static Color? parseHexadecimalColor(String hexadecimalColorValue) {
    final normalizedColorValue =
        hexadecimalColorValue.trim().replaceFirst('#', '');
    if (normalizedColorValue.length != expectedHexadecimalDigitCount) {
      return null;
    }
    final int? colorValue =
        int.tryParse(normalizedColorValue, radix: hexadecimalRadix);
    if (colorValue == null) {
      return null;
    }
    return Color(fullOpacityMask | colorValue);
  }
}
