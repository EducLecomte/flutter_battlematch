// Tests unitaires du parsing sécurisé des couleurs hexadécimales.

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
  });
}
