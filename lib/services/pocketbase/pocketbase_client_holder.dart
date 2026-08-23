// ===========================================================================
// Détenteur du client PocketBase MetaWar : initialisation avec persistance
// de session, accès au client, identité courante, échappement des filtres
// et flux temps réel générique par collection.
//
// Instance cible : https://metabase.pedagogeek.fr (voir lib/config/app_config.dart).
// ===========================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

class PocketbaseClientHolder {
  static final PocketbaseClientHolder instance =
      PocketbaseClientHolder._internal();

  PocketbaseClientHolder._internal();

  PocketBase? _clientPocketBase;

  /// Durée d'attente avant un rafraîchissement temps réel (débouncage des
  /// rafales d'événements SSE, ex. import en masse).
  static const Duration dureeDebounceRafraichissement =
      Duration(milliseconds: 300);

  /// Initialise le client avec persistance de session (SharedPreferences).
  /// À appeler impérativement dans main() avant runApp().
  Future<void> ensureInitialized() async {
    if (_clientPocketBase != null) return;

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final authStore = AsyncAuthStore(
      save: (String encodedSession) =>
          preferences.setString(sharedPreferencesKeyAuthSession, encodedSession),
      initial:
          preferences.getString(sharedPreferencesKeyAuthSession) ?? '',
      clear: () async =>
          preferences.remove(sharedPreferencesKeyAuthSession),
    );

    _clientPocketBase = PocketBase(pocketBaseServerUrl, authStore: authStore);
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
  String? get currentUserId => clientPocketBase.authStore.record?.id;

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
        debugPrint('Erreur de rafraîchissement temps réel ($nomCollection) : '
            '$exception');
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
