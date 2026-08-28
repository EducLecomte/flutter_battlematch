import 'package:pocketbase/pocketbase.dart';

/// Représente une équipe permanente (collection `teams`).
class Team {
  final String id;
  final String nom;
  final String? capitaineId;
  final String tournoiId;
  final String motDePasse;

  Team({
    required this.id,
    required this.nom,
    this.capitaineId,
    this.tournoiId = '',
    this.motDePasse = '',
  });

  factory Team.fromPocketBaseRecord(RecordModel record) {
    return Team(
      id: record.id,
      nom: record.get<String>('nom'),
      capitaineId:
          record.get<String?>('capitaine_id', null),
      tournoiId: record.get<String>('tournoi_id', ''),
      motDePasse: record.get<String>('mot_de_passe', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'capitaine_id': capitaineId,
      'tournoi_id': tournoiId,
      'mot_de_passe': motDePasse,
    };
  }
}
