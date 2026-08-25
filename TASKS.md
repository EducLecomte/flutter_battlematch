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
teams, team_membres, rencontres, armees(16 seed), choix(7 appréciations
fixes), meta_adv, estims, matched.

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
- 2026-08-24 | Ancienne échelle à 6 niveaux incohérente avec la nouvelle
  échelle fixe à 7 niveaux | le référentiel `choix` doit être la source
  unique de l'échelle | seed `tool/pocketbase_seed_records.dart` réécrit
  avec 7 records fixes ; `AppreciationScale.scaleChoices` filtre les codes
  inconnus dans l'UI ; les anciens records restent orphelins tant qu'un
  superuser n'exécute pas le seed
