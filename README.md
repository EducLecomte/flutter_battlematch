# MetaWar — Flutter Web + PocketBase

Portage de l'application PHP MetaWar (gestion de tournois The Ninth Age :
estimations d'équipe, matrice d'appariement) en application Flutter Web
adossée à une instance PocketBase.

- **Backend** : https://metabase.pedagogeek.fr (admin : `/_/`)
- **Legacy PHP** : dossier `php/` (référence historique uniquement)

## Architecture

```
lib/
  main.dart                              # AuthGate + shell de navigation
  config/app_config.dart                 # URL serveur + noms de collections
  models/models.dart                     # Modèles Dart ↔ RecordModel PocketBase
  services/pocketbase_data_service.dart  # Auth + CRUD + temps réel (singleton)
  services/pocketbase_referentiels_service.dart # CRUD armées/choix
  services/pocketbase_admin_service.dart # Administration des joueurs
  services/new_recruit_import_service.dart # Import API directe + parsing local
  screens/                               # Tournois, Équipes, Dashboard, Profil, Administration
  utils/hex_color_parser.dart            # Helpers couleurs hex
  utils/error_snack_bar_presenter.dart   # SnackBar d'erreur (log debug + copie)
tool/
  pocketbase_seed_records.dart           # Seed des référentiels armees/choix
  pocketbase_seed_demo_records.dart      # Jeu de données de démonstration
  pocketbase_tool_support.dart           # Support commun des scripts PocketBase
  pocketbase_purge_meta_war_records.dart # Purge des données MetaWar
  pocketbase_seed_test_accounts.dart     # Comptes de test test1 à test4
pocketbase_schema.json                   # Snapshot de schéma à importer
```

## Déploiement du backend (une seule fois)

### 1. Importer le schéma des collections

1. Ouvrir l'admin PocketBase : https://metabase.pedagogeek.fr/_/
2. **Settings → Collections → Import collection(s)** (bouton en haut à droite)
3. Coller le contenu intégral de `pocketbase_schema.json` puis confirmer.

Le snapshot est au **format génération moderne** PocketBase (≥ 0.23 ;
instance migrée en **0.39.11** le 2026-08-22). Il crée/met à jour :
`joueurs` (collection `auth` **dédiée** aux profils MetaWar, champ
`nom`, auth email+mot de passe), `tournois`, `teams`,
`team_membres`, `armees`, `choix`, `team_meta`, `estims`,
`matched` — relations, index uniques anti-doublon (appariements,
estimations par joueur, armées/choix) et règles d'accès.

> ⚠️ **M16 (2026-08-30) :** la collection `rencontres` a été supprimée du
> snapshot. `estims`/`matched` sont ancrés sur le duo
> `team_id` + `adversaire_team_id`. Lors du réimport, supprimer
> manuellement la collection `rencontres` existante dans l'admin
> (l'import est additif et ne la retire pas).

> ⚠️ **M18 (2026-09-03) :** la collection `meta_adv` a été remplacée par
> `team_meta` (1 ligne par joueur par équipe, ancrée sur `team_id` seul,
> index unique `(team_id, nom_jo)`). `estims`/`matched` utilisent désormais
> `team_meta_id`. Lors du réimport, supprimer manuellement la collection
> `meta_adv` existante dans l'admin (l'import est additif).

> ✅ La collection native `users` n'apparaît **pas** dans le snapshot :
> l'import est **additif** et la laisse strictement intacte (l'application
> ne la référence pas ; elle utilise `joueurs`).
>
> ⚠️ Si l'instance héberge d'autres projets, **ne pas activer l'option**
> « delete missing collections » lors de l'import : elle effacerait leurs
> collections absentes du fichier (comportement par défaut : désactivé).

| Règle | Principe |
|---|---|
| Lecture | tout utilisateur authentifié (référentiels publics) |
| Tournois | création/suppression réservées aux admins ; ouverture bloquée pour les non-admins tant que l'import des équipes n'est pas effectué |
| Équipes | création réservée aux admins ; réclamation d'une équipe sans capitaine ; join par mot de passe ; suppression admin ou capitaine |
| Invitations | capitaine de l'équipe ; acceptation/refus par l'invité |
| Adversaires & appariements | capitaine de l'équipe ; admin (bypass — saisie depuis la carte tournoi, M16.11) |
| Estimations | chaque joueur et le capitaine de son équipe |
| Administration | compte `admin` : gestion des joueurs, armées et appréciations |

> ⚠️ **Limitation de sécurité (instance hobby) :** PocketBase n'expose pas de
> règles d'écriture par champ. Un compte authentifié peut modifier son propre
> champ `admin` via l'API brute, puis obtenir les droits d'administration.
> Cette auto-promotion est acceptée pour ce périmètre ; la promotion normale
> se fait depuis l'écran Administration ou via l'admin PocketBase.

> En cas d'échec d'import lié à une différence de version du serveur,
> exporter un snapshot vide depuis l'UI admin et transposer les champs/règles.

### Compatibilité SDK

Le serveur tourne sur PocketBase **0.39.11** (génération moderne, migré
depuis ≤ 0.22 le 2026-08-22). Le SDK Dart `pocketbase 0.25.0` cible les
serveurs ≥ 0.23 — alignement correct pour les points utilisés par
l'application (CRUD `/api/collections/*/records`, `auth-with-password`,
temps réel SSE, URLs de fichiers). La validation complète se fait à
l'étape M7.3.

### 2. Alimenter les référentiels (16 armées T9A + 7 appréciations)

Avec les identifiants super-utilisateur (`_superusers`) :

```bash
dart run tool/pocketbase_seed_records.dart --email admin@exemple.fr --password 'motDePasse'
# ou via variables d'environnement PB_SUPERUSER_EMAIL / PB_SUPERUSER_PASSWORD
```

Script idempotent (mise à jour si l'enregistrement existe déjà).

### 3. Jeu de données de démonstration (optionnel)

```bash
PB_SUPERUSER_EMAIL=... PB_SUPERUSER_PASSWORD=... \
  dart run tool/pocketbase_seed_demo_records.dart
```

Crée un univers de test **idempotent** rattaché à l'équipe `Les randomiques`
(et à son tournoi `IR2026`, ou une équipe/tournoi `[DEMO]` à défaut) :

- 5 comptes joueurs : `martin|sophie|lucas|emma|hugo.demo@pedagogeek.fr`,
  mot de passe commun `DemoMetaWar2026`, ajoutés comme membres acceptés
- 4 équipes adverses `[DEMO] vs …` créées dans le tournoi, chacune avec
  3 adversaires (listes T9A réalistes)
- 60 estimations pré-remplies avec **trous volontaires** pour tester la saisie
- 1 appariement exemple sur la première équipe adverse

Pour repartir de zéro : supprimer les enregistrements dont le nom commence
par `[DEMO]` et les comptes `*.demo@pedagogeek.fr` depuis l'admin.

### 4. Purger les données MetaWar (maintenance)

Sans `--yes`, le script affiche uniquement les collections visées :

```bash
dart run tool/pocketbase_purge_meta_war_records.dart
```

Avec `--yes`, il supprime les données MetaWar dans l'ordre anti-orphelins :
`matched`, `estims`, `team_meta`, `team_membres`, `teams`,
`tournois`, `joueurs`. Les collections natives PocketBase (`users`,
`_superusers`, fichiers) ne sont pas touchées.

```bash
dart run tool/pocketbase_purge_meta_war_records.dart --yes \
  --email admin@exemple.fr --password 'motDePasse'
```

Ajouter `--purge-referentiels` pour supprimer aussi `armees` et `choix`.

### 5. Comptes de test

```bash
dart run tool/pocketbase_seed_test_accounts.dart \
  --email admin@exemple.fr --password 'motDePasse'
```

Le script est idempotent : il crée les comptes s'ils sont absents, sinon il
met à jour `nom`, `short`, `admin` et le mot de passe. Les mots de passe sont
courts et conformes à la politique d'inscription.

| Identifiant | Mot de passe |
|---|---|
| `test1@pedagogeek.fr` | `Test1!23` |
| `test2@pedagogeek.fr` | `Test2!23` |
| `test3@pedagogeek.fr` | `Test3!23` |
| `test4@pedagogeek.fr` | `Test4!23` |

## Lancer l'application

```bash
flutter pub get
flutter run -d chrome     # développement
flutter build web         # build de production → build/web/
```

## Tests

```bash
flutter test              # tests unitaires des modèles
flutter analyze           # analyse statique
```

## Fonctionnalités

- Inscription/connexion joueurs (collection dédiée `joueurs`, session web
  persistante, mot de passe : 8 caractères minimum, une majuscule,
  un caractère spécial)
- Tutoriel de bienvenue : affiché dans un dialog bloquant à la première
  connexion sur l'appareil (drapeau « vu » stocké en local, par navigateur),
  tour d'horizon des écrans principaux (MEMO 10)
- Tournois gérés par les admins : création, import des équipes, suppression ;
  ouverture bloquée pour les non-admins si l'import des équipes n'est pas
  effectué
- Équipes : réclamation d'une équipe sans capitaine, join par mot de passe,
  gestion du mot de passe, nomination d'un capitaine, invitations, retrait de
  membres
- Équipes adverses du tournoi par équipe (chaque équipe peut estimer
  n'importe quelle autre équipe du tournoi)
- Matrice d'estimation temps réel joueur × adversaire (7 appréciations fixes,
   symbole `Dicy` en gris, scores 20-0, confiance, commentaires, valeurs
   visibles en cellule appariée/bloquée)
- Mode Capitaine : appariements verrouillés (un duel unique par joueur
   ET par adversaire, garanti par index uniques serveur), estimation possible
   pour tous les membres, et association membre ↔ liste depuis la gestion
   d'équipe
- Profil : affichage des équipes et tournois de l'utilisateur
- Paramètres (Profil) : bascule mode clair/sombre (persistée en local, thème
  sombre dérivé des couleurs de l'application), dialog « À propos » et
  re-visionnage du tutoriel de bienvenue (MEMO 11)
- Équipes du tournoi visibles par tous (sélection de l'équipe active
   depuis l'écran Équipes)
- Import tournoi : texte ou JSON depuis l'écran Équipes, avec création des
   équipes adverses (si absentes du tournoi) et des adversaires,
   dédoublonnage des adversaires déjà importés et comptage des armées inconnues
 - Administration (compte `admin`, accessible depuis le Profil) :
    promotion/rétrogradation et suppression des joueurs, gestion des armées et
    des appréciations
  - Suppression de son compte depuis le Profil (confirmation, purge des équipes
     capitaines et des tournois créés, déconnexion)
  - Messages d'erreur copiables (log debug + bouton « Copier »)
  - Maintenance PocketBase : purge sécurisée des données MetaWar et comptes de
    test idempotents (`test1` à `test4`)
