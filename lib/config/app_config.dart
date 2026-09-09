// ===========================================================================
// Configuration centralisée de l'application MetaWar.
// Regroupe toutes les valeurs externes (URL serveur, noms de collections)
// afin d'éviter toute valeur magique dispersée dans le code.
// ===========================================================================

/// URL racine de l'instance PocketBase hébergeant les données MetaWar.
const String pocketBaseServerUrl = 'https://metabase.pedagogeek.fr';

// ---------------------------------------------------------------------------
// Identité de l'application
// ---------------------------------------------------------------------------

/// Nom de l'application (utilisé notamment par le dialog « À propos », MEMO 11).
const String applicationName = 'MetaWar';

/// Version de l'application affichée dans le dialog « À propos » (MEMO 11).
/// À garder alignée avec le champ `version` de pubspec.yaml.
const String appVersion = '1.0.0';

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

/// Référentiel statique des 16 armées (The Ninth Age).
const String collectionNameArmees = 'armees';

/// Référentiel statique des 7 appréciations fixes du système d'estimation.
const String collectionNameChoix = 'choix';

/// Joueurs d'une équipe avec leur armée et leur liste (1 ligne par joueur,
/// indépendante des rencontres).
const String collectionNameTeamMeta = 'team_meta';

/// Estimations saisies par nos joueurs sur chaque adversaire.
const String collectionNameEstims = 'estims';

/// Appariements verrouillés par le capitaine.
const String collectionNameMatched = 'matched';

// ---------------------------------------------------------------------------
// Clé de persistance locale du jeton d'authentification (web)
// ---------------------------------------------------------------------------

/// Clé SharedPreferences stockant la session PocketBase sérialisée.
const String sharedPreferencesKeyAuthSession = 'metawar_pocketbase_auth_session';

/// Clé SharedPreferences du drapeau « tutoriel de bienvenue déjà affiché ».
/// Stockage local (par navigateur) : le tutoriel s'affiche à la première
/// connexion sur un appareil donné, sans migration de schéma PocketBase.
const String sharedPreferencesKeyTutorielVu = 'metawar_tutoriel_vu';

/// Clé SharedPreferences du mode d'affichage clair/sombre (MEMO 11).
/// Valeur stockée : `'light'` ou `'dark'`. Absence de valeur = thème clair
/// (comportement initial de l'application).
const String sharedPreferencesKeyThemeMode = 'metawar_theme_mode';

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
// Durées d'affichage de l'interface
// ---------------------------------------------------------------------------

/// Durée d'affichage d'un SnackBar (confirmation ou erreur) avant disparition
/// automatique. Valeur volontairement courte : le SnackBar ne doit jamais
/// rester bloqué à l'écran.
const Duration snackBarDisplayDuration = Duration(seconds: 2);

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
