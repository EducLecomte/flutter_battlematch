// ===========================================================================
// Boîte de dialogue du tutoriel de bienvenue (tutoriel_dialog.dart).
// Tour d'horizon de l'application affiché à la première connexion (MEMO 10)
// et re-visionnable depuis les paramètres (MEMO 11).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';

/// Affiche le tutoriel de bienvenue. Bloquant (barrière non dismissible) :
/// l'utilisateur doit le valider pour continuer.
Future<void> showTutorielDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const TutorielDialog(),
  );
}

/// Tutoriel de bienvenue : un tour d'horizon des écrans principaux.
class TutorielDialog extends StatelessWidget {
  /// Largeur maximale du dialog.
  static const double _largeurMax = 540;

  /// Marge d'insertion autour du dialog.
  static const double _margeInset = 24;

  const TutorielDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Dialog ne borne pas la hauteur de son contenu : on limite la zone
    // défilante à la hauteur disponible pour que le dialog défile au lieu
    // de déborder de l'écran (écrans courts / contenus longs).
    final double hauteurMax =
        MediaQuery.sizeOf(context).height - 2 * _margeInset;
    return Dialog(
      insetPadding: const EdgeInsets.all(_margeInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _largeurMax,
          maxHeight: hauteurMax,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contenu défilant, borné à la hauteur disponible…
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 28,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Bienvenue sur $applicationName !',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Voici un tour d’horizon rapide pour vous familiariser '
                      'avec l’application.',
                    ),
                    const SizedBox(height: 16),
                    const _LigneTutoriel(
                      icone: Icons.emoji_events_outlined,
                      titre: 'Tournois',
                      texte:
                          'Consultez la liste des tournois et les tailles '
                          'd’équipe importées par les admins.',
                    ),
                    const _LigneTutoriel(
                      icone: Icons.group_outlined,
                      titre: 'Équipes',
                      texte:
                          'Choisissez votre équipe active, gérez les membres '
                          '(rôles joueur/coach, capitaine), et les invitations.',
                    ),
                    const _LigneTutoriel(
                      icone: Icons.table_chart_outlined,
                      titre: 'Tableau de bord',
                      texte:
                          'Matrice d’estimation en temps réel : pour chaque '
                          'adversaire, appréciation (7 niveaux), score 0–20, '
                          'confiance et commentaire.',
                    ),
                    const _LigneTutoriel(
                      icone: Icons.lock_outline,
                      titre: 'Mode capitaine',
                      texte:
                          'Verrouillez les appariements (un duel par joueur '
                          'et par adversaire) et estimez pour vos membres.',
                    ),
                    const _LigneTutoriel(
                      icone: Icons.person_outline,
                      titre: 'Profil',
                      texte:
                          'Vos équipes et tournois, les invitations en '
                          'attente, la déconnexion et la suppression de '
                          'compte.',
                    ),
                  ],
                ),
              ),
            ),
            // …et bouton de validation en pied fixe, toujours visible.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('C’est parti !'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une ligne du tutoriel : icône + titre en gras + description.
class _LigneTutoriel extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String texte;

  const _LigneTutoriel({
    required this.icone,
    required this.titre,
    required this.texte,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 22, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$titre : ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: [TextSpan(text: texte)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
