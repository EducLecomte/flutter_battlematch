// Tests unitaires du parsing sécurisé des couleurs hexadécimales.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/utils/hex_color_parser.dart';

void main() {
  group('HexColorParser', () {
    test('analyse une couleur avec ou sans dièse', () {
      final colorWithHash =
          HexColorParser.parseHexadecimalColor('#FBC02D');
      final colorWithoutHash =
          HexColorParser.parseHexadecimalColor('FBC02D');

      expect(colorWithHash?.toARGB32(), 0xFFFBC02D);
      expect(colorWithoutHash?.toARGB32(), 0xFFFBC02D);
    });

    test('renvoie null pour une valeur mal formée', () {
      expect(HexColorParser.parseHexadecimalColor(''), isNull);
      expect(HexColorParser.parseHexadecimalColor('#FFF'), isNull);
      expect(HexColorParser.parseHexadecimalColor('#GGGGGG'), isNull);
      expect(HexColorParser.parseHexadecimalColor('#FBC02D1'), isNull);
    });

    test('normalise une couleur en #RRGGBB majuscule', () {
      expect(HexColorParser.normalizeHexadecimalColor('#fbC02d'), '#FBC02D');
      expect(HexColorParser.normalizeHexadecimalColor('0a1b2c'), '#0A1B2C');
      expect(HexColorParser.normalizeHexadecimalColor('  #FBC02D  '), '#FBC02D');
    });

    test('la normalisation renvoie null pour une valeur mal formée', () {
      expect(HexColorParser.normalizeHexadecimalColor(''), isNull);
      expect(HexColorParser.normalizeHexadecimalColor('#FFF'), isNull);
      expect(HexColorParser.normalizeHexadecimalColor('#GGGGGG'), isNull);
    });

    test('convertit une couleur en #RRGGBB majuscule (alpha ignoré)', () {
      expect(HexColorParser.colorToHexString(const Color(0xFFFBC02D)),
          '#FBC02D');
      expect(HexColorParser.colorToHexString(const Color(0x800A1B2C)),
          '#0A1B2C');
      expect(
          HexColorParser.colorToHexString(Colors.amber.shade500), '#FFC107');
    });
  });
}
