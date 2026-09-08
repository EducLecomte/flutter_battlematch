// ===========================================================================
// Tests de régression du panneau de détail de la gestion d'équipe
// (team_management_detail_panel_test.dart)
//
// Couvre les points MEMO.md :
// - 6.1 : le panneau « Appariements » ne liste que les adversaires NON
//         appariés (appariements d'effectif à effectuer) ;
// - 7   : la zone de détail défile verticalement — plus de RenderFlex
//         overflowed (Axis.vertical) sur écran de hauteur réduite.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/team_management_controller.dart';
import 'package:flutter_metawar/screens/widgets/team_management_team_detail_panel.dart';
import 'package:flutter_metawar/services/pocketbase_data_service.dart';

/// Construit un contrôleur en mémoire (aucune requête réseau) : capitaine
/// d'une équipe de 2 membres face à 2 équipes adverses (3 joueurs au total,
/// dont « Pseudo 2 » déjà apparié à Membre 2).
TeamManagementController _buildController({required bool tousApparies}) {
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
  controller.matchedByOpponentTeamId = {
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

void main() {
  group('MEMO 6.1 — panneau Appariements', () {
    testWidgets('ne liste que les adversaires non appariés', (tester) async {
      final controller = _buildController(tousApparies: false);
      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();

      // Une carte par équipe adverse avec au moins un joueur non apparié.
      expect(
        find.text('Adversaire : Adversaire 1 — 1 joueur(s) non apparié(s)'),
        findsOneWidget,
      );
      expect(
        find.text('Adversaire : Adversaire 2 — 1 joueur(s) non apparié(s)'),
        findsOneWidget,
      );

      // « Pseudo 2 » est déjà apparié : il ne doit plus être affiché.
      expect(find.text('Pseudo 2'), findsNothing);

      // La liste d'armée d'un adversaire en attente est affichée.
      expect(find.text('Liste : Liste 3'), findsOneWidget);

      // Le capitaine voit l'action d'appariement pour chaque attente.
      expect(find.byTooltip('Apparier'), findsNWidgets(2));

      expect(find.text('Aucun appariement à effectuer.'), findsNothing);
    });

    testWidgets('affiche l état vide quand tout est apparié',
        (tester) async {
      final controller = _buildController(tousApparies: true);
      await tester.pumpWidget(_buildHarness(controller));
      await tester.pumpAndSettle();

      expect(find.text('Aucun appariement à effectuer.'), findsOneWidget);
      expect(find.text('Pseudo 1'), findsNothing);
      expect(find.text('Pseudo 3'), findsNothing);
      expect(find.byTooltip('Apparier'), findsNothing);
    });
  });

  group('MEMO 7 — défilement vertical du détail', () {
    testWidgets(
        'pas de RenderFlex overflow et scroll fonctionnel sur écran court',
        (tester) async {
      final controller = _buildController(tousApparies: false);
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
