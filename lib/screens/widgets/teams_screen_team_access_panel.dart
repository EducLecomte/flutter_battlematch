// ===========================================================================
// Panneau d'accès aux équipes d'un tournoi (teams_screen_team_access_panel)
// Affiché quand l'utilisateur n'a encore aucune équipe dans le tournoi.
// Propose de devenir capitaine ou de rejoindre une équipe par mot de passe.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class TeamsScreenTeamAccessPanel extends StatefulWidget {
  final List<Team> equipesTournoi;
  final bool isLoading;
  final ValueChanged<Team> onClaimTeam;
  final void Function(Team, String) onJoinTeam;

  const TeamsScreenTeamAccessPanel({
    super.key,
    required this.equipesTournoi,
    required this.isLoading,
    required this.onClaimTeam,
    required this.onJoinTeam,
  });

  @override
  State<TeamsScreenTeamAccessPanel> createState() =>
      _TeamsScreenTeamAccessPanelState();
}

class _TeamsScreenTeamAccessPanelState
    extends State<TeamsScreenTeamAccessPanel> {
  Future<void> _showJoinDialog(Team team) async {
    final TextEditingController passwordController = TextEditingController();
    final bool? joinConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Rejoindre « ${team.nom} »"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Mot de passe de l'équipe",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text("Rejoindre"),
          ),
        ],
      ),
    );
    final String motDePasse = passwordController.text;
    passwordController.dispose();

    if (joinConfirmed == true && motDePasse.isNotEmpty) {
      widget.onJoinTeam(team, motDePasse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choisissez votre équipe",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (widget.equipesTournoi.isEmpty)
              const Text(
                "Aucune équipe n'a encore été importée pour ce tournoi.",
              )
            else
              ListView.separated(
                shrinkWrap: true,
                itemCount: widget.equipesTournoi.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final Team team = widget.equipesTournoi[index];
                  final bool sansCapitaine =
                      team.capitaineId == null || team.capitaineId!.isEmpty;
                  final bool rejointParMotDePasse =
                      !sansCapitaine && team.motDePasse.isNotEmpty;

                  return Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text(team.nom),
                      subtitle: Text(
                        sansCapitaine
                            ? "Sans capitaine"
                            : rejointParMotDePasse
                                ? "Rejoignable avec mot de passe"
                                : "Invitation requise",
                      ),
                      trailing: sansCapitaine
                          ? FilledButton(
                              child: const Text("Devenir capitaine"),
                              onPressed: () => widget.onClaimTeam(team),
                            )
                          : rejointParMotDePasse
                              ? TextButton(
                                  child: const Text("Rejoindre"),
                                  onPressed: () => _showJoinDialog(team),
                                )
                              : null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
