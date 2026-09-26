import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/widgets/estim_details_sheet.dart';
import 'package:flutter_metawar/screens/widgets/estim_dialog.dart';

void main() {
  final joueur = Joueur(id: 'j1', email: 'j1@test.com', nom: 'Joueur 1');
  final opponent = TeamMeta(id: 'opp1', teamId: 't2', armeeId: 'a1', nomJo: 'Adv 1', listeJo: 'Liste');
  final choices = [
    Choix(id: 'c1', libelle: 'Grand favori', short: '++', couleurHex: '#00FF00'),
    Choix(id: 'c2', libelle: 'Favori', short: '+', couleurHex: '#7CFC00'),
    Choix(id: 'c3', libelle: 'Egalite', short: '=', couleurHex: '#FFFF00'),
    Choix(id: 'c4', libelle: 'Defavorise', short: '-', couleurHex: '#FFA500'),
    Choix(id: 'c5', libelle: 'Grand defavorise', short: '--', couleurHex: '#FF0000'),
  ];
  final estim = Estim(
    joueurId: 'j1',
    teamId: 't1',
    adversaireTeamId: 't2',
    teamMetaId: 'opp1',
    choixId: 'c1',
    confiance: 'eleve',
    scoreMin: 10,
    scoreMax: 15,
    commentaire: 'Commentaire tactique un peu long avec plusieurs lignes pour tester le débordement hors écran dans la feuille de détail.',
  );
  final veryLongEstim = Estim(
    joueurId: 'j1',
    teamId: 't1',
    adversaireTeamId: 't2',
    teamMetaId: 'opp1',
    choixId: 'c1',
    confiance: 'eleve',
    scoreMin: 10,
    scoreMax: 15,
    commentaire: List.generate(20, (index) => 'Ligne de note tactique $index détaillant le plan de jeu').join('\n'),
  );

  group('showEstimDetailsSheet défilement et absence d overflow', () {
    testWidgets('affiche la feuille sur 400x700 sans overflow', (tester) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEstimDetailsSheet(
                  context,
                  joueur: joueur,
                  opponent: opponent,
                  estim: estim,
                  choix: choices.first,
                  canEdit: true,
                  onEdit: () {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text("Éditer l'estimation"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('affiche la feuille en mode paysage 640x360 sans overflow', (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEstimDetailsSheet(
                  context,
                  joueur: joueur,
                  opponent: opponent,
                  estim: estim,
                  choix: choices.first,
                  canEdit: true,
                  onEdit: () {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text("Éditer l'estimation"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('défile sans overflow même avec un commentaire très long', (tester) async {
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showEstimDetailsSheet(
                  context,
                  joueur: joueur,
                  opponent: opponent,
                  estim: veryLongEstim,
                  choix: choices.first,
                  canEdit: true,
                  onEdit: () {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text("Éditer l'estimation"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EstimDialog défilement et absence d overflow', () {
    testWidgets('s affiche sur écran très étroit 320x600 sans overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EstimDialog(
                    joueur: joueur,
                    opponent: opponent,
                    ownTeamId: 't1',
                    listChoix: choices,
                    currentEstim: estim,
                    onSave: (e) async => null,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(EstimDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('s affiche sur écran court 640x360 paysage sans overflow', (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EstimDialog(
                    joueur: joueur,
                    opponent: opponent,
                    ownTeamId: 't1',
                    listChoix: choices,
                    currentEstim: estim,
                    onSave: (e) async => null,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(EstimDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('s affiche avec clavier virtuel ouvert sans overflow', (tester) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: 350);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => EstimDialog(
                    joueur: joueur,
                    opponent: opponent,
                    ownTeamId: 't1',
                    listChoix: choices,
                    currentEstim: estim,
                    onSave: (e) async => null,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(EstimDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
