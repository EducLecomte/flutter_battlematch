import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      action: SnackBarAction(
        label: 'Copier',
        onPressed: () async {
          try {
            await Clipboard.setData(ClipboardData(text: messageError));
            messenger.showSnackBar(
              const SnackBar(content: Text('Erreur copiée.')),
            );
          } catch (copyError) {
            debugPrint('MetaWar error copy: $copyError');
            messenger.showSnackBar(
              SnackBar(content: Text('Impossible de copier : $copyError')),
            );
          }
        },
      ),
    ),
  );
}
