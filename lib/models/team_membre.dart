import 'package:pocketbase/pocketbase.dart';

/// Représente l'association entre une équipe et son joueur membre
/// (collection `team_membres`).
class TeamMembre {
  final String teamId;
  final String joueurId;
  final String role; // 'captain' ou 'player'
  final String statut; // 'pending' ou 'accepted'

  TeamMembre({
    required this.teamId,
    required this.joueurId,
    required this.role,
    required this.statut,
  });

  factory TeamMembre.fromPocketBaseRecord(RecordModel record) {
    return TeamMembre(
      teamId: record.get<String>('team_id'),
      joueurId: record.get<String>('joueur_id'),
      role: record.get<String>('role'),
      statut: record.get<String>('statut'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'joueur_id': joueurId,
      'role': role,
      'statut': statut,
    };
  }
}
