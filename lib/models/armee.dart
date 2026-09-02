// Représente une armée/faction du référentiel (collection `armees`).

import 'package:pocketbase/pocketbase.dart';

class Armee {
  final String id;
  final String nom;
  final String short; // BH, DE, etc.

  Armee({
    required this.id,
    required this.nom,
    required this.short,
  });

  factory Armee.fromPocketBaseRecord(RecordModel record) {
    return Armee(
      id: record.id,
      nom: record.get<String>('nom'),
      short: record.get<String>('short'),
    );
  }
}
