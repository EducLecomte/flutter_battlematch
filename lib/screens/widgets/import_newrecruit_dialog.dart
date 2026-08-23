// ===========================================================================
// Dialogue d'Importation New Recruit (import_newrecruit_dialog.dart)
// Gère l'importation via l'API directe ou le copier-coller manuel.
// Permet de choisir l'équipe adverse parmi celles détectées.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'import_newrecruit_api_failure_dialog.dart';
import 'import_newrecruit_controller.dart';
import 'import_newrecruit_import_tabs.dart';
import 'import_newrecruit_loading_indicator.dart';
import 'import_newrecruit_team_selector.dart';

class ImportNewRecruitDialog extends StatefulWidget {
  final String rencontreId;
  final List<Armee> armeesReference;
  final VoidCallback onImportCompleted;

  const ImportNewRecruitDialog({
    super.key,
    required this.rencontreId,
    required this.armeesReference,
    required this.onImportCompleted,
  });

  @override
  State<ImportNewRecruitDialog> createState() => _ImportNewRecruitDialogState();
}

class _ImportNewRecruitDialogState extends State<ImportNewRecruitDialog> {
  final ImportNewRecruitController _controller = ImportNewRecruitController();

  // Contrôleurs pour l'import automatique
  final _tournamentIdController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  // Contrôleur pour le copier-coller manuel
  final _manualTextController = TextEditingController();

  void _notifyStateChanged() {
    if (mounted) setState(() {});
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Lance l'importation automatique via l'API
  Future<void> _runApiImport() async {
    final result = await _controller.runApiImport(
      tournamentId: _tournamentIdController.text,
      login: _loginController.text,
      password: _passwordController.text,
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (result is ImportNewRecruitApiImportError) {
      await showImportNewRecruitApiFailureDialog(context);
    } else if (result != null) {
      _showSnackBar(result as String);
    }
  }

  // Lance l'importation via le copier-coller manuel
  Future<void> _runManualImport() async {
    final errorMessage = await _controller.runManualImport(
      content: _manualTextController.text,
      armeesReference: widget.armeesReference,
      onStateChanged: _notifyStateChanged,
    );
    if (errorMessage != null && mounted) {
      _showSnackBar(errorMessage);
    }
  }

  // Valide l'importation finale de l'équipe sélectionnée
  Future<void> _confirmImport() async {
    final errorMessage = await _controller.confirmImport(
      rencontreId: widget.rencontreId,
      armeesReference: widget.armeesReference,
      onImportCompleted: widget.onImportCompleted,
      onStateChanged: _notifyStateChanged,
    );
    if (!mounted) return;

    if (errorMessage == null) {
      Navigator.of(context).pop(); // Ferme le dialogue
    } else {
      _showSnackBar(errorMessage);
    }
  }

  @override
  void dispose() {
    _tournamentIdController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    _manualTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDetectedTeams = _controller.detectedTeams.isNotEmpty;
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download, color: Colors.blueAccent),
          SizedBox(width: 12),
          Text("Importation depuis New Recruit"),
        ],
      ),
      content: _controller.isLoading
          ? ImportNewRecruitLoadingIndicator(
              statusText: _controller.statusText,
            )
          : SizedBox(
              width: 500,
              height: 450,
              child: hasDetectedTeams
                  ? ImportNewRecruitTeamSelector(
                      controller: _controller,
                      onTeamChanged: (teamName) {
                        if (teamName == null) return;
                        _controller.selectedTeamToImport = teamName;
                        setState(() {});
                      },
                    )
                  : ImportNewRecruitImportTabs(
                      tournamentIdController: _tournamentIdController,
                      loginController: _loginController,
                      passwordController: _passwordController,
                      manualTextController: _manualTextController,
                      onRunApiImport: _runApiImport,
                      onRunManualImport: _runManualImport,
                    ),
            ),
      actions: [
        if (hasDetectedTeams) ...[
          TextButton(
            onPressed: () {
              // Retourner à l'étape 1
              _controller.resetToStepOne();
              setState(() {});
            },
            child: const Text("Retour"),
          ),
          ElevatedButton(
            onPressed: _confirmImport,
            child: const Text("Importer cette équipe"),
          ),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fermer"),
          ),
        ],
      ],
    );
  }
}
