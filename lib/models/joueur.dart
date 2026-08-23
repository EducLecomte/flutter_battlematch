import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur (profil authentifié, collection dédiée `joueurs`).
class Joueur {
  final String id;
  final String email;
  final String nom; // Pseudo affiché dans la matrice
  final String short; // Initiales (max 6 caractères)

  Joueur({
    required this.id,
    required this.email,
    required this.nom,
    required this.short,
  });

  /// Convertit un enregistrement PocketBase de la collection `joueurs`.
  factory Joueur.fromPocketBaseRecord(RecordModel record) {
    return Joueur(
      id: record.id,
      email: record.get<String>('email'),
      nom: record.get<String>('nom'),
      short: record.get<String>('short'),
    );
  }

  // Convertit une réponse JSON en instance de Joueur
  factory Joueur.fromJson(Map<String, dynamic> json) {
    return Joueur(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      nom: json['nom'] as String,
      short: json['short'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'short': short,
    };
  }
}
