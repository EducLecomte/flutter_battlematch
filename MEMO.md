# Mémo des problemes identifiés
## 1 [RESOLU]
- ~~il manque un bouton pour permettre au capitaine d'ajouter un joueur dans l'équipe depuis l'écran du tournoi (@team_screen.dart)~~
- Résolu : bouton « Inviter un joueur » dans l'AppBar de `TeamsScreen` (visible si l'utilisateur est capitaine de l'équipe active) ouvrant `showTeamsScreenInvitePlayerDialog` ; recherche + invitation dans `TeamsScreenController`.

## 2 [RESOLU]
- ~~il manque un outils qui permet de dire qui est joueur dans l'équipe, et qui est coach (le capitaine peut etre coach).~~
- ~~Seul les joueurs on une ligne dans la matrice des appariements.~~
- Résolu : nouveau rôle `coach` dans `team_membres.role` ; sélecteur Joueur/Coach par membre dans le panneau de gestion ; le capitaine est identifié par `teams.capitaine_id` (il peut donc être coach) ; les coachs sont exclus de la matrice (`team_members` filtrés au chargement).

## 3 - [Obsolete]
- probleme dans le rafraichissement du tableau des estimations apres une modification 

## 4 [RESOLU]
- ~~il serait bien d'identifier le nombre de joueur par équipe d'un tournoi et l'afficher dans les cards des tounois sur l'ecran @tournois_screen~~
- ~~De plus, une équipe ne peut pas avoir plus de joueur que de le nombre de joueur des équipe du tournoi~~
- Résolu : la taille d'équipe (nb de joueurs importés, `team_meta`) est affichée sur chaque carte de tournoi importé ; l'ajout d'un membre « joueur » (invitation du capitaine, réclamation en capitaine, join par mot de passe) est bloqué avec un message explicite dès que l'équipe atteint la taille du tournoi. Le capitaine est compté s'il est en rôle joueur (`captain`/`player`), le coach (`coach`) non.

## 4.1 [RESOLU]
- ~~dans @team_managament_screen, si il est possible d'avoir plusieurs joueur dans l'équipe que la limite, si on passe un coach en joueur, même si le nombre de joueur est dej aau max.~~
- ~~Il faut ajouter un test pur pouvoir modifier les roles dans "membres de l'équipe"~~
- Résolu : la mise à jour du rôle lit d'abord le rôle courant (`PocketbaseTeamMembresService.getRoleMembre`). Une transition `coach → capitaine/joueur` est considérée comme un ajout de joueur (`PocketbaseDataService.transitionAjouteJoueur`) et déclenche `_verifierCapaciteAjoutJoueur` ; si la taille du tournoi est atteinte, l'opération est bloquée avec « L'équipe est déjà complète (X/Y joueurs). ». En cas d'échec, `TeamManagementTeamActions.changeMemberRole` appelle `onStateChanged()` pour resynchroniser le dropdown. Tests : `test/team_member_role_test.dart`.

## 4.2 [RESOLU]
- ~~retire les liens vers les tournois, c'est inutile au final~~
- Résolu : l'affichage « Lien: <newRecruitURL> » a été retiré de `TournoiCard` ; le champ `lien_nr` reste obligatoire dans les formulaires de création/édition d'un tournoi.

## 4.3 [RESOLU]
- ~~retirer le champs en BDD concernant les URL de tournoi (ainsi que toute reference dans le code ( lorsd e la création des tournois par exemple))~~
- Résolu : champ `lien_nr` retiré de `pocketbase_schema.json` (collection `tournois`) et de tout le code : modèle `Tournoi`, `PocketbaseTournoisService.createTournoi/updateTournoi` (validation + corps de requête), façade `PocketbaseDataService`, `TournoiController` (suppression du `lienController`), dialogues d'ajout/édition de tournoi (un seul champ « Nom »), test du modèle mis à jour. `pocketbase_schema.json` est à réimporter dans l'admin PocketBase.

## 5 - [RESOLU] ajout d'adversaire inutile
- ~~on peut retirer ligne 91-98 de @team_dashboard_screen. Il n'est pas utile d'ajouter un joueur adverse (fait via l'import automatiquement)~~
- Résolu : bouton « Ajouter un adversaire » retiré de l'AppBar de `TeamDashboardScreen` ; fichiers devenus orphelins supprimés (`add_opponent_dialog.dart`, `TeamDashboardController.addOpponent`) ; message d'état vide de la matrice mis à jour (plus de référence au bouton, seul l'import New Recruit configure les adversaires). La suppression d'un adversaire (dialog détails, capitaine) est conservée.

## 6 [RESOLU] - ecran de gestion d'equipe a modifier
- ~~dans @team_screen_management, retirer le panneau "Équipes adverse & Appariements", car trop lourd à charger. Remplacer plutot par simplement "Appariement", ou apparaitrait les informations de l'adversaire (équipes, nom, liste ...)~~
- Résolu : le panneau est renommé « Appariements » et ses données (équipes adverses, joueurs, appariements) ne sont plus chargées systématiquement au démarrage ni au changement d'équipe (1 + 2×N requêtes). Chargement paresseux une fois par sélection : le panneau affiche d'abord une carte « Afficher les appariements » (spinner pendant le chargement) ; après chargement, la liste des joueurs de l'équipe appariés avec leur adversaire (point 6.1). Les données sont réinitialisées au changement d'équipe ; un chargement dont l'équipe a changé entre-temps est ignoré.

## 6.1 [RESOLU]
- ~~le point 6 n'est pas resolu. Je ne veux plus voir apparaitre l'ensemble des équipes et adversaire. Seulement les adverses, si il y a un appariement d'effectif.~~
- Résolu : le panneau « Appariements » liste les **joueurs de l'équipe qui sont appariés**, avec l'adversaire correspondant (pseudo, liste d'armée si renseignée, équipe adverse) — un joueur peut apparaître plusieurs fois (un appariement par équipe adverse). Un joueur sans appariement n'apparaît pas ; s'il n'y a aucun appariement, rien n'est affiché. Le panneau est en lecture seule : l'appariement et l'annulation se font depuis la matrice du tableau de bord (tap sur une cellule, `toggleMatched`). Tests de régression dans `test/team_management_detail_panel_test.dart`.

## 7 [RESOLU] - Verification des scrollsviews dans le team management
- ~~probleme de Renderflex overflowed dans @team_management_team_members_panel (The overflowing RenderFlex has an orientation of Axis.vertical.)~~
- ~~verifier l'ensemble, car plusieurs widgets semblent problematiques sur cette écran~~
- ~~ajouter des scrollsviews, car si beaucoup d'information, il y a des dépassements~~
- Résolu : la zone de détail de `TeamManagementScreen` est enveloppée dans un `SingleChildScrollView` (colonne `mainAxisSize.min`) — c'est la page qui défile. Les `Expanded` verticaux internes (panneaux membres et invitations) sont remplacés par des `ListView` `shrinkWrap` / widgets de hauteur naturelle ; les `Expanded` horizontaux (répartition largeur membres/invitations) et la sidebar 250 px restent inchangés. Test de régression d'overflow + scroll dans `test/team_management_detail_panel_test.dart`.

## 8 [RESOLU] - polorpicker admin
- ~~dans l'administration, ajouter un colorpicker lors de l'édition des appréciations~~
- Résolu : le swatch de couleur du dialog d'appréciation (`admin_choix_edit_dialog.dart`) est cliquable et ouvre un sélecteur (`admin_color_picker_dialog.dart`) : grille des 19 teintes Material (500), tap pour sélectionner, « Valider » pour confirmer. La couleur choisie est resynchronisée dans le champ hexadécimal (`HexColorParser.colorToHexString`, format `#RRGGBB` stocké), qui reste éditable à la main ; `AdminController.saveChoix` continue de normaliser/valider la valeur. Tests : `test/hexadecimal_color_parser_test.dart` (`colorToHexString`) et `test/admin_dialog_repro_test.dart` (flux picker → champ hex → Enregistrer).

## 9 [RESOLU] - validation login
- ~~ajouter une validation de formulaire pour @login_screen, avec la touche entrée~~
- Résolu : la validation du formulaire (format email, règles du mot de passe, pseudo requis à l'inscription) était déjà en place et déclenchée par `_submit()` ; la touche Entrée sur chaque champ (`onFieldSubmitted` dans `LoginFormFields`) invoque désormais le même `_submit()` que le bouton, donc la même validation avant toute soumission. Tests : `test/login_screen_test.dart` (Entrée → callback de soumission, Entrée avec saisie invalide → erreurs affichées sans soumission).

## 10 - tuto
- la premiere fois qu'un utilisateur se connecte, afficher un tutoriel d'explication/utilisation dans un dialog.

## 11 - Ajout de setting
- ajouter dans le profil, une catégorie "parametres"
- On y retrouvera un mode jour/nuit (faire attention au couleur deja utilisé, afin de garder de la visibilité)
- on y retrouvera un showaboutdialog
- on y retrouvera un bouton pour revoir le dialog d'explication/tutoriel

