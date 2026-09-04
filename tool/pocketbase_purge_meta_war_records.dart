import 'dart:io';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:pocketbase/pocketbase.dart';

import 'pocketbase_tool_support.dart';

const List<String> collectionsMetaWarParDefaut = [
  collectionNameMatched,
  collectionNameEstims,
  collectionNameTeamMeta,
  collectionNameTeamMembres,
  collectionNameTeams,
  collectionNameTournois,
  collectionNameJoueurs,
];

const List<String> collectionsReferentielsMetaWar = [
  collectionNameArmees,
  collectionNameChoix,
];

Future<void> main(List<String> arguments) async {
  final bool confirmationPurge = contientArgument(arguments, '--yes');
  final bool purgeReferentiels = contientArgument(
    arguments,
    '--purge-referentiels',
  );
  final List<String> collectionsVisees = [
    ...collectionsMetaWarParDefaut,
    if (purgeReferentiels) ...collectionsReferentielsMetaWar,
  ];

  if (!confirmationPurge) {
    stderr.writeln('Purge demandée sans --yes.');
    for (final String nomCollection in collectionsVisees) {
      stderr.writeln('  - $nomCollection');
    }
    stderr.writeln('Relancer avec --yes pour confirmer la suppression.');
    exit(codeSortieArgumentsManquants);
  }

  final PocketBase clientPocketBase = await connecterClientSuperuser(arguments);
  final Map<String, int> enregistrementsSupprimesParCollection = {};
  var totalEnregistrementsSupprimes = 0;

  try {
    for (final String nomCollection in collectionsVisees) {
      final int nombreSupprime = await supprimerTousLesEnregistrements(
        clientPocketBase,
        nomCollection,
      );
      enregistrementsSupprimesParCollection[nomCollection] = nombreSupprime;
      totalEnregistrementsSupprimes += nombreSupprime;
      stdout.writeln('$nomCollection : $nombreSupprime');
    }
  } on ClientException catch (exceptionPocketBase) {
    echouerEcriturePocketBase('Échec de la purge MetaWar', exceptionPocketBase);
  }

  stdout.writeln(
    'Purge terminée sur ${collectionsVisees.length} collections : '
    '$totalEnregistrementsSupprimes enregistrements supprimés.',
  );
  exit(codeSortieSucces);
}
