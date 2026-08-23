// ===========================================================================
// Configuration centralisée de l'application MetaWar.
// Regroupe toutes les valeurs externes (URL serveur, noms de collections)
// afin d'éviter toute valeur magique dispersée dans le code.
// ===========================================================================

/// URL racine de l'instance PocketBase hébergeant les données MetaWar.
const String pocketBaseServerUrl = 'https://metabase.pedagogeek.fr';

// ---------------------------------------------------------------------------
// Noms des collections PocketBase
// ---------------------------------------------------------------------------

/// Collection d'authentification dédiée aux profils joueurs.
/// Collection `auth` distincte créée spécifiquement pour MetaWar afin de
/// laisser la collection native `users` de PocketBase totalement intacte
/// (champs, règles et méthodes d'authentification inchangées).
const String collectionNameJoueurs = 'joueurs';

/// Tournois créés par les utilisateurs.
const String collectionNameTournois = 'tournois';

/// Équipes permanentes rattachées à un tournoi.
const String collectionNameTeams = 'teams';

/// Association équipe ↔ joueur avec rôle et statut d'invitation.
const String collectionNameTeamMembres = 'team_membres';

/// Rencontres (rondes) opposant une équipe à une équipe adverse.
const String collectionNameRencontres = 'rencontres';

/// Référentiel statique des 16 armées (The Ninth Age).
const String collectionNameArmees = 'armees';

/// Référentiel statique des 6 choix d'estimation colorés.
const String collectionNameChoix = 'choix';

/// Joueurs adverses (méta adverse) attachés à une rencontre.
const String collectionNameMetaAdv = 'meta_adv';

/// Estimations saisies par nos joueurs sur chaque adversaire.
const String collectionNameEstims = 'estims';

/// Appariements verrouillés par le capitaine.
const String collectionNameMatched = 'matched';

// ---------------------------------------------------------------------------
// Clé de persistance locale du jeton d'authentification (web)
// ---------------------------------------------------------------------------

/// Clé SharedPreferences stockant la session PocketBase sérialisée.
const String sharedPreferencesKeyAuthSession = 'metawar_pocketbase_auth_session';
