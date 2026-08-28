// ===========================================================================
// Authentification MetaWar sur la collection dédiée « joueurs » :
// inscription, connexion, déconnexion, profil courant et recherche de joueurs.
// ===========================================================================

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import 'pocketbase_client_holder.dart';

/// Erreur d'authentification / inscription avec un message lisible,
/// à la place du déversement technique du ClientException PocketBase.
class ErreurAuthentification implements Exception {
  final String message;

  const ErreurAuthentification(this.message);

  @override
  String toString() => message;
}

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
  /// puis connecte immédiatement l'utilisateur (pas de vérification email
  /// sur le serveur).
  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
  }) async {
    try {
      await _holder.clientPocketBase.collection(collectionNameJoueurs).create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
          'emailVisibility': true,
          'nom': nom,
        },
      );
    } on ClientException catch (exceptionInscription) {
      throw ErreurAuthentification(
        'Inscription impossible : ${_messageServeurPocketBase(exceptionInscription)}',
      );
    }

    await signIn(email: email, password: password);
  }

  /// Connexion de l'utilisateur (met à jour l'authStore et donc l'AuthGate).
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _holder.clientPocketBase
          .collection(collectionNameJoueurs)
          .authWithPassword(email, password);
    } on ClientException catch (exceptionConnexion) {
      throw ErreurAuthentification(
        _messageErreurAuthentification(exceptionConnexion),
      );
    }
  }

  /// Convertit l'erreur d'authentification PocketBase en message lisible.
  String _messageErreurAuthentification(ClientException exception) {
    if (exception.statusCode == httpCodeIdentifiantsRejetes) {
      return 'Identifiants incorrects : vérifiez votre email et votre mot de passe.';
    }
    if (exception.statusCode == httpCodeTropDeTentatives) {
      return 'Trop de tentatives de connexion, réessayez dans quelques instants.';
    }
    return 'Connexion impossible : ${_messageServeurPocketBase(exception)}';
  }

  /// Extrait le message d'erreur du serveur dans un ClientException PocketBase.
  String _messageServeurPocketBase(ClientException exception) {
    final dynamic messageServeur = exception.response['message'];
    if (messageServeur is String && messageServeur.isNotEmpty) {
      return messageServeur;
    }
    return 'erreur inconnue';
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

  /// Met à jour le pseudo du profil de l'utilisateur courant.
  Future<void> updateJoueurProfileFields({
    required String nom,
  }) async {
    final String? userId = currentUserId;
    if (userId == null) throw Exception("Non authentifié");

    await _holder.clientPocketBase
        .collection(collectionNameJoueurs)
        .update(userId, body: {'nom': nom});
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
