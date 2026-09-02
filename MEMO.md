# Mémo des problemes identifiés
## 1 
- probleme avec l'import, il créé des doublons des équipe et faire enregistre toutes les rencontre possible. ce n'est ps ce qui est attendu. 
- On va renommer meta_adv par team_meta, dans laquelle on retrouve team_id, armee_id, nom_jo, liste_jo (et les données pocketbase de base, id, created, updated)
- si 300 joueurs, on devra trouver 300 lignes pour le tournoi, si 15 joueurs, 15 lignes
- dans team_membres, on va ajouter en plus l'id de team_meta, pour associé un membre de l'équipe a son armées associé. on peut avoir des membres d'équipe non joueurs (coach, pour pouvoir consulter les matrices d'estimation)

## 2
- probleme chargement de l'ecran "équipe", sur l'ecran principal avec le bottomnavbar. Il est Très long.
