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

## 4
- le parseur semble en erreur (@exemple_tournoi.txt contient 4 équipes de 2 joueurs)
- sur les grosses équipes, en grand nombre ça ne fonctionne pas bien ( @exemple_tournoi_2.txt, il y a 50 équipes, le parseur en identifie 31 )

## 5
- erreur d'affichage des equipes (néccessite un singlechildscrollview ?)
- voicie l'erreur
Erreur de chargement des équipes du tournoi : ClientException: {url: https://metabase.pedagogeek.fr/api/collections/teams/records?page=1&perPage=1000&filter=tournoi_id+%3D+%22excscdrjd2ky0ip%22&sort=nom&skipTotal=true, isAbort: false, statusCode: 400, response: {data: {}, message: Something went wrong while processing your request., status: 400}, originalError: null}
══╡ EXCEPTION CAUGHT BY RENDERING LIBRARY ╞═════════════════════════════════════════════════════════
The following assertion was thrown during layout:
A RenderFlex overflowed by 1806 pixels on the bottom.

The relevant error-causing widget was:
  Column
  Column:file:///home/gus/Dev/flutter_metawar/lib/screens/widgets/teams_screen_team_access_panel.dart:72:16

The overflowing RenderFlex has an orientation of Axis.vertical.
The edge of the RenderFlex that is overflowing has been marked in the rendering with a yellow and
black striped pattern. This is usually caused by the contents being too big for the RenderFlex.
Consider applying a flex factor (e.g. using an Expanded widget) to force the children of the
RenderFlex to fit within the available space instead of being sized to their natural size.
This is considered an error condition because it indicates that there is content that cannot be
seen. If the content is legitimately bigger than the available space, consider clipping it with a
ClipRect widget before putting it in the flex, or using a scrollable container rather than a Flex,
like a ListView.
The specific RenderFlex in question is: RenderFlex#2c9f8 relayoutBoundary=up9 OVERFLOWING:
  needs compositing
  creator: Column ← Padding ← Semantics ← DefaultTextStyle ← AnimatedDefaultTextStyle ←
    _InkFeatures-[GlobalKey#a4c95 ink renderer] ← NotificationListener<LayoutChangedNotification> ←
    CustomPaint ← _ShapeBorderPaint ← PhysicalShape ← _MaterialInterior ← Material ← ⋯
  parentData: offset=Offset(12.0, 12.0) (can use size)
  constraints: BoxConstraints(0.0<=w<=802.0, 0.0<=h<=701.0)
  size: Size(802.0, 701.0)
  direction: vertical
  mainAxisAlignment: start
  mainAxisSize: max
  crossAxisAlignment: start
  textDirection: ltr
  verticalDirection: down
  spacing: 0.0


## 6
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

