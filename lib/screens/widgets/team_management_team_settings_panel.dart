// ===========================================================================
// Paramètres capitaine d'une équipe (team_management_team_settings_panel.dart)
// Gère le mot de passe d'accès et le transfert de la capitainerie.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../team_management_controller.dart';

class TeamManagementTeamSettingsPanel extends StatefulWidget {
  final TeamManagementController controller;
  final ValueChanged<String> onUpdateMotDePasse;
  final ValueChanged<Joueur> onNominateCaptain;

  const TeamManagementTeamSettingsPanel({
    super.key,
    required this.controller,
    required this.onUpdateMotDePasse,
    required this.onNominateCaptain,
  });

  @override
  State<TeamManagementTeamSettingsPanel> createState() =>
      _TeamManagementTeamSettingsPanelState();
}

class _TeamManagementTeamSettingsPanelState
    extends State<TeamManagementTeamSettingsPanel> {
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(
      text: widget.controller.selectedTeam?.motDePasse ?? '',
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  List<Joueur> get _captainCandidates =>
      widget.controller.captainCandidates;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paramètres capitaine",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe d'accès",
                      border: OutlineInputBorder(),
                      helperText:
                          "Laissez vide pour désactiver le join par mot de passe.",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  child: const Text("Enregistrer"),
                  onPressed: () =>
                      widget.onUpdateMotDePasse(_passwordController.text),
                ),
              ],
            ),
            if (_captainCandidates.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                "Transférer la capitainerie",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final Joueur candidate in _captainCandidates)
                    OutlinedButton(
                      child: Text(candidate.nom),
                      onPressed: () => widget.onNominateCaptain(candidate),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
