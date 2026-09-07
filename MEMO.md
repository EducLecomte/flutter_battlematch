# Mémo des problemes identifiés
## 1 [RESOLU]
- ~~il manque un bouton pour permettre au capitaine d'ajouter un joueur dans l'équipe depuis l'écran du tournoi (@team_screen.dart)~~
- Résolu : bouton « Inviter un joueur » dans l'AppBar de `TeamsScreen` (visible si l'utilisateur est capitaine de l'équipe active) ouvrant `showTeamsScreenInvitePlayerDialog` ; recherche + invitation dans `TeamsScreenController`.

## 2 [RESOLU]
- ~~il manque un outils qui permet de dire qui est joueur dans l'équipe, et qui est coach (le capitaine peut etre coach).~~
- ~~Seul les joueurs on une ligne dans la matrice des appariements.~~
- Résolu : nouveau rôle `coach` dans `team_membres.role` ; sélecteur Joueur/Coach par membre dans le panneau de gestion ; le capitaine est identifié par `teams.capitaine_id` (il peut donc être coach) ; les coachs sont exclus de la matrice (`team_members` filtrés au chargement).

## 3
- probleme dans le rafraichissement du tableau des estimations apres une modification 

## 4
- une équipe ne peut pas avoir plus de joueur que de le nombre de joueur des équipe du tournoi
- il serait bien d'identifier le nombre de joueur par équipe d'un tournoi et l'afficher dans les cards des tounois

## 5
- dans @team_screen_management.dart, ajouter un bouton pour naviguer vers l'ecran du tournoi, vers l'ecran des equipes adverses (matrice)
- ajouter un bouton pour lire la liste d'un adversaire

## 6
- on peut retirer ligne 91-98 de @team_dashboard_screen.dart. Il n'est pas utile d'ajouter un joueur adverse (fait via l'import automatiquement)

## 7
- probleme de Renderflex overflowed dans @team_management_team_members_panel.dart (The overflowing RenderFlex has an orientation of Axis.vertical.)
- verifier l'ensemble, car plusieurs widgets semblent problematiques sur cette écran
- ajouter des scrollsviews, car si beaucoup d'information, il y a des dépassements

## 8
- dans l'administration, ajouter un colorpicker lors de l'édition des appréciations

## 9
- la premiere fois qu'un utilisateur se connecte, afficher un tutoriel d'explication/utilisation dans un dialog.

## 
- ajouter dans le profil, une catégorie "parametres"
- On y retrouvera un mode jour/nuit (faire attention au couleur deja utilisé, afin de garder de la visibilité)
- on y retrouvera un showaboutdialog
- on y retrouvera un bouton pour revoir le dialog d'explication/tutoriel

