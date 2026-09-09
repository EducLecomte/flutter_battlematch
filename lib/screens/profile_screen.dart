// ===========================================================================
// Écran de Profil & Invitations (profile_screen.dart)
// Permet de modifier son profil et de répondre aux invitations d'équipes.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'admin_screen.dart';
import 'profile_controller.dart';
import 'refreshable_screen.dart';
import 'widgets/profile_account_management_section.dart';
import 'widgets/profile_delete_account_dialog.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_invitations_section.dart';
import 'widgets/profile_settings_section.dart';
import 'widgets/profile_teams_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends RefreshableScreenState<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  // Recharge le profil et les invitations : appelé par HomeShell quand
  // l'onglet devient actif dans la barre du bas.
  @override
  void refreshOnTabActivated() {
    _loadProfileAndInvitations();
  }

  void _showSnackBar(String message) {
    showErrorSnackBar(context, message);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: snackBarDisplayDuration,
      ),
    );
  }

  // Déconnecte puis remonte à la première route : si ce profil a été
  // ouvert par push depuis un autre écran, la route est refermée et
  // l'AuthGate peut afficher proprement l'écran de connexion.
  Future<void> _handleSignOut() async {
    await _controller.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final bool confirmed = await showProfileDeleteAccountConfirmation(context);
    if (confirmed && mounted) {
      final String? errorMessage = await _controller.deleteAccount();
      if (!mounted) return;
      if (errorMessage == null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showSnackBar(errorMessage);
      }
    }
  }

  // Charge les données de profil et les invitations
  Future<void> _loadProfileAndInvitations() async {
    final errorMessage = await _controller.loadProfileAndInvitations(
      onStateChanged: _notifyStateChanged,
    );
    if (errorMessage != null && mounted) {
      _showSnackBar(errorMessage);
    }
  }

  // Sauvegarde les modifications de profil
  Future<void> _saveProfile() async {
    final errorMessage = await _controller.saveProfile(
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (errorMessage != null) {
      _showSnackBar(errorMessage);
    } else {
      _showSuccessSnackBar("Profil mis à jour avec succès !");
    }
  }

  // Répond à une invitation (Accepter ou Refuser)
  Future<void> _respondToInvite(Team team, bool accept) async {
    final errorMessage = await _controller.respondToInvite(
      team.id,
      accept,
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (errorMessage != null) {
      _showSnackBar(errorMessage);
    } else {
      _showSuccessSnackBar(
        accept ? "Invitation acceptée !" : "Invitation refusée.",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileAndInvitations();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileInfoCard(
              email: _controller.joueur?.email ?? '',
              nomController: _controller.nomController,
              isSaving: _controller.isSaving,
              onSave: _saveProfile,
            ),

            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProfileTeamsSection(
                    userTeams: _controller.userTeams,
                    userTournois: _controller.userTournois,
                    currentUserId: _controller.joueur?.id,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ProfileInvitationsSection(
                    invitations: _controller.invitations,
                    onRespondToInvite: _respondToInvite,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const ProfileSettingsSection(),
            const SizedBox(height: 24),

            ProfileAccountManagementSection(
              isAdmin: _controller.joueur?.admin ?? false,
              onOpenAdmin: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (dialogContext) => const AdminScreen(),
                  ),
                );
              },
              onRequestAccountDeletion: _handleDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
