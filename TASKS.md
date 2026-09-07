# TASKS.md — MetaWar : Migration PHP/Supabase → Flutter Web + PocketBase

## Contexte projet (résumé pour sessions futures)
- **Legacy PHP** (`php/`) : app tournoi T9A — Tournois → Teams → Adversaires (listes)
  + matrice estimations joueur×armée (6 choix colorés) + appariements "matched".
- **Cible** : Flutter Web existant (~2800 lignes d'écrans dans `lib/screens/`,
  tous appelés via `SupabaseService.instance.*` à migrer) + PocketBase.
- **PocketBase** : https://metabase.pedagogeek.fr (admin UI `/_/`, `/api/health` OK).
- **Décisions validées** :
  - Schéma déployé via snapshot `pocketbase_schema.json` importé dans l'UI admin.
  - Auth = collection `auth` dédiée `joueurs` (email+mot de passe) ;
    la collection native `users` de PocketBase est CONSERVÉE telle quelle
    (ni modifiée ni supprimée, décision utilisateur 2026-08-22) ;
    à l'import du snapshot : NE PAS activer « delete missing collections »
    (option désactivée par défaut — l'import est additif).
  - Import New Recruit = appel API direct côté client + fallback parsing texte.
  - Post-test 2026-08-22 : l'import API New Recruit est mis de côté ;
    l'import texte devient le chemin principal depuis `TeamsScreen`.
  - Post-test 2026-08-22 : une équipe active par tournoi/joueur est attendue ;
    le dropdown « Équipe active » doit être simplifié ou supprimé.
  - Le service garde la même surface d'API que SupabaseService → écrans intacts.

## Architecture cible
lib/
  main.dart                  # AuthGate + navigation
  models/models.dart         # IDs string PocketBase
  services/pocketbase_data_service.dart   # singleton, auth+CRUD+realtime
  services/new_recruit_import_service.dart # API directe + parsing texte
  screens/...                # inchangés sauf imports

Collections PB : joueurs (auth DÉDIÉE — users natif intouché), tournois,
teams, team_membres, armees(16 seed), choix(7 appréciations fixes),
team_meta, estims, matched.

## Missions

### M1 — Setup dépendances ✅
- [x] M1.1 Ajouter `pocketbase` au pubspec.yaml, retirer traces supabase
- [x] M1.2 Constante URL serveur centralisée (pas de magic value)
      → `lib/config/app_config.dart` (URL + noms de collections + clé session)

### M2 — Schéma PocketBase ✅ (import serveur en attente côté utilisateur)
- [x] M2.1 Écrire `pocketbase_schema.json` (10 collections, relations,
      règles API : lecture membres équipe, écriture auth-only, uniques anti-doublon)
- [x] M2.2 Seed armees (16 armées T9A) + choix (6 estimations) depuis MetaWar.sql
      → `tool/pocketbase_seed_records.dart` (idempotent, superuser requis)
- [x] M2.3 Documenter la procédure d'import dans le README
- [x] M2.4 Snapshot importé sur metabase.pedagogeek.fr (collections alignées
      par script superuser) + seed exécuté : 16 armées / 6 choix créés

### M3 — Service de données ✅
- [x] M3.1 Créer pocketbase_data_service.dart : auth (signIn/signUp/signOut,
      profil courant) — remplace supabase_service.dart
- [x] M3.2 CRUD tournois / teams / team_membres (invitations pending/accepted)
- [x] M3.3 CRUD rencontres / meta_adv
- [x] M3.4 Estims upsert/delete + toggleMatched (uniques PB en garde-fou)
- [x] M3.5 Realtime : subscribe() opponents/estims/matched par rencontre
      (refetch complet sur événement ; SSE auto-connecté par subscribe)

### M4 — Modèles ✅
- [x] M4.1 Adapter models.dart aux IDs string PB + champs snake_case
      (+ constantes choixEstimationInexistanteId / choixEstimationDefautId)

### M5 — Câblage application ✅
- [x] M5.1 main.dart : AuthGate (Stream auth) → Login ou HomeShell
- [x] M5.2 Navigation Tournois ↔ Teams ↔ Dashboard ↔ Profil (NavigationBar 3 onglets)

### M6 — Import New Recruit ✅
- [x] M6.1 new_recruit_import_service.dart : fetch API newrecruit.eu côté client
      (endpoint à confirmer si CORS/chemin diffèrent : `/api/tournament/{id}`)
- [x] M6.2 Rebrancher le parsing texte local existant comme fallback

### M7 — Validation
- [x] M7.1 flutter analyze sans erreur ni warning (25 infos préexistantes)
- [x] M7.2 flutter build web OK (+ flutter test 7/7)
- [x] M7.3 Test CRUD réel contre metabase.pedagogeek.fr
      → E2E 20/20 : auth, règles d'accès (refus inter-joueurs), index uniques
      (estims/matched), référentiels publics, temps réel SSE filtré ;
      nettoyage vérifié (0 enregistrement résiduel, référentiels intacts)

### M8 — Corrections post-tests (import texte, estimations, équipes)
- [x] M8.1 Mettre à jour `TASKS.md` avec la mission post-tests
- [x] M8.2 Indexer/mettre à jour la mémoire RAG via le serveur MCP
- [x] M8.3 Parser robuste du format `exemple_tournoi.txt`
      (service atomique, séparé de l'UI, ≤150 lignes par fichier)
- [x] M8.4 Câbler l'import txt dans `lib/screens/teams_screen.dart`
      et mettre l'import API New Recruit de côté (sans le supprimer)
- [x] M8.5 Édition des estimations par rôle :
      joueur = ses estimations ; capitaine = les siennes + celles de son équipe
      → `_canEditEstimationOf` + `_openEstimDialog` dans team_dashboard_screen.dart ;
      bouton « Éditer » dans la sheet de détails ; appui long crée une estimation vide
- [x] M8.6 Permettre le retrait d'un joueur d'une équipe
      dans `lib/screens/team_management_screen.dart`
      → `_canRemoveMember` + `_removeMember` ; capitaine retire les joueurs,
      un joueur se retire lui-même ; réutilise declineOrRemoveTeamInvite
- [x] M8.7 Supprimer/simplifier le dropdown « Équipe active »
      (équipe unique par tournoi/joueur)
      → dropdown retiré : affichage statique du nom d'équipe dans
      teams_screen_team_selector.dart ; changeActiveTeam supprimée du controller
- [x] M8.8 Corriger l'overflow mobile
      (`RenderFlex overflowed by 37 pixels on the right`) et les freezes
      → overflow : actions AppBar en IconButtons (plus de libellés), matrice en
      scroll horizontal+vertical imbriqués (colonnes fixes dépassaient l'écran
      mobile sans défilement), titre équipe en Flexible+ellipsis ;
      freezes : streams temps réel créés UNE fois dans initState (avant : nouveau
      stream à chaque rebuild → résouscriptions SSE + refetchs en cascade),
      rendu matrice en index O(1) (Maps/Sets), debounce 300 ms du refetch SSE
      dans _streamCollectionRecords
- [x] M8.9 Refactor atomique des fichiers >150 lignes impliqués
      (1 fichier = 1 responsabilité, UI/logique séparées)
      → 2026-08-23 : tous les dépassements traités. Découpages :
      pocketbase_data_service (641→150, 9 sous-services lib/services/pocketbase/),
      team_management_screen (563→177 + controller 212 + 5 widgets),
      import_newrecruit_dialog (461→167 + controller 191 + 6 widgets),
      models.dart (375→barrel 10 fichiers), profile_screen (301→134 + controller
      + 2 widgets), login_screen (289→127 + controller + 3 widgets),
      tournois_screen (255→163 + controller + 2 widgets),
      estim_dialog (254→167 + 4 sections), team_dashboard trio (209/179/188 →
      120/133/131 + estim_actions + body + matrix_player_row),
      new_recruit_import_service (178→90 + api_client 61 + json_extractor 53
      + armee_name_matcher 29), teams_screen (167→132 + encounter_actions 132),
      pocketbase_team_membres_service (156→69 + invitations_service 108,
      façade 153)
- [x] M8.10 Valider : `flutter analyze`, `flutter build web`, test import txt
      → 2026-08-23 22:10 : analyze 0 erreur / 0 warning / 3 infos
      préexistantes (add_opponent_dialog 55/56, opponent_details_dialog 88 —
      use_build_context_synchronously, hors périmètre M8), build web OK,
      flutter test 10/10 (parser import txt inclus)
- [x] M8.11 Échelle fixe à 7 appréciations + agrégats de score appariements
      → `AppreciationScale` (7 codes, recherche par code/id, tri/filtre),
      `HexColorParser` (couleurs sans exception), `EstimScoreCalculator`
      (midpoint + label), `MatchedScoreSummaryCalculator` (total/moyenne),
      `EstimDialogController` (état/sauvegarde isolés), bandeau
      `TeamDashboardScoreSummary`, cellules matrice sécurisées,
      seed de référence 7 niveaux, seed demo filtré sur l’échelle fixe,
      4 fichiers de tests unitaires helpers
      → 2026-08-24 : analyze 0 erreur / 0 warning / 3 infos
       préexistantes, build web OK, flutter test 21/21

### M9 — Appréciation Dicy, matrice enrichie et import tournoi
- [x] M9.1 Ajouter `Dicy` comme symbole d'appréciation générale absente
      (`AppreciationScale.dicyLabel`) et l'afficher en gris dans la matrice
- [x] M9.2 Enrichir `team_dashboard_matrix_matchup_cell.dart` avec :
      appréciation générale, fourchette du score estimé et étoile de confiance
      (`confiance_star_icon.dart`)
- [x] M9.3 Déplacer l'import du fichier de tournoi au niveau `TeamsScreen`
      (bouton AppBar, `TeamsScreenController.activeTeam`, sans `encounterId`)
- [x] M9.4 Créer `tournament_text_import_service.dart` :
      une rencontre par équipe détectée, adversaires créés, armées inconnues
      comptées, résumé `TournamentTextImportSummary` affiché dans un snackbar
- [x] M9.5 Corriger le parseur des lignes dash :
      `Équipe - JoueurA/JoueurB` reste un bloc équipe/joueurs combinés,
      toute autre ligne dash devient une ligne joueur/armée
      (armée connue ou inconnue) + test dédié
- [x] M9.6 Checkup et corrections :
      BuildContext after async gap, sélection d'équipe sans `!`,
      import New Recruit bloqué si toutes les armées sont inconnues
- [x] M9.7 Validation 2026-08-25 :
      `flutter analyze` sans problème, `flutter test` 22/22, `flutter build web` OK

 ### M10 — Retour tests : validations, capitaine, rafraîchissements, visibilité
 - [x] M10.1 Login/inscription : validation du format d'email et du mot de
       passe (8 caractères minimum, une majuscule, un caractère spécial) avec
       tooltip explicatif ; champ d'initiales retiré des formulaires, `short`
       auto-généré depuis le nom via `Joueur.genererShortDepuisNom`
 - [x] M10.2 Icônes capitaine/membre dans le panel des membres
       (`workspace_premium` / `person`) ; sous-titre de l'invitation = email
 - [x] M10.3 Règles `estims` : le capitaine d'une équipe peut estimer pour
       tous ses membres (sous-requêtes `team_membres`/`teams` dans
       `pocketbase_schema.json` — **import manuel sur le serveur PB requis**)
 - [x] M10.4 Point d'arrêt déconnexion : après `signOut`,
       `Navigator.popUntil` jusqu'à la première route
 - [x] M10.5 Rafraîchissements post-actions : `setState` après
       création/invitation/suppression d'équipe et de membre,
       `onStateChanged` après suppression d'une rencontre
 - [x] M10.6 Visibilité globale : `getTeamsParticipatingInTournoi` (équipes
       ayant au moins une rencontre dans le tournoi), dropdown de
       sélection d'équipe dans `TeamsScreen`, équipe active par défaut =
       première équipe de l'utilisateur
 - [x] M10.7 Dédoublonnage de l'import texte : adversaires déjà présents
       ignorés (`skippedDuplicateEncounterCount` ajouté au résumé snackbar)
  - [x] M10.8 Matrice : réponse utilisateur « garder un visuel sur les
        valeurs » — cellule appariée/bloquée affiche désormais toujours
        l'appréciation, l'étoile et la fourchette (suppression de la branche
        `SizedBox.shrink()` dans `team_dashboard_matrix_matchup_cell.dart`)
  - [x] M10.9 Backend d'administration (périmètre confirmé « Oui exactement ») :
        champ booléen `admin` sur `joueurs`, règles PB élargies
        (joueurs update/delete + armées/choix create/update/delete →
        `@request.auth.admin = true`), écran d'administration à 3 onglets
        (Armées, Appréciations, Joueurs) accessible depuis le Profil si
        `joueur.admin` — **import manuel du schéma sur le serveur PB requis**
  - [x] M10.10 Validation 2026-08-26 :
        `flutter analyze` sans problème, `flutter test` 22/22, `flutter build web` OK
        (re-validé après M10.8 + M10.9)

### M11 — Fiabilité : erreurs traçables + suppression de compte
- [x] M11.1 Helper central `showErrorSnackBar` : message affiché, `debugPrint`,
      bouton « Copier » pour l'erreur
- [x] M11.2 Refactoriser les SnackBar d'erreur existants vers le helper central
- [x] M11.3 Bouton « Supprimer mon compte » dans `ProfileScreen` avec
      `AlertDialog`, déconnexion, purge intégrée des équipes capitaines et
      des tournois créés par l'utilisateur
- [x] M11.4 Validation 2026-08-26 : `flutter analyze` sans problème,
      `flutter test` 24/24, `flutter build web` OK, mise à jour
      `DOC.md`/`README.md`, RAG et Discord

### M12 — Scripts de maintenance superuser
- [x] M12.1 Helper partagé `tool/pocketbase_tool_support.dart`
       (lecture des identifiants superuser, sorties d'erreur normalisées)
- [x] M12.2 `tool/pocketbase_purge_meta_war_records.dart`
       (purge des données métier sans supprimer les comptes de test ni les
       référentiels si l'option correspondante est utilisée)
- [x] M12.3 `tool/pocketbase_seed_test_accounts.dart`
       (comptes test1 à test4 avec identifiants connus, idempotent)
- [x] M12.4 Validation : `flutter analyze` sans problème, `flutter test` 24/24,
       `flutter build web` OK, scripts sans identifiants en erreur d'usage

### M13 — Point 4 MEMO : refonte logique tournois / équipes ✅
- [x] M13.1 Mettre à jour `TASKS.md` avec la présente milestone
- [x] M13.2 Schéma PocketBase :
        `tournois.lien_nr` obligatoire, `tournois.import_effectue`,
        création/modification/suppression de tournoi réservées aux admins ;
        `teams.tournoi_id` avec cascade delete, `teams.mot_de_passe`,
        `teams.capitaine_id` optionnel, création d'équipe réservée aux admins,
        réclamation d'équipe sans capitaine, suppression admin ou capitaine ;
        `team_membres.createRule` pour invitation capitaine, réclamation
        capitaine et join par mot de passe
        → `pocketbase_schema.json` mis à jour et validé localement ;
        import manuel sur l'instance PocketBase requis
- [x] M13.3 Modèles Dart :
        `Tournoi.importEffectue`, `Team.tournoiId`, et le champ mot de passe
        d'équipe si la règle de visibilité est conservée côté client
        → `tournoi.dart` et `team.dart` mis à jour
- [x] M13.4 Services tournois / équipes / membres / façade :
        lister les équipes d'un tournoi, créer un tournoi avec lien NR,
        marquer l'import des équipes comme effectué, réclamer une équipe
        en devenant capitaine, rejoindre une équipe avec le mot de passe,
        modifier le mot de passe, nommer un nouveau capitaine, supprimer
        un tournoi ou une équipe avec cascade
        → services PocketBase + `TournamentTeamImportService` + façade
        `PocketbaseDataService` écrits ; adaptation UI suivante
- [x] M13.5 Import des équipes depuis la carte tournoi :
       création des records `teams` manquants pour le tournoi, puis
       `import_effectue = true` ; les rencontres importées plus tard par les
       capitaines depuis `TeamsScreen`
       → `TournamentTeamImportService.importTeamsForTournoi` + action dans
       `TournoisScreen` (badge import, bouton admin)
- [x] M13.6 Écrans tournois :
       création/suppression admin-only, formulaire nom + lien NR obligatoires,
       badge « import des équipes requis », ouverture bloquée pour les
       non-admins tant que l'import n'est pas effectué
       → `TournoiCard`, `TournoiAddDialog`, `TournoiTeamImportDialog`,
       contrôle d'accès dans `TournoisScreen`
- [x] M13.7 Écran équipes :
       utilisateur sans équipe = liste des équipes du tournoi avec
       « Devenir capitaine » ou « Rejoindre avec mot de passe » ;
       utilisateur avec équipe = sélection parmi ses équipes du tournoi,
       rencontres et import texte comme avant
       → `TeamsScreenTeamAccessPanel`, `TeamsScreenTeamAccessActions`,
       sélection d'équipe dans `TeamsScreenController`
- [x] M13.8 Écran de gestion d'équipe :
       supprimer la création d'équipe standalone, gérer le mot de passe,
       nommer un capitaine parmi les membres, inviter/retirer des joueurs
       → `TeamManagementTeamActions` (4 méthodes), `TeamManagementScreen`
       refondu, `create_team_dialog` supprimé, `error_snack_bar_presenter`
       avec `showErrorSnackBarUsingMessenger`
- [x] M13.9 Profil utilisateur : afficher ses équipes et ses tournois
       → `ProfileController` charge `getTeamsForUser` + tournois distincts,
       `ProfileTeamsSection` widget, insertion dans `ProfileScreen`
- [x] M13.10 Association membre/liste :
       appariement d'un membre de l'équipe à l'une des listes importées
       (`matched` existant)
       → `TeamManagementController.loadEncountersForSelectedTeam` +
       `toggleMatched`, `TeamManagementMatchedPanel` (ExpansionTile par
       rencontre, dialog d'appariement), intégration dans
       `TeamManagementTeamDetailPanel`
- [x] M13.11 Validation finale :
        `flutter analyze`, `flutter test`, `flutter build web`,
        mise à jour `DOC.md`/`README.md`, RAG et Discord
        → 2026-08-28 : `flutter analyze` sans problème,
        `flutter test` 24/24, `flutter build web` OK ;
        `DOC.md` et `README.md` mis à jour

### M14 — Point 6 MEMO : CRUD tournoi + corrections dialogs ✅
- [x] M14.1 Reproduire les erreurs d'édition des dialogs (framework.dart:6281,
       "A TextEditingController was used after being disposed",
       Duplicate GlobalKey) → `test/admin_dialog_repro_test.dart`
       (test de garde : cycles ouverts/fermés sans exception)
- [x] M14.2 Convertir les dialogs d'édition admin en StatefulWidget :
       le State possède les contrôleurs + GlobalKey et les libère dans
       `dispose()` ; API publique `showArmeeEditDialog` / `showChoixEditDialog`
       inchangée (résultat via `pop`)
- [x] M14.3 Corriger l'overflow SnackBar 99134 px (panel appariements) :
       pseudo de l'adversaire à la place de la liste entière
- [x] M14.4 CRUD tournoi complété : `updateTournoi` (service + controller),
       `TournoiEditDialog` + `showTournoiEditDialog`, bouton édition (admin)
       sur `TournoiCard`, câblage dans l'écran
- [x] M14.5 Découpage service : `pocketbase_rencontres_service.dart`
       (rencontres + équipes participantes), `pocketbase_tournois_service.dart`
       retourne au CRUD tournoi pur
- [x] M14.6 Compaction de `TournoisScreen` : `TournoiListBody` (corps de
       liste) + `showTournoiTeamImportDialog` (tournoi_team_import_actions.dart)
       + `_runTournoiOperation` (232→163 lignes)
- [x] M14.7 Validation finale 2026-08-29 : `flutter analyze` sans problème,
        `flutter test` 28/28, `flutter build web` OK ;
        `DOC.md`/`MEMO.md` mis à jour, RAG et Discord

### M15 — Points 7 et 9 MEMO : durée des SnackBars + sélecteur équipe
- [x] M15.1 Point 7 : constante `snackBarDisplayDuration = Duration(seconds: 2)`
        dans `app_config.dart` (section « Durées d'affichage de l'interface ») ;
        `duration` appliquée au présentateur d'erreurs
        (`error_snack_bar_presenter.dart`, 3 SnackBars) et aux 11 SnackBars
        succès/info (profile, team_dashboard, team_management ×3,
        add_opponent_dialog, tournois, team_access_actions,
        matched_panel ×2, admin, tournoi_team_import_actions)
- [x] M15.2 Point 9 : `teams_screen_team_selector.dart` réécrit en affichage
        statique `Text` du nom d'équipe active (plus de `DropdownButton`) ;
        `teams_screen.dart` : `_handleTeamSelected` supprimé, appel réduit à
        `TeamsScreenTeamSelector(activeTeam: …)` ;
        `teams_screen_controller.dart` : `selectableTeams` et `setActiveTeam`
        supprimés (morts). Équipe active = première équipe du tournoi/joueur
- [x] M15.3 Test de garde `test/memo_7_9_repro_test.dart` (3 tests :
        disparition auto du SnackBar, sélecteur = Text sans dropdown,
        cas équipe nulle)
- [x] M15.4 Cause racine du test point 7 en échec : ce n'était PAS un
        problème de timing de pump — le SnackBar d'erreur avait une `action`
        (bouton « Copier ») et dans Flutter 3.47 un `SnackBar` avec `action`
        reçoit `persist = true` par défaut (`snack_bar.dart:303` :
        `persist = persist ?? action != null`) → le timer fire mais le
        SnackBar ne s'auto-ferme jamais (test ET prod). Fix : bouton « Copier »
        retiré du présentateur d'erreurs (le message reste dans les logs via
        `debugPrint`) ; aucun autre SnackBar de `lib/` n'a d'`action`
- [x] M15.5 Validation finale : `flutter analyze` 0 problème,
        `flutter test` 32/32, `flutter build web` OK ; points 7 et 9 RESOLU
        dans `MEMO.md`, `DOC.md` finalisé, RAG et notification Discord

### M16 — Point 8 MEMO : suppression de la collection `rencontres` ✅
- [x] M16.1 Schéma `pocketbase_schema.json` : collection `rencontres` supprimée ;
        `meta_adv`/`estims`/`matched` ancrés sur `team_id` + `adversaire_team_id`
        (relations `teams`, cascadeDelete) ; index uniques `matched` recalés sur
        `(team_id, adversaire_team_id, joueur_id)` et
        `(team_id, adversaire_team_id, meta_adv_id)` ; règles d'écriture
        recalées sur `team_id.capitaine_id`
- [x] M16.2 Modèles : `MetaAdv`/`Estim`/`Matched` — `rencontreId` remplacé par
        `teamId` + `adversaireTeamId` ; `lib/models/rencontre.dart` supprimé
        (+ export `models.dart`)
- [x] M16.3 Services : filtres `pocketbase_dashboard_{adversaires,estims,matched}`
        sur `team_id`/`adversaire_team_id` ; `deleteEstim` sans `rencontreId` ;
        façade `pocketbase_data_service` recâblée (create/get/delete Rencontre et
        `getTeamsParticipatingInTournoi` retirés, `getTeamsForTournoi` = liste des
        adversaires) ; `pocketbase_rencontres_service.dart` supprimé ;
        `collectionNameRencontres` retiré de `app_config.dart`
- [x] M16.4 Écran Équipes : liste = équipes du tournoi (hors équipe active) ;
        suppression des « rencontres personnalisées » (texte libre), du bouton
        de création de rencontre, du bouton de suppression et des widgets
        `rencontre_list_tile`/`add_encounter_dialog`/`rencontre_delete_confirmation`
- [x] M16.5 Tableau de bord : `TeamDashboardScreen`/`Controller` pilotés par
        `team` + `adversaireTeam` (flux filtrés sur le duo d'équipes) ;
        panel d'appariements de la gestion d'équipe recalé sur les équipes adverses
- [x] M16.6 Import texte : `TournamentTextImportService` ancre `meta_adv` sur
        l'équipe adverse réelle (créée si absente du tournoi) ; compteurs
        `createdEncounterCount` → `createdOpponentTeamCount`
- [x] M16.7 Outils : purge sans `rencontres` ; seed démo réécrit (4 équipes
        adverses [DEMO] créées dans le tournoi, `meta_adv`/`estims`/`matched`
        ancrés sur les duos d'équipes)
- [x] M16.8 Tests : fixtures `rencontre_id` remplacées ; test de garde point 8
         (modèles sans `rencontreId`) → `test/memo_8_repro_test.dart` (3 tests :
         MetaAdv/Estim/Matched ancrés sur teamId + adversaireTeamId, toJson
         sans `rencontre_id`)
- [x] M16.9 Docs (README/DOC/MEMO point 8 RESOLU) + RAG + notification Discord
 - [x] M16.10 Validation : `flutter analyze` 0, `flutter test` OK,
          `flutter build web` OK
          → 2026-08-30 : `flutter analyze` sans problème,
          `flutter test` 35/35, `flutter build web` OK
  - [x] M16.11 Correctif import carte tournoi : règles d'écriture `meta_adv`
           sans bypass admin → 400 « Failed to create record » sur les équipes
           dont le capitaine ≠ utilisateur connecté. `|| @request.auth.admin = true`
           ajouté aux règles create/update/delete `meta_adv` (snapshot +
           application directe serveur via superuser 2026-08-31). Vérifié
           de bout en bout (compte admin temporaire : create/update/delete OK).
           `matched`/`estims` inchangées.

### M17 — Point 2 MEMO : rafraîchissement automatique des écrans (barre du bas)
- [x] M17.1 Base partagée `RefreshableScreenState<T>`
      (`lib/screens/refreshable_screen.dart`) : méthode vide
      `refreshOnTabActivated()`
- [x] M17.2 `HomeShell` (main.dart) : `GlobalKey<RefreshableScreenState<…>>`
      par écran, attaché comme `key:` dans l'`IndexedStack` (liste d'écrans
      inline — plus de `static const _onglets`) ; au `onDestinationSelected`,
      appel de `refreshOnTabActivated()` sur l'écran devenu actif
      (pas de rafraîchissement au premier affichage, pas de double fetch)
- [x] M17.3 Écrans héritant de la base et relançant leur chargement existant :
      `TournoisScreen` (`_loadTournois`), `TeamManagementScreen`
      (`_loadInitialData`), `ProfileScreen` (`_loadProfileAndInvitations`)
- [x] M17.4 `TeamManagementScreen` : commentaire orphelin `//raffraichir ?`
      remplacé par un `IconButton` de rafraîchissement dans l'AppBar
      (cohérent avec `TournoisScreen`)
- [x] M17.5 `TeamManagementController.loadInitialData` : conservation de
      l'équipe sélectionnée au rechargement si elle figure encore dans la
      liste (avant : réinitialisation inconditionnelle sur la première)
- [x] M17.6 Validation : `flutter analyze` 0 problème, `flutter test` 35/35,
      `flutter build web` OK
- [x] M17.7 Docs : point 2 RESOLU dans `MEMO.md`, mémoire RAG
      → 2026-09-02 : `MEMO.md` point 2 marqué « RESOLU » + puce Résolution,
   `DOC.md`/`TASKS.md` à jour, mémoire RAG (M17) finalisée

### M18 — Point 1 MEMO : refonte `meta_adv` → `team_meta` (1 ligne par joueur par équipe)
- [x] M18.1 Schéma PocketBase : collection `team_meta` (id `mwteammeta00001`,
      remplace `meta_adv`) : `team_id`, `armee_id`, `nom_jo`, `liste_jo` +
      index unique `(team_id, nom_jo)` ; `team_membres.team_meta_id` optionnel ;
      `estims`/`matched` `meta_adv_id` → `team_meta_id` (index uniques adaptés)
- [x] M18.2 Modèles : `TeamMeta` (`id`, `teamId`, `armeeId`, `nomJo`,
      `listeJo`) remplace `MetaAdv` ; `Estim`/`Matched` : `metaAdvId` →
      `teamMetaId` (`team_meta_id`) ; `app_config` : `collectionNameTeamMeta`
- [x] M18.3 Services : `pocketbase_dashboard_adversaires_service` (nom
      conservé) réécrit `team_meta` par équipe (`getTeamMeta`,
      `streamTeamMeta(teamId)`, `createTeamMeta`, `updateTeamMeta`,
      `deleteTeamMeta`) ; `saveEstim` upsert sur `(team_id,
      adversaire_team_id, joueur_id, team_meta_id)` ; `toggleMatched`
      `teamMetaId` ; `mettreAJourTeamMetaMembre` ; façade
      `pocketbase_data_service` synchronisée
- [x] M18.4 Import : `importTeamsForTournoi` crée/récupère chaque équipe une
      fois puis `importTeamMeta` une fois par équipe ;
      `TournamentTextImportService.importTeamMeta` upsert idempotent par
      `(team_id, nom_jo)` (plus de doublons d'équipes ni de métas)
- [x] M18.5 UI dashboard : `TeamDashboardController` (`streamTeamMeta` de
      l'équipe adverse, `createTeamMeta`/`deleteTeamMeta`, `toggleMatched`
      `TeamMeta`) ; matrice/lignes/en-têtes `TeamMeta` + clés `teamMetaId` ;
      dialogs (adversaire, estim + `ownTeamId`, détails estim) et panel
      appariements `TeamMeta` ; `TeamManagementController` `List<TeamMeta>`
      via `getTeamMeta`
- [x] M18.6 Seed/Purge + tests : `pocketbase_purge` → `collectionNameTeamMeta` ;
      `pocketbase_seed_demo` : `team_meta` ancrée sur l'équipe adverse
      (`team_id` + `nom_jo`), `estims`/`matched` `team_meta_id` ; tests
      `metaAdvId` → `teamMetaId`, `memo_8` réécrit (`TeamMeta` ancré sur
      `team_id` seul)
- [x] M18.7 Validation : `flutter analyze` 0 problème, `flutter test` 35/35,
      `flutter build web` OK
- [x] M18.8 Docs : point 1 RESOLU dans `MEMO.md`, `DOC.md` à jour, mémoire
      RAG → 2026-09-03 : `MEMO.md` point 1 « RESOLU » + puce Résolution,
      `TASKS.md`/`DOC.md` à jour, mémoire RAG (M18)

### M19 — Points 1 et 2 MEMO : invitation capitaine + rôle joueur/coach
- [x] M19.1 Schéma PocketBase : `team_membres.role` select `captain|player` →
      `captain|player|coach` (import additif à re-faire dans l'UI admin PB)
- [x] M19.2 Services/façade : `pocketbase_team_membres_service` constante
      `roleCoach` + helper `estRouleJoueur(role)` ; façade
      `pocketbase_data_service` expose `roleCapitaine`/`roleJoueur`/`roleCoach`,
      `estRouleJoueur`, `mettreAJourRoleMembre(teamId, joueurId, role)`
      (délégation `set` du champ `role`)
- [x] M19.3 Capitaine via `capitaine_id` : `TeamManagementController`
      `canRemoveMember`/`canNominateCaptain`/`captainCandidates` s'appuient sur
      `selectedTeam.capitaineId` ; `pocketbase_team_access_service`
      `nommerNouveauCapitaine` préserve le statut coach du capitaine sortant
      (→ `player` s'il jouait, `coach` s'il coachait)
- [x] M19.4 Outil de rôle (M2b) : `TeamManagementTeamMembersPanel` sélecteur
      Joueur/Coach par membre accepté (visible si capitaine) ; badge capitaine
      (`workspace_premium`) + coach (`sports_score`) dérivés de `capitaineId`
      et du rôle ; sous-titre `Capitaine`/`Coach`/`Joueur` ;
      `TeamManagementController.changeMemberRole` + action
      `TeamManagementTeamActions.changeMemberRole` + câblage
      `TeamManagementScreen`
- [x] M19.5 Matrice (M2c) : `TeamDashboardController` filtre `teamMembers`
      aux membres acceptés `estRouleJoueur` (coach exclu de la matrice)
- [x] M19.6 Invitation capitaine (M1) : `TeamsScreenController`
      `isCaptainOfActiveTeam` (via `activeTeam.capitaineId`),
      `searchPlayers` (exclut les membres de l'équipe active), `sendInvite` ;
      bouton `person_add_alt_1` dans l'AppBar de `TeamsScreen` (si capitaine)
      ouvrant `showTeamsScreenInvitePlayerDialog`
      (`teams_screen_invite_player_dialog.dart`, recherche + invitation)
- [x] M19.7 Validation : `flutter analyze` 0 problème, `flutter test` 35/35,
      `flutter build web` OK
- [x] M19.8 Docs : points 1 et 2 RESOLU dans `MEMO.md`, `TASKS.md`/`DOC.md`
      à jour, mémoire RAG

    ## Journal erreurs/découvertes
[Date | Problème | Cause racine | Règle préventive]
- 2026-08-21 | Code jamais compilé | pubspec sans supabase_flutter |
  toujours vérifier pubspec avant de supposer qu'un build passe
- 2026-08-22 | 5 erreurs SDK pocketbase 0.25 dès l'écriture du service |
  API diffère des tutos : AsyncAuthStore prend `initial:` (pas `load:`),
  pas de realtime.connect() (subscribe auto-connecte), onChange émet
  AuthStoreEvent, get() à défaut positionnel, subscribe retourne UnsubscribeFunc |
  lire le source du package dans ~/.pub-cache avant d'écrire contre un SDK
- 2026-08-22 | Écrans legacy en erreur (Icons inexistants, Colors.black85,
  extensions Colors bidouillées) | code écrit sans jamais compiler |
  faire passer flutter analyze dès la première écriture, pas en fin de mission
- 2026-08-22 | Diagnostic ERRONÉ "auth mot de passe désactivée sur users" |
  re-vérification : GET /api/collections/users/auth-methods renvoie
  emailPassword:true — l'auth par mot de passe est ACTIVE |
  relire la réponse API brute avant de conclure ; ne pas confondre
  format de réponse et état d'activation
- 2026-08-22 | Session persistée non détectée au démarrage |
  authStore.onChange n'émet rien lors de la restauration initiale |
  tout Stream d'état doit émettre sa valeur courante immédiatement (yield initial)
- 2026-08-22 | Demande utilisateur : ne pas toucher à la collection users native |
  PB supporte plusieurs collections `auth` ; snapshot réécrit avec collection
  dédiée `joueurs` (id mwjoueurs000001) + relations repointées ; config isolée
  par collection (passwordAuth propre) rend le users natif sans effet |
  privilégier les collections auth dédiées par application sur instance partagée
- 2026-08-22 | DÉCOUVERTE MAJEURE : serveur PB ancienne génération (≤0.22) —
  diagnostic initial "UI Svelte5 / PB ≥0.29" FAUX (réfuté par auth-methods
  au format plat usernamePassword/emailPassword) | snapshot entier réécrit au
  format ancien : clé `schema` (pas `fields`), options auth dans bloc
  `options` (allowEmailAuth…), flags `unique:true` de champs convertis en
  index uniques explicites, `autogeneratePattern` retiré ; users inclus
  VERBATIM dans le snapshot (conserve demandée par l'utilisateur) ; SDK Dart
  0.25 officiellement pour serveurs ≥0.23 mais endpoints utilisés identiques |
  déterminer la version/génération du backend AVANT d'écrire tout artefact de
  déploiement ; un export utilisateur réel est la source de vérité du format
- 2026-08-22 | L'UTILISATEUR a migré le serveur vers PB 0.39.11 entre-temps —
  la conversion "ancien format" devient obsolète à son tour | vérification
  live : auth-methods hybride (password.identityFields + clés legacy) =
  génération moderne confirmée ; snapshot réécrit au format moderne
  (`fields` aplatis, blocs mfa/otp/oauth2/passwordAuth/token en racine,
  users EXCLU — copie verbatim post-migration impossible, secrets
  régénérés) ; import additif = users natif intact par défaut |
  NE JAMAIS figer un artefact de déploiement sur une version de backend
  non confirmée ; re-vérifier l'état du serveur après toute intervention
  utilisateur sur l'infra avant d'écrire
- 2026-08-22 | Jeu de données de démonstration demandé par l'utilisateur |
  tool/pocketbase_seed_demo_records.dart (idempotent) : 5 comptes démo +
  adhésions, 4 rencontres [DEMO] × 3 adversaires T9A, 60 estimations avec
  trous volontaires, 1 appariement exemple ; le superuser contourne les
  règles API PB (écritures inter-utilisateurs possibles pour le seed) |
  pour peupler des données réalistes multi-joueurs, passer par le token
   _superusers plutôt que dupliquer la logique de règles côté client
- 2026-08-26 | Estimation du capitaine refusée (400 sur create estims) |
  règles `estims` limitées au propriétaire de la ligne ; le capitaine n'était
  pas couvert | règle capitaine par sous-requête `team_membres`/`teams`
  dans le schéma ; tout changement de règle PB exige un import manuel dans
  l'admin (pas de superuser côté agent)
- 2026-08-24 | Ancienne échelle à 6 niveaux incohérente avec la nouvelle
  échelle fixe à 7 niveaux | le référentiel `choix` doit être la source
  unique de l'échelle | seed `tool/pocketbase_seed_records.dart` réécrit
  avec 7 records fixes ; `AppreciationScale.scaleChoices` filtre les codes
  inconnus dans l'UI ; les anciens records restent orphelins tant qu'un
  superuser n'exécute pas le seed
- 2026-08-26 | 5 erreurs d'analyse au 1er passe du CRUD admin |
  SDK pocketbase 0.25 : `create`/`update` prennent le corps en argument
  Nommé `body:` (pas positionnel) ; `showDialog<T>` renvoie `T?` |
  recopier les signatures déjà prouvées dans les services existants
  (pocketbase_teams_service, pocketbase_team_invitations_service)
  plutôt que de deviner l'API du SDK
- 2026-08-26 | Backend admin M10.9 : limitation sécurité acceptée et
   documentée | PB n'a pas de règles d'écriture par champ : un compte
   authentifié peut s'autopasser `admin: true` via l'API brute
   (updateRule `id = @request.auth.id || @request.auth.admin = true`
   le permet) | documenté dans README (section Administration) ;
   acceptable pour une application de hobby non publique
- 2026-08-26 | Échec d'import `pocketbase_schema.json` : « Failed to
   import collections » | Les règles `estims` utilisaient des sous-requêtes
   SQL (`IN (SELECT ...)`) invalides dans le langage de filtres PocketBase ;
   le bloc `values` du champ bool `admin` a aussi été retiré | règles
    remplacées par `@collection.team_membres:member` avec `?=` ; reimport à
    tester
- 2026-08-26 | Erreurs d'analyse M11 (helper SnackBar + dialog suppression) |
   `ScaffoldMessenger.of` retourne `ScaffoldMessengerState` (pas
   `ScaffoldMessenger`) et `showDialog<bool>` retourne `Future<bool?>` |
   typer le messenger en `ScaffoldMessengerState` et normaliser la valeur
   du dialog avec `.then((confirmation) => confirmation ?? false)`
- 2026-08-29 | Édition des dialogs admin : "A TextEditingController was used
   after being disposed" (framework.dart:6281) + Duplicate GlobalKey |
   contrôleurs/GlobalKey créés dans la fonction `show...EditDialog` et
   disposés au retour de `showDialog` pendant que l'animation de fermeture
   rebuildait encore le widget | l'état d'un dialog (contrôleurs de texte,
   clés de formulaire) doit appartenir au State d'un StatefulWidget et être
   libéré dans `dispose()` ; l'API publique du wrapper `show...` reste
   inchangée (objet résultat renvoyé via `pop`)
- 2026-08-26 | Suppression de compte : données orphelines possibles sur
    `teams.capitaine_id` et `tournois.created_by` | ces relations n'ont pas
    `cascadeDelete: true` ; `deleteCurrentAccount` liste/supprime d'abord
    les équipes capitaines puis les tournois créés avant la suppression
    du joueur ; les autres relations (`team_membres`, `rencontres`,
    `meta_adv`, `estims`, `matched`) sont nettoyées par cascade
- 2026-08-29 | Test de garde point 7 : le SnackBar ne disparaît jamais
    (FakeAsync, 6 s de pumps) — l'hypothèse initiale « timing de pump »
    était fausse | un `SnackBar` avec `action` (bouton « Copier ») reçoit
    `persist = true` par défaut dans Flutter 3.47 (`snack_bar.dart:303` :
    `persist = persist ?? action != null`) ; le timer d'auto-dismiss fire
    mais `ScaffoldMessengerState` respecte `persist` et ne masque pas le
    SnackBar (bug app réel, pas seulement de test) | un SnackBar qui doit
    s'auto-fermer ne doit pas avoir d'`action` (ou passer `persist: false`
    explicitement) ; pour diagnostiquer un SnackBar persistant en test,
    vérifier d'abord `persist`/`action` avant d'incriminer le timing FakeAsync
