// ===========================================================================
// Tests de régression du panneau de détail de la gestion d'équipe
// (team_management_detail_panel_test.dart)
//
// Couvre les points MEMO.md :
// - 6.1 : le panneau « Appariements » liste les joueurs de l'équipe qui
//         sont appariés, avec l'adversaire correspondant ; un joueur sans
//         appariement n'apparaît pas, et rien n'est affiché s'il n'y a
//         aucun appariement ;
// - 7   : la zone de détail défile verticalement — plus de RenderFlex
//         overflowed (Axis.vertical) sur écran de hauteur réduite.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/team_management_controller.dart';
import 'package:flutter_metawar/screens/widgets/team_management_matched_panel.dart';
import 'package:flutter_metawar/screens/widgets/team_management_team_detail_panel.dart';
import 'package:flutter_metawar/services/pocketbase_data_service.dart';

/// Construit un contrôleur en mémoire (aucune requête réseau) : capitaine
/// d'une équipe de 2 membres face à 2 équipes adverses (3 joueurs au total).
///
/// - `aucunAppariement` : aucun `Matched` — le panneau n'affiche rien ;
/// - sinon, « Pseudo 2 » (Adversaire 1) est apparié à Membre 2 ;
/// - `tousApparies` : y ajoute Capitaine ↔ Pseudo 1 (Adversaire 1) et
///   Capitaine ↔ Pseudo 3 (Adversaire 2).
TeamManagementController _buildController({
  bool tousApparies = false,
  bool aucunAppariement = false,
}) {
  final TeamManagementController controller = TeamManagementController();
  controller.currentUserProfile = Joueur(
    id: 'captain000001',
    email: 'capitaine@metawar.fr',
    nom: 'Capitaine',
  );
  controller.selectedTeam = Team(
    id: 'team00000001',
    nom: 'Mon équipe',
    capitaineId: 'captain000001',
    tournoiId: 'tournoi00001',
  );
  controller.members = [
    {
      'joueur': Joueur(
        id: 'captain000001',
        email: 'capitaine@metawar.fr',
        nom: 'Capitaine',
      ),
      'role': PocketbaseDataService.roleCapitaine,
      'statut': 'accepted',
    },
    {
      'joueur': Joueur(
        id: 'membre0000002',
        email: 'm2@metawar.fr',
        nom: 'Membre 2',
      ),
      'role': PocketbaseDataService.roleJoueur,
      'statut': 'accepted',
    },
  ];
  controller.opponentTeams = [
    Team(id: 'adversaire001', nom: 'Adversaire 1'),
    Team(id: 'adversaire002', nom: 'Adversaire 2'),
  ];
  controller.opponentsByOpponentTeamId = {
    'adversaire001': [
      TeamMeta(
        id: 'meta000000001',
        teamId: 'adversaire001',
        armeeId: 'armee0001',
        nomJo: 'Pseudo 1',
        listeJo: 'Liste 1',
      ),
      TeamMeta(
        id: 'meta000000002',
        teamId: 'adversaire001',
        armeeId: 'armee0002',
        nomJo: 'Pseudo 2',
        listeJo: '',
      ),
    ],
    'adversaire002': [
      TeamMeta(
        id: 'meta000000003',
        teamId: 'adversaire002',
        armeeId: 'armee0003',
        nomJo: 'Pseudo 3',
        listeJo: 'Liste 3',
      ),
    ],
  };
  controller.matchedByOpponentTeamId = aucunAppariement
      ? {
          'adversaire001': <Matched>[],
          'adversaire002': <Matched>[],
        }
      : {
          'adversaire001': [
            Matched(
              id: 'matched00001',
              teamId: 'team00000001',
              adversaireTeamId: 'adversaire001',
              joueurId: 'membre0000002',
              teamMetaId: 'meta000000002',
            ),
            if (tousApparies)
              Matched(
                id: 'matched00003',
                teamId: 'team00000001',
                adversaireTeamId: 'adversaire001',
                joueurId: 'captain000001',
                teamMetaId: 'meta000000001',
              ),
          ],
          'adversaire002': tousApparies
              ? [
                  Matched(
                    id: 'matched00002',
                    teamId: 'team00000001',
                    adversaireTeamId: 'adversaire002',
                    joueurId: 'captain000001',
                    teamMetaId: 'meta000000003',
                  ),
                ]
              : <Matched>[],
        };
  controller.opponentsLoaded = true;
  return controller;
}

/// Réplique le corps de TeamManagementScreen : sidebar 250px + panneau de
/// détail en Expanded.
Widget _buildHarness(TeamManagementController controller) {
  final TextEditingController searchController = TextEditingController();
  return MaterialApp(
    home: Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 250),
          Expanded(
            child: TeamManagementTeamDetailPanel(
              controller: controller,
              searchController: searchController,
              onStateChanged: () {},
              onSearchTextChanged: (_) {},
              onSendInvite: (_) {},
              onRemoveMember: (_) {},
              onDeleteTeam: (_) {},
              onUpdateMotDePasse: (_) {},
              onNominateCaptain: (_) {},
              onMemberRoleChanged: (_, _) {},
            ),
          ),
        ],
      ),
    ),
  );
}

/// Recherche de texte limitée au panneau « Appariements ».
Finder _inMatchedPanel(Finder finder) {
  return find.descendant(of: find.byType(TeamManagementMatchedPanel), matching: finder);
}

void main() {
  group('MEMO 6.1 — panneau Appariements', () {
    testWidgets(
        'liste les joueurs de l’équipe appariés avec leur adversaire',
        (tester) async {
      final controller = _buildController();
      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();

      // Membre 2 est apparié : il apparaît avec son adversaire (Pseudo 2,
      // sans liste d'armée, équipe Adversaire 1).
      expect(_inMatchedPanel(find.text('Membre 2')), findsOneWidget);
      expect(_inMatchedPanel(find.text('Pseudo 2 (Adversaire 1)')), findsOneWidget);

      // Le Capitaine n'a pas d'appariement : il n'apparaît pas dans le
      // panneau (même s'il figure dans l'effectif).
      expect(_inMatchedPanel(find.text('Capitaine')), findsNothing);

      // Les adversaires non appariés ne sont pas listés.
      expect(_inMatchedPanel(find.text('Pseudo 1 — Liste 1 (Adversaire 1)')), findsNothing);
      expect(_inMatchedPanel(find.text('Pseudo 3 — Liste 3 (Adversaire 2)')), findsNothing);
    });

    testWidgets('affiche tous les appariements, y compris multiples par joueur',
        (tester) async {
      final controller = _buildController(tousApparies: true);
      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();

      // Le Capitaine est apparié avec un adversaire par équipe adverse :
      // deux entrées.
      expect(_inMatchedPanel(find.text('Capitaine')), findsNWidgets(2));
      expect(_inMatchedPanel(find.text('Pseudo 1 — Liste 1 (Adversaire 1)')), findsOneWidget);
      expect(_inMatchedPanel(find.text('Pseudo 3 — Liste 3 (Adversaire 2)')), findsOneWidget);
      expect(_inMatchedPanel(find.text('Membre 2')), findsOneWidget);
      expect(_inMatchedPanel(find.text('Pseudo 2 (Adversaire 1)')), findsOneWidget);
    });

    testWidgets('n’affiche rien quand il n’y a aucun appariement',
        (tester) async {
      final controller = _buildController(aucunAppariement: true);
      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();

      // Ni carte de joueurs, ni carte de chargement, ni message d'état vide.
      expect(_inMatchedPanel(find.byType(Card)), findsNothing);
      expect(_inMatchedPanel(find.text('Afficher les appariements')), findsNothing);
      expect(_inMatchedPanel(find.text('Pseudo 1')), findsNothing);
      expect(_inMatchedPanel(find.text('Pseudo 2')), findsNothing);
      expect(_inMatchedPanel(find.text('Pseudo 3')), findsNothing);
    });
  });

  group('MEMO 7 — défilement vertical du détail', () {
    testWidgets(
        'pas de RenderFlex overflow et scroll fonctionnel sur écran court',
        (tester) async {
      // tousApparies : le plus de contenu dans le panneau appariements pour
      // garantir que la page dépasse la hauteur de l'écran.
      final controller = _buildController(tousApparies: true);
      await tester.binding.setSurfaceSize(const Size(900, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Le contenu (paramètres + appariements + membres + invitations)
      // dépasse la hauteur de l'écran : le défilement doit avancer.
      final ScrollableState scrollable = tester.state(
        find.descendant(
          of: find.byType(TeamManagementTeamDetailPanel),
          matching: find.byType(Scrollable).first,
        ),
      );
      final double positionInitiale = scrollable.position.pixels;
      await tester.drag(
        find.byType(TeamManagementTeamDetailPanel),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(scrollable.position.pixels, greaterThan(positionInitiale));
    });
  });
}
