import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur d'une équipe avec son armée et sa liste
/// (collection `team_meta`).
///
/// Une seule ligne par joueur dans le tournoi, indépendante des rencontres :
/// le contexte de match (équipe A vs équipe B) est porté par `estims`/`matched`.
class TeamMeta {
  final String id;
  final String teamId;
  final String armeeId;
  final String nomJo; // Pseudo du joueur
  final String listeJo; // Liste d'armée textuelle

  TeamMeta({
    required this.id,
    required this.teamId,
    required this.armeeId,
    required this.nomJo,
    required this.listeJo,
  });

  factory TeamMeta.fromPocketBaseRecord(RecordModel record) {
    return TeamMeta(
      id: record.id,
      teamId: record.get<String>('team_id'),
      armeeId: record.get<String>('armee_id'),
      nomJo: record.get<String>('nom_jo', ''),
      listeJo: record.get<String>('liste_jo', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'armee_id': armeeId,
      'nom_jo': nomJo,
      'liste_jo': listeJo,
    };
  }
}
