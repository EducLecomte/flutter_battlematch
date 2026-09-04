import 'package:pocketbase/pocketbase.dart';

/// Représente un appariement verrouillé par le capitaine
/// (collection `matched`).
class Matched {
  final String id;
  final String teamId;
  final String adversaireTeamId;
  final String joueurId;
  final String teamMetaId;

  Matched({
    required this.id,
    required this.teamId,
    required this.adversaireTeamId,
    required this.joueurId,
    required this.teamMetaId,
  });

  factory Matched.fromPocketBaseRecord(RecordModel record) {
    return Matched(
      id: record.id,
      teamId: record.get<String>('team_id'),
      adversaireTeamId: record.get<String>('adversaire_team_id'),
      joueurId: record.get<String>('joueur_id'),
      teamMetaId: record.get<String>('team_meta_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'adversaire_team_id': adversaireTeamId,
      'joueur_id': joueurId,
      'team_meta_id': teamMetaId,
    };
  }
}
