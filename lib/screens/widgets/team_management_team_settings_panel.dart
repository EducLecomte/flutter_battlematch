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
  final void Function(bool, bool, bool) onUpdateOptions;

  const TeamManagementTeamSettingsPanel({
    super.key,
    required this.controller,
    required this.onUpdateMotDePasse,
    required this.onNominateCaptain,
    required this.onUpdateOptions,
  });

  @override
  State<TeamManagementTeamSettingsPanel> createState() =>
      _TeamManagementTeamSettingsPanelState();
}

class _TeamManagementTeamSettingsPanelState
    extends State<TeamManagementTeamSettingsPanel> {
  late final TextEditingController _passwordController;
  late bool _membresVoirSynthese;
  late bool _membresMatcher;
  late bool _membresEditerEstims;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController(
      text: widget.controller.selectedTeam?.motDePasse ?? '',
    );
    final team = widget.controller.selectedTeam;
    if (team != null) {
      _membresVoirSynthese = team.membresVoirSynthese;
      _membresMatcher = team.membresMatcher;
      _membresEditerEstims = team.membresEditerEstims;
    } else {
      _membresVoirSynthese = false;
      _membresMatcher = false;
      _membresEditerEstims = false;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  List<Joueur> get _captainCandidates => widget.controller.captainCandidates;

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
            LayoutBuilder(
              builder: (context, constraints) {
                final passwordField = TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Mot de passe d'accès",
                    border: OutlineInputBorder(),
                    helperText: "Laissez vide pour désactiver le join par mot de passe.",
                  ),
                );
                final saveButton = FilledButton(
                  onPressed: () =>
                      widget.onUpdateMotDePasse(_passwordController.text),
                  child: const Text("Enregistrer"),
                );

                if (constraints.maxWidth < 600) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      passwordField,
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: saveButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: passwordField),
                    const SizedBox(width: 12),
                    saveButton,
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Permissions des membres",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text("Voir les colonnes Moy. / Δ"),
              subtitle: const Text("Permet aux membres (non-capitaines) de voir les colonnes Moy. / Δ."),
              value: _membresVoirSynthese,
              onChanged: (bool value) {
                setState(() {
                  _membresVoirSynthese = value;
                });
                widget.onUpdateOptions(
                  _membresVoirSynthese,
                  _membresMatcher,
                  _membresEditerEstims,
                );
              },
            ),
            SwitchListTile(
              title: const Text("Matcher les parties"),
              subtitle: const Text("Permet aux membres (non-capitaines) de matcher les parties."),
              value: _membresMatcher,
              onChanged: (bool value) {
                setState(() {
                  _membresMatcher = value;
                });
                widget.onUpdateOptions(
                  _membresVoirSynthese,
                  _membresMatcher,
                  _membresEditerEstims,
                );
              },
            ),
            SwitchListTile(
              title: const Text("Modifier les estimations des autres"),
              subtitle: const Text("Permet aux membres (non-capitaines) de modifier les estimations des autres."),
              value: _membresEditerEstims,
              onChanged: (bool value) {
                setState(() {
                  _membresEditerEstims = value;
                });
                widget.onUpdateOptions(
                  _membresVoirSynthese,
                  _membresMatcher,
                  _membresEditerEstims,
                );
              },
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
