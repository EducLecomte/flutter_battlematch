// ===========================================================================
// Écran des Tournois (tournois_screen.dart)
// Permet de lister, d'ajouter et de supprimer des tournois.
// Redirige vers la sélection de rencontre.
// ===========================================================================

import 'package:flutter/material.dart';

import 'teams_screen.dart'; // Écran des rencontres (matchs)
import 'tournois_controller.dart';
import 'widgets/tournoi_add_dialog.dart';
import 'widgets/tournoi_card.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
    if (_controller.nomController.text.trim().isEmpty) return;

    final errorMessage = await _controller.addTournoi(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTournoiDialog,
        child: const Icon(Icons.add),
      ),
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
                      onDeleteTournoi: _handleDeleteTournoi,
                      onOpenTournoi: () {
                        // Au clic, on navigue vers la sélection de rencontre
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TeamsScreen(tournoi: tournoi),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
