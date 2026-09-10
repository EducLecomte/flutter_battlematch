import 'package:flutter/material.dart';

import '../../config/app_config.dart';

/// En-tête de marque de l'écran de connexion
/// (icône, titre de l'application et sous-titre selon le mode).
class LoginBrandHeader extends StatelessWidget {
  final bool isSignUp;

  const LoginBrandHeader({super.key, required this.isSignUp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Icon(Icons.auto_mode, size: 64, color: Colors.blueAccent),
        const SizedBox(height: 16),
        Text(
          "MATCH MAKER",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          appTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          isSignUp ? "Création de compte" : "Connexion Capitaine & Joueurs",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
