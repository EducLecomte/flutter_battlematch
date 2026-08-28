// ===========================================================================
// Écran d'administration MetaWar (admin_screen.dart)
// Trois onglets : Armées, Appréciations, Joueurs. Réservé aux comptes
// marqués `admin` (accès depuis l'écran de Profil).
// ===========================================================================

import 'package:flutter/material.dart';

import '../utils/error_snack_bar_presenter.dart';
import 'admin_controller.dart';
import 'widgets/admin_armees_tab.dart';
import 'widgets/admin_choix_tab.dart';
import 'widgets/admin_joueurs_tab.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final AdminController _controller = AdminController();

  /// Nombre d'onglets de l'écran d'administration.
  static const int nombreOnglets = 3;

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message, {required bool isFailure}) {
    if (isFailure) {
      showErrorSnackBar(context, message);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _loadAdministration() async {
    final String? errorMessage = await _controller.loadAdministration(
      onStateChanged: _notifyStateChanged,
    );
    if (errorMessage != null && mounted) {
      _showMessage(errorMessage, isFailure: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAdministration();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Administration")),
      body: DefaultTabController(
        length: nombreOnglets,
        child: Column(
          children: [
            const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: "Armées"),
                Tab(text: "Appréciations"),
                Tab(text: "Joueurs"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AdminArmeesTab(
                    controller: _controller,
                    onStateChanged: _notifyStateChanged,
                    onMessage: (String message, bool isFailure) =>
                        _showMessage(message, isFailure: isFailure),
                  ),
                  AdminChoixTab(
                    controller: _controller,
                    onStateChanged: _notifyStateChanged,
                    onMessage: (String message, bool isFailure) =>
                        _showMessage(message, isFailure: isFailure),
                  ),
                  AdminJoueursTab(
                    controller: _controller,
                    onStateChanged: _notifyStateChanged,
                    onMessage: (String message, bool isFailure) =>
                        _showMessage(message, isFailure: isFailure),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
