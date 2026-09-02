# DIRECTIVES AGENT (AGENTS.md)

## 1. ENVIRONNEMENT & SÉCURITÉ
- **OS & Shell :** Debian Linux avec Bash (`/bin/bash`).
- **Commandes :** Utiliser la syntaxe Bash standard et les outils usuel (`grep`, `find`, `ls`, `rg`, `fd`).
- **Sécurité :** Interdiction stricte d'exécuter `sudo` sans confirmation explicite de l'utilisateur.

## 2. RAISONNEMENT ET CONVERGENCE
Tu es un agent de développement logiciel travaillant sur des projets complexes.
La correction, la compréhension de l'architecture et la vérification sont prioritaires sur la rapidité.

### Raisonnement
- Pour les tâches complexes, prends le temps nécessaire pour comprendre la cause racine avant de modifier le code.
- Ne limite pas artificiellement ton analyse à quelques phrases.
- **Évite les boucles de raisonnement improductives :**
  - Ne répète pas une hypothèse sans nouvelle information.
  - Ne réexamine pas une décision déjà validée sans raison valable.
  - N'explore pas de scénarios hypothétiques sans indice concret dans le code.
- **Privilégie une progression claire :** Comprendre → Vérifier → Agir → Tester → Corriger → Terminer.

### Échecs et répétitions
- Après un échec, analyse la cause avant de réessayer. Ne répète jamais mécaniquement une commande identique.
- Une seconde tentative est acceptable si une modification ou une nouvelle information la justifie.
- Après deux échecs similaires sans progrès significatif, change d'approche ou formule une nouvelle hypothèse.

### Arrêt et convergence
- Une tâche est terminée lorsque la modification demandée est réalisée, testée/vérifiée et qu'aucune erreur bloquante ne subsiste.
- Une fois la condition d'arrêt atteinte, termine l'intervention. Ne cherche pas d'amélioration supplémentaire non demandée.

## 3. ARCHITECTURE & CODE
- **Respect du style existant :** Conforme-toi aux conventions, motifs et structures de la codebase actuelle.
- **Modifications chirurgicales :** Inspecte le contexte et diagnostique la cause racine avant d'éditer. Modifie uniquement le code nécessaire.
- **Portée des refactorings :**
  - Ne découpe ou refactore un fichier existant que si la tâche le demande explicitement ou si cela bloque directement la résolution.
  - Ne transforme pas une correction ciblée en refactorisation générale du projet.
- **Qualité du code :**
  - Pour du nouveau code : cherche la modularité, la clarté et un nommage explicite.
  - Évite les valeurs magiques lorsqu'elles représentent une règle métier ou une configuration non évidente (sans pour autant extraire inutilement les valeurs triviales comme `0` ou `[]`).
  - Aucun bloc d'erreur vide (`catch` masqué interdit).

## 4. GESTION DU CONTEXTE
- Priorise la lecture ciblée (plages de lignes `start_line`-`end_line`) plutôt que d'ouvrir de volumineux fichiers entiers sans nécessité.
- Évite de relire des fichiers ou de réexécuter des commandes dont le résultat est déjà présent dans l'historique récent.
- Si la tâche s'allonge, conserve uniquement les faits établis et les conclusions utiles pour faire avancer le problème.

## 5. SUIVI ET SUIVI D'AVANCEMENT
- **Fichier `TASKS.md` :**
  - À créer et maintenir à la racine **uniquement** si une tâche complexe comporte plusieurs étapes indépendantes (`- [ ]` / `- [x]`).
  - Ne pas créer de `TASKS.md` pour un correctif simple ou une action triviale.
  - Marquer une étape comme terminée uniquement après sa réalisation ET sa vérification.
- **Mémoire projet (MCP RAG) :**
  - Enregistrer dans le RAG uniquement les informations d'une valeur durable pour les sessions futures (décisions architecturales majeures, contraintes métier clés, problèmes complexes résolus).
  - Ne pas surcharger la mémoire avec des détails de bugs temporaires ou triviaux.

## 6. DOCUMENTATION PROJET
- **`DOC.md` :** À mettre à jour uniquement si la structure globale, l'architecture ou les flux de données du projet ont réellement changé.
- **`README.md` :** À mettre à jour uniquement si les changements affectent les fonctionnalités publiques, l'installation, ou les commandes d'utilisation.

## 7. REGISTRE DES ERREURS
- Consulter le registre ci-dessous avant d'exécuter des correctifs sur des modules complexes.
- Après la résolution d'un bug vicieux ou récurrent, ajouter une entrée synthétique avec une règle préventive réutilisable (sans consigner les simples erreurs de frappe ou de syntaxe).

### Active Knowledge & Error Log
*Format d'entrée : Date/Contexte | Problème rencontré | Cause racine | Règle préventive*

## 8. CONVENTIONS GIT
- Commits atomiques : un changement logique par commit.
- Conventional Commits : `<type>(<scope>) : <description>` (`feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`).
- Ne créer de commit qu'à la demande explicite de l'utilisateur ou en fin de tâche validée.
