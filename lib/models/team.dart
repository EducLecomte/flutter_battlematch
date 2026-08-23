import 'package:pocketbase/pocketbase.dart';

/// Représente une équipe permanente (collection `teams`).
class Team {
  final String id;
  final String nom;
  final String? capitaineId;

  Team({
    required this.id,
    required this.nom,
    this.capitaineId,
  });

  factory Team.fromPocketBaseRecord(RecordModel record) {
    return Team(
      id: record.id,
      nom: record.get<String>('nom'),
      capitaineId:
          record.get<String?>('capitaine_id', null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capitaine_id': capitaineId,
    };
  }
}
