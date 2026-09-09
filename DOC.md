# DOC.md — Cartographie technique MetaWar

*[2026-09-06] M20 — Point 4 MEMO : taille d'équipe par tournoi + plafond de
joueurs (RESOLU). La taille d'équipe = nombre de joueurs importés (nb de
lignes `team_meta` de l'équipe). Affichage : `TournoiController`
(`tailleEquipeParTournoi` + `_chargerTaillesEquipes()`, tournois
`importEffectue` uniquement, après `loadTournois`) → `TournoiListBody` →
`TournoiCard` (param `tailleEquipe`, affiche « Taille d'équipe : X joueurs »
si > 0) ; taille d'un tournoi = max des comptes `team_meta` de ses équipes
(`getTailleEquipeTournoi`). Plafond : garde `_verifierCapaciteAjoutJoueur`
(lève « L'équipe est déjà complète (X/Y joueurs). ») appliquée dans la façade
`PocketbaseDataService` avant `inviteJoueurToTeam`, `reclamerEquipeEnCapitaine`
et `rejoindreEquipeAvecMotDePasse` ; effectif « joueurs » =
`compterJoueursEquipe` (rôles `captain`/`player`, i.e. `role != coach` — le
coach ne compte pas, les invitations pending comptent) ; aucune restriction si
aucun `team_meta`. Aucune modification de schéma PocketBase. Validation :
`flutter analyze` 0 problème, `flutter test` 35/35, `flutter build web` OK.
Précédent :
*[2026-09-05] M19 — Points 1 et 2 MEMO : invitation capitaine + rôle
joueur/coach (RESOLU). **Point 1** : bouton « Inviter un joueur »
(`person_add_alt_1`) dans l'AppBar de `TeamsScreen`, visible si l'utilisateur
est capitaine de l'équipe active (`TeamsScreenController.isCaptainOfActiveTeam`
= comparaison `activeTeam.capitaineId` avec l'id connecté) ; ouvre
`showTeamsScreenInvitePlayerDialog` (`teams_screen_invite_player_dialog.dart`)
— recherche de joueurs (`TeamsScreenController.searchPlayers`, exclut les
membres de l'équipe active via `loadActiveTeamMembers`) + invitation
(`sendInvite` → `inviteJoueurToTeam`). **Point 2** : nouveau rôle `coach`
dans `team_membres.role` (select `captain|player|coach`) ; le capitaine est
identifié par `teams.capitaine_id` et non par le rôle, il peut donc être
coach. Outil de rôle : `TeamManagementTeamMembersPanel` gagne un sélecteur
Joueur/Coach par membre accepté (visible si capitaine), badge capitaine
(`workspace_premium`) + coach (`sports_score`), sous-titre
`Capitaine`/`Coach`/`Joueur`. `TeamManagementController.changeMemberRole` →
façade `mettreAJourRoleMembre(teamId, joueurId, role)` ;
`pocketbase_team_access_service.nommerNouveauCapitaine` préserve le statut
coach du capitaine sortant (`player` s'il jouait, `coach` sinon). Matrice :
`TeamDashboardController` filtre `teamMembers` aux membres acceptés
`estRouleJoueur` (`role != coach`) — seuls les joueurs ont une ligne dans la
matrice. Façade expose `roleCapitaine`/`roleJoueur`/`roleCoach` + helper
`estRouleJoueur`. **Import manuel du schéma PB requis** (`team_membres.role`
+ `coach`). Validation : `flutter analyze` 0 problème, `flutter test` 35/35,
`flutter build web` OK. Précédent :
*[2026-09-03] M18 — point 1 MEMO : refonte `meta_adv` → `team_meta` (RESOLU).
L'import créait des doublons d'équipes et stockait toutes les combinaisons
d'adversaires possibles. `team_meta` remplace `meta_adv` : 1 ligne par joueur
par équipe, ancrée UNIQUEMENT sur son `team_id` (plus de `adversaire_team_id`),
champs `team_id`, `armee_id`, `nom_jo`, `liste_jo`, index unique
`(team_id, nom_jo)` ; `estims`/`matched` conservent `team_id` +
`adversaire_team_id` et remplacent `meta_adv_id` par `team_meta_id` ;
`team_membres` gagne `team_meta_id` optionnel (membre → équipe/armée, y
compris non-joueurs). Import upsert idempotent par `(team_id, nom_jo)`
(`importTeamsForTournoi` crée/récupère chaque équipe une fois,
`importTeamMeta` une fois par équipe). Service
`pocketbase_dashboard_adversaires_service` (nom conservé) réécrit `team_meta`
par équipe ; UI dashboard : `TeamDashboardController` lit les `team_meta` de
l'équipe ADVERSE B (`streamTeamMeta(adversaireTeam.id)`), `EstimDialog` reçoit
`ownTeamId` (= équipe A) car `TeamMeta` ne porte que `teamId` (= B) ; clés
matrice `teamMetaId`. Seed démo : `team_meta` ancrée sur l'équipe adverse.
Test de garde `memo_8` réécrit (`TeamMeta` sur `team_id` seul).
**Import manuel du schéma PB requis** (collection `team_meta` remplace
`meta_adv` + champs `team_meta_id` + index). Validation : `flutter analyze`
0 problème, `flutter test` 35/35, `flutter build web` OK. Précédent :
*[2026-09-02] M17 — point 2 MEMO : rafraîchissement automatique des écrans
depuis la barre du bas (RESOLU). Cause racine : `HomeShell` garde les 3
écrans en vie dans un `IndexedStack`, leur `initState` (et donc leur
chargement de données) ne court qu'une fois → données périmées après une
navigation dans la `NavigationBar`. Fix : base partagée
`RefreshableScreenState<T>` (`lib/screens/refreshable_screen.dart`, méthode
`refreshOnTabActivated()`) héritée par les states de `TournoisScreen`,
`TeamManagementScreen` et `ProfileScreen`, qui relancent chacun leur
chargement existant (`_loadTournois` / `_loadInitialData` /
`_loadProfileAndInvitations`). `HomeShell` détient un
`GlobalKey<RefreshableScreenState<…>>` par écran (attaché comme `key:`,
liste d'écrans inline — plus de `static const _onglets`) et appelle
`refreshOnTabActivated()` sur l'écran devenu actif dans
`onDestinationSelected` (pas de rafraîchissement au premier affichage).
`TeamManagementController.loadInitialData` conserve désormais l'équipe
sélectionnée au rechargement si elle existe encore (avant : retour
inconditionnel sur la première équipe). Le commentaire orphelin
`//raffraichir ?` de `TeamManagementScreen` est remplacé par un `IconButton`
de rafraîchissement (cohérent avec `TournoisScreen`). Aucune modification
serveur ni schéma PocketBase. Validation : `flutter analyze` 0 problème,
`flutter test` 35/35, `flutter build web` OK. Précédent :
*[2026-09-02] Nettoyage : suppression du code mort (RESOLU). La chaîne
d'import texte de `TeamsScreen` (bouton disparu) est supprimée :
`teams_screen_actions.importTournamentText` + launcher + dialog txt
standalone ; l'import de tournoi se fait uniquement depuis la carte tournoi
(`showTournoiTeamImportDialog`, M13.5). Façade allégée : `getJoueurProfile`,
`createTeam`, `markTournoiImportEffectue`, `getTeam`, `deleteEstim`,
`getEstims` supprimés (les sous-services restent publics et sont appelés
directement). `PocketbaseTeamsService.createTeam(String)` (création d'équipe
seule, sans tournoi) et `PocketbaseDashboardEstimsService.deleteEstim`/
`getEstims` supprimés : aucun appelant (le `saveEstim` ne purge plus les
orphelins). Sérialisations JSON mortes retirées des modèles :
`Joueur.fromJson`/`toJson`, `Armee.toJson`, `Choix.toJson`, `Team.toJson`,
`Tournoi.toJson` (aucun appelant dans lib/test/tool ; `Estim`/`MetaAdv`/
`Matched.toJson` conservés — service estims + tests). Aucune modification
serveur ni schéma PocketBase. Validation : `flutter analyze` sans problème,
`flutter test` 35/35. Précédent :
*[2026-08-31] M16.11 — correctif : bypass admin des règles d'écriture
`meta_adv` (RESOLU). L'import « équipes + listes adverses » depuis la carte
tournoi (M15) échouait en 400 « Failed to create record » dès la première
équipe dont le capitaine n'était pas l'utilisateur connecté : les règles
d'écriture `meta_adv` (`@request.auth.id = team_id.capitaine_id`) n'incluaient
pas de bypass admin, alors que l'import de tournoi est une action admin
(M13.5/M13.6 : l'admin saisit les adversaires depuis la carte tournoi).
`|| @request.auth.admin = true` ajouté aux règles create/update/delete de
`meta_adv` (snapshot + application directe sur le serveur via superuser le
2026-08-31). `matched`/`estims` inchangées (pas de flux d'écriture admin).
Vérifié de bout en bout avec un compte admin temporaire
(create/update/delete OK, puis nettoyage). Précédent :
*[2026-08-30] M16 — point 8 MEMO : suppression de la collection `rencontres`
(RESOLU). Chaque équipe d'un tournoi peut estimer n'importe quelle autre
équipe du tournoi : la « rencontre » n'était qu'un intermédiaire inutile.
`meta_adv`/`estims`/`matched` sont ancrés directement sur le duo
`team_id` + `adversaire_team_id` (relations `teams`, cascadeDelete) ;
index uniques `matched` recalés sur `(team_id, adversaire_team_id,
joueur_id)` et `(team_id, adversaire_team_id, meta_adv_id)` ; règles
d'écriture recalées sur `team_id.capitaine_id` (+ règle capitaine
d'équipe pour `estims`). `lib/models/rencontre.dart` supprimé ;
`pocketbase_rencontres_service.dart`, `teams_screen_encounter_list.dart`,
`teams_screen_encounter_actions.dart`, `rencontre_list_tile.dart`,
`rencontre_delete_confirmation.dart`, `add_encounter_dialog.dart` supprimés.
`TeamsScreen` : liste = équipes du tournoi hors équipe active, création de
rencontre « texte libre » supprimée. `TeamDashboardScreen`/Controller
pilotés par `team` + `adversaireTeam` (flux filtrés sur le duo d'équipes).
`TournamentTextImportService` ancre `meta_adv` sur l'équipe adverse réelle
(créée si absente du tournoi) ; compteurs `createdOpponentTeamCount`.
Seed démo réécrit (4 équipes adverses `[DEMO]` dans le tournoi). Purge sans
`rencontres`. Test de garde `test/memo_8_repro_test.dart`.
**Import manuel du schéma sur le serveur PB requis** (collection
`rencontres` à supprimer + relations/index/règles nouveaux). Validation :
`flutter analyze` sans problème, `flutter test` 35/35, `flutter build web`
OK. Précédent :
*[2026-08-29] M15 — points 7 et 9 MEMO : durée des SnackBars + sélecteur
d'équipe (RESOLU). Point 7 (précision utilisateur : c'est la DURÉE qui est
trop longue, pas le texte) : aucun `duration` n'était défini dans `lib/` →
tous les SnackBars utilisaient la valeur par défaut SDK de 4 s ;
`SnackBarThemeData` ne possède pas de champ `duration` (pas de fix global
via le thème). Fix : constante `snackBarDisplayDuration = Duration(seconds: 2)`
dans `app_config.dart` + `duration` explicite sur tous les SnackBars
(présentateur d'erreurs + 11 SnackBars succès/info). Piège Flutter 3.47
(trouvé en M15.4) : un `SnackBar` avec `action` reçoit `persist = true` par
défaut (`snack_bar.dart:303` : `persist = persist ?? action != null`) → le
timer d'auto-dismiss fire mais le SnackBar ne se ferme jamais ; le bouton
« Copier » du présentateur d'erreurs a donc été retiré (le message reste
dans les logs via `debugPrint`) ; un SnackBar qui doit s'auto-fermer ne doit
pas avoir d'`action` (ou passer `persist: false` explicitement). Point 9 :
`teams_screen_team_selector.dart` réécrit en affichage statique `Text` du
nom d'équipe active (plus de `DropdownButton`) ; `setActiveTeam` et
`selectableTeams` supprimés du controller (morts) ; équipe active = première
équipe du tournoi/joueur, plus de commutation manuelle depuis TeamsScreen.
Test de garde `test/memo_7_9_repro_test.dart` (3 tests). Validation :
`flutter analyze` sans problème, `flutter test` 32/32, `flutter build web`
OK. Précédent :
*[2026-08-29] Mise à jour M14 — point 6 MEMO : édition de tournoi +
corrections dialogs. Cause racine des erreurs d'édition : contrôleurs de
texte/GlobalKey créés dans la fonction `show...EditDialog` et disposés au
retour de `showDialog` pendant que l'animation de fermeture rebuildait le
widget → « TextEditingController used after being disposed » (framework.dart:6281)
+ Duplicate GlobalKey ; fix : StatefulWidgets dont le State possède et libère
dans `dispose()` (admin_armee/admin_choix/tournoi_edit), API publique
inchangée. CRUD tournoi complété : `PocketbaseTournoisService.updateTournoi`,
`TournoiController.updateTournoi`, `TournoiEditDialog` + bouton édition
(admin) sur `TournoiCard`, opérations consolidées dans `TournoisScreen`
(`_runTournoiOperation`). Compaction : `TournoiListBody` (corps de liste) +
`showTournoiTeamImportDialog` (`tournoi_team_import_actions.dart`) ; découpage
service → `pocketbase_rencontres_service.dart`. Overflow SnackBar 99134 px
corrigé (pseudo adverse au lieu de la liste). Test de garde
`test/admin_dialog_repro_test.dart`. Validation : `flutter analyze` sans
problème, `flutter test` 28/28, `flutter build web` OK.
Précédents acceptés : pocketbase_data_service 242,
teams_screen_team_access_panel 241, team_management_matched_panel 241,
teams_screen_encounter_list 218, team_management_controller 199,
admin_controller 186, team_management_team_actions 183, profile_screen 175,
tournament_text_import_parser 170, admin_choix_edit_dialog 166,
tournois_screen 163, pocketbase_auth_service 162,
teams_screen_encounter_actions 158, estim_dialog 157, teams_screen 156,
team_management_screen 153, profile_controller 153.
Précédent *[2026-08-28] Mise à jour M13 complète — refonte tournois/équipes
terminée. M13.5 : import des équipes depuis la carte tournoi
(`TournamentTeamImportService`).
M13.6 : écrans tournois admin-only (création/suppression, badge import,
ouverture bloquée non-admin). M13.7 : écran équipes avec claim/join par mot
de passe (`TeamsScreenTeamAccessPanel`, `TeamsScreenTeamAccessActions`).
M13.8 : gestion d'équipe refondue — `TeamManagementTeamActions` (retrait,
suppression, mot de passe, capitainerie), `create_team_dialog` supprimé,
`showErrorSnackBarUsingMessenger` pour les gaps async. M13.9 : profil
affichant équipes et tournois de l'utilisateur (`ProfileTeamsSection`).
M13.10 : association membre/liste via `matched` existant
(`TeamManagementMatchedPanel` : ExpansionTile par rencontre, dialog
d'appariement, `toggleMatched` dans le controller). Validation M13.11 :
`flutter analyze` sans problème, `flutter test` 24/24, `flutter build web` OK.
Précédent M13 (2026-08-27) : schéma PocketBase tournois/équipes,
modèles, services. Précédent :
*[2026-08-26] Mise à jour après M12 : scripts de maintenance PocketBase
(`tool/pocketbase_purge_meta_war_records.dart` : `--yes` obligatoire,
option `--purge-referentiels`, suppression feuilles → parents ;
`tool/pocketbase_seed_test_accounts.dart` : comptes `test1` à `test4`
idempotents) et support commun `tool/pocketbase_tool_support.dart`.
M11 : helper `showErrorSnackBar` (log debug + bouton Copier presse-papiers),
suppression de compte dans le Profil avec `AlertDialog`, purge explicite des
équipes capitaine et des tournois créés par l'utilisateur avant suppression
(`deleteCurrentAccount`), déconnexion post-suppression. M10 : validations
login/inscription (8 car + majuscule + spécial, tooltip), `short`
auto-généré, icônes capitaine/membre, `popUntil` après déconnexion,
raîchissements post-actions, équipes du tournoi visibles par tous,
dédoublonnage de l'import texte, matrice : valeurs toujours visibles en
cellule appariée, backend d'administration complet (champ `admin` sur
`joueurs`, écran admin 3 onglets — import manuel du schéma PB requis).
Précédents M9 : `Dicy`, matrice enrichie, import tournoi.*

## Structure

```
lib/
  main.dart                        # AuthGate (Stream auth) → Login ou HomeShell
                                    # (NavigationBar 3 onglets : Tournois, Équipes,
                                    # Profil) ; HomeShell rafraîchit l'écran
                                    # activé via RefreshableScreenState (M17)
  config/
    app_config.dart                # URL PocketBase, noms de collections,
                                    # clé session, bornes/scores/confiance
                                    # d'estimation, teamPasswordMaxLength,
                                    # snackBarDisplayDuration (2 s, M15) —
                                    # zéro magic value
  models/                          # Modèles purs (IDs string PB, champs snake_case)
    models.dart                    # Barrel : ré-exporte les modèles ci-dessous
    appreciation_scale.dart        # Échelle fixe 7 appréciations + recherches
     armee.dart choix.dart estim.dart joueur.dart matched.dart
      team.dart team_meta.dart tournoi.dart
                                     # M13 : Tournoi.importEffectue ;
                                     # Team.tournoiId / Team.motDePasse ;
                                     # M18 : team_meta (1 ligne par joueur/équipe,
                                     # ancrée sur team_id) ; estims/matched + teamMetaId
  logic/
    estim_score_calculator.dart    # Midpoint + label compact du score
    matched_score_summary.dart     # Total/moyenne des appariements scorés
  utils/
    hex_color_parser.dart          # Parsing sécurisé `#RRGGBB` → Color?
    error_snack_bar_presenter.dart # `showErrorSnackBar` : log debug +
                                   # snackbar 2 s sans `action` (une `action`
                                   # impose persist=true par défaut, M15)
  screens/                         # Écrans = thin shell (init + build + refresh)
     *_controller.dart              # Logique d'écran : TextEditingControllers,
                                    # chargements, mutations ; onStateChanged (VoidCallback)
     refreshable_screen.dart        # Base RefreshableScreenState :
                                    # refreshOnTabActivated() rappelé par HomeShell
                                    # à l'activation de l'onglet (M17)
     login_screen.dart              # Connexion/inscription (shell)
    login_controller.dart          # validate() / submit() → Future<String?>
     tournois_screen.dart           # Liste des tournois + FAB ajout + actions
                                    # édition/suppression/import (précédent,
                                    # 163 lignes)
      tournois_controller.dart       # load/add/update/delete tournoi + tailles d'équipes importées (M20)
     tournoi_team_import_actions.dart # showTournoiTeamImportDialog : armées de
                                    # référence, dialog d'import, snackbar résumé
      teams_screen.dart              # Équipe active + liste des équipes adverses
                                     # du tournoi (M16, plus de rencontres)
     teams_screen_controller.dart   # bindTournoi, loadTeams, équipes adverses
                                     # du tournoi (hors équipe active)
    team_management_screen.dart    # Gestion équipes (sidebar + détail + appariements)
    team_management_controller.dart # Logique gestion d'équipe : membres,
                                     # rencontres, adversaires (chargés à la
                                     # demande, une fois par sélection, M23),
                                     # appariements
    team_management_team_actions.dart # Opérations d'écriture : retrait,
                                      # suppression, mot de passe, capitainerie
    team_dashboard_screen.dart     # Tableau de bord d'un duel (shell)
    team_dashboard_controller.dart # Streams realtime team_meta/estims/matched,
                                   # droits d'édition par rôle (joueur/capitaine)
    team_dashboard_estim_actions.dart  # Modales d'estimation + taps cellules matrice
    profile_screen.dart            # Profil + invitations en attente (shell)
    profile_controller.dart        # Chargement profil/invitations, accept/refus,
                                   # deleteAccount
    admin_screen.dart              # Écran d'administration : 3 onglets
                                    # (Armées, Appréciations, Joueurs)
    admin_controller.dart          # Chargement des 3 listes + CRUD armées/
                                    # appréciations + toggle admin / delete joueur
                                    # + helpers couleur hex
  screens/widgets/                 # Composants UI atomiques (1 fichier = 1 rôle)
     login_*                        # brand_header / form_fields (touche Entrée
                                     # → soumission, M28) / submit_actions
     tournoi_card.dart              # Carte tournoi (suppression confirmée
                                     # interne, actions admin édition/import, taille d'équipe si > 0 (M20))
     tournoi_add_dialog.dart        # Dialog ajout tournoi
     tournoi_edit_dialog.dart       # Dialog modification tournoi (StatefulWidget,
                                    # contrôleurs libérés dans dispose)
     tournoi_list_body.dart         # Corps de liste : chargement / vide / cartes
    estim_dialog.dart + estim_{choix,score,confiance,commentaire}_section.dart
                                   # Dialog estimation découpé en 4 sections
    estim_dialog_controller.dart   # État/validation/sauvegarde du dialog
    estim_details_sheet.dart       # Bottom sheet détail d'estimation (édition)
     tournament_text_import_{action_bar,analysis_section}.dart
                                    # Sections du dialog d'import d'équipe
                                    # (tournoi_team_import_dialog) ; launcher et
                                    # dialog txt standalone supprimés (02/09)
    confiance_star_icon.dart       # Étoile de confiance (faible/moyen/élevée)
    team_dashboard_body.dart       # Streams imbriqués du dashboard + résumé
                                   # des scores appariés
    team_dashboard_matrix.dart     # Table matrice joueurs×adversaires (scrolls
                                   # horizontal+vertical, colonnes fixes)
    team_dashboard_matrix_player_row.dart  # Classe plain TableRow (pas un Widget)
    team_dashboard_matrix_{matchup_cell,opponent_header_cell}.dart
    team_dashboard_mode_banner.dart
    team_dashboard_score_summary.dart # Bandeau appariements/total/moyenne
    team_management_*              # 6 panels : sidebar, detail, invite, members,
                                    # settings, matched_panel
      teams_screen_{opponent_list,team_selector}.dart
                                     # opponent_list (M16) : liste des équipes
                                     # adverses du tournoi, sans rencontre
                                     # team_selector (M15) : affichage statique
                                     # Text du nom d'équipe active (pas de
                                     # DropdownButton)
    opponent_details_dialog.dart   # Bottom sheet détail adversaire (top-level
                                   # show*, onDelete : Future<void> Function())
    profile_{info_card,invitations_section,teams_section}.dart
    profile_account_management_section.dart # Administration + suppression
                                            # de compte (cartes profil)
    profile_delete_account_dialog.dart      # Confirmation AlertDialog
                                            # avant suppression de compte
     admin_{armeees,choix,joueurs}_tab.dart   # Onglets admin : list + actions
      admin_{armee,choix}_edit_dialog.dart     # Dialogues d'édition (StatefulWidget :
                                      # le State possède et libère les contrôleurs
                                      # dans dispose ; swatch couleur cliquable
                                      # pour les choix → sélecteur ci-contre)
      admin_color_picker_dialog.dart           # Sélecteur de couleur (M27) : grille
                                      # des 19 teintes Material 500 en Wrap borné,
                                      # tap = sélection, Valider → Color (ValueKey hex
                                      # par échantillon pour les tests)
  services/
      pocketbase_data_service.dart   # Façade singleton : surface API historique
                                     # (ex-SupabaseService) → délégation totale
                                       # aux sous-services ci-dessous (~242 lg) ; garde capacité équipe (M20)
    pocketbase/
      pocketbase_client_holder.dart    # Client PB + AsyncAuthStore + yield initial
                                       # du stream d'auth + échappement filtres
      pocketbase_auth_service.dart     # signIn/signUp/signOut, profil courant,
                                       # searchJoueurs
        pocketbase_teams_service.dart    # teams : équipes par tournoi/joueur,
                                         # création pour un tournoi, mot de
                                         # passe, capitaine
       pocketbase_team_membres_service.dart  # Membres : inscription accepté,
                                         # join mot de passe, listing, rôles, compterJoueursEquipe (M20)
       pocketbase_team_invitations_service.dart # Invitations : pending, invite,
                                        # accept, decline/remove
       pocketbase_team_access_service.dart # Claim capitaine, join mot de passe,
                                        # nomination d'un nouveau capitaine
         pocketbase_tournois_service.dart # CRUD tournois (dont updateTournoi)
                                           # + import des équipes marqué
        pocketbase_referentiels_service.dart   # getArmees / getChoix (publics)
                                              # + CRUD admin armées/choix
        pocketbase_admin_service.dart          # Admin joueurs : liste, toggle
                                               # du rôle `admin`, suppression
                                               # du compte courant (équipes
                                               # capitaine + tournois créés)
       pocketbase_dashboard_adversaires_service.dart # CRUD + stream team_meta (par équipe, M18) + compterTeamMeta (M20)
       pocketbase_dashboard_estims_service.dart      # upsert + stream estims
      pocketbase_dashboard_matched_service.dart     # CRUD + stream matched
     new_recruit_import_service.dart  # Parsing local New Recruit (JSON collé
                                      # ou texte) + correspondance armées
     new_recruit_json_extractor.dart  # extractPlayersFromTournamentJson
     new_recruit_armee_name_matcher.dart # matchArmeeInReference (normalisation)
    tournament_text_import_parser.dart  # Parser du format texte de tournoi
                                        # (équipes, joueurs, listes, armées)
       tournament_text_import_service.dart # Import tournoi : team_meta
                                           # par équipe (upsert par
                                           # team_id + nom_jo, M18),
                                           # armées inconnues, dédoublonnage,
                                           # résumé
     tournament_team_import_service.dart # Import des équipes d'un tournoi :
                                         # création/récupération des teams (une fois),
                                         # + team_meta par équipe (M18), mark import_effectue
test/
   widget_test.dart                 # Tests des conversions PocketBase ↔ modèles
   admin_dialog_repro_test.dart     # Garde : dialogs d'édition admin (cycles
                                    # ouverture/fermeture sans exception)
   tournament_text_import_parser_test.dart # Tests du parser (4 cas)
    memo_7_9_repro_test.dart              # Garde M15 : disparition auto du
                                          # SnackBar + sélecteur équipe statique
                                          # (le test point 7 est en attente du
                                          # fix de timing M15.4)
    memo_8_repro_test.dart                # Garde M16/M18 : team_meta ancrée
                                          # sur team_id (pas adversaire_team_id) ;
                                          # estims/matched + teamMetaId, sans rencontre_id
  appreciation_scale_test.dart     # Échelle fixe 7 appréciations
  hexadecimal_color_parser_test.dart # Parsing couleurs hexadécimales
  estim_score_calculator_test.dart # Midpoint + label score
  matched_score_summary_test.dart  # Agrégats des appariements scorés
tool/
  pocketbase_seed_records.dart     # Seed idempotent 16 armées + 7 appréciations
                                   # fixes
  pocketbase_seed_demo_records.dart # Jeu de données démo multi-joueurs
  pocketbase_tool_support.dart     # Arguments, connexion superuser, codes de
                                   # sortie, suppression par collection
  pocketbase_purge_meta_war_records.dart # Purge MetaWar sécurisée (--yes)
  pocketbase_seed_test_accounts.dart # Comptes de test test1-test4 idempotents
```

## Flux de données

1. **Auth** : `main.dart` écoutre `PocketbaseDataService.authStateChanges`
   (stream émettant la valeur courante immédiatement — yield initial dans
   `pocketbase_client_holder.dart`) → LoginScreen ou HomeShell.
2. **Écrans** : chaque écran = shell StatefulWidget qui instancie son
   `*_controller` dans `initState`, s'abonne à `onStateChanged`
   (`setState` si `mounted`) et délègue toute mutation. Les méthodes de
   mutation retournent `Future<String?>` (null = succès) ; les erreurs
   passent par `showErrorSnackBar` (log debug + bouton Copier), les succès
   restent des SnackBar verts. Les 3 écrans du shell principal (Tournois,
   Équipes, Profil) héritent de `RefreshableScreenState` (M17) : leur
   `initState` ne court qu'une fois (`IndexedStack` qui les garde en vie),
   donc à chaque activation d'onglet `HomeShell` appelle
   `refreshOnTabActivated()` sur l'écran devenu actif pour recharger ses
   données (pas de rafraîchissement au premier affichage).
3. **Services** : les écrans n'appellent JAMAIS PocketBase directement —
   toujours via la façade `PocketbaseDataService.instance`, qui délègue aux
   sous-services `lib/services/pocketbase/` (singletons). Certains
   sous-services coopèrent entre eux (ex. `PocketbaseTeamAccessService` →
   `PocketbaseTeamsService` + `PocketbaseTeamMembresService`).
4. **Temps réel + agrégats** : les streams SSE (team_meta/estims/matched)
   sont créés UNE FOIS dans `initState` du controller dashboard ; refetch
   complet sur événement, debounce 300 ms ; rendu matrice O(1) (Maps/Sets).
   `team_dashboard_body.dart` construit la clé
    `joueurId + dashboardEstimKeySeparator + teamMetaId`, puis
   `MatchedScoreSummaryCalculator.summarize` calcule total/moyenne à partir
   du midpoint `(scoreMin + scoreMax) / 2`.
5. **Import tournoi** : depuis la carte tournoi (`TournoisScreen`, M13.5),
   le bouton d'import ouvre `showTournoiTeamImportDialog`
   (`tournoi_team_import_actions.dart`) →
   `NewRecruitImportService.parseNewRecruitContent` (JSON collé ou texte via
   `TournamentTextImportParser`) → `PocketbaseDataService.importTeamsForTournoi`
    → `TournamentTeamImportService` (création/récupération des équipes,
    une fois) + `TournamentTextImportService` (`team_meta` par
    équipe détectée — upsert par `team_id` + `nom_jo`, M18 ;
   armées inconnues comptées) → `markTournoiImportEffectue`. L'import API
   direct (dialog New Recruit + `NewRecruitApiClient`) et le bouton d'import
   texte de `TeamsScreen` ont été supprimés : features sans point d'entrée.
6. **Modèles** : `fromPocketBaseRecord` / champs snake_case ; les IDs sont
    des strings PocketBase. L'échelle d'appréciation est fixe dans
    `appreciation_scale.dart` (`--`, `-`, `=-`, `=`, `=+`, `+`, `++`);
    `choix.dart` est un simple modèle, sans constantes sentinelles.
7. **Administration** : `ProfileScreen` affiche la carte « Administration »
   seulement si `joueur.admin` (booléen, collection `joueurs`) → `AdminScreen`
   → `AdminController` → façade → `PocketbaseAdminService` (joueurs) et
   `PocketbaseReferentielsService` (CRUD armées/choix). Côté PocketBase :
   règles d'écriture `@request.auth.admin = true` (armées, choix) et
   `id = @request.auth.id || @request.auth.admin = true` (joueurs) —
   `pocketbase_schema.json` doit être réimporté manuellement dans l'admin.
8. **Suppression de compte** : `ProfileScreen` →
   `ProfileAccountManagementSection` → `showProfileDeleteAccountConfirmation`
   (AlertDialog) → `ProfileController.deleteAccount()` →
   `PocketbaseDataService.deleteCurrentAccount()` →
   `PocketbaseAdminService.deleteCurrentAccount()`. Le service liste puis
   supprime d'abord les équipes dont `capitaine_id` est l'utilisateur,
   ensuite les tournois dont `created_by` est l'utilisateur, puis le joueur
    et enfin déclenche `signOut`. Cascades PocketBase : `team_membres`,
    `team_meta`, `estims`, `matched` (M16 : `rencontres` supprimée).
    Suppression explicite des
   équipes capitaines (champ `capitaine_id` sans cascade) et des tournois
    créés (champ `created_by` sans cascade) pour éviter les données orphelines.
9. **M13 tournois/équipes** : création/suppression de tournoi admin-only ;
    `TournoiController.addTournoi` valide le nom non vide (point 4.3 MEMO :
    champ `lien_nr` retiré de la BDD et du code) ;
   `TournamentTeamImportService` crée les équipes manquantes puis appelle
   `markTournoiImportEffectue` ; `PocketbaseTeamAccessService` gère
   claim/join/nomination. M13.8 : `TeamManagementTeamActions` extrait les
   opérations d'écriture (retrait, suppression, mot de passe, capitainerie)
   avec capture de `ScaffoldMessengerState` avant les gaps async. M13.9 :
   `ProfileController` charge `getTeamsForUser` + tournois distincts,
    `ProfileTeamsSection` affiche les équipes groupées par tournoi. M13.10 :
     `TeamManagementController.loadOpponentsForSelectedTeam` charge
     adversaires/appariements (M16 : par équipe adverse, plus de rencontres) ;
       `TeamManagementMatchedPanel` affiche les appariements de l'équipe.
        M23 : chargement paresseux des adversaires (point 6 MEMO) — le panneau
        « Appariements » ne déclenche les requêtes qu'au tap « Afficher les
        appariements », une fois par sélection ; `resetOpponents()`
        au changement d'équipe, résultat périmé ignoré si la sélection change
        pendant le chargement. M26 (point 6.1 MEMO, correction de M24) : le
        panneau liste les **joueurs de l'équipe qui sont appariés**, avec
        l'adversaire correspondant (pseudo, liste d'armée, équipe adverse) —
        un joueur apparaît une fois par équipe adverse ; un joueur sans
        appariement n'apparaît pas et, sans aucun appariement, rien n'est
        affiché. Le panneau est en lecture seule : l'appariement et l'annulation
        se font depuis la matrice du dashboard (`toggleMatched`).
        M25 (point 7 MEMO) : la zone de détail est
       enveloppée dans un `SingleChildScrollView` (colonne `mainAxisSize.min`)
       et les listes membres/invitations sont en `shrinkWrap` — plus de
       RenderFlex overflow vertical sur écran court. M14 :
    `updateTournoi` complète le CRUD
    (service/controller/`TournoiEditDialog` + bouton admin sur `TournoiCard`) ;
    les contrôleurs de texte des dialogs appartiennent au State (libérés dans
    `dispose`) pour éviter l'usage après disposition pendant l'animation de
    fermeture ; `TournoiListBody` + `showTournoiTeamImportDialog` condensent
    l'écran des tournois.
 10. **Maintenance PocketBase** : `tool/pocketbase_purge_meta_war_records.dart`
    exige `--yes`, supprime `matched`, `estims`, `team_meta`,
    `team_membres`, `teams`, `tournois`, `joueurs` (feuilles → parents,
    M16 : plus de `rencontres`), et
   optionnellement `armees`/`choix` avec `--purge-referentiels` ;
   `tool/pocketbase_seed_test_accounts.dart` crée ou met à jour les comptes
    `test1` à `test4` dans `joueurs` avec des mots de passe conformes.
 11. **Taille d'équipe + plafond (M20)** : après `loadTournois`,
     `TournoiController._chargerTaillesEquipes()` charge, pour chaque tournoi
     importé, `PocketbaseDataService.getTailleEquipeTournoi` (max des comptes
     `team_meta` des équipes du tournoi, via `compterTeamMeta`) ; `TournoiCard`
     l'affiche si > 0. Côté plafond, la façade applique
     `_verifierCapaciteAjoutJoueur(teamId)` avant tout ajout de membre « joueur »
     (invitation capitaine, réclamation en capitaine, join par mot de passe) :
     si l'effectif (`compterJoueursEquipe`, `role != coach`, pending inclus)
     atteint la taille de l'équipe, une exception est levée et remontée par les
     snackbars d'erreur des écrans équipes.

## Contraintes de code (voir AGENTS.md)

- 1 fichier = 1 responsabilité, ≤150 lignes recommandé (précédents acceptés
  listés en tête de document).
- Nommage explicite, zéro abréviation, zéro magic value (→ `app_config.dart`).
- `TableRow` est une classe plain dans Flutter : les composants de matrice
  qui produisent des lignes sont des classes plain avec `build(BuildContext)`.
