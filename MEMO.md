# Idées a implementer

## score auto [RESOLU]
- lors de la selection des estimation +/=/-, mettre un score par defaut dans la fourchette d'estimation. On va dire : --:2 ; -:5; =-:7;=:10;=+:13;+:15;++:18
  - Résolu : `Choix.defaultScoreForShort` intègre ces valeurs par défaut (--:2, -:5, =-:7, =:10, =+:13, +:15, ++:18). Dans `EstimDialogController`, `selectChoice` assigne automatiquement ce score au score minimum et maximum.
- ajouter dans le panneau d'admin la possibiliter de changer la valeur du score par defaut
  - Résolu : champ `score_defaut` optionnel ajouté au modèle `Choix`, dans `pb_schema.json`, et éditable via le formulaire d'appréciation (`ChoixEditDialog` / `AdminChoixTab`). Si présent, il prévaut sur le score standard.

## deconenction/cache [RESOLU]
- verifier le code lors des deconnections, ou absence de connection avec un compte, il y a des problemes, qui ne font pas revenir à l'ecrand e login, si la session est "closed"
  - Résolu :
    1. `PocketbaseClientHolder.ensureInitialized` : si la session en cache n'est plus valide (`!authStore.isValid`), l'authStore est immédiatement purgé. Si elle est valide temporellement, un `authRefresh()` serveur est exécuté. Si le serveur répond 401/403 (session fermée ou révoquée), `handleSessionExpired()` purge l'authStore.
    2. `PocketbaseAuthInterceptorClient` : intercepte tout statut 401 sur les requêtes authentifiées et déclenche automatiquement `handleSessionExpired()`.
    3. `PocketbaseAuthService.authStateChanges` : s'appuie désormais sur `isUserAuthenticated` (`authStore.isValid && authStore.record != null`).
    4. `main.dart` : `appNavigatorKey` permet de dépiler immédiatement toutes les routes (`popUntil((route) => route.isFirst)`) pour afficher instantanément le `LoginScreen` lors de toute déconnexion ou expiration de session.
  - Résolu :
    1. `PocketbaseClientHolder.ensureInitialized` : si la session en cache n'est plus valide (`!authStore.isValid`), l'authStore est immédiatement purgé. Si elle est valide temporellement, un `authRefresh()` serveur est exécuté. Si le serveur répond 401/403 (session fermée ou révoquée), `handleSessionExpired()` purge l'authStore.
    2. `PocketbaseAuthInterceptorClient` : intercepte tout statut 401 sur les requêtes authentifiées et déclenche automatiquement `handleSessionExpired()`.
    3. `PocketbaseAuthService.authStateChanges` : s'appuie désormais sur `isUserAuthenticated` (`authStore.isValid && authStore.record != null`).
    4. `main.dart` : `appNavigatorKey` permet de dépiler immédiatement toutes les routes (`popUntil((route) => route.isFirst)`) pour afficher instantanément le `LoginScreen` lors de toute déconnexion ou expiration de session.
- verifier le code lors des deconnections, ou absence de connection avec un compte, il y a des problemes, qui ne font pas revenir à l'ecrand e login, si la session est "closed"