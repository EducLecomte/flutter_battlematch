import 'package:pocketbase/pocketbase.dart';

/// Représente un joueur (profil authentifié, collection dédiée `joueurs`).
class Joueur {
  final String id;
  final String email;
  final String nom; // Pseudo affiché dans la matrice
  final String short; // Initiales (max 6 caractères)
  final bool admin; // Droit d'accès à l'écran d'administration

  Joueur({
    required this.id,
    required this.email,
    required this.nom,
    required this.short,
    this.admin = false,
  });

  /// Convertit un enregistrement PocketBase de la collection `joueurs`.
  factory Joueur.fromPocketBaseRecord(RecordModel record) {
    return Joueur(
      id: record.id,
      email: record.get<String>('email'),
      nom: record.get<String>('nom'),
      short: record.get<String>('short'),
      admin: (record.get<dynamic>('admin') as bool?) ?? false,
    );
  }

  // Convertit une réponse JSON en instance de Joueur
  factory Joueur.fromJson(Map<String, dynamic> json) {
    return Joueur(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      nom: json['nom'] as String,
      short: json['short'] as String,
      admin: json['admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nom': nom,
      'short': short,
      'admin': admin,
    };
  }

  // -------------------------------------------------------------------
  // Génération automatique du champ `short`
  // -------------------------------------------------------------------

  /// Nombre maximal de lettres du champ `short`.
  static const int shortMaximumLettres = 6;

  /// Valeur de repli du champ `short` quand le nom ne contient aucune lettre.
  static const String shortValeurDeRepli = 'JOU';

  /// Génère automatiquement le champ `short` à partir du nom :
  /// seules les lettres sont conservées, en majuscules, tronquées à 6 lettres.
  /// Le champ n'est plus saisi par l'utilisateur (remplacé par une icône).
  static String genererShortDepuisNom(String nom) {
    final String lettres =
        nom.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (lettres.isEmpty) return shortValeurDeRepli;
    return lettres.length > shortMaximumLettres
        ? lettres.substring(0, shortMaximumLettres)
        : lettres;
  }
}
