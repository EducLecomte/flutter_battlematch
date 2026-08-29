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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Team> get _filteredTeams {
    if (_searchQuery.trim().isEmpty) return widget.equipesTournoi;
    final String query = _searchQuery.trim().toLowerCase();
    return widget.equipesTournoi
        .where((team) => team.nom.toLowerCase().contains(query))
        .toList();
  }

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
    final List<Team> teamsToShow = _filteredTeams;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Choisissez votre équipe",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (widget.equipesTournoi.isNotEmpty)
                  Text(
                    "${widget.equipesTournoi.length} équipe(s)",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (widget.equipesTournoi.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Aucune équipe n'a encore été importée pour ce tournoi.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              if (widget.equipesTournoi.length > 5) ...[
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher une équipe...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
              ],
              Expanded(
                child: teamsToShow.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucune équipe ne correspond à la recherche.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        itemCount: teamsToShow.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final Team team = teamsToShow[index];
                          final bool sansCapitaine =
                              team.capitaineId == null ||
                              team.capitaineId!.isEmpty;
                          final bool rejointParMotDePasse =
                              !sansCapitaine && team.motDePasse.isNotEmpty;

                          return Card(
                            elevation: 1,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: sansCapitaine
                                    ? Colors.amber.shade100
                                    : Colors.blue.shade100,
                                child: Icon(
                                  sansCapitaine
                                      ? Icons.shield_outlined
                                      : Icons.shield,
                                  color: sansCapitaine
                                      ? Colors.amber.shade800
                                      : Colors.blueAccent,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                team.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                sansCapitaine
                                    ? "Sans capitaine — disponible"
                                    : rejointParMotDePasse
                                        ? "Rejoignable avec mot de passe"
                                        : "Invitation requise",
                                style: TextStyle(
                                  color: sansCapitaine
                                      ? Colors.amber.shade900
                                      : null,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: sansCapitaine
                                  ? FilledButton.icon(
                                      icon: const Icon(Icons.flag, size: 16),
                                      label: const Text("Devenir capitaine"),
                                      onPressed: () =>
                                          widget.onClaimTeam(team),
                                    )
                                  : rejointParMotDePasse
                                      ? OutlinedButton.icon(
                                          icon: const Icon(Icons.key, size: 16),
                                          label: const Text("Rejoindre"),
                                          onPressed: () =>
                                              _showJoinDialog(team),
                                        )
                                      : const Chip(
                                          label: Text(
                                            "Sur invitation",
                                            style: TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
