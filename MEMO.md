# Mémo des problemes identifiés
## 1
- erreur durant imports des equipes: 
Erreur de chargement des équipes du tournoi : ClientException: {url: https://metabase.pedagogeek.fr/api/collections/teams/records?page=1&perPage=1000&filter=tournoi_id+%3D+%22excscdrjd2ky0ip%22&sort=nom&skipTotal=true, isAbort: false, statusCode: 400, response: {data: {}, message: Something went wrong while processing your request., status: 400}, originalError: null}
- probleme de connexion : Erreur : ClientException: {url: https://metabase.pedagogeek.fr/api/collections/joueurs/auth-with-password, isAbort: false, statusCode: 400, response: {data: {}, message: Failed to authenticate., status: 400}, originalError: null}

## 2
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

## 3 
- le parseur semble en erreur (identifie 11 équipes sur 12, dans le nouveau @exemple_tournoi.txt)

## 4 
- collection joueur, champs "short" inutile dans pocketbase