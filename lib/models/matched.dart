import 'package:pocketbase/pocketbase.dart';

/// Représente un appariement verrouillé par le capitaine
/// (collection `matched`).
class Matched {
  final String id;
  final String rencontreId;
  final String joueurId;
  final String metaAdvId;

  Matched({
    required this.id,
    required this.rencontreId,
    required this.joueurId,
    required this.metaAdvId,
  });

  factory Matched.fromPocketBaseRecord(RecordModel record) {
    return Matched(
      id: record.id,
      rencontreId: record.get<String>('rencontre_id'),
      joueurId: record.get<String>('joueur_id'),
      metaAdvId: record.get<String>('meta_adv_id'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rencontre_id': rencontreId,
      'joueur_id': joueurId,
      'meta_adv_id': metaAdvId,
    };
  }
}
