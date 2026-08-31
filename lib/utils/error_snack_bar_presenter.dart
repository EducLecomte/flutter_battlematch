import 'package:flutter/material.dart';

import '../config/app_config.dart';

void showErrorSnackBar(BuildContext buildContext, String messageError) {
  final ScaffoldMessengerState messenger = ScaffoldMessenger.of(buildContext);
  showErrorSnackBarUsingMessenger(messenger, messageError);
}

void showErrorSnackBarUsingMessenger(
    ScaffoldMessengerState messenger, String messageError) {
  debugPrint('MetaWar error: $messageError');

  messenger.showSnackBar(
    SnackBar(
      content: Text(messageError),
      backgroundColor: Colors.redAccent,
      duration: snackBarDisplayDuration,
    ),
  );
}
