import 'dart:io';

import 'package:flutter_metawar/config/app_config.dart';
import 'package:pocketbase/pocketbase.dart';

const String collectionNameSuperusers = '_superusers';
const int codeSortieSucces = 0;
const int codeSortieArgumentsManquants = 64;
const int codeSortieAuthentificationEchouee = 65;
const int codeSortieEchecPocketBase = 66;

String? extraireValeurArgument(List<String> arguments, String cle) {
  final int position = arguments.indexOf(cle);
  if (position < 0 || position + 1 >= arguments.length) {
    return null;
  }
  return arguments[position + 1];
}

bool contientArgument(List<String> arguments, String argument) {
  return arguments.contains(argument);
}

Never echouerArgumentsManquants(String message) {
  stderr.writeln(message);
  exit(codeSortieArgumentsManquants);
}

Never echouerEcriturePocketBase(
  String contexte,
  ClientException exceptionPocketBase,
) {
  stderr.writeln('$contexte : ${exceptionPocketBase.response}');
  exit(codeSortieEchecPocketBase);
}

Future<PocketBase> connecterClientSuperuser(List<String> arguments) async {
  final String? emailSuperuser =
      extraireValeurArgument(arguments, '--email') ??
      Platform.environment['PB_SUPERUSER_EMAIL'];
  final String? motDePasseSuperuser =
      extraireValeurArgument(arguments, '--password') ??
      Platform.environment['PB_SUPERUSER_PASSWORD'];

  if (emailSuperuser == null || motDePasseSuperuser == null) {
    echouerArgumentsManquants(
      'Identifiants super-utilisateur manquants. '
      'Fournir --email/--password ou PB_SUPERUSER_EMAIL/PB_SUPERUSER_PASSWORD.',
    );
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
    exit(codeSortieAuthentificationEchouee);
  }
  return clientPocketBase;
}

Future<int> supprimerTousLesEnregistrements(
  PocketBase clientPocketBase,
  String nomCollection,
) async {
  final List<RecordModel> enregistrements = await clientPocketBase
      .collection(nomCollection)
      .getFullList(fields: 'id');
  for (final RecordModel enregistrement in enregistrements) {
    await clientPocketBase.collection(nomCollection).delete(enregistrement.id);
  }
  return enregistrements.length;
}
