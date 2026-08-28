// ===========================================================================
// Écran des Tournois (tournois_screen.dart)
// Permet de lister, d'ajouter et de supprimer des tournois.
// Redirige vers la sélection de rencontre.
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../services/tournament_team_import_service.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen.dart'; // Écran des rencontres (matchs)
import 'tournois_controller.dart';
import 'widgets/tournoi_add_dialog.dart';
import 'widgets/tournoi_card.dart';
import 'widgets/tournoi_team_import_dialog.dart';

class TournoisScreen extends StatefulWidget {
  const TournoisScreen({super.key});

  @override
  State<TournoisScreen> createState() => _TournoisScreenState();
}

class _TournoisScreenState extends State<TournoisScreen> {
  final TournoiController _controller = TournoiController();

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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  // Charge la liste des tournois depuis PocketBase
  Future<void> _loadTournois() async {
    final errorMessage = await _controller.loadTournois(
      onStateChanged: _notifyStateChanged,
    );
    if (errorMessage != null && mounted) {
      _showErrorSnackBar(errorMessage);
    }
  }

  // Crée un nouveau tournoi, puis ferme la boîte de dialogue
  Future<void> _handleAddTournoi() async {
    final String? errorMessage = await _controller.addTournoi(
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (errorMessage != null) {
      _showErrorSnackBar(errorMessage);
      return;
    }

    Navigator.of(context).pop(); // Ferme la boîte de dialogue
    _showSuccessSnackBar("Tournoi ajouté !");
    await _loadTournois();
  }

  // Ouvre un tournoi si l'import des équipes est déjà effectué.
  Future<void> _handleOpenTournoi(Tournoi tournoi) async {
    if (!tournoi.importEffectue && !_controller.estAdministrateur) {
      _showInfoSnackBar(
        "L'import des équipes est requis avant d'ouvrir ce tournoi.",
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeamsScreen(tournoi: tournoi),
      ),
    );
  }

  // Ouvre la boîte de dialogue d'import des équipes d'un tournoi.
  Future<void> _showTeamImportDialog(Tournoi tournoi) async {
    final List<Armee> referenceArmies =
        await PocketbaseDataService.instance.getArmees();
    if (!mounted) return;

    TournamentTeamImportSummary? importSummary;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => TournoiTeamImportDialog(
        tournoiId: tournoi.id,
        tournoiNom: tournoi.nom,
        referenceArmies: referenceArmies,
        onImportCompleted: (summary) => importSummary = summary,
      ),
    );
    if (!mounted) return;

    final TournamentTeamImportSummary? completedImportSummary = importSummary;
    if (completedImportSummary == null) return;

    _showSuccessSnackBar(
      "Import terminé : ${completedImportSummary.createdTeamCount} "
      "équipe(s) créée(s), "
      "${completedImportSummary.skippedExistingTeamCount} ignorée(s).",
    );
    await _loadTournois();
  }

  // Supprime un tournoi et actualise la liste
  Future<void> _handleDeleteTournoi(String tournoiId) async {
    final errorMessage = await _controller.deleteTournoi(tournoiId);
    if (!mounted) return;

    if (errorMessage != null) {
      _showErrorSnackBar(errorMessage);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tournoi supprimé.")),
    );
    await _loadTournois();
  }

  // Ouvre la boîte de dialogue d'ajout de tournoi
  void _showAddTournoiDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => TournoiAddDialog(
        tournoiController: _controller,
        onAddSubmitted: _handleAddTournoi,
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
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.tournois.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun tournoi enregistré. Ajoutez-en un !",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _controller.tournois.length,
                  itemBuilder: (context, index) {
                    final tournoi = _controller.tournois[index];

                    return TournoiCard(
                      tournoi: tournoi,
                      estAdministrateur: _controller.estAdministrateur,
                      onDeleteTournoi: _controller.estAdministrateur
                          ? _handleDeleteTournoi
                          : null,
                      onOpenTournoi: () => _handleOpenTournoi(tournoi),
                      onImportTeams: _controller.estAdministrateur &&
                              !tournoi.importEffectue
                          ? () => _showTeamImportDialog(tournoi)
                          : null,
                    );
                  },
                ),
    );
  }
}
