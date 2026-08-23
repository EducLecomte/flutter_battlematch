import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur adverse composant la méta adverse d'une rencontre
/// (collection `meta_adv`).
class MetaAdv {
  final String id;
  final String rencontreId;
  final String armeeId;
  final String? nomJoAdv; // Pseudo de l'adversaire
  final String listeAdv; // Liste d'armée textuelle

  MetaAdv({
    required this.id,
    required this.rencontreId,
    required this.armeeId,
    this.nomJoAdv,
    required this.listeAdv,
  });

  factory MetaAdv.fromPocketBaseRecord(RecordModel record) {
    return MetaAdv(
      id: record.id,
      rencontreId: record.get<String>('rencontre_id'),
      armeeId: record.get<String>('armee_id'),
      nomJoAdv: record.get<String?>('nom_jo_adv', null),
      listeAdv: record.get<String>('liste_adv', ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rencontre_id': rencontreId,
      'armee_id': armeeId,
      'nom_jo_adv': nomJoAdv,
      'liste_adv': listeAdv,
    };
  }
}
