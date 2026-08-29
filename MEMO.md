# Mémo des problemes identifiés
## 1 — RESOLU
- probleme de connexion : Erreur : ClientException: {url: https://metabase.pedagogeek.fr/api/collections/joueurs/auth-with-password, isAbort: false, statusCode: 400, response: {data: {}, message: Failed to authenticate., status: 400}, originalError: null}
- Résolution : le serveur et le compte (testé avec test1 et contact@pedagogeek.fr) étaient sains ; le 400 = identifiants rejetés. Les erreurs PocketBase sont maintenant converties en messages lisibles (`ErreurAuthentification` dans `pocketbase_auth_service.dart`) : 400 → "Identifiants incorrects…", 429 → "Trop de tentatives…". La gestion de la vérification par email a été retirée (SMTP désactivé côté serveur, inscription = connexion immédiate, messages de confirmation supprimés).

## 2 — RESOLU
- collection joueur, champs "short" inutile dans pocketbase
- Résolution : champ retiré du modèle `Joueur`, du schema `pocketbase_schema.json`, des seeds de test, du service d'auth et de la collection en ligne (PATCH API superuser).

## 3 — RESOLU
- faire le menage, analyser les fichiers et fonctions inutiles pour alleger le contexte et le projet
- Résolution : suppression de la feature d'import New Recruit sans point d'entrée (8 fichiers `import_newrecruit_*` + `new_recruit_api_client.dart` + méthode API du service), du modèle mort `team_membre.dart`, et de la dépendance `http`. Tests du parser alignés sur le nouveau `exemple_tournoi.txt` (4 équipes × 2 joueurs). `flutter analyze` : 0 problème ; `flutter test` : 24/24 OK.

## 4 — RESOLU
- le parseur semble en erreur (@exemple_tournoi.txt contient 4 équipes de 2 joueurs)
- sur les grosses équipes, en grand nombre ça ne fonctionne pas bien ( @exemple_tournoi_2.txt, il y a 50 équipes, de 6 joueurs,  le parseur en identifie 31 )
- il semblerait que les teams ne soit pas associé a leur méta (meta_adv) lors de l'import
- Résolution :
  1. **Refonte du parseur par blocs (`tournament_text_import_parser.dart`)** : l'ancien parseur ligne à ligne confondait les noms d'équipes contenant des tirets (ex. `Belgique 1 - Brussels Fanatics`, `BFC 3 - Lucky Dukes`, `PDL 1 - Les P'tits Beurrés`) avec des lignes de joueurs, fusionnant ainsi plusieurs équipes. Le nouveau parseur identifie distinctement les blocs d'en-tête d'équipe et les blocs de listes d'armées, tout en extrayant correctement les variantes `Joueur (Pseudo) - Armée`, `Équipe - Joueur / Armée` et listes multi-lignes.
  2. **Validation des deux jeux de données** :
     - `exemple_tournoi.txt` : 4/4 équipes, 8/8 joueurs identifiés.
     - `exemple_tournoi_2.txt` : 50/50 équipes, 300/300 joueurs et armées résolus (100%).
  3. **Association méta/adversaires** : intégration dans `tournament_text_import_service.dart` pour peupler automatiquement les `meta_adv` dans les rencontres.
  4. `flutter analyze` : 0 problème ; `flutter test` : 25/25 tests passés.


## 5 — RESOLU
- erreur d'affichage des equipes (néccessite un singlechildscrollview ?)
- voici l'erreur
Erreur de chargement des équipes du tournoi : ClientException: {url: https://metabase.pedagogeek.fr/api/collections/teams/records?page=1&perPage=1000&filter=tournoi_id+%3D+%22excscdrjd2ky0ip%22&sort=nom&skipTotal=true, isAbort: false, statusCode: 400, response: {data: {}, message: Something went wrong while processing your request., status: 400}, originalError: null}
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
A RenderFlex overflowed by 1806 pixels on the bottom.
  Column:file:///home/gus/Dev/flutter_metawar/lib/screens/widgets/teams_screen_team_access_panel.dart:72:16
- Résolution :
  1. **Correction du débordement RenderFlex (1806 px) & UX d'accès** : dans `teams_screen_team_access_panel.dart`, suppression du `shrinkWrap: true` dans une `Column` non bornée au profit d'un `Expanded(child: ListView.separated(...))` et ajout d'un champ de recherche en direct pour filtrer facilement les équipes sur les gros tournois (35–50 équipes).
  2. **Affichage automatique des équipes adverses du tournoi** : dans `teams_screen.dart`, `teams_screen_controller.dart` et `teams_screen_encounter_list.dart`, l'équipe active affiche directement l'intégralité des autres équipes du tournoi comme rondes/rencontres potentielles avec recherche intégrée. Un simple clic sur une équipe adverse génère/récupère la rencontre automatiquement et ouvre le tableau de bord d'estimations.
  3. **Bouton d'import New Recruit accessible** : ajout d'un bouton d'action dans la barre d'application de `teams_screen.dart` pour importer/synchroniser les listes textuelles des adversaires à tout moment, avec mise à jour intelligente des rencontres existantes dans `tournament_text_import_service.dart`.
  4. **Correction de l'affichage des adversaires dans les appariements** : correction dans `team_management_matched_panel.dart` où le texte complet de la liste (`listeAdv`) était utilisé par erreur à la place du nom du joueur adverse (`nomJoAdv`).
  5. `flutter analyze` : 0 problème ; `flutter test` : 24/24 tests passés.


## 6 — RESOLU
- revoir l'administration, il manque des cruds (pour modifier tournoi par exemple, ou alors on le met dans le @tournois_screen.dart )
- erreur lors de l'edition des appréciations : Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/widgets/framework.dart:6281:12
- erreur lors de l'edition des armées : Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/widgets/framework.dart:6281:12
- erreur visuel : 
Another exception was thrown: Duplicate GlobalKeys detected in widget tree.
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/rendering/object.dart:2138:12
object.dart:2138
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/material/material.dart:768:12
material.dart:768
Another exception was thrown: A RenderFlex overflowed by 99134 pixels on the right.
2
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/material/material.dart:768:12
material.dart:768
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/rendering/object.dart:2138:12
object.dart:2138
14
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/material/material.dart:768:12
material.dart:768
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/rendering/object.dart:2138:12
object.dart:2138
16
Another exception was thrown: Assertion failed: file:///home/gus/development/flutter/packages/flutter/lib/src/material/material.dart:768:12
- Résolution :
  1. **Cause racine des erreurs d'édition armées/appréciations (framework.dart:6281)** : les `TextEditingController` étaient créés dans la fonction `show...EditDialog` et disposés dès le retour de `showDialog`, alors que l'animation de fermeture du dialogue rebuildait encore le widget → « A TextEditingController was used after being disposed » et cascade d'assertions (framework.dart:6281, object.dart:2138, material.dart:768, Duplicate GlobalKeys). Correction : conversion en StatefulWidgets `ArmeeEditDialog` / `ChoixEditDialog` — le State possède les contrôleurs et les libère dans `dispose()` ; l'API publique des fonctions est inchangée.
  2. **Overflow RenderFlex 99134 px** : le SnackBar d'appariement de `team_management_matched_panel.dart` affichait le texte complet de la liste d'armée (`listeAdv`) ; remplacé par le pseudo de l'adversaire (`nomJoAdv`).
  3. **CRUD tournoi manquant** : ajout de `updateTournoi` (service PocketBase + façade + `TournoiController`), du dialogue `tournoi_edit_dialog.dart` (mêmes principes de cycle de vie) et du bouton « Modifier » admin sur `TournoiCard`, câblé dans `tournois_screen.dart`.
  4. **Découpage service** : extraction des méthodes rencontres dans `pocketbase_rencontres_service.dart` pour garder une responsabilité par fichier (tournois : 100 lignes, rencontres : 91 lignes).
  5. **Test de garde** : `test/admin_dialog_repro_test.dart` reproduisait l'assertion utilisateur avant correction (3 tests : cycles complets armée/choix + annulation), passe après correction. `flutter analyze` : 0 problème ; `flutter test` : 28/28 passés ; `flutter build web` : OK.

## 7 
-snackbar trop longue (des erreurs surtout), verifier ou apporter amélioration

## 8 
- collection rencontres inutiles. chaque équipes peut faire des estimations pour chaque autre équipes du tournoi

## 9 
- affichage du nom de l'équipe dans un widget Text suffit (pas besoin de dropdownButton)

## 10
- probleme de rafraichissement au moment du chargement des screens
- @team_management_screen.dart l87-89 commentaire pour raffraichir la page

## 11
- dans @team_management_screen.dart cliquer sur l'équipe devrait ammener a la page de l'équipe (et donc du tournoi)
- ajouter sous le nom de l'équipe le nom du tournoi