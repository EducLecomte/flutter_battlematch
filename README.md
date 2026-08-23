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
  services/new_recruit_import_service.dart # Import API directe + parsing local
  screens/                               # Tournois, Équipes, Dashboard, Profil
tool/
  pocketbase_seed_records.dart           # Seed des référentiels armees/choix
pocketbase_schema.json                   # Snapshot de schéma à importer
```

## Déploiement du backend (une seule fois)

### 1. Importer le schéma des collections

1. Ouvrir l'admin PocketBase : https://metabase.pedagogeek.fr/_/
2. **Settings → Collections → Import collection(s)** (bouton en haut à droite)
3. Coller le contenu intégral de `pocketbase_schema.json` puis confirmer.

Le snapshot est au **format génération moderne** PocketBase (≥ 0.23 ;
instance migrée en **0.39.11** le 2026-08-22). Il crée/met à jour :
`joueurs` (collection `auth` **dédiée** aux profils MetaWar, champs
`nom`/`short`, auth email+mot de passe), `tournois`, `teams`,
`team_membres`, `rencontres`, `armees`, `choix`, `meta_adv`, `estims`,
`matched` — relations, index uniques anti-doublon (appariements,
estimations par joueur, armées/choix) et règles d'accès.

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
| Écriture équipes/tournois | créateur / capitaine uniquement |
| Invitations | capitaine de l'équipe ; acceptation par l'invité |
| Adversaires & appariements | capitaine de l'équipe de la rencontre |
| Estimations | chaque joueur n'écrit que sa propre ligne |

> En cas d'échec d'import lié à une différence de version du serveur,
> exporter un snapshot vide depuis l'UI admin et transposer les champs/règles.

### Compatibilité SDK

Le serveur tourne sur PocketBase **0.39.11** (génération moderne, migré
depuis ≤ 0.22 le 2026-08-22). Le SDK Dart `pocketbase 0.25.0` cible les
serveurs ≥ 0.23 — alignement correct pour les points utilisés par
l'application (CRUD `/api/collections/*/records`, `auth-with-password`,
temps réel SSE, URLs de fichiers). La validation complète se fait à
l'étape M7.3.

### 2. Alimenter les référentiels (16 armées T9A + 6 choix)

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
- 4 rencontres `[DEMO] vs …` avec 12 adversaires (listes T9A réalistes)
- 60 estimations pré-remplies avec **trous volontaires** pour tester la saisie
- 1 appariement exemple sur la première rencontre

Pour repartir de zéro : supprimer les enregistrements dont le nom commence
par `[DEMO]` et les comptes `*.demo@pedagogeek.fr` depuis l'admin.

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

- Inscription/connexion joueurs (collection dédiée `joueurs`, session web persistante)
- Tournois → Équipes (invitations pending/accepted, recherche de joueurs)
- Rencontres (rondes) par équipe et tournoi
- Matrice d'estimation temps réel joueur × adversaire (6 choix colorés,
  scores 20-0, confiance, commentaires)
- Mode Capitaine : appariements verrouillés (un duel unique par joueur
  ET par adversaire, garanti par index uniques serveur)
- Import New Recruit : appel API direct depuis le navigateur ou copier/coller
  JSON/texte (fallback)
