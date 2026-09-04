import 'package:pocketbase/pocketbase.dart';

/// Représente l'estimation saisie par un joueur contre un adversaire
/// (collection `estims`).
class Estim {
  final String joueurId;
  final String teamId;
  final String adversaireTeamId;
  final String teamMetaId;
  final String choixId;
  final int? scoreMin; // Optionnel (système 20-0)
  final int? scoreMax;
  final String confiance; // 'faible', 'moyen', 'eleve'
  final String? commentaire;

  Estim({
    required this.joueurId,
    required this.teamId,
    required this.adversaireTeamId,
    required this.teamMetaId,
    required this.choixId,
    this.scoreMin,
    this.scoreMax,
    this.confiance = 'moyen',
    this.commentaire,
  });

  factory Estim.fromPocketBaseRecord(RecordModel record) {
    return Estim(
      joueurId: record.get<String>('joueur_id'),
      teamId: record.get<String>('team_id'),
      adversaireTeamId: record.get<String>('adversaire_team_id'),
      teamMetaId: record.get<String>('team_meta_id'),
      choixId: record.get<String>('choix_id'),
      scoreMin: record.get<int?>('score_min', null),
      scoreMax: record.get<int?>('score_max', null),
      confiance: record.get<String>('confiance', 'moyen'),
      commentaire: record.get<String?>('commentaire', null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'joueur_id': joueurId,
      'team_id': teamId,
      'adversaire_team_id': adversaireTeamId,
      'team_meta_id': teamMetaId,
      'choix_id': choixId,
      'score_min': scoreMin,
      'score_max': scoreMax,
      'confiance': confiance,
      'commentaire': commentaire,
    };
  }
}
