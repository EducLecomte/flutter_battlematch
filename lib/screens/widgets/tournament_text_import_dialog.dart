import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/new_recruit_import_service.dart';
import '../../services/pocketbase_data_service.dart';
import 'tournament_text_import_action_bar.dart';
import 'tournament_text_import_analysis_section.dart';
import 'tournament_text_import_team_selector.dart';

class TournamentTextImportDialog extends StatefulWidget {
  final String encounterId;
  final List<Armee> referenceArmies;
  final VoidCallback onImportCompleted;

  const TournamentTextImportDialog({
    super.key,
    required this.encounterId,
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
  String? _selectedTeamName;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() { super.initState(); _pasteController = TextEditingController(); }

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

    final List<String> teamNames = players
        .map((player) => player['teamName'] as String)
        .toSet()
        .toList();

    setState(() {
      _errorMessage = null;
      _importedPlayers = players;
      _detectedTeamNames = teamNames;
      _selectedTeamName = teamNames.isNotEmpty ? teamNames.first : null;
    });
  }

  Future<void> _confirmImport() async {
    if (_selectedTeamName == null || _importedPlayers.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> selectedPlayers = _importedPlayers
          .where((player) => player['teamName'] == _selectedTeamName)
          .toList();

      for (final Map<String, dynamic> player in selectedPlayers) {
        final Armee? resolvedArmy = NewRecruitImportService.instance
            .findArmeeByName(player['armyName'] as String, widget.referenceArmies);

        if (resolvedArmy == null) continue;

        await PocketbaseDataService.instance.createOpponent(
          widget.encounterId,
          resolvedArmy.id,
          player['playerName'] as String,
          player['listText'] as String,
        );
      }

      widget.onImportCompleted();
      if (mounted) Navigator.of(context).pop();
    } catch (exceptionImport) {
      if (mounted) setState(() => _errorMessage = 'Erreur : $exceptionImport');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _selectedPlayerCount => _importedPlayers
      .where((player) => player['teamName'] == _selectedTeamName)
      .length;

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
              const Text('Importer un tournoi depuis un texte',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TournamentTextImportAnalysisSection(
                pasteController: _pasteController,
                errorMessage: _errorMessage,
                onAnalyze: _analyzeTournamentText,
              ),
              if (_importedPlayers.isNotEmpty) ...[
                const SizedBox(height: 16),
                TournamentTextImportTeamSelector(
                  availableTeamNames: _detectedTeamNames,
                  selectedTeamName: _selectedTeamName,
                  playerCountForSelectedTeam: _selectedPlayerCount,
                  onTeamChanged: (teamName) =>
                      setState(() => _selectedTeamName = teamName),
                ),
              ],
              const SizedBox(height: 20),
              TournamentTextImportActionBar(
                isLoading: _isLoading,
                canImport: _selectedTeamName != null,
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
