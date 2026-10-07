import 'package:pocketbase/pocketbase.dart';

/// Représente une équipe permanente (collection `teams`).
class Team {
  final String id;
  final String nom;
  final String? capitaineId;
  final String tournoiId;
  final String motDePasse;
  final bool membresVoirSynthese;
  final bool membresMatcher;
  final bool membresEditerEstims;

  Team({
    required this.id,
    required this.nom,
    this.capitaineId,
    this.tournoiId = '',
    this.motDePasse = '',
    this.membresVoirSynthese = false,
    this.membresMatcher = false,
    this.membresEditerEstims = false,
  });

  factory Team.fromPocketBaseRecord(RecordModel record) {
    return Team(
      id: record.id,
      nom: record.get<String>('nom'),
      capitaineId: record.get<String?>('capitaine_id', null),
      tournoiId: record.get<String>('tournoi_id', ''),
      motDePasse: record.get<String>('mot_de_passe', ''),
      membresVoirSynthese: record.get<bool>('membres_voir_synthese', false),
      membresMatcher: record.get<bool>('membres_matcher', false),
      membresEditerEstims: record.get<bool>('membres_editer_estims', false),
    );
  }
}
