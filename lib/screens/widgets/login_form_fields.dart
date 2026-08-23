import 'package:flutter/material.dart';

/// Champs du formulaire de connexion / inscription
/// (email, mot de passe, et pseudo + initiales en mode inscription).
class LoginFormFields extends StatelessWidget {
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nomController;
  final TextEditingController shortController;

  const LoginFormFields({
    super.key,
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.nomController,
    required this.shortController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Champ E-mail
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Adresse email",
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Veuillez renseigner votre email";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Champ Mot de passe
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Mot de passe",
            prefixIcon: Icon(Icons.lock_outline),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Veuillez renseigner votre mot de passe";
            }
            if (value.length < 6) {
              return "Le mot de passe doit faire au moins 6 caractères";
            }
            return null;
          },
        ),

        // Champs supplémentaires uniquement en cas d'inscription
        if (isSignUp) ...[
          const SizedBox(height: 16),

          // Champ Nom / Pseudo
          TextFormField(
            controller: nomController,
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
          const SizedBox(height: 16),

          // Champ Initiales (court)
          TextFormField(
            controller: shortController,
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: "Initiales (Max 6 lettres)",
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
              helperText: "Exemple: Zur, Mando ...",
            ),
            validator: (value) {
              if (isSignUp && (value == null || value.trim().isEmpty)) {
                return "Veuillez renseigner vos initiales";
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
