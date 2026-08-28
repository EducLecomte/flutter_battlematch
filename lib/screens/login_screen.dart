// ===========================================================================
// Écran de Connexion / Inscription (login_screen.dart)
// Permet de s'authentifier via PocketBase ou de créer un compte avec profil.
// ===========================================================================

import 'package:flutter/material.dart';

import '../utils/error_snack_bar_presenter.dart';
import 'login_controller.dart';
import 'widgets/login_brand_header.dart';
import 'widgets/login_form_fields.dart';
import 'widgets/login_submit_actions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _controller = LoginController();

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  void _showErrorSnackBar(String message) {
    showErrorSnackBar(context, message);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Soumission du formulaire (Connexion ou Inscription)
  Future<void> _submit() async {
    if (!_controller.validate()) return;

    final bool wasInSignUpMode = _controller.isSignUp;
    final errorMessage = await _controller.submit(
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (errorMessage != null) {
      _showErrorSnackBar(errorMessage);
    } else if (wasInSignUpMode) {
      _showSuccessSnackBar(
        "Inscription réussie ! Un email de confirmation a été envoyé si "
        "configuré, sinon vous pouvez vous connecter.",
      );
    }
  }

  // Bascule entre les modes Connexion et Inscription
  void _toggleMode() {
    _controller.toggleMode();
    _notifyStateChanged();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Form(
                  key: _controller.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoginBrandHeader(isSignUp: _controller.isSignUp),
                      const SizedBox(height: 32),
                      LoginFormFields(
                        isSignUp: _controller.isSignUp,
                        emailController: _controller.emailController,
                        passwordController: _controller.passwordController,
                        nomController: _controller.nomController,
                      ),
                      const SizedBox(height: 24),
                      LoginSubmitActions(
                        isLoading: _controller.isLoading,
                        isSignUp: _controller.isSignUp,
                        onSubmit: _submit,
                        onToggleMode: _toggleMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
