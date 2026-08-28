import 'dart:io';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:pocketbase/pocketbase.dart';

import 'pocketbase_tool_support.dart';

const List<Map<String, String>> comptesTestMetaWar = [
  {
    'email': 'test1@pedagogeek.fr',
    'nom': 'Joueur Test 1',
    'motDePasse': 'Test1!23',
  },
  {
    'email': 'test2@pedagogeek.fr',
    'nom': 'Joueur Test 2',
    'motDePasse': 'Test2!23',
  },
  {
    'email': 'test3@pedagogeek.fr',
    'nom': 'Joueur Test 3',
    'motDePasse': 'Test3!23',
  },
  {
    'email': 'test4@pedagogeek.fr',
    'nom': 'Joueur Test 4',
    'motDePasse': 'Test4!23',
  },
];

Future<void> main(List<String> arguments) async {
  final PocketBase clientPocketBase = await connecterClientSuperuser(arguments);
  var nombreComptesCrees = 0;
  var nombreComptesMisesAJour = 0;

  try {
    for (final Map<String, String> definitionCompte in comptesTestMetaWar) {
      final String emailCompte = definitionCompte['email']!;
      final List<RecordModel> comptesExistants = await clientPocketBase
          .collection(collectionNameJoueurs)
          .getFullList(filter: 'email = "$emailCompte"');

      if (comptesExistants.isEmpty) {
        await clientPocketBase
            .collection(collectionNameJoueurs)
            .create(
              body: <String, dynamic>{
                'email': emailCompte,
                'password': definitionCompte['motDePasse'],
                'passwordConfirm': definitionCompte['motDePasse'],
                'nom': definitionCompte['nom'],
                'admin': false,
              },
            );
        nombreComptesCrees++;
      } else {
        await clientPocketBase
            .collection(collectionNameJoueurs)
            .update(
              comptesExistants.first.id,
              body: <String, dynamic>{
                'password': definitionCompte['motDePasse'],
                'passwordConfirm': definitionCompte['motDePasse'],
                'nom': definitionCompte['nom'],
                'admin': false,
              },
            );
        nombreComptesMisesAJour++;
      }
    }
  } on ClientException catch (exceptionPocketBase) {
    echouerEcriturePocketBase(
      'Échec de création ou mise à jour des comptes de test',
      exceptionPocketBase,
    );
  }

  stdout.writeln(
    'Comptes de test terminés : '
    'créés=$nombreComptesCrees, mis à jour=$nombreComptesMisesAJour.',
  );
  for (final Map<String, String> definitionCompte in comptesTestMetaWar) {
    stdout.writeln(
      '  ${definitionCompte['email']} : ${definitionCompte['motDePasse']}',
    );
  }
  exit(codeSortieSucces);
}
