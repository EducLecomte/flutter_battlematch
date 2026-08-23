// ===========================================================================
// Écran de Profil & Invitations (profile_screen.dart)
// Permet de modifier son profil et de répondre aux invitations d'équipes.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import 'profile_controller.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/profile_invitations_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController _controller = ProfileController();

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        actions: [
          IconButton(
            onPressed: () => _controller.signOut(),
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
              shortController: _controller.shortController,
              isSaving: _controller.isSaving,
              onSave: _saveProfile,
            ),
            const SizedBox(height: 24),
            ProfileInvitationsSection(
              invitations: _controller.invitations,
              onRespondToInvite: _respondToInvite,
            ),
          ],
        ),
      ),
    );
  }
}
