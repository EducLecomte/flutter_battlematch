# DIRECTIVES AGENT (AGENTS.md)

## 1. ENVIRONNEMENT & SÉCURITÉ
- **OS :** Linux (Debian 13.6).
- **Sécurité :** Interdiction stricte d'exécuter `sudo` sans confirmation explicite.

## 2. CONVENTIONS DE CODE & FACTORISATION (STRICT)
- **Architecture modulaire & atomique (Économie de contexte) :**
  - **1 fichier = 1 responsabilité.** Taille maximale recommandée : 150 lignes par fichier.
  - Découper immédiatement tout fichier devenant trop volumineux en sous-composants ou services isolés.
  - Séparer strictement la logique métier, les appels API, les modèles et l'interface utilisateur.
- **Nommage explicite (Zéro abréviation) :**
  - Noms de variables, fonctions et fichiers entièrement explicites sans abréger.
  - Exception unique : `i` pour l'index d'une boucle hyper-locale.
  - Mots interdits : `data`, `info`, `obj`, `res`, `req`, `usr`, `util`, `getUser()`.
- **Principes :** Typage strict | Zero valeur magique (extraire les constantes) | Ne jamais masquer une erreur (`catch` vide interdit).

## 3. GESTION DU CONTEXTE (MAX 65 500 TOKENS) & SUIVI D'AVANCEMENT
- **Fichier `tasks.md` :** Créer/mettre à jour à la racine dès qu'une tâche comporte plusieurs étapes (`- [ ]` / `- [x]`).
- **Gestion du budget de contexte :**
  - Ne jamais dépasser la limite stricte de **65 500 tokens**.
  - Privilégier la lecture ciblée par plages de lignes (`start_line`-`end_line`) plutôt que de charger des fichiers complets.
- **Indexation RAG :** Enregistrer les décisions et l'état du projet dans la mémoire MCP RAG.

## 4. DOCUMENTATION PROJET (`DOC.md` ET `README.md`)
- **`DOC.md` (Interne) :** Maintenir la cartographie technique du projet (structure des dossiers, rôle de chaque fichier, flux de données). À mettre à jour à chaque modification de structure ou ajout de fichier.
- **`README.md` (GitHub) :** Maintenir la présentation publique à jour (installation, commandes de build, fonctionnalités). À mettre à jour lors de chaque nouvelle fonctionnalité (`feat`).

## 5. FORMAT DES RETOURS & HORODATAGE
- Tous les retours de statut, comptes-rendus d'exécution et logs doivent obligatoirement inclure la date et l'heure courante.
- **Format d'en-tête obligatoire :** `[YYYY-MM-DD HH:mm]` (ex: `[2026-08-23 09:45] Documentation DOC.md mise à jour`).

## 6. PROTOCOLE D'EXÉCUTION & REPRISE SUR ERREUR
1. **Inspection :** Découvrir l'architecture via le RAG/LSP avant d'éditer.
2. **Édition chirurgicale :** Modifier uniquement le code strictement nécessaire.
3. **Validation :** Exécuter le linter/tests immédiatement après l'édition.
4. **Log d'erreur :** Mettre à jour la section `7. LOG D'ERREURS` en cas de résolution de problème complexe.

## 7. LOG D'ERREURS & APPRENTISSAGE
*[Format : [YYYY-MM-DD HH:mm] | Contexte | Problème | Cause racine | Règle préventive]*

## 8. CONVENTIONS GIT
- **Commits atomiques :** `<type>(<scope>): <description>` (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`).

## 9. COMPORTEMENT DE L'AGENT
- Réponses concises, directes, horodatées et sans bavardage.
- Auto-correction basée sur les retours du terminal.
- Alerte immédiate en cas de mauvaise pratique détectée dans le code.
