import 'package:flutter/material.dart';

import '../../config/app_config.dart';

/// Champs du formulaire de connexion / inscription
/// (email, mot de passe, et pseudo en mode inscription).
/// Le champ d'initiales a été retiré : il est désormais généré
/// automatiquement à partir du pseudo.
/// La touche Entrée sur un champ déclenche [onSubmit] (MEMO 9).
class LoginFormFields extends StatelessWidget {
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nomController;

  /// Action de soumission du formulaire, invoquée quand l'utilisateur
  /// valide un champ avec la touche Entrée.
  final VoidCallback onSubmit;

  const LoginFormFields({
    super.key,
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.nomController,
    required this.onSubmit,
  });

  /// Valide le format de l'adresse email.
  String? _validerEmail(String? value) {
    final String? email = value?.trim();
    if (email == null || email.isEmpty) {
      return "Veuillez renseigner votre email";
    }
    if (!emailValidationPattern.hasMatch(email)) {
      return "Adresse email invalide";
    }
    return null;
  }

  /// Valide le mot de passe : simple non-vide en connexion,
  /// règles complètes (longueur, majuscule, caractère spécial) à l'inscription.
  String? _validerMotDePasse(String? value) {
    if (value == null || value.isEmpty) {
      return "Veuillez renseigner votre mot de passe";
    }
    if (!isSignUp) return null;
    if (value.length < passwordMinimumLength) {
      return "Au moins $passwordMinimumLength caractères";
    }
    if (!passwordUppercasePattern.hasMatch(value)) {
      return "Au moins une majuscule";
    }
    if (!passwordSpecialCharacterPattern.hasMatch(value)) {
      return "Au moins un caractère spécial";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Champ E-mail
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(
            labelText: "Adresse email",
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          validator: _validerEmail,
        ),
        const SizedBox(height: 16),

        // Champ Mot de passe
        TextFormField(
          controller: passwordController,
          obscureText: true,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: InputDecoration(
            labelText: "Mot de passe",
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: isSignUp
                ? Tooltip(
                    message:
                        "$passwordMinimumLength caractères minimum, au moins "
                        "une majuscule et un caractère spécial.",
                    child: const Icon(Icons.info_outline),
                  )
                : null,
          ),
          validator: _validerMotDePasse,
        ),

        // Champs supplémentaires uniquement en cas d'inscription
        if (isSignUp) ...[
          const SizedBox(height: 16),

          // Champ Nom / Pseudo
          TextFormField(
            controller: nomController,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: "Nom / Pseudo",
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (isSignUp && (value == null || value.trim().isEmpty)) {
                return "Veuillez renseigner votre pseudo";
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
