// Conversions sécurisées entre couleurs hexadécimales `#RRGGBB` (format
// stocké dans PocketBase) et `Color`.

import 'package:flutter/material.dart';

/// Analyse une chaîne hexadécimale sans lever d'exception sur une valeur
/// mal formée.
abstract final class HexColorParser {
  static const int hexadecimalRadix = 16;
  static const int expectedHexadecimalDigitCount = 6;
  static const int fullOpacityMask = 0xFF000000;

  /// Renvoie la couleur correspondante, ou `null` si la valeur est invalide.
  static Color? parseHexadecimalColor(String hexadecimalColorValue) {
    final int? colorValue =
        parseHexadecimalColorValue(hexadecimalColorValue);
    if (colorValue == null) {
      return null;
    }
    return Color(fullOpacityMask | colorValue);
  }

  /// Normalise une valeur en `#RRGGBB` majuscule (format stocké dans
  /// PocketBase), ou `null` si la valeur est invalide.
  static String? normalizeHexadecimalColor(String hexadecimalColorValue) {
    final int? colorValue =
        parseHexadecimalColorValue(hexadecimalColorValue);
    if (colorValue == null) {
      return null;
    }
    return '#${colorValue.toRadixString(hexadecimalRadix).padLeft(
        expectedHexadecimalDigitCount, '0').toUpperCase()}';
  }

  /// Convertit une couleur en chaîne `#RRGGBB` majuscule (format stocké dans
  /// PocketBase) ; la composante alpha est ignorée.
  static String colorToHexString(Color color) {
    final int colorValue = 0x00FFFFFF & color.toARGB32();
    return '#${colorValue.toRadixString(hexadecimalRadix).padLeft(
        expectedHexadecimalDigitCount, '0').toUpperCase()}';
  }

  /// Extrait la valeur entière d'une couleur hexadécimale, ou `null`.
  static int? parseHexadecimalColorValue(String hexadecimalColorValue) {
    final String normalizedColorValue =
        hexadecimalColorValue.trim().replaceFirst('#', '');
    if (normalizedColorValue.length != expectedHexadecimalDigitCount) {
      return null;
    }
    return int.tryParse(normalizedColorValue, radix: hexadecimalRadix);
  }
}
