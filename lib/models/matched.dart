import 'package:pocketbase/pocketbase.dart';

/// Représente un appariement verrouillé par le capitaine
/// (collection `matched`).
class Matched {
  final String id;
  final String teamId;
  final String adversaireTeamId;
  final String joueurId;
  final String metaAdvId;

  Matched({
    required this.id,
    required this.teamId,
    required this.adversaireTeamId,
    required this.joueurId,
    required this.metaAdvId,
  });

  factory Matched.fromPocketBaseRecord(RecordModel record) {
    return Matched(
      id: record.id,
      teamId: record.get<String>('team_id'),
      adversaireTeamId: record.get<String>('adversaire_team_id'),
      joueurId: record.get<String>('joueur_id'),
      metaAdvId: record.get<String>('meta_adv_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'adversaire_team_id': adversaireTeamId,
      'joueur_id': joueurId,
      'meta_adv_id': metaAdvId,
    };
  }
}
