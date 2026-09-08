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

## 4.3
- retirer le champs en BDD concernant les URL de tournoi

## 5 - ajout d'adversaier inutile
- on peut retirer ligne 91-98 de @team_dashboard_screen. Il n'est pas utile d'ajouter un joueur adverse (fait via l'import automatiquement)

## 6 - ecran de gestion d'equipe a modifier
- dans @team_screen_management, retirer le panneau "Équipes adverse & Appariements", car trop lourd à charger. Remplacer plutot par simplement "Appariement", ou apparaitrait les informations de l'adversaire (équipes, nom, liste ...)

## 7 - Verification des scrollsviews dans le team management
- probleme de Renderflex overflowed dans @team_management_team_members_panel (The overflowing RenderFlex has an orientation of Axis.vertical.)
- verifier l'ensemble, car plusieurs widgets semblent problematiques sur cette écran
- ajouter des scrollsviews, car si beaucoup d'information, il y a des dépassements

## 8 - polorpicker admin
- dans l'administration, ajouter un colorpicker lors de l'édition des appréciations

## 9 - tuto
- la premiere fois qu'un utilisateur se connecte, afficher un tutoriel d'explication/utilisation dans un dialog.

## 10 - validation login
- ajouter une validation de formulaire pour @login_screen, avec la touche entrée

## 11 - Ajout de setting
- ajouter dans le profil, une catégorie "parametres"
- On y retrouvera un mode jour/nuit (faire attention au couleur deja utilisé, afin de garder de la visibilité)
- on y retrouvera un showaboutdialog
- on y retrouvera un bouton pour revoir le dialog d'explication/tutoriel

