// Représente un tournoi (collection `tournois`).

import 'package:pocketbase/pocketbase.dart';

class Tournoi {
  final String id;
  final String nom;
  final String lienNr; // Lien obligatoire vers New Recruit
  final String? createdBy;
  final bool importEffectue;

  Tournoi({
    required this.id,
    required this.nom,
    this.lienNr = '',
    this.createdBy,
    this.importEffectue = false,
  });

  factory Tournoi.fromPocketBaseRecord(RecordModel record) {
    return Tournoi(
      id: record.id,
      nom: record.get<String>('nom'),
      lienNr: record.get<String>('lien_nr', ''),
      createdBy: record.get<String?>('created_by', null),
      importEffectue: record.get<bool>('import_effectue', false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'lien_nr': lienNr,
      'created_by': createdBy,
      'import_effectue': importEffectue,
    };
  }
}
