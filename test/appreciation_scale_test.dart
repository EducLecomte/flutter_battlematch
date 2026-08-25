// Tests unitaires de l'échelle fixe d'appréciation stratégique.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/models/models.dart';

Choix buildTestChoix(
  String choixId,
  String choixLibelle,
  String choixCodeCourt,
  String choixCouleurHex,
) {
  return Choix(
    id: choixId,
    libelle: choixLibelle,
    short: choixCodeCourt,
    couleurHex: choixCouleurHex,
  );
}

void main() {
  group('AppreciationScale', () {
    test('définit les sept codes fixes dans l’ordre stratégique', () {
      expect(
        AppreciationScale.fixedCodes,
        ['--', '-', '=-', '=', '=+', '+', '++'],
      );
      expect(AppreciationScale.defaultCode, '=');
      expect(AppreciationScale.unknownLabel, '??');
    });

    test('retrouve un choix par son code court exact', () {
      final choiceList = [
        buildTestChoix('choix00001', 'Défavorable', '-', '#D32F2F'),
        buildTestChoix('choix00002', 'Égalité', '=', '#F9A825'),
      ];

      final matchedChoice =
          AppreciationScale.choiceByCode(choiceList, '=');

      expect(matchedChoice?.id, 'choix00002');
      expect(AppreciationScale.choiceByCode(choiceList, 'x'), isNull);
    });

    test('retrouve un choix par son identifiant PocketBase', () {
      final choiceList = [
        buildTestChoix('choix00001', 'Défavorable', '-', '#D32F2F'),
      ];

      expect(AppreciationScale.choiceById(choiceList, 'choix00001')?.short,
          '-');
      expect(AppreciationScale.choiceById(choiceList, 'choix00002'), isNull);
      expect(AppreciationScale.choiceById(choiceList, null), isNull);
    });

    test('ordonne les codes fixes et repousse les codes inconnus', () {
      final choiceList = [
        buildTestChoix('choix00001', 'Égalité', '=', '#F9A825'),
        buildTestChoix('choix00002', 'Très défavorable', '--', '#B71C1C'),
        buildTestChoix('choix00003', 'Ancien', 'x', '#000000'),
        buildTestChoix('choix00004', 'Lég. favor.', '=+', '#7CB342'),
      ];

      final orderedChoiceList =
          AppreciationScale.orderedChoices(choiceList);

      expect(
        orderedChoiceList.map((choice) => choice.short).toList(),
        ['--', '=', '=+', 'x'],
      );
    });

    test('filtre uniquement les choix de l’échelle fixe', () {
      final choiceList = [
        buildTestChoix('choix00001', 'Favorable', '+', '#388E3C'),
        buildTestChoix('choix00002', 'Ancien', 'x', '#000000'),
      ];

      final scaleChoiceList = AppreciationScale.scaleChoices(choiceList);

      expect(scaleChoiceList.single.short, '+');
    });
  });
}
