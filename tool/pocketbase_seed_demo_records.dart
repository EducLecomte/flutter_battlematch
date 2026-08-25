// ===========================================================================
// Script de jeu de données de démonstration pour MetaWar.
// Crée un univers de test cohérent et idempotent sur l'instance PocketBase :
// comptes joueurs de démonstration, adhésions d'équipe, rencontres,
// adversaires avec listes d'armées T9A réalistes, estimations pré-remplies
// (avec trous volontaires pour tester la saisie) et un appariement exemple.
//
// Usage :
//   dart run tool/pocketbase_seed_demo_records.dart --email <superuser> --password <mdp>
//   ou avec variables d'environnement PB_SUPERUSER_EMAIL / PB_SUPERUSER_PASSWORD :
//   dart run tool/pocketbase_seed_demo_records.dart
//
// Idempotence : chaque catégorie est recherchée par sa clé naturelle
// (email du joueur, couple team/joueur, couple tournoi/nom_adversaire,
// couple joueur/meta_adv) puis mise à jour au lieu d'être dupliquée.
//
// Prérequis : les collections MetaWar doivent exister et les référentiels
// armées/choix être alimentés (voir pocketbase_seed_records.dart).
// ===========================================================================

import 'dart:io';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:flutter_metawar/models/appreciation_scale.dart';
import 'package:pocketbase/pocketbase.dart';

/// Nom de la collection d'authentification des super-utilisateurs PocketBase.
const String collectionNameSuperusers = '_superusers';

/// Mot de passe commun aux comptes de démonstration (longueur >= minimum PB).
const String motDePasseDemonstration = 'DemoMetaWar2026';

/// Bornes déterministes des scores de démonstration.
const int scoreMinimuDemonstration = 8;
const int pasScoreMinimuDemonstration = 3;
const int amplitudeScoreMinimuDemonstration = 7;
const int incrementScoreMaximumDemonstration = 1;
const int amplitudeScoreMaximumDemonstration = 5;

/// Comptes joueurs de démonstration (upsert par email).
const List<Map<String, String>> referentielJoueursDemo = [
  {'email': 'martin.demo@pedagogeek.fr', 'nom': 'Martin Dupont', 'short': 'MDUP'},
  {'email': 'sophie.demo@pedagogeek.fr', 'nom': 'Sophie Martin', 'short': 'SMAR'},
  {'email': 'lucas.demo@pedagogeek.fr', 'nom': 'Lucas Bernard', 'short': 'LBER'},
  {'email': 'emma.demo@pedagogeek.fr', 'nom': 'Emma Petit', 'short': 'EPET'},
  {'email': 'hugo.demo@pedagogeek.fr', 'nom': 'Hugo Moreau', 'short': 'HMOR'},
];

/// Rencontres de démonstration et armées des trois adversaires de chacune.
const List<Map<String, dynamic>> definitionRencontresDemo = [
  {
    'nom_adversaire': '[DEMO] vs Les Chevaliers du Sud',
    'shorts_armees': ['KoE', 'EoS', 'HE'],
  },
  {
    'nom_adversaire': '[DEMO] vs Compagnie Verte',
    'shorts_armees': ['SE', 'SA', 'BH'],
  },
  {
    'nom_adversaire': '[DEMO] vs La Garde de Fer',
    'shorts_armees': ['DH', 'ID', 'VS'],
  },
  {
    'nom_adversaire': '[DEMO] vs Horde du Nord',
    'shorts_armees': ['WDG', 'VC', 'OK'],
  },
];

/// Adversaires de démonstration par short d'armée : pseudo et liste New Recruit.
const Map<String, Map<String, String>> adversairesParShortArmee = {
  'KoE': {
    'pseudo': 'Bertrand le Preux',
    'liste': 'Duke (Barded Steed)\nKnights of the Grail x8\nPegasus Knights x4\nMen-at-Arms x40\nRealm Knights x6\nTreasurer\nFolk Hero',
  },
  'EoS': {
    'pseudo': 'Wilhelm von Hagen',
    'liste': 'Marshal on Black Stallion\nImperial Guard x30\nHeavy Infantry x40\nReiters x10\nArtillery: Cannon\nArtillery: Mortar\nWizard Apprentice',
  },
  'HE': {
    'pseudo': 'Caelin Amarelion',
    'liste': 'Prince on Giant Eagle\nSea Guard Levy x45\nSword Masters x15\nRepeater Battery x2\nGrey Watchers x10\nHigh Loyalist',
  },
  'SE': {
    'pseudo': 'Yannick Feuilleombre',
    'liste': 'Forest Prince on Elven Horse\nForest Rangers x15\nSylvan Sentinels x15\nHeath Riders x8\nBlade Dancers x7\nDruid\nScout Sentinel',
  },
  'SA': {
    'pseudo': 'Tekla Cuirassée',
    'liste': 'Ancient on Carnosaur\nTemple Militants x25\nRhamphodon Riders x5\nGuerrilla Warriors x30\nTaurosaur\nPredatory Banner',
  },
  'BH': {
    'pseudo': "Gork la Corne",
    'liste': 'Beast Lord on Razortusk Chariot\nWildhorn Herd x40\nCentaur Chieftains x6\nGargoyles x8\nRazortusk Herd x15\nSoothsayer\nCyclops',
  },
  'DH': {
    'pseudo': 'Thorgrim Barbefer',
    'liste': 'Clan Warlord on War Throne\nDeep Watch x20\nGreybeards x25\nRangers x15\nForge Wardens x10\nSteam Copters x2\nRunesmith',
  },
  'ID': {
    'pseudo': "Zahhak le Brasier",
    'liste': 'Prophet on Great Behemoth\nVassal Levies x60\nInfernal Warriors x25\nTauruk Anointed x4\nKadim Titan\nInfernal Artillery x2',
  },
  'VS': {
    'pseudo': 'Seigneur Verminux',
    'liste': 'Plague Patriarch on Plague Pendulum\nVermin Swarm x60\nPlague Brothers x25\nWeapon Teams x3\nGiant Rats x20\nMagister\nGrand Blightbearer',
  },
  'WDG': {
    'pseudo': 'Mordrek le Déchu',
    'liste': 'Exalted Herald\nWarriors of the Dark Gods x25 (Gluttony)\nChosen of the Dark Gods x12\nFallen Knights x5\nWasteland Behemoth\nSoothsayer\nForsworn x15',
  },
  'VC': {
    'pseudo': 'Comtesse Isolde',
    'liste': 'Vampire Count on Skeletal Steed\nSkeletons x55\nBarrow Knights x6\nGhouls x45\nBanshee\nNecromancer\nBat Swarms x3',
  },
  'OK': {
    'pseudo': 'Gronnak Mange-Tonnes',
    'liste': 'Khan on Battered Big Brother\nOgre Khans x8\nBruisers x6\nYetis x8\nScrappy Snotlings x40\nFirebellies x2\nBattle Sage',
  },
};

/// Commentaires d'estimation attribués cycliquement.
const List<String> commentairesEstimation = [
  'Liste agressive, surveiller les éclaireurs.',
  'Beaucoup de tir, privilégier le terrain couvert.',
  'Gros bloc de combat, éviter le choc frontal.',
  'Combos magiques redoutables, prévoir la dispellation.',
  'Faible mobilité, on peut choisir nos combats.',
  'Unités volantes dangereuses pour nos machines de guerre.',
];

Future<void> main(List<String> arguments) async {
  final String? emailSuperuser = _extraireValeurArgument(arguments, '--email') ??
      Platform.environment['PB_SUPERUSER_EMAIL'];
  final String? motDePasseSuperuser =
      _extraireValeurArgument(arguments, '--password') ??
          Platform.environment['PB_SUPERUSER_PASSWORD'];

  if (emailSuperuser == null || motDePasseSuperuser == null) {
    stderr.writeln(
      'Identifiants super-utilisateur manquants. '
      'Fournir --email/--password ou PB_SUPERUSER_EMAIL/PB_SUPERUSER_PASSWORD.',
    );
    exit(64);
  }

  final PocketBase clientPocketBase = PocketBase(pocketBaseServerUrl);

  try {
    await clientPocketBase
        .collection(collectionNameSuperusers)
        .authWithPassword(emailSuperuser, motDePasseSuperuser);
  } on ClientException catch (exceptionAuthentification) {
    stderr.writeln(
      'Échec de connexion super-utilisateur sur $pocketBaseServerUrl : '
      '${exceptionAuthentification.response}',
    );
    exit(65);
  }

  try {
    // --- Référentiels vivants -------------------------------------------------
    final List<RecordModel> armees = await clientPocketBase
        .collection(collectionNameArmees)
        .getFullList(sort: 'short');
    final Map<String, String> idsArmeesParShort = {
      for (final RecordModel armee in armees) armee.data['short'] as String: armee.id,
    };
    final List<RecordModel> choix =
        await clientPocketBase.collection(collectionNameChoix).getFullList(sort: 'short');
    final List<RecordModel> choixAppreciation =
        _filtrerAppreciationsFixes(choix);
    if (choixAppreciation.isEmpty) {
      stderr.writeln(
        'Aucune appréciation fixe trouvée. '
        'Exécuter d’abord tool/pocketbase_seed_records.dart.',
      );
      exit(67);
    }

    // --- Comptes joueurs de démonstration -------------------------------------
    final Map<String, RecordModel> joueursDemoParEmail = {};
    var nombreJoueursCrees = 0;
    var nombreJoueursMisAJour = 0;
    for (final Map<String, String> definitionJoueur in referentielJoueursDemo) {
      final String email = definitionJoueur['email']!;
      final Map<String, dynamic> corps = <String, dynamic>{
        'nom': definitionJoueur['nom'],
        'short': definitionJoueur['short'],
      };

      final List<RecordModel> existants = await clientPocketBase
          .collection(collectionNameJoueurs)
          .getFullList(filter: 'email = "$email"');

      if (existants.isEmpty) {
        final RecordModel cree = await clientPocketBase
            .collection(collectionNameJoueurs)
            .create(body: <String, dynamic>{
          'email': email,
          'password': motDePasseDemonstration,
          'passwordConfirm': motDePasseDemonstration,
          ...corps,
        });
        joueursDemoParEmail[email] = cree;
        nombreJoueursCrees++;
      } else {
        final RecordModel existant = existants.first;
        await clientPocketBase
            .collection(collectionNameJoueurs)
            .update(existant.id, body: corps);
        joueursDemoParEmail[email] = existant;
        nombreJoueursMisAJour++;
      }
    }
    final List<RecordModel> listeJoueursDemo = joueursDemoParEmail.values.toList();

    // --- Équipe cible ----------------------------------------------------------
    final RecordModel equipeCible = await _rechercherPremier(clientPocketBase,
            nomCollection: collectionNameTeams, filtre: 'nom = "Les randomiques"') ??
        await clientPocketBase.collection(collectionNameTeams).create(
              body: {'nom': '[DEMO] Équipe Test', 'capitaine_id': listeJoueursDemo.first.id},
            );
    final String identifiantCapitaine = equipeCible.data['capitaine_id'] as String;
    final RecordModel capitaine = await clientPocketBase
        .collection(collectionNameJoueurs)
        .getOne(identifiantCapitaine);

    // --- Adhésions acceptées des joueurs de démonstration ----------------------
    var nombreMembresCrees = 0;
    for (final RecordModel joueur in listeJoueursDemo) {
      final RecordModel? membreExistant = await _rechercherPremier(
        clientPocketBase,
        nomCollection: collectionNameTeamMembres,
        filtre: 'team_id = "${equipeCible.id}" && joueur_id = "${joueur.id}"',
      );
      if (membreExistant != null) continue;
      await clientPocketBase.collection(collectionNameTeamMembres).create(body: {
        'team_id': equipeCible.id,
        'joueur_id': joueur.id,
        'role': 'player',
        'statut': 'accepted',
      });
      nombreMembresCrees++;
    }

    // --- Tournoi cible ----------------------------------------------------------
    RecordModel? tournoiTrouve = await _rechercherPremier(clientPocketBase,
        nomCollection: collectionNameTournois,
        filtre: 'created_by = "$identifiantCapitaine" && nom = "IR2026"');
    tournoiTrouve ??= await _rechercherPremier(clientPocketBase,
        nomCollection: collectionNameTournois,
        filtre: 'created_by = "$identifiantCapitaine"');
    final RecordModel tournoiCible = tournoiTrouve ??
        await clientPocketBase.collection(collectionNameTournois).create(
              body: {
                'nom': '[DEMO] Tournoi IR2026',
                'created_by': identifiantCapitaine,
              },
            );

    // --- Rencontres et adversaires ---------------------------------------------
    var nombreRencontresCreees = 0;
    var nombreAdversairesCrees = 0;
    final List<RecordModel> rencontresDemo = [];
    final Map<String, List<RecordModel>> adversairesParRencontre = {};

    for (final Map<String, dynamic> definitionRencontre in definitionRencontresDemo) {
      final String nomAdversaireEquipe = definitionRencontre['nom_adversaire'] as String;
      final RecordModel rencontre = await _rechercherPremier(clientPocketBase,
              nomCollection: collectionNameRencontres,
              filtre:
                  'tournoi_id = "${tournoiCible.id}" && nom_adversaire = "$nomAdversaireEquipe"') ??
          await clientPocketBase.collection(collectionNameRencontres).create(body: {
            'tournoi_id': tournoiCible.id,
            'team_id': equipeCible.id,
            'nom_adversaire': nomAdversaireEquipe,
          });
      if (_estNouvelleCreation(rencontre)) nombreRencontresCreees++;
      rencontresDemo.add(rencontre);

      final List<RecordModel> adversairesDeLaRencontre = [];
      for (final String shortArmee in definitionRencontre['shorts_armees'] as List<String>) {
        final Map<String, String>? adversaireReference =
            adversairesParShortArmee[shortArmee];
        final String? identifiantArmee = idsArmeesParShort[shortArmee];
        if (adversaireReference == null || identifiantArmee == null) {
          stderr.writeln('Avertissement : armée "$shortArmee" introuvable, adversaire ignoré.');
          continue;
        }
        final RecordModel adversaire = await _rechercherPremier(clientPocketBase,
                nomCollection: collectionNameMetaAdv,
                filtre:
                    'rencontre_id = "${rencontre.id}" && nom_jo_adv = "${adversaireReference['pseudo']}"') ??
            await clientPocketBase.collection(collectionNameMetaAdv).create(body: {
              'rencontre_id': rencontre.id,
              'armee_id': identifiantArmee,
              'nom_jo_adv': adversaireReference['pseudo'],
              'liste_adv': adversaireReference['liste'],
            });
        if (_estNouvelleCreation(adversaire)) nombreAdversairesCrees++;
        adversairesDeLaRencontre.add(adversaire);
      }
      adversairesParRencontre[rencontre.id] = adversairesDeLaRencontre;
    }

    // --- Estimations pré-remplies (avec trous volontaires) ---------------------
    final List<RecordModel> estimateurs = <RecordModel>[capitaine, ...listeJoueursDemo];
    var nombreEstimsCreees = 0;
    for (final RecordModel rencontre in rencontresDemo) {
      final List<RecordModel> adversaires = adversairesParRencontre[rencontre.id]!;
      for (var indexJoueur = 0; indexJoueur < estimateurs.length; indexJoueur++) {
        for (var indexAdv = 0; indexAdv < adversaires.length; indexAdv++) {
          // Trous volontaires (~1 case sur 6) pour tester la saisie manuelle.
          if ((indexJoueur + indexAdv) % 6 == 2) continue;

          final RecordModel estimateur = estimateurs[indexJoueur];
          final RecordModel adversaire = adversaires[indexAdv];
          final RecordModel? estimExistante = await _rechercherPremier(
            clientPocketBase,
            nomCollection: collectionNameEstims,
            filtre:
                'joueur_id = "${estimateur.id}" && meta_adv_id = "${adversaire.id}"',
          );
          if (estimExistante != null) continue;

          final int scoreMin = scoreMinimuDemonstration +
              ((indexJoueur + indexAdv) * pasScoreMinimuDemonstration) %
                  amplitudeScoreMinimuDemonstration;
          final int scoreMax = (scoreMin +
                  incrementScoreMaximumDemonstration +
                  (indexJoueur * indexAdv) %
                      amplitudeScoreMaximumDemonstration)
              .clamp(scoreMin, estimScoreMaximum);
          await clientPocketBase.collection(collectionNameEstims).create(body: {
            'joueur_id': estimateur.id,
            'rencontre_id': rencontre.id,
            'meta_adv_id': adversaire.id,
            'choix_id':
                choixAppreciation[(indexJoueur * 2 + indexAdv) % choixAppreciation.length].id,
            'score_min': scoreMin,
            'score_max': scoreMax,
            'confiance':
                estimConfianceOptions[(indexJoueur + indexAdv) % estimConfianceOptions.length],
            'commentaire': commentairesEstimation[(indexJoueur * 2 + indexAdv) % commentairesEstimation.length],
          });
          nombreEstimsCreees++;
        }
      }
    }

    // --- Un appariement exemple sur la première rencontre ----------------------
    var nombreMatchedCrees = 0;
    if (rencontresDemo.isNotEmpty &&
        (adversairesParRencontre[rencontresDemo.first.id]?.isNotEmpty ?? false)) {
      final RecordModel premiereRencontre = rencontresDemo.first;
      final RecordModel premierAdversaire =
          adversairesParRencontre[premiereRencontre.id]!.first;
      final RecordModel? appariementExistant = await _rechercherPremier(
        clientPocketBase,
        nomCollection: collectionNameMatched,
        filtre: 'rencontre_id = "${premiereRencontre.id}"',
      );
      if (appariementExistant == null) {
        await clientPocketBase.collection(collectionNameMatched).create(body: {
          'rencontre_id': premiereRencontre.id,
          'joueur_id': listeJoueursDemo.first.id,
          'meta_adv_id': premierAdversaire.id,
        });
        nombreMatchedCrees++;
      }
    }

    // --- Bilan -------------------------------------------------------------------
    stdout.writeln(
      'Jeu de données de démonstration terminé sur $pocketBaseServerUrl :\n'
      '  joueurs démo créés/maj       : $nombreJoueursCrees / $nombreJoueursMisAJour\n'
      '  membres ajoutés              : $nombreMembresCrees\n'
      '  rencontres créées            : $nombreRencontresCreees\n'
      '  adversaires créés            : $nombreAdversairesCrees\n'
      '  estimations créées           : $nombreEstimsCreees\n'
      '  appariements exemple créés   : $nombreMatchedCrees\n'
      '\nComptes de démonstration (mot de passe : $motDePasseDemonstration) :',
    );
    for (final Map<String, String> definitionJoueur in referentielJoueursDemo) {
      stdout.writeln(
        '  ${definitionJoueur['email']} (${definitionJoueur['nom']})',
      );
    }
  } on ClientException catch (exceptionEcriture) {
    stderr.writeln("Échec d'écriture du jeu de données : ${exceptionEcriture.response}");
    exit(66);
  }

  exit(0);
}

/// Extrait la valeur associée à un argument de type `--cle valeur`.
String? _extraireValeurArgument(List<String> arguments, String cle) {
  final int position = arguments.indexOf(cle);
  if (position < 0 || position + 1 >= arguments.length) {
    return null;
  }
  return arguments[position + 1];
}

/// Recherche le premier enregistrement correspondant au filtre, sinon null.
Future<RecordModel?> _rechercherPremier(
  PocketBase clientPocketBase, {
  required String nomCollection,
  required String filtre,
}) async {
  final List<RecordModel> resultats = await clientPocketBase
      .collection(nomCollection)
      .getFullList(filter: filtre);
  if (resultats.isEmpty) {
    return null;
  }
  return resultats.first;
}

/// Filtre les 7 appréciations fixes et les trie selon l'échelle d'estimation.
List<RecordModel> _filtrerAppreciationsFixes(List<RecordModel> choixBruts) {
  final List<RecordModel> choixAppreciation = choixBruts
      .where(
        (choix) =>
            AppreciationScale.fixedCodes
                .contains(choix.data['short'] as String),
      )
      .toList();

  choixAppreciation.sort(
    (choixGauche, choixDroit) => AppreciationScale.fixedCodes
        .indexOf(choixGauche.data['short'] as String)
        .compareTo(
          AppreciationScale.fixedCodes.indexOf(choixDroit.data['short'] as String),
        ),
  );

  return choixAppreciation;
}

/// Indique si l'enregistrement vient d'être créé (créé à l'instant par ce run).
bool _estNouvelleCreation(RecordModel enregistrement) {
  final DateTime? dateCreation =
      DateTime.tryParse(enregistrement.get<String>('created'));
  if (dateCreation == null) return false;
  return DateTime.now().difference(dateCreation).inMinutes < 1;
}
