// ===========================================================================
// Boîte de dialogue d'import des équipes d'un tournoi (admin).
// Analyse un contenu New Recruit puis crée les équipes manquantes.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/new_recruit_import_service.dart';
import '../../services/pocketbase_data_service.dart';
import '../../services/tournament_team_import_service.dart';
import 'tournament_text_import_action_bar.dart';
import 'tournament_text_import_analysis_section.dart';

class TournoiTeamImportDialog extends StatefulWidget {
  final String tournoiId;
  final String tournoiNom;
  final List<Armee> referenceArmies;
  final ValueChanged<TournamentTeamImportSummary> onImportCompleted;

  const TournoiTeamImportDialog({
    super.key,
    required this.tournoiId,
    required this.tournoiNom,
    required this.referenceArmies,
    required this.onImportCompleted,
  });

  @override
  State<TournoiTeamImportDialog> createState() =>
      _TournoiTeamImportDialogState();
}

class _TournoiTeamImportDialogState extends State<TournoiTeamImportDialog> {
  late final TextEditingController _pasteController;
  List<Map<String, dynamic>> _importedPlayers = [];
  List<String> _detectedTeamNames = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pasteController = TextEditingController();
  }

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  void _analyzeContent() {
    final List<Map<String, dynamic>> players =
        NewRecruitImportService.instance.parseNewRecruitContent(
      _pasteController.text,
      widget.referenceArmies,
    );

    if (players.isEmpty) {
      setState(() => _errorMessage = 'Aucune équipe détectée dans le contenu.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _importedPlayers = players;
      _detectedTeamNames = players
          .map((player) => (player['teamName'] as String? ?? '').trim())
          .where((teamName) => teamName.isNotEmpty)
          .toSet()
          .toList();
    });
  }

  Future<void> _confirmImport() async {
    if (_importedPlayers.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final TournamentTeamImportSummary importSummary =
          await PocketbaseDataService.instance.importTeamsForTournoi(
        tournoiId: widget.tournoiId,
        importedPlayers: _importedPlayers,
      );

      widget.onImportCompleted(importSummary);
      if (mounted) Navigator.of(context).pop();
    } catch (importError) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur : $importError');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Importer les équipes de « ${widget.tournoiNom} »',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TournamentTextImportAnalysisSection(
                pasteController: _pasteController,
                errorMessage: _errorMessage,
                onAnalyze: _analyzeContent,
              ),
              if (_detectedTeamNames.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${_detectedTeamNames.length} équipe(s) détectée(s). '
                  'Les équipes déjà présentes seront ignorées.',
                ),
              ],
              const SizedBox(height: 20),
              TournamentTextImportActionBar(
                isLoading: _isLoading,
                canImport: _detectedTeamNames.isNotEmpty,
                onCancel: () => Navigator.of(context).pop(),
                onImport: _confirmImport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
