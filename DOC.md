# DOC.md — Cartographie technique MetaWar

*[2026-08-23 22:15] Mise à jour après le refactor M8.9 (tous fichiers ≤150
lignes sauf précédents acceptés : team_management_controller 212,
import_newrecruit_controller 191, team_management_screen 176,
import_newrecruit_dialog 167, estim_dialog 167, tournois_screen 163,
façade pocketbase_data_service 153).*

## Structure

```
lib/
  main.dart                        # AuthGate (Stream auth) → Login ou HomeShell
                                   # (NavigationBar 3 onglets : Tournois, Profil, Teams)
  config/
    app_config.dart                # URL PocketBase, noms de collections,
                                   # clé session — zéro magic value
  models/                          # Modèles purs (IDs string PB, champs snake_case)
    models.dart                    # Barrel : ré-exporte les 10 modèles ci-dessous
    armee.dart choix.dart estim.dart joueur.dart matched.dart
    meta_adversaire.dart rencontre.dart team.dart team_membre.dart tournoi.dart
  screens/                         # Écrans = thin shell (init + build + refresh)
    *_controller.dart              # Logique d'écran : TextEditingControllers,
                                   # chargements, mutations ; onStateChanged (VoidCallback)
    login_screen.dart              # Connexion/inscription (shell)
    login_controller.dart          # validate() / submit() → Future<String?>
    tournois_screen.dart           # Liste des tournois + FAB ajout
    tournois_controller.dart       # load/add/delete tournoi
    teams_screen.dart              # Équipe active + liste des rencontres du tournoi
    teams_screen_controller.dart   # bindTournoi, loadTeams/Encounters, create/delete
    teams_screen_encounter_actions.dart  # Opérations données rencontres (snackbars,
                                   # import txt, confirmation suppression)
    team_management_screen.dart    # CRUD équipes (sidebar + détail + invitations)
    team_management_controller.dart # Logique gestion d'équipe (212 lg, accepté)
    team_dashboard_screen.dart     # Tableau de bord d'un duel (shell)
    team_dashboard_controller.dart # Streams realtime opponents/estims/matched,
                                   # droits d'édition par rôle (joueur/capitaine)
    team_dashboard_estim_actions.dart  # Modales d'estimation + taps cellules matrice
    profile_screen.dart            # Profil + invitations en attente (shell)
    profile_controller.dart        # Chargement profil/invitations, accept/refus
  screens/widgets/                 # Composants UI atomiques (1 fichier = 1 rôle)
    login_*                        # brand_header / form_fields / submit_actions
    tournoi_card.dart              # Carte tournoi (suppression confirmée interne)
    tournoi_add_dialog.dart        # Dialog ajout tournoi
    estim_dialog.dart + estim_{choix,score,confiance,commentaire}_section.dart
                                   # Dialog estimation découpé en 4 sections
    estim_details_sheet.dart       # Bottom sheet détail d'estimation (édition)
    import_newrecruit_*            # Dialog import New Recruit (controller + 6 widgets)
    tournament_text_import_*       # Dialog import txt : launcher (top-level
                                   # showTournamentTextImportDialog), dialog,
                                   # action_bar, analysis_section, team_selector
    team_dashboard_body.dart       # Streams imbriqués du dashboard
    team_dashboard_matrix.dart     # Table matrice joueurs×adversaires (scrolls
                                   # horizontal+vertical, colonnes fixes)
    team_dashboard_matrix_player_row.dart  # Classe plain TableRow (pas un Widget)
    team_dashboard_matrix_{matchup_cell,opponent_header_cell}.dart
    team_dashboard_mode_banner.dart
    team_management_*              # 5 panels : sidebar, detail, invite, members,
                                   # create_team_dialog
    teams_screen_{encounter_list,team_selector}.dart
    rencontre_{list_tile,delete_confirmation}.dart
    add_encounter_dialog.dart
    add_opponent_dialog.dart       # Dialog ajout adversaire (top-level show*)
    opponent_details_dialog.dart   # Bottom sheet détail adversaire (top-level
                                   # show*, onDelete : Future<void> Function())
    profile_{info_card,invitations_section}.dart
  services/
    pocketbase_data_service.dart   # Façade singleton : surface API historique
                                   # (ex-SupabaseService) → délégation totale
                                   # aux sous-services ci-dessous (153 lg)
    pocketbase/
      pocketbase_client_holder.dart    # Client PB + AsyncAuthStore + yield initial
                                       # du stream d'auth + échappement filtres
      pocketbase_auth_service.dart     # signIn/signUp/signOut, profil courant,
                                       # searchJoueurs
      pocketbase_teams_service.dart    # CRUD teams (+ inscription capitaine)
      pocketbase_team_membres_service.dart  # Membres : inscription accepté,
                                       # listing avec profils
      pocketbase_team_invitations_service.dart # Invitations : pending, invite,
                                       # accept, decline/remove
      pocketbase_tournois_service.dart # CRUD tournois + rencontres
      pocketbase_referentiels_service.dart   # getArmees / getChoix (publics)
      pocketbase_dashboard_adversaires_service.dart # CRUD + stream meta_adv
      pocketbase_dashboard_estims_service.dart      # CRUD + stream estims
      pocketbase_dashboard_matched_service.dart     # CRUD + stream matched
    new_recruit_import_service.dart  # Façade import New Recruit : Méthode A
                                     # (API) + Méthode B (parsing local) +
                                     # correspondance armées
    new_recruit_api_client.dart      # Méthode A : GET newrecruit.eu/api/tournament
                                     # (Basic auth, timeout 30 s)
    new_recruit_json_extractor.dart  # extractPlayersFromTournamentJson (A et B)
    new_recruit_armee_name_matcher.dart # matchArmeeInReference (normalisation)
    tournament_text_import_parser.dart  # Parser du format texte de tournoi
                                        # (équipes, joueurs, listes, armées)
test/
  widget_test.dart                 # Smoke test app
  tournament_text_import_parser_test.dart # Tests du parser (8 cas)
tool/
  pocketbase_seed_records.dart     # Seed idempotent 16 armées + 6 choix
  pocketbase_seed_demo_records.dart # Jeu de données démo multi-joueurs
```

## Flux de données

1. **Auth** : `main.dart` écoutre `PocketbaseDataService.authStateChanges`
   (stream émettant la valeur courante immédiatement — yield initial dans
   `pocketbase_client_holder.dart`) → LoginScreen ou HomeShell.
2. **Écrans** : chaque écran = shell StatefulWidget qui instancie son
   `*_controller` dans `initState`, s'abonne à `onStateChanged`
   (`setState` si `mounted`) et délègue toute mutation. Les méthodes de
   mutation retournent `Future<String?>` (null = succès) ; l'écran affiche
   un SnackBar vert/rouge.
3. **Services** : les écrans n'appellent JAMAIS PocketBase directement —
   toujours via la façade `PocketbaseDataService.instance` (sauf
   `PocketbaseTeamsService` qui invoque `PocketbaseTeamMembresService.
   inscrireMembreAccepte` à la création d'équipe). La façade délègue aux
   sous-services `lib/services/pocketbase/` (singletons).
4. **Temps réel** : les streams SSE (opponents/estims/matched) sont créés
   UNE FOIS dans `initState` du controller dashboard ; refetch complet sur
   événement, debounce 300 ms ; rendu matrice O(1) (Maps/Sets).
5. **Import New Recruit** : depuis `TeamsScreen`, `showTournamentTextImportDialog`
   (launcher) → `TournamentTextImportParser` (texte) ou
   `NewRecruitImportService.parseNewRecruitContent` (JSON collé) →
   `matchArmeeInReference` → `PocketbaseDataService` (rencontre + meta_adv).
   L'import API direct (`NewRecruitApiClient`) est conservé mais mis de côté.
6. **Modèles** : `fromPocketBaseRecord` / champs snake_case ; les IDs sont
   des strings PocketBase ; constantes d'estimation dans `choix.dart`
   (`choixEstimationDefautId`, `choixEstimationInexistanteId`).

## Contraintes de code (voir AGENTS.md)

- 1 fichier = 1 responsabilité, ≤150 lignes recommandé (précédents acceptés
  listés en tête de document).
- Nommage explicite, zéro abréviation, zéro magic value (→ `app_config.dart`).
- `TableRow` est une classe plain dans Flutter : les composants de matrice
  qui produisent des lignes sont des classes plain avec `build(BuildContext)`.
