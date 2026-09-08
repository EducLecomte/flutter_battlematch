import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_metawar/screens/widgets/admin_armee_edit_dialog.dart';
import 'package:flutter_metawar/screens/widgets/admin_choix_edit_dialog.dart';

void main() {
  int savedCount = 0;

  Future<void> pumpHostPage(WidgetTester tester) async {
    savedCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => showArmeeEditDialog(
                      dialogContext: context,
                      existingArmee: null,
                      onSave: (nom, short) async => savedCount++,
                    ),
                    child: const Text("armee"),
                  ),
                  ElevatedButton(
                    onPressed: () => showChoixEditDialog(
                      dialogContext: context,
                      existingChoix: null,
                      onSave: (libelle, short, couleur) async => savedCount++,
                    ),
                    child: const Text("choix"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("dialogue armee : ouvrir, saisir, enregistrer, rouvrir",
      (tester) async {
    await pumpHostPage(tester);

    await tester.tap(find.text("armee"));
    await tester.pumpAndSettle();
    expect(find.text("Ajouter une armée"), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, "Nom de l'armée"),
      "Vampire Covenant",
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, "Initiales (ex : BH)"),
      "VC",
    );
    await tester.pump();
    await tester.tap(find.text("Enregistrer"));
    await tester.pumpAndSettle();
    expect(savedCount, 1);
    expect(tester.takeException(), isNull);

    // Deuxième ouverture (nouvelle armée).
    await tester.tap(find.text("armee"));
    await tester.pumpAndSettle();
    expect(find.text("Ajouter une armée"), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, "Nom de l'armée"),
      "Daemon Legions",
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, "Initiales (ex : BH)"),
      "DL",
    );
    await tester.pump();
    await tester.tap(find.text("Enregistrer"));
    await tester.pumpAndSettle();
    expect(savedCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets("dialogue choix : apercou couleur + deux cycles complets",
      (tester) async {
    await pumpHostPage(tester);

    for (int cycle = 0; cycle < 2; cycle++) {
      await tester.tap(find.text("choix"));
      await tester.pumpAndSettle();
      expect(find.text("Ajouter une appréciation"), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, "Libellé (ex : Entre 8 et 12)"),
        "Entre 8 et 12",
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, "Initiales (ex : 8-12)"),
        "8-12",
      );
      await tester.enterText(
        find.widgetWithText(
            TextFormField, "Couleur hexadécimale (ex : #FBC02D)"),
        "#FBC02D",
      );
      await tester.pump();
      await tester.tap(find.text("Enregistrer"));
      await tester.pumpAndSettle();
      expect(savedCount, cycle + 1);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets("dialogue choix : colorpicker met à jour le champ couleur",
      (tester) async {
    await pumpHostPage(tester);

    await tester.tap(find.text("choix"));
    await tester.pumpAndSettle();
    expect(find.text("Ajouter une appréciation"), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, "Libellé (ex : Entre 8 et 12)"),
      "Entre 8 et 12",
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, "Initiales (ex : 8-12)"),
      "8-12",
    );

    // Ouvre le sélecteur depuis le swatch.
    await tester.tap(find.byTooltip("Choisir la couleur"));
    await tester.pumpAndSettle();
    expect(find.text("Choisir une couleur"), findsOneWidget);

    // Sélectionne l'ambre 500 (#FFC107) puis valide.
    await tester.tap(find.byKey(const ValueKey<String>("#FFC107")));
    await tester.pump();
    await tester.tap(find.text("Valider"));
    await tester.pumpAndSettle();
    expect(find.text("Choisir une couleur"), findsNothing);

    final Finder champCouleur = find.widgetWithText(
        TextFormField, "Couleur hexadécimale (ex : #FBC02D)");
    final TextEditingController controllerChampCouleur =
        (champCouleur.evaluate().single.widget as TextFormField).controller!;
    expect(controllerChampCouleur.text, "#FFC107");

    await tester.tap(find.text("Enregistrer"));
    await tester.pumpAndSettle();
    expect(savedCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets("dialogue choix : annuler puis rouvrir sans exception",
      (tester) async {
    await pumpHostPage(tester);

    await tester.tap(find.text("choix"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Annuler"));
    await tester.pumpAndSettle();
    expect(savedCount, 0);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text("choix"));
    await tester.pumpAndSettle();
    expect(find.text("Ajouter une appréciation"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
