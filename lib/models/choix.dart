// Représente un choix d'estimation coloré du référentiel (collection `choix`).

import 'package:pocketbase/pocketbase.dart';

/// Identifiant sentinelle signifiant "aucun choix d'estimation sélectionné".
/// Utilisé par la matrice du tableau de bord pour repérer les cellules vides.
const String choixEstimationInexistanteId = '0';

/// Identifiant du choix d'estimation pré-sélectionné à l'ouverture du
/// formulaire ("Entre 5 et 7" dans le référentiel `choix`).
const String choixEstimationDefautId = '3';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'short': short,
      'couleur_hex': couleurHex,
    };
  }
}
