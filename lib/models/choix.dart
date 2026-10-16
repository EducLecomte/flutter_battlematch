// Représente un choix d'estimation coloré du référentiel (collection `choix`).

import 'package:pocketbase/pocketbase.dart';

class Choix {
  final String id;
  final String libelle; // "Entre 8 et 12"
  final String short; // "8-12"
  final String couleurHex; // "#FBC02D"
  final int? scoreDefaut;

  Choix({
    required this.id,
    required this.libelle,
    required this.short,
    required this.couleurHex,
    this.scoreDefaut,
  });

  /// Renvoie le score par défaut : la valeur stockée si définie,
  /// sinon la valeur par défaut standard associée au code court.
  int get defaultScore {
    if (scoreDefaut != null) return scoreDefaut!;
    return defaultScoreForShort(short);
  }

  /// Score par défaut standard de l'échelle (--:2 ; -:5; =-:7; =:10; =+:13; +:15; ++:18).
  static int defaultScoreForShort(String shortCode) {
    switch (shortCode) {
      case '--':
        return 2;
      case '-':
        return 5;
      case '=-':
        return 7;
      case '=':
        return 10;
      case '=+':
        return 13;
      case '+':
        return 15;
      case '++':
        return 18;
      default:
        return 10;
    }
  }

  factory Choix.fromPocketBaseRecord(RecordModel record) {
    return Choix(
      id: record.id,
      libelle: record.get<String>('libelle'),
      short: record.get<String>('short'),
      couleurHex: record.get<String>('couleur_hex'),
      scoreDefaut: record.get<num?>('score_defaut', null)?.toInt(),
    );
  }
}
