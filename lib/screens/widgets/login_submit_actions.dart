import 'package:flutter/material.dart';

/// Actions du formulaire de connexion : bouton de validation principal
/// et bouton de bascule Connexion / Inscription.
class LoginSubmitActions extends StatelessWidget {
  final bool isLoading;
  final bool isSignUp;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  const LoginSubmitActions({
    super.key,
    required this.isLoading,
    required this.isSignUp,
    required this.onSubmit,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bouton de Validation principal
        ElevatedButton(
          onPressed: isLoading ? null : onSubmit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  isSignUp ? "S'inscrire" : "Se connecter",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Bouton pour basculer entre Connexion et Inscription
        TextButton(
          onPressed: isLoading ? null : onToggleMode,
          child: Text(
            isSignUp
                ? "Déjà inscrit ? Connectez-vous"
                : "Pas encore de compte ? Inscrivez-vous",
          ),
        ),
      ],
    );
  }
}
