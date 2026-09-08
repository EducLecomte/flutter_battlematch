// ===========================================================================
// Écran des Tournois (tournois_screen.dart)
// Permet de lister, d'ajouter, de modifier et de supprimer des tournois.
// Redirige vers la sélection d'équipe adverse.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/models.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'refreshable_screen.dart';
import 'teams_screen.dart'; // Écran des équipes adverses
import 'tournoi_team_import_actions.dart';
import 'tournois_controller.dart';
import 'widgets/tournoi_add_dialog.dart';
import 'widgets/tournoi_edit_dialog.dart';
import 'widgets/tournoi_list_body.dart';

class TournoisScreen extends StatefulWidget {
  const TournoisScreen({super.key});

  @override
  State<TournoisScreen> createState() => _TournoisScreenState();
}

class _TournoisScreenState extends RefreshableScreenState<TournoisScreen> {
  final TournoiController _controller = TournoiController();

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  // Recharge la liste des tournois : appelé par HomeShell quand l'onglet
  // devient actif dans la barre du bas.
  @override
  void refreshOnTabActivated() {
    _loadTournois();
  }

  void _showInfoSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: snackBarDisplayDuration,
      ),
    );
  }

  // Charge la liste des tournois depuis PocketBase
  Future<void> _loadTournois() async {
    final errorMessage = await _controller.loadTournois(
      onStateChanged: _notifyStateChanged,
    );
    if (errorMessage != null && mounted) {
      showErrorSnackBar(context, errorMessage);
    }
  }

  // Exécute une opération du contrôleur, affiche l'erreur ou le message de
  // succès, puis actualise la liste en cas de succès.
  Future<void> _runTournoiOperation(
    Future<String?> Function() operation,
    String successMessage, {
    bool closeDialog = false,
  }) async {
    final String? errorMessage = await operation();
    if (!mounted) return;
    if (errorMessage != null) {
      showErrorSnackBar(context, errorMessage);
      return;
    }
    if (closeDialog) Navigator.of(context).pop();
    _showInfoSnackBar(successMessage, Colors.green);
    await _loadTournois();
  }

  // Modifie un tournoi depuis la boîte de dialogue d'édition
  Future<void> _handleEditTournoi(Tournoi tournoi) async {
    final TournoiEditResult? editResult = await showTournoiEditDialog(
      context: context,
      tournoi: tournoi,
    );
    if (editResult == null) return;

    await _runTournoiOperation(
      () => _controller.updateTournoi(
        tournoi.id,
        editResult.nom,
      ),
      "Tournoi enregistré.",
    );
  }

  // Ouvre un tournoi si l'import des équipes est déjà effectué.
  Future<void> _handleOpenTournoi(Tournoi tournoi) async {
    if (!tournoi.importEffectue && !_controller.estAdministrateur) {
      _showInfoSnackBar(
        "L'import des équipes est requis avant d'ouvrir ce tournoi.",
        Colors.blueGrey,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => TeamsScreen(tournoi: tournoi)),
    );
  }

  // Ouvre la boîte de dialogue d'ajout de tournoi
  void _showAddTournoiDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => TournoiAddDialog(
        tournoiController: _controller,
        onAddSubmitted: () => _runTournoiOperation(
          () => _controller.addTournoi(onStateChanged: _notifyStateChanged),
          "Tournoi ajouté !",
          closeDialog: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTournois();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MetaWar Tournois"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTournois,
            tooltip: "Rafraîchir",
          ),
        ],
      ),
      floatingActionButton: _controller.estAdministrateur
          ? FloatingActionButton(
              onPressed: _showAddTournoiDialog,
              child: const Icon(Icons.add),
            )
          : null,
      body: TournoiListBody(
        isLoading: _controller.isLoading,
        tournois: _controller.tournois,
        estAdministrateur: _controller.estAdministrateur,
        tailleEquipeParTournoi: _controller.tailleEquipeParTournoi,
        onDeleteTournoi: (tournoiId) => _runTournoiOperation(
          () => _controller.deleteTournoi(tournoiId),
          "Tournoi supprimé.",
        ),
        onOpenTournoi: _handleOpenTournoi,
        onImportTeams: (tournoi) => showTournoiTeamImportDialog(
          context: context,
          tournoi: tournoi,
          onImportCompleted: _loadTournois,
        ),
        onEditTournoi: _handleEditTournoi,
      ),
    );
  }
}
