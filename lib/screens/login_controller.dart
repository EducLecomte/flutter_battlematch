// ===========================================================================
// Contrôleur de l'écran de Connexion / Inscription (login_controller.dart)
// Détient l'état du formulaire (mode, champs, chargement) et pilote la
// soumission vers PocketBase.
// ===========================================================================

import 'package:flutter/material.dart';

import '../services/pocketbase_data_service.dart';

class LoginController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Clé du formulaire pour les validations
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Contrôleurs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomController =
      TextEditingController(); // Pseudo (utilisé à l'inscription)
  // Le champ d'initiales a été retiré : `short` est généré automatiquement
  // à partir du pseudo lors de l'inscription.

  // Indique si on est en mode Inscription (true) ou Connexion (false)
  bool isSignUp = false;

  // Indique si une requête est en cours (pour afficher le spinner)
  bool isLoading = false;

  // Bascule entre les modes Connexion et Inscription
  void toggleMode() {
    isSignUp = !isSignUp;
  }

  // Valide le formulaire. Retourne true si tous les champs sont valides.
  bool validate() {
    final FormState? formState = formKey.currentState;
    if (formState == null) return false;
    return formState.validate();
  }

  // Soumet le formulaire (Connexion ou Inscription).
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> submit({required VoidCallback onStateChanged}) async {
    isLoading = true;
    onStateChanged();

    try {
      if (isSignUp) {
        // Enregistrement d'un nouvel utilisateur
        await _pocketbaseService.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          nom: nomController.text.trim(),
        );

        // Bascule automatique en mode connexion après inscription
        isSignUp = false;
      } else {
        // Connexion de l'utilisateur existant
        await _pocketbaseService.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        // PocketBase met à jour l'authStore et l'AuthGate redirige
        // automatiquement
      }
      return null;
    } catch (submitError) {
      return "Erreur : ${submitError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Libère les contrôleurs de texte.
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nomController.dispose();
  }
}
