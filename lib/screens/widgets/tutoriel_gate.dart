// ===========================================================================
// Porte du tutoriel de bienvenue (tutoriel_gate.dart).
// Enveloppe l'application authentifiée : affiche le tutoriel (MEMO 10) à la
// première connexion sur l'appareil, puis plus jamais (drapeau local).
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import 'tutoriel_dialog.dart';

/// Affiche [child] et, à la première connexion (drapeau local absent),
/// présente le tutoriel de bienvenue avant de poser le drapeau.
class TutorielGate extends StatefulWidget {
  final Widget child;

  const TutorielGate({super.key, required this.child});

  @override
  State<TutorielGate> createState() => _TutorielGateState();
}

class _TutorielGateState extends State<TutorielGate> {
  @override
  void initState() {
    super.initState();
    // En attente de la première frame : le context (et son Navigator) doit
    // être prêt avant d'ouvrir un dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) => _verifierTutoriel());
  }

  Future<void> _verifierTutoriel() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    final bool tutorielDejaVu =
        preferences.getBool(sharedPreferencesKeyTutorielVu) ?? false;
    if (tutorielDejaVu || !mounted) return;

    await showTutorielDialog(context);
    if (!mounted) return;

    await preferences.setBool(sharedPreferencesKeyTutorielVu, true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
