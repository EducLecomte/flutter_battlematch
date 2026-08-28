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

/// Référentiel statique des 7 appréciations fixes du système d'estimation.
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

// ---------------------------------------------------------------------------
// Paramètres du tableau de bord d'équipe et des estimations
// ---------------------------------------------------------------------------

/// Séparateur de la clé composite (joueur, adversaire) utilisée pour
/// retrouver l'estimation correspondant à un appariement.
const String dashboardEstimKeySeparator = ':';

/// Score minimum du système d'estimation 0-20.
const int estimScoreMinimum = 0;

/// Score maximum du système d'estimation 0-20.
const int estimScoreMaximum = 20;

/// Nombre de divisions du curseur de score.
const int estimScoreDivisions = 20;

/// Score par défaut du curseur d'estimation.
const int estimScoreDefault = 10;

/// Niveau de confiance faible.
const String estimConfianceFaible = 'faible';

/// Niveau de confiance moyen.
const String estimConfianceMoyen = 'moyen';

/// Niveau de confiance élevé.
const String estimConfianceEleve = 'eleve';

/// Niveau de confiance par défaut.
const String estimConfianceDefault = estimConfianceMoyen;

/// Niveaux de confiance acceptés par l'application.
const List<String> estimConfianceOptions = [
  estimConfianceFaible,
  estimConfianceMoyen,
  estimConfianceEleve,
];

/// Nombre de décimales affiché pour les agrégats de score.
const int scoreSummaryDecimalPlaces = 1;

/// Longueur maximale du mot de passe d'accès d'une équipe.
const int teamPasswordMaxLength = 128;

// ---------------------------------------------------------------------------
// Codes de réponse HTTP PocketBase utilisés pour les messages d'erreur
// ---------------------------------------------------------------------------

/// Code HTTP renvoyé par PocketBase quand les identifiants sont rejetés.
const int httpCodeIdentifiantsRejetes = 400;

/// Code HTTP renvoyé par PocketBase en cas de limite de tentatives dépassée.
const int httpCodeTropDeTentatives = 429;

// ---------------------------------------------------------------------------
// Règles de validation du formulaire de connexion / inscription
// ---------------------------------------------------------------------------

/// Longueur minimale du mot de passe à l'inscription.
const int passwordMinimumLength = 8;

/// Exige au moins une majuscule dans le mot de passe.
final RegExp passwordUppercasePattern = RegExp(r'[A-Z]');

/// Exige au moins un caractère spécial (hors lettres et chiffres).
final RegExp passwordSpecialCharacterPattern = RegExp(r'[^A-Za-z0-9]');

/// Format minimal attendu pour une adresse email.
final RegExp emailValidationPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
