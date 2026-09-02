import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur (profil authentifié, collection dédiée `joueurs`).
class Joueur {
  final String id;
  final String email;
  final String nom; // Pseudo affiché dans la matrice
  final bool admin; // Droit d'accès à l'écran d'administration

  Joueur({
    required this.id,
    required this.email,
    required this.nom,
    this.admin = false,
  });

  /// Convertit un enregistrement PocketBase de la collection `joueurs`.
  factory Joueur.fromPocketBaseRecord(RecordModel record) {
    return Joueur(
      id: record.id,
      email: record.get<String>('email'),
      nom: record.get<String>('nom'),
      admin: (record.get<dynamic>('admin') as bool?) ?? false,
    );
  }
}
