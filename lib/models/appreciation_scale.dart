// Échelle fixe d'appréciation stratégique utilisée par le formulaire
// d'estimation et la matrice du tableau de bord.

import 'choix.dart';

/// Définit les 7 appréciations fixes et les recherches associées.
abstract final class AppreciationScale {
  /// Codes courts exacts, du plus défavorable au plus favorable.
  static const List<String> fixedCodes = [
    '--',
    '-',
    '=-',
    '=',
    '=+',
    '+',
    '++',
  ];

  /// Appréciation pré-sélectionnée à l'ouverture du formulaire.
  static const String defaultCode = '=';

  /// Libellé affiché quand un enregistrement pointe vers un choix inconnu.
  static const String unknownLabel = '??';

  /// Symbole d'appréciation générale absente ou inconnue, affiché en gris.
  static const String dicyLabel = 'Dicy';

  /// Renvoie le choix correspondant à un code court exact.
  static Choix? choiceByCode(List<Choix> availableChoices, String code) {
    for (final choice in availableChoices) {
      if (choice.short == code) {
        return choice;
      }
    }
    return null;
  }

  /// Renvoie le choix correspondant à un identifiant PocketBase.
  static Choix? choiceById(List<Choix> availableChoices, String? choiceId) {
    if (choiceId == null) {
      return null;
    }
    for (final choice in availableChoices) {
      if (choice.id == choiceId) {
        return choice;
      }
    }
    return null;
  }

  /// Renvoie uniquement les choix appartenant à l'échelle fixe, ordonnés.
  static List<Choix> scaleChoices(List<Choix> availableChoices) {
    final scaleChoiceList = availableChoices
        .where((choice) => fixedCodes.contains(choice.short))
        .toList();
    return orderedChoices(scaleChoiceList);
  }

  /// Ordonne des choix selon l'échelle fixe sans modifier la liste source.
  static List<Choix> orderedChoices(List<Choix> availableChoices) {
    final orderedChoiceList = [...availableChoices];
    orderedChoiceList.sort((choiceA, choiceB) {
      final positionA = fixedCodes.indexOf(choiceA.short);
      final positionB = fixedCodes.indexOf(choiceB.short);
      final sortedPositionA = positionA == -1 ? fixedCodes.length : positionA;
      final sortedPositionB = positionB == -1 ? fixedCodes.length : positionB;
      if (sortedPositionA != sortedPositionB) {
        return sortedPositionA.compareTo(sortedPositionB);
      }
      return choiceA.short.compareTo(choiceB.short);
    });
    return orderedChoiceList;
  }
}
