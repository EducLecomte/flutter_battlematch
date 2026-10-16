import 'package:flutter/material.dart';
import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/widgets/admin_choix_edit_dialog.dart';
import 'package:flutter_metawar/screens/widgets/estim_dialog_controller.dart';
import 'package:flutter_metawar/services/pocketbase/pocketbase_client_holder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Score auto (MEMO)', () {
    final choices = [
      Choix(
        id: 'c1',
        libelle: 'Grand defavorise',
        short: '--',
        couleurHex: '#FF0000',
      ),
      Choix(id: 'c2', libelle: 'Defavorise', short: '-', couleurHex: '#FFA500'),
      Choix(
        id: 'c3',
        libelle: 'Legerement defavorise',
        short: '=-',
        couleurHex: '#FFD700',
      ),
      Choix(id: 'c4', libelle: 'Egalite', short: '=', couleurHex: '#FFFF00'),
      Choix(
        id: 'c5',
        libelle: 'Legerement favorise',
        short: '=+',
        couleurHex: '#9ACD32',
      ),
      Choix(id: 'c6', libelle: 'Favorise', short: '+', couleurHex: '#7CFC00'),
      Choix(
        id: 'c7',
        libelle: 'Grand favorise',
        short: '++',
        couleurHex: '#00FF00',
      ),
    ];

    test('Choix.defaultScore retourne les scores par défaut standard', () {
      expect(Choix.defaultScoreForShort('--'), 2);
      expect(Choix.defaultScoreForShort('-'), 5);
      expect(Choix.defaultScoreForShort('=-'), 7);
      expect(Choix.defaultScoreForShort('='), 10);
      expect(Choix.defaultScoreForShort('=+'), 13);
      expect(Choix.defaultScoreForShort('+'), 15);
      expect(Choix.defaultScoreForShort('++'), 18);
    });

    test('Choix.defaultScore prend en compte scoreDefaut si renseigné', () {
      final customChoix = Choix(
        id: 'c_custom',
        libelle: 'Custom',
        short: '+',
        couleurHex: '#00FF00',
        scoreDefaut: 16,
      );
      expect(customChoix.defaultScore, 16);
    });

    test('EstimDialogController met à jour le score lors de selectChoice', () {
      final joueur = Joueur(id: 'j1', email: 'j1@test.com', nom: 'Joueur 1');
      final opponent = TeamMeta(
        id: 'opp1',
        teamId: 't2',
        armeeId: 'a1',
        nomJo: 'Adv 1',
        listeJo: 'Liste',
      );

      final controller = EstimDialogController(
        currentJoueur: joueur,
        currentOpponent: opponent,
        ownTeamId: 't1',
        choiceList: choices,
        existingEstim: null,
      );

      // Par défaut = (score 10)
      expect(controller.minimumScore, 10);
      expect(controller.maximumScore, 10);

      // Sélection de -- -> score 2
      final choixMoinsMoins = choices.firstWhere((c) => c.short == '--');
      controller.selectChoice(choixMoinsMoins);
      expect(controller.minimumScore, 2);
      expect(controller.maximumScore, 2);

      // Sélection de - -> score 5
      final choixMoins = choices.firstWhere((c) => c.short == '-');
      controller.selectChoice(choixMoins);
      expect(controller.minimumScore, 5);
      expect(controller.maximumScore, 5);

      // Sélection de =- -> score 7
      final choixEgalMoins = choices.firstWhere((c) => c.short == '=-');
      controller.selectChoice(choixEgalMoins);
      expect(controller.minimumScore, 7);
      expect(controller.maximumScore, 7);

      // Sélection de =+ -> score 13
      final choixEgalPlus = choices.firstWhere((c) => c.short == '=+');
      controller.selectChoice(choixEgalPlus);
      expect(controller.minimumScore, 13);
      expect(controller.maximumScore, 13);

      // Sélection de + -> score 15
      final choixPlus = choices.firstWhere((c) => c.short == '+');
      controller.selectChoice(choixPlus);
      expect(controller.minimumScore, 15);
      expect(controller.maximumScore, 15);

      // Sélection de ++ -> score 18
      final choixPlusPlus = choices.firstWhere((c) => c.short == '++');
      controller.selectChoice(choixPlusPlus);
      expect(controller.minimumScore, 18);
      expect(controller.maximumScore, 18);
    });

    testWidgets(
      'ChoixEditDialog permet de saisir et valider un score par défaut',
      (tester) async {
        ChoixEditResult? savedResult;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showChoixEditDialog(
                    dialogContext: context,
                    existingChoix: choices.first,
                    onSave: (libelle, short, couleurHex, scoreDefaut) async {
                      savedResult = ChoixEditResult(
                        libelle: libelle,
                        short: short,
                        couleurHex: couleurHex,
                        scoreDefaut: scoreDefaut,
                      );
                    },
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text("Score par défaut (0-20)"), findsOneWidget);

        // Modifier le score
        final scoreFinder = find.widgetWithText(
          TextFormField,
          "Score par défaut (0-20)",
        );
        await tester.enterText(scoreFinder, '3');
        await tester.pumpAndSettle();

        await tester.tap(find.text("Enregistrer"));
        await tester.pumpAndSettle();

        expect(savedResult, isNotNull);
        expect(savedResult!.scoreDefaut, 3);
      },
    );
  });

  group('Déconnexion et session fermée (MEMO)', () {
    test('PocketbaseAuthInterceptorClient déclenche onUnauthorized sur 401 hors requête auth', () async {
      bool unauthorizedCalled = false;

      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Unauthorized"}', 401);
      });

      final interceptor = PocketbaseAuthInterceptorClient(
        mockClient,
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      // Requête classique de données
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/api/collections/tournois/records'),
      );
      await interceptor.send(request);

      expect(unauthorizedCalled, isTrue);
    });

    test('PocketbaseAuthInterceptorClient ne déclenche pas onUnauthorized sur tentative de connexion échouée', () async {
      bool unauthorizedCalled = false;

      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Invalid credentials"}', 401);
      });

      final interceptor = PocketbaseAuthInterceptorClient(
        mockClient,
        onUnauthorized: () {
          unauthorizedCalled = true;
        },
      );

      // Requête de tentative de login
      final request = http.Request(
        'POST',
        Uri.parse(
          'https://example.com/api/collections/joueurs/auth-with-password',
        ),
      );
      await interceptor.send(request);

      expect(unauthorizedCalled, isFalse);
    });
  });

  group('Client http du holder (contrat SDK PocketBase)', () {
    // Le SDK PocketBase ferme le client renvoyé par httpClientFactory après
    // CHAQUE requête (sauf en mode reuseHTTPClient). La fabrique du holder
    // doit donc renvoyer une instance fraîche à chaque appel, sinon la
    // requête suivante échoue avec « Client is already closed ».

    test(
        'La fabrique du holder renvoie une instance fraîche à chaque appel',
        () async {
      SharedPreferences.setMockInitialValues({});
      await PocketbaseClientHolder.instance.ensureInitialized();

      final fabrique =
          PocketbaseClientHolder.instance.clientPocketBase.httpClientFactory;

      final clientA = fabrique();
      final clientB = fabrique();

      expect(identical(clientA, clientB), isFalse);
      clientA.close();
      clientB.close();
    });
  });
}
