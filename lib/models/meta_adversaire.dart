import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur adverse composant la méta adverse d'une équipe
/// (collection `meta_adv`).
class MetaAdv {
  final String id;
  final String teamId;
  final String adversaireTeamId;
  final String armeeId;
  final String? nomJoAdv; // Pseudo de l'adversaire
  final String listeAdv; // Liste d'armée textuelle

  MetaAdv({
    required this.id,
    required this.teamId,
    required this.adversaireTeamId,
    required this.armeeId,
    this.nomJoAdv,
    required this.listeAdv,
  });

  factory MetaAdv.fromPocketBaseRecord(RecordModel record) {
    return MetaAdv(
      id: record.id,
      teamId: record.get<String>('team_id'),
      adversaireTeamId: record.get<String>('adversaire_team_id'),
      armeeId: record.get<String>('armee_id'),
      nomJoAdv: record.get<String?>('nom_jo_adv', null),
      listeAdv: record.get<String>('liste_adv', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'adversaire_team_id': adversaireTeamId,
      'armee_id': armeeId,
      'nom_jo_adv': nomJoAdv,
      'liste_adv': listeAdv,
    };
  }
}
