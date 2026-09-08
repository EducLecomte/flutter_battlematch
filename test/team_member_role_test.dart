// ===========================================================================
// Tests du point 4.1 MEMO : modification des rôles dans « Membres de
// l'équipe » et détection des transitions qui ajoutent un joueur.
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/screens/widgets/team_management_team_members_panel.dart';
import 'package:flutter_metawar/services/pocketbase_data_service.dart';

Future<void> _pumpMembersPanel(
  WidgetTester tester, {
  required List<Map<String, dynamic>> members,
  String? captainId,
  required ValueChanged<Joueur> onRemoveMember,
  required void Function(Joueur player, String role) onRoleChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TeamManagementTeamMembersPanel(
          members: members,
          captainId: captainId,
          canChangeRole: true,
          canRemoveMember: (_) => false,
          onRemoveMember: onRemoveMember,
          onRoleChanged: onRoleChanged,
        ),
      ),
    ),
  );
}

void main() {
  group('PocketbaseDataService.transitionAjouteJoueur', () {
    test('coach → joueur ajoute un joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleCoach,
          PocketbaseDataService.roleJoueur,
        ),
        true,
      );
    });

    test('coach → capitaine ajoute un joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleCoach,
          PocketbaseDataService.roleCapitaine,
        ),
        true,
      );
    });

    test('joueur → coach ne compte pas comme ajout de joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleJoueur,
          PocketbaseDataService.roleCoach,
        ),
        false,
      );
    });

    test('capitaine → coach ne compte pas comme ajout de joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleCapitaine,
          PocketbaseDataService.roleCoach,
        ),
        false,
      );
    });

    test('coach → coach ne compte pas comme ajout de joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleCoach,
          PocketbaseDataService.roleCoach,
        ),
        false,
      );
    });

    test('capitaine → joueur ne compte pas comme ajout de joueur', () {
      expect(
        PocketbaseDataService.transitionAjouteJoueur(
          PocketbaseDataService.roleCapitaine,
          PocketbaseDataService.roleJoueur,
        ),
        false,
      );
    });
  });

  group('TeamManagementTeamMembersPanel', () {
    testWidgets('permet de passer un coach en joueur', (tester) async {
      final Joueur coach = Joueur(
        id: 'coach1',
        email: 'coach@exemple.fr',
        nom: 'Coach',
      );
      final List<Joueur> joueursConcernes = [];
      final List<String> rolesChoisis = [];

      await _pumpMembersPanel(
        tester,
        members: [
          {
            'role': PocketbaseDataService.roleCoach,
            'statut': 'accepted',
            'joueur': coach,
          },
        ],
        captainId: null,
        onRemoveMember: (_) {},
        onRoleChanged: (Joueur player, String role) {
          joueursConcernes.add(player);
          rolesChoisis.add(role);
        },
      );

      expect(find.byType(DropdownButton<String>), findsOneWidget);
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Joueur'));
      await tester.pumpAndSettle();

      expect(joueursConcernes.single.id, coach.id);
      expect(rolesChoisis.single, PocketbaseDataService.roleJoueur);
    });

    testWidgets('permet de passer un capitaine coach en capitaine',
        (tester) async {
      final Joueur capitaine = Joueur(
        id: 'capitaine1',
        email: 'capitaine@exemple.fr',
        nom: 'Capitaine',
      );
      final List<Joueur> joueursConcernes = [];
      final List<String> rolesChoisis = [];

      await _pumpMembersPanel(
        tester,
        members: [
          {
            'role': PocketbaseDataService.roleCoach,
            'statut': 'accepted',
            'joueur': capitaine,
          },
        ],
        captainId: capitaine.id,
        onRemoveMember: (_) {},
        onRoleChanged: (Joueur player, String role) {
          joueursConcernes.add(player);
          rolesChoisis.add(role);
        },
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Joueur'));
      await tester.pumpAndSettle();

      expect(joueursConcernes.single.id, capitaine.id);
      expect(rolesChoisis.single, PocketbaseDataService.roleCapitaine);
    });

    testWidgets('permet de passer un joueur en coach', (tester) async {
      final Joueur joueur = Joueur(
        id: 'joueur1',
        email: 'joueur@exemple.fr',
        nom: 'Joueur',
      );
      final List<Joueur> joueursConcernes = [];
      final List<String> rolesChoisis = [];

      await _pumpMembersPanel(
        tester,
        members: [
          {
            'role': PocketbaseDataService.roleJoueur,
            'statut': 'accepted',
            'joueur': joueur,
          },
        ],
        captainId: null,
        onRemoveMember: (_) {},
        onRoleChanged: (Joueur player, String role) {
          joueursConcernes.add(player);
          rolesChoisis.add(role);
        },
      );

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coach'));
      await tester.pumpAndSettle();

      expect(joueursConcernes.single.id, joueur.id);
      expect(rolesChoisis.single, PocketbaseDataService.roleCoach);
    });
  });
}
