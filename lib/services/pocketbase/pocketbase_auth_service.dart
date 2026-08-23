// ===========================================================================
// Authentification MetaWar sur la collection dédiée « joueurs » :
// inscription, connexion, déconnexion, profil courant et recherche de joueurs.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

class PocketbaseAuthService {
  static final PocketbaseAuthService instance =
      PocketbaseAuthService._internal();

  PocketbaseAuthService._internal();

  PocketbaseClientHolder get _holder => PocketbaseClientHolder.instance;

  /// Identifiant PocketBase de l'utilisateur actuellement connecté (null si déconnecté).
  String? get currentUserId => _holder.currentUserId;

  /// Flux booléen reflétant l'état d'authentification (pour l'AuthGate).
  /// Émet immédiatement l'état courant (session persistée restaurée) puis
  /// à chaque changement du authStore.
  late final Stream<bool> authStateChanges = () async* {
    yield _holder.clientPocketBase.authStore.record != null;
    await for (final AuthStoreEvent event
        in _holder.clientPocketBase.authStore.onChange) {
      yield event.record != null;
    }
  }().asBroadcastStream();

  /// Inscription d'un nouvel utilisateur : crée l'enregistrement du profil
  /// puis tente une connexion automatique silencieuse.
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    required String short,
  }) async {
    await _holder.clientPocketBase.collection(collectionNameJoueurs).create(
      body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'emailVisibility': true,
        'nom': nom,
        'short': short,
      },
    );

    try {
      await _holder.clientPocketBase
          .collection(collectionNameJoueurs)
          .authWithPassword(email, password);
    } catch (exceptionConnexionAutomatique) {
      // La connexion automatique peut échouer si la vérification email est
      // activée côté serveur ; l'utilisateur passera alors par l'écran de connexion.
      debugPrint('Connexion automatique post-inscription impossible : '
          '$exceptionConnexionAutomatique');
    }
  }

  /// Connexion de l'utilisateur (met à jour l'authStore et donc l'AuthGate).
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _holder.clientPocketBase
        .collection(collectionNameJoueurs)
        .authWithPassword(email, password);
  }

  /// Déconnexion
  Future<void> signOut() async {
    _holder.clientPocketBase.authStore.clear();
  }

  /// Récupère le profil joueur associé à l'utilisateur actuellement connecté.
  Future<Joueur?> getCurrentJoueurProfile() async {
    final String? userId = currentUserId;
    if (userId == null) return null;
    return await getJoueurProfile(userId);
  }

  /// Récupère le profil d'un joueur par son identifiant PocketBase.
  Future<Joueur?> getJoueurProfile(String userId) async {
    try {
      final RecordModel record = await _holder.clientPocketBase
          .collection(collectionNameJoueurs)
          .getOne(userId);
      return Joueur.fromPocketBaseRecord(record);
    } catch (exception) {
      debugPrint('Profil introuvable ($userId) : $exception');
      return null;
    }
  }

  /// Met à jour les champs éditables du profil de l'utilisateur courant.
  Future<void> updateJoueurProfileFields({
    required String nom,
    required String short,
  }) async {
    final String? userId = currentUserId;
    if (userId == null) throw Exception("Non authentifié");

    await _holder.clientPocketBase.collection(collectionNameJoueurs).update(
      userId,
      body: {
        'nom': nom,
        'short': short,
      },
    );
  }

  /// Recherche des joueurs enregistrés (pseudo ou email) pour envoyer des invitations.
  Future<List<Joueur>> searchJoueurs(String query) async {
    final String recherche = _holder.echapperFiltrePocketBase(query.trim());
    if (recherche.isEmpty) return [];
    try {
      final List<RecordModel> records =
          await _holder.clientPocketBase.collection(collectionNameJoueurs).getFullList(
                filter: 'nom ~ "$recherche" || email ~ "$recherche"',
                sort: 'nom',
              );
      return records.map(Joueur.fromPocketBaseRecord).toList();
    } catch (exception) {
      debugPrint('Erreur de recherche joueurs : $exception');
      return [];
    }
  }
}
