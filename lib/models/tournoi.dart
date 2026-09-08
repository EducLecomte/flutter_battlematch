// Représente un tournoi (collection `tournois`).

import 'package:pocketbase/pocketbase.dart';

class Tournoi {
  final String id;
  final String nom;
  final String? createdBy;
  final bool importEffectue;

  Tournoi({
    required this.id,
    required this.nom,
    this.createdBy,
    this.importEffectue = false,
  });

  factory Tournoi.fromPocketBaseRecord(RecordModel record) {
    return Tournoi(
      id: record.id,
      nom: record.get<String>('nom'),
      createdBy: record.get<String?>('created_by', null),
      importEffectue: record.get<bool>('import_effectue', false),
    );
  }
}
