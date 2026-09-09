// ===========================================================================
// Tests du point 9 du MEMO — formulaire de connexion/inscription :
// la touche Entrée sur un champ déclenche la soumission (onFieldSubmitted),
// et la validation du formulaire bloque une soumission invalide.
// Aucun appel réseau : la soumission n'est testée qu'au niveau du callback
// (onSubmit factice) et du chemin de validation (aucun appel au service).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/screens/login_screen.dart';
import 'package:flutter_metawar/screens/widgets/login_form_fields.dart';

void main() {
  group('point 9 MEMO — touche Entrée soumet le formulaire', () {
    // Pompe LoginFormFields isolé avec un callback de soumission factice,
    // afin de vérifier le câblage Entrée → onSubmit sans aucun service réseau.
    Future<void> pumpFields(
      WidgetTester tester, {
      bool isSignUp = false,
      required VoidCallback onSubmit,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginFormFields(
              isSignUp: isSignUp,
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
              nomController: TextEditingController(),
              onSubmit: onSubmit,
            ),
          ),
        ),
      );
    }

    // Simule la validation d'un champ par la touche Entrée : l'action IME
    // « done » est le signal qui déclenche onFieldSubmitted (touche Entrée
    // sur web/desktop).
    Future<void> validerParEntree(WidgetTester tester) async {
      await tester.testTextInput.receiveAction(TextInputAction.done);
    }

    testWidgets('Entrée sur le champ email déclenche la soumission (connexion)',
        (tester) async {
      int soumissions = 0;
      await pumpFields(tester, onSubmit: () => soumissions++);

      await tester.enterText(find.byType(TextFormField).at(0), 'gus@test.fr');
      await validerParEntree(tester);

      expect(soumissions, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'Entrée sur le champ mot de passe déclenche la soumission (connexion)',
        (tester) async {
      int soumissions = 0;
      await pumpFields(tester, onSubmit: () => soumissions++);

      await tester.enterText(find.byType(TextFormField).at(1), 'Secret1!');
      await validerParEntree(tester);

      expect(soumissions, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Entrée sur le champ pseudo déclenche la soumission (inscription)',
        (tester) async {
      int soumissions = 0;
      await pumpFields(tester, isSignUp: true, onSubmit: () => soumissions++);

      // En mode inscription, le champ pseudo est le troisième champ.
      await tester.enterText(find.byType(TextFormField).at(2), 'Augustin');
      await validerParEntree(tester);

      expect(soumissions, 1);
      expect(tester.takeException(), isNull);
    });
  });

  group('point 9 MEMO — la validation bloque une soumission invalide', () {
    testWidgets(
        'Entrée avec email invalide et mot de passe vide affiche les erreurs '
        'sans tenter de soumettre', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump();

      // Saisit un email invalide et laisse le mot de passe vide, puis
      // valide le champ email avec la touche Entrée.
      await tester.enterText(find.byType(TextFormField).at(0), 'pasunemail');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Les erreurs de validation des deux champs sont affichées.
      expect(find.text('Adresse email invalide'), findsOneWidget);
      expect(find.text('Veuillez renseigner votre mot de passe'),
          findsOneWidget);

      // Aucune tentative de soumission : pas de spinner de chargement.
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
