// Représente une rencontre de ronde contre une équipe adverse
// (collection `rencontres`).

import 'package:pocketbase/pocketbase.dart';

class Rencontre {
  final String id;
  final String tournoiId;
  final String teamId;
  final String nomAdversaire; // Désignation de l'équipe adverse

  Rencontre({
    required this.id,
    required this.tournoiId,
    required this.teamId,
    required this.nomAdversaire,
  });

  factory Rencontre.fromPocketBaseRecord(RecordModel record) {
    return Rencontre(
      id: record.id,
      tournoiId: record.get<String>('tournoi_id'),
      teamId: record.get<String>('team_id'),
      nomAdversaire: record.get<String>('nom_adversaire'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournoi_id': tournoiId,
      'team_id': teamId,
      'nom_adversaire': nomAdversaire,
    };
  }
}
