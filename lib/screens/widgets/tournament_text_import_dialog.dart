import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/new_recruit_import_service.dart';
import '../../services/tournament_text_import_service.dart';
import 'tournament_text_import_action_bar.dart';
import 'tournament_text_import_analysis_section.dart';

class TournamentTextImportDialog extends StatefulWidget {
  final String tournoiId;
  final String targetTeamId;
  final String targetTeamName;
  final List<Armee> referenceArmies;
  final ValueChanged<TournamentTextImportSummary> onImportCompleted;

  const TournamentTextImportDialog({
    super.key,
    required this.tournoiId,
    required this.targetTeamId,
    required this.targetTeamName,
    required this.referenceArmies,
    required this.onImportCompleted,
  });

  @override
  State<TournamentTextImportDialog> createState() =>
      _TournamentTextImportDialogState();
}

class _TournamentTextImportDialogState
    extends State<TournamentTextImportDialog> {
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

  void _analyzeTournamentText() {
    final List<Map<String, dynamic>> players =
        NewRecruitImportService.instance.parseNewRecruitContent(
      _pasteController.text,
      widget.referenceArmies,
    );

    if (players.isEmpty) {
      setState(() => _errorMessage = 'Aucun joueur détecté dans le texte.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _importedPlayers = players;
      _detectedTeamNames = players
          .map((player) => player['teamName'] as String)
          .toSet()
          .toList();
    });
  }

  Future<void> _confirmImport() async {
    if (_importedPlayers.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final TournamentTextImportSummary importSummary =
          await TournamentTextImportService.instance.importTournamentText(
        tournoiId: widget.tournoiId,
        targetTeamId: widget.targetTeamId,
        targetTeamName: widget.targetTeamName,
        importedPlayers: _importedPlayers,
        referenceArmies: widget.referenceArmies,
      );

      if (importSummary.createdOpponentTeamCount +
          importSummary.createdOpponentCount +
          importSummary.skippedDuplicateTeamCount ==
          0) {
        if (mounted) {
          setState(() => _errorMessage =
              "Aucune équipe détectée à importer pour ce tournoi.");
        }
        return;
      }

      widget.onImportCompleted(importSummary);
      if (mounted) Navigator.of(context).pop();
    } catch (exceptionImport) {
      if (mounted) setState(() => _errorMessage = 'Erreur : $exceptionImport');
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
              const Text(
                  'Importer un tournoi depuis un texte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TournamentTextImportAnalysisSection(
                pasteController: _pasteController,
                errorMessage: _errorMessage,
                onAnalyze: _analyzeTournamentText,
              ),
              if (_importedPlayers.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${_detectedTeamNames.length} équipe(s) et '
                  '${_importedPlayers.length} joueur(s) prêts à importer. '
                  'L\'équipe cible « ${widget.targetTeamName} » est ignorée.',
                ),
              ],
              const SizedBox(height: 20),
              TournamentTextImportActionBar(
                isLoading: _isLoading,
                canImport: _importedPlayers.isNotEmpty,
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
