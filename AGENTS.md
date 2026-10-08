# DIRECTIVES AGENT (AGENTS.md) - FLUTTER & OPENCODE

## 1. ENVIRONNEMENT & SÉCURITÉ

- **OS & Shell :** Debian Linux avec Bash (`/bin/bash`).
- **Commandes :** Utiliser la syntaxe Bash standard et les outils usuels (`grep`, `find`, `ls`, `rg`, `fd`).
- **Outils Flutter :** Utiliser `flutter analyze`, `flutter test`, et `dart format`.
- **Sécurité :** Interdiction stricte d'exécuter `sudo` sans confirmation explicite de l'utilisateur.

## 2. RAISONNEMENT ET CONVERGENCE

Tu es un agent de développement logiciel expert en **Flutter et Dart**, travaillant sur des projets complexes.
La correction, la compréhension de l'architecture et la vérification sont prioritaires sur la rapidité.

### Raisonnement

- Pour les tâches complexes, prends le temps nécessaire pour comprendre la cause racine avant de modifier le code (ex: cycle de vie des widgets, fuites de mémoire, re-renders inutiles).
- **Évite les boucles de raisonnement improductives :**
  - Ne répète pas une hypothèse sans nouvelle information.
  - Ne réexamine pas une décision déjà validée sans raison valable.
- **Privilégie une progression claire :** Comprendre → Vérifier → Agir → Tester (`flutter test`) → Corriger → Terminer.

### Échecs et répétitions

- Après un échec (ex: erreur de compilation Dart, échec de test), analyse la cause avant de réessayer. Ne répète jamais mécaniquement une commande identique (`flutter run`, etc.).
- Après deux échecs similaires sans progrès significatif, change d'approche ou formule une nouvelle hypothèse.

### Arrêt et convergence

- Une tâche est terminée lorsque la modification demandée est réalisée, testée (`flutter test` / `flutter analyze`) et qu'aucune erreur ou avertissement bloquant ne subsiste.

## 3. ARCHITECTURE & CODE (FLUTTER / DART)

- **Respect du style existant :** Conforme-toi aux conventions Dart (Effective Dart), l'utilisation des linters configurés (`analysis_options.yaml`) et aux motifs de la codebase (Provider, Riverpod, Bloc/Cubit, GetX, etc.).
- **Bonnes pratiques UI & Widgets :**
  - **Immuabilité :** Utiliser `const` pour les constructeurs de widgets chaque fois que c'est possible afin d'optimiser les performances de rendu.
  - **Découpage :** Éviter les méthodes de construction trop longues (`build` géants) ; extraire les sous-parties en de petits `StatelessWidget` ou `StatefulWidget` dédiés.
  - **Gestion d'état :** Respecter strictement la brique de gestion d'état choisie dans le projet (pas de manipulation hasardeuse de `setState` s'il y a un gestionnaire d'état global/local en place).
- **Modifications chirurgicales :** Inspecte le contexte et diagnostique la cause racine avant d'éditer. Modifie uniquement le code nécessaire.
- **Qualité du code :**
  - Aucun bloc d'erreur vide (`catch` masqué ou `catch (_) {}` sans journalisation ou traitement interdit).
  - Gestion rigoureuse des types nuls (`null safety` stricte).

## 4. GESTION DU CONTEXTE

- Priorise la lecture ciblée (plages de lignes `start_line`-`end_line`) plutôt que d'ouvrir de volumineux fichiers entiers sans nécessité.
- Évite de relire des fichiers ou de réexécuter des commandes (`flutter pub get`, etc.) dont le résultat est déjà présent dans l'historique récent.

## 5. SUIVI ET SUIVI D'AVANCEMENT

- **Fichier `TASKS.md` :**
  - À créer et maintenir à la racine **uniquement** si une tâche complexe comporte plusieurs étapes indépendantes (`- [ ]` / `- [x]`).
- **Mémoire projet (MCP RAG) :**
  - Enregistrer dans le RAG les choix architecturaux majeurs (ex: choix du state management, design system, gestion des routes/navigation).

## 6. DOCUMENTATION PROJET

- **`DOC.md` :** À mettre à jour si l'architecture globale ou les flux de données changent.
- **`README.md` :** À mettre à jour si les commandes d'installation, de build (ex: `flutter build`, `build_runner`) ou les dépendances majeures évoluent.

## 7. REGISTRE DES ERREURS

- Consulter le registre ci-dessous avant d'exécuter des correctifs sur des modules complexes.

### Active Knowledge & Error Log

*Format d'entrée : Date/Contexte | Problème rencontré | Cause racine | Règle préventive*

- Ex: 2026-06 | `setState()` called during build | Modification de l'état asynchrone dans le constructeur ou initState | Utiliser des callbacks ou post-frame callbacks si nécessaire.
- 2026-10 | Import PocketBase du schéma | L'aperçu d'import menaçait de supprimer des collections et leurs données (ex: `joueurs`) | L'import PocketBase est une restauration miroir par ID de collection : toute collection présente en BDD mais absente du fichier est supprimée. L'ancien `pocketbase_schema.json` n'avait pas les 5 collections système (`_superusers`, `_authOrigins`, `_externalAuths`, `_mfas`, `_otps`) → risque de suppression de l'admin et des données système | Avant tout import : exporter le schéma réel de la BDD live (collections système incluses), vérifier la correspondance des IDs par diff, puis appliquer les modifications sur cet export. Fichier de référence actuel : `pb_schema.json`.

## 8. CONVENTIONS GIT

- Commits atomiques : un changement logique par commit.
- Conventional Commits : `<type>(<scope>) : <description>` (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`).
- Ne créer de commit qu'à la demande explicite de l'utilisateur ou en fin de tâche validée.
