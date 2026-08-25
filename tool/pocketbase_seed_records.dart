// ===========================================================================
// Script de seed PocketBase pour MetaWar.
// Alimente les collections de référence `armees` et `choix` : armées issues
// du projet PHP historique, appréciations d'estimation fixes de l'application.
//
// Usage :
//   dart run tool/pocketbase_seed_records.dart --email <superuser@exemple.fr> --password <motDePasse>
//   ou avec variables d'environnement PB_SUPERUSER_EMAIL / PB_SUPERUSER_PASSWORD :
//   dart run tool/pocketbase_seed_records.dart
//
// Le script est idempotent : les enregistrements déjà présents sont mis à jour,
// pas dupliqués (recherche par nom d'armée / intitulé court du choix).
// ===========================================================================

import 'dart:io';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:pocketbase/pocketbase.dart';

/// Référentiel des 16 armées The Ninth Age (source : MW_Armee).
const List<Map<String, String>> referentielArmees = [
  {'nom': 'Beast Herds', 'short': 'BH'},
  {'nom': 'Daemon Legion', 'short': 'DL'},
  {'nom': 'Dread Elves', 'short': 'DE'},
  {'nom': 'Dwarven Holds', 'short': 'DH'},
  {'nom': 'Empire of Sonnstahl', 'short': 'EoS'},
  {'nom': 'Highborn Elves', 'short': 'HE'},
  {'nom': 'Infernal Dwarves', 'short': 'ID'},
  {'nom': 'Kingdom of Equitaine', 'short': 'KoE'},
  {'nom': 'Ogre Khans', 'short': 'OK'},
  {'nom': 'Orcs and Goblins', 'short': 'O&G'},
  {'nom': 'Saurian Ancients', 'short': 'SA'},
  {'nom': 'Sylvan Elves', 'short': 'SE'},
  {'nom': 'Undying Dynasties', 'short': 'UD'},
  {'nom': 'Vampire Covenant', 'short': 'VC'},
  {'nom': 'Vermin Swarm', 'short': 'VS'},
  {'nom': 'Warriors of the Dark Gods', 'short': 'WDG'},
];

/// Référentiel des 7 appréciations d'estimation fixes.
/// Les `short` correspondent exactement aux codes affichés dans la matrice.
/// Les couleurs hexadécimales sont assombries pour rester lisibles avec le
/// texte blanc de la matrice.
const List<Map<String, String>> referentielChoix = [
  {'libelle': 'Très défavorable', 'short': '--', 'couleur_hex': '#B71C1C'},
  {'libelle': 'Défavorable', 'short': '-', 'couleur_hex': '#D32F2F'},
  {'libelle': 'Lég. défavor.', 'short': '=-', 'couleur_hex': '#F57F17'},
  {'libelle': 'Égalité', 'short': '=', 'couleur_hex': '#F9A825'},
  {'libelle': 'Lég. favor.', 'short': '=+', 'couleur_hex': '#7CB342'},
  {'libelle': 'Favorable', 'short': '+', 'couleur_hex': '#388E3C'},
  {'libelle': 'Très favorable', 'short': '++', 'couleur_hex': '#1B5E20'},
];

/// Nom de la collection d'authentification des super-utilisateurs PocketBase.
const String collectionNameSuperusers = '_superusers';

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

  var nombreArmeesCreees = 0;
  var nombreArmeesMisesAJour = 0;
  var nombreChoixCrees = 0;
  var nombreChoixMisAJour = 0;

  try {
    for (final Map<String, String> definitionArmee in referentielArmees) {
      final enregistrementExistant =
          await _rechercherEnregistrementParChamp(
        clientPocketBase,
        nomCollection: collectionNameArmees,
        champRecherche: 'nom',
        valeurRecherchee: definitionArmee['nom']!,
      );

      if (enregistrementExistant == null) {
        await clientPocketBase.collection(collectionNameArmees).create(
              body: Map<String, dynamic>.of(definitionArmee),
            );
        nombreArmeesCreees++;
      } else {
        await clientPocketBase.collection(collectionNameArmees).update(
              enregistrementExistant.id,
              body: Map<String, dynamic>.of(definitionArmee),
            );
        nombreArmeesMisesAJour++;
      }
    }

    for (final Map<String, String> definitionChoix in referentielChoix) {
      final enregistrementExistant =
          await _rechercherEnregistrementParChamp(
        clientPocketBase,
        nomCollection: collectionNameChoix,
        champRecherche: 'short',
        valeurRecherchee: definitionChoix['short']!,
      );

      if (enregistrementExistant == null) {
        await clientPocketBase.collection(collectionNameChoix).create(
              body: Map<String, dynamic>.of(definitionChoix),
            );
        nombreChoixCrees++;
      } else {
        await clientPocketBase.collection(collectionNameChoix).update(
              enregistrementExistant.id,
              body: Map<String, dynamic>.of(definitionChoix),
            );
        nombreChoixMisAJour++;
      }
    }
  } on ClientException catch (exceptionEcriture) {
    stderr.writeln(
      "Échec d'écriture des référentiels : ${exceptionEcriture.response}",
    );
    exit(66);
  }

  stdout.writeln(
    'Seed terminé sur $pocketBaseServerUrl : '
    'armées créées=$nombreArmeesCreees, armées mises à jour=$nombreArmeesMisesAJour, '
    'choix créés=$nombreChoixCrees, choix mis à jour=$nombreChoixMisAJour.',
  );

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

/// Recherche un enregistrement par égalité exacte sur un champ donné.
Future<RecordModel?> _rechercherEnregistrementParChamp(
  PocketBase clientPocketBase, {
  required String nomCollection,
  required String champRecherche,
  required String valeurRecherchee,
}) async {
  final List<RecordModel> resultats = await clientPocketBase
      .collection(nomCollection)
      .getFullList(filter: '$champRecherche = "$valeurRecherchee"');

  if (resultats.isEmpty) {
    return null;
  }
  return resultats.first;
}
