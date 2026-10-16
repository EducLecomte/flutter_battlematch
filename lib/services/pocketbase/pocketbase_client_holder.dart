// ===========================================================================
// Détenteur du client PocketBase MetaWar : initialisation avec persistance
// de session, accès au client, identité courante, échappement des filtres,
// interception des sessions expirées/fermées et flux temps réel générique.
//
// Instance cible : https://metabase.pedagogeek.fr (voir lib/config/app_config.dart).
// ===========================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

/// Client HTTP intermédiaire qui intercepte les erreurs 401 (non autorisé / session fermée)
/// pour déclencher la réinitialisation de l'authentification.
class PocketbaseAuthInterceptorClient extends http.BaseClient {
  final http.Client _inner;
  final VoidCallback onUnauthorized;

  PocketbaseAuthInterceptorClient(this._inner, {required this.onUnauthorized});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401) {
      final path = request.url.path;
      final isAuthAttempt =
          path.contains('auth-with-password') ||
          path.contains('auth-with-oauth2') ||
          path.contains('auth-with-otp');
      if (!isAuthAttempt) {
        onUnauthorized();
      }
    }
    return response;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class PocketbaseClientHolder {
  static final PocketbaseClientHolder instance =
      PocketbaseClientHolder._internal();

  PocketbaseClientHolder._internal();

  PocketBase? _clientPocketBase;

  /// Callback invoqué lorsque la session est fermée ou révoquée par le serveur.
  VoidCallback? onSessionExpired;

  /// Durée d'attente avant un rafraîchissement temps réel (débouncage des
  /// rafales d'événements SSE, ex. import en masse).
  static const Duration dureeDebounceRafraichissement = Duration(
    milliseconds: 300,
  );

  /// Indique si l'utilisateur est authentifié avec une session valide et un profil chargé.
  bool get isUserAuthenticated =>
      _clientPocketBase != null &&
      _clientPocketBase!.authStore.isValid &&
      _clientPocketBase!.authStore.record != null;

  /// Gère l'expiration ou fermeture de session en vidant le store et notifiant l'application.
  void handleSessionExpired() {
    if (_clientPocketBase != null) {
      _clientPocketBase!.authStore.clear();
    }
    onSessionExpired?.call();
  }

  /// Initialise le client avec persistance de session (SharedPreferences).
  /// À appeler impérativement dans main() avant runApp().
  Future<void> ensureInitialized({http.Client? httpClient}) async {
    if (_clientPocketBase != null) return;

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final authStore = AsyncAuthStore(
      save: (String encodedSession) => preferences.setString(
        sharedPreferencesKeyAuthSession,
        encodedSession,
      ),
      initial: preferences.getString(sharedPreferencesKeyAuthSession) ?? '',
      clear: () async => preferences.remove(sharedPreferencesKeyAuthSession),
    );

    // Contrat du SDK PocketBase (mode par défaut, sans reuseHTTPClient) :
    // le client renvoyé par la fabrique est fermé après CHAQUE requête.
    // La fabrique doit donc renvoyer une instance fraîche à chaque appel,
    // sinon la requête suivante échoue avec « Client is already closed ».
    final http.Client Function() fabriqueClientHttp = httpClient != null
        ? () => httpClient
        : () => PocketbaseAuthInterceptorClient(
              http.Client(),
              onUnauthorized: handleSessionExpired,
            );

    _clientPocketBase = PocketBase(
      pocketBaseServerUrl,
      authStore: authStore,
      httpClientFactory: fabriqueClientHttp,
    );

    // Vérification de l'état de la session restaurée depuis le cache.
    // Si le jeton est expiré localement ou si la session a été fermée/révoquée côté serveur,
    // on purge l'authStore pour forcer l'affichage de l'écran de login.
    if (!authStore.isValid) {
      if (authStore.token.isNotEmpty || authStore.record != null) {
        authStore.clear();
      }
    } else {
      // Le jeton local est valide selon son expiration temporelle.
      // On tente un authRefresh pour valider que la session est toujours active sur le serveur.
      try {
        await _clientPocketBase!
            .collection(collectionNameJoueurs)
            .authRefresh();
      } on ClientException catch (exception) {
        if (exception.statusCode == 401 || exception.statusCode == 403) {
          debugPrint(
            'Session fermée ou invalide sur le serveur : purge authStore',
          );
          handleSessionExpired();
        }
      } catch (e) {
        // En cas d'erreur réseau (ex. hors ligne), on ne déconnecte pas l'utilisateur.
        debugPrint('Vérification session hors ligne : $e');
      }
    }
  }

  /// Client PocketBase garanti initialisé.
  PocketBase get clientPocketBase {
    final client = _clientPocketBase;
    if (client == null) {
      throw StateError(
        'PocketBase non initialisé : appeler '
        'PocketbaseClientHolder.instance.ensureInitialized() dans main().',
      );
    }
    return client;
  }

  /// Identifiant PocketBase de l'utilisateur actuellement connecté (null si déconnecté).
  String? get currentUserId =>
      isUserAuthenticated ? clientPocketBase.authStore.record?.id : null;

  /// Échappe les guillemets et antislashs d'une valeur insérée dans un filtre
  /// PocketBase afin d'éviter toute injection de filtre.
  String echapperFiltrePocketBase(String valeur) {
    return valeur.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
  }

  /// Flux temps réel générique : à l'écoute, recharge la liste complète puis
  /// la réémet à chaque événement serveur de la collection filtrée.
  /// Approche volontairement simple et robuste (pas d'état incrémental).
  Stream<List<RecordModel>> streamCollectionRecords({
    required String nomCollection,
    required String filtre,
    required String tri,
  }) {
    late StreamController<List<RecordModel>> controller;
    UnsubscribeFunc? fonctionDesabonnement;
    Timer? minuteurRafraichissement;

    Future<void> rechargerEtEmettre() async {
      try {
        final List<RecordModel> records = await clientPocketBase
            .collection(nomCollection)
            .getFullList(filter: filtre, sort: tri);
        if (!controller.isClosed) {
          controller.add(records);
        }
      } catch (exception) {
        debugPrint(
          'Erreur de rafraîchissement temps réel ($nomCollection) : '
          '$exception',
        );
      }
    }

    void programmerRafraichissement() {
      minuteurRafraichissement?.cancel();
      minuteurRafraichissement = Timer(
        dureeDebounceRafraichissement,
        rechargerEtEmettre,
      );
    }

    controller = StreamController<List<RecordModel>>(
      onListen: () async {
        // subscribe() établit automatiquement la connexion SSE si nécessaire
        await rechargerEtEmettre();
        fonctionDesabonnement = await clientPocketBase
            .collection(nomCollection)
            .subscribe('*', (RecordSubscriptionEvent event) {
              programmerRafraichissement();
            }, filter: filtre);
      },
      onCancel: () async {
        minuteurRafraichissement?.cancel();
        await fonctionDesabonnement?.call();
      },
    );

    return controller.stream;
  }
}
