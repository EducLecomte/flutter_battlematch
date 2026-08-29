import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      action: SnackBarAction(
        label: 'Copier',
        onPressed: () async {
          try {
            await Clipboard.setData(ClipboardData(text: messageError));
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Erreur copiée.'),
                duration: snackBarDisplayDuration,
              ),
            );
          } catch (copyError) {
            debugPrint('MetaWar error copy: $copyError');
            messenger.showSnackBar(
              SnackBar(
                content: Text('Impossible de copier : $copyError'),
                duration: snackBarDisplayDuration,
              ),
            );
          }
        },
      ),
    ),
  );
}
