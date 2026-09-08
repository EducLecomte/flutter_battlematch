import 'package:flutter/material.dart';

/// En-tête de marque de l'écran de connexion
/// (icône, titre METAWAR et sous-titre selon le mode).
class LoginBrandHeader extends StatelessWidget {
  final bool isSignUp;

  const LoginBrandHeader({super.key, required this.isSignUp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const Icon(
          Icons.query_stats_outlined,
          size: 64,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        Text(
          "METAWAR",
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: theme.colorScheme.primary,
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
