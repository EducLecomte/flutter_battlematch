// ===========================================================================
// Section « Paramètres » de l'écran de Profil (profile_settings_section.dart).
// MEMO 11 : bascule clair/sombre, dialog « À propos » et re-visualisation du
// tutoriel de bienvenue.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../services/theme_controller.dart';
import 'tutoriel_dialog.dart';

/// Section « Paramètres » du profil (MEMO 11) :
/// - bascule mode clair/sombre (appliquée à toute l'application, persistée),
/// - dialog « À propos » de l'application,
/// - bouton de re-visualisation du tutoriel de bienvenue.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key});

  void _afficherAPropos(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: applicationName,
      applicationVersion: appVersion,
      applicationIcon: const Icon(
        Icons.emoji_events,
        size: 48,
        color: Colors.deepPurple,
      ),
      children: const [
        Text(
          'Outil de gestion de tournois The Ninth Age : estimations d\'équipe, '
          'matrice d\'appariement et suivi des adversaires, adossé à une '
          'instance PocketBase.',
        ),
      ],
    );
  }

  Future<void> _revoirTutoriel(BuildContext context) async {
    await showTutorielDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Paramètres',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              // La bascule réécoute le contrôleur pour refléter l'état courant
              // sans état local redondant.
              ListenableBuilder(
                listenable: ThemeController.instance,
                builder: (BuildContext context, Widget? child) {
                  final bool sombre =
                      ThemeController.instance.themeMode == ThemeMode.dark;
                  return SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Mode sombre'),
                    subtitle: const Text(
                      'Affichage de nuit de toute l\'application',
                    ),
                    value: sombre,
                    onChanged: (bool valeur) =>
                        ThemeController.instance.setThemeMode(
                          valeur ? ThemeMode.dark : ThemeMode.light,
                        ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('À propos de $applicationName'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _afficherAPropos(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('Revoir le tutoriel'),
                subtitle: const Text('Tour d\'horizon de l\'application'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _revoirTutoriel(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
