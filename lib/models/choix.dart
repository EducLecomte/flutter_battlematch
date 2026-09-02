// Représente un choix d'estimation coloré du référentiel (collection `choix`).

import 'package:pocketbase/pocketbase.dart';

class Choix {
  final String id;
  final String libelle; // "Entre 8 et 12"
  final String short; // "8-12"
  final String couleurHex; // "#FBC02D"

  Choix({
    required this.id,
    required this.libelle,
    required this.short,
    required this.couleurHex,
  });

  factory Choix.fromPocketBaseRecord(RecordModel record) {
    return Choix(
      id: record.id,
      libelle: record.get<String>('libelle'),
      short: record.get<String>('short'),
      couleurHex: record.get<String>('couleur_hex'),
    );
  }
}
