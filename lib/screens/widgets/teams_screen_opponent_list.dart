import 'package:flutter/material.dart';

import '../../models/models.dart';

class TeamsScreenOpponentList extends StatefulWidget {
  final Team? activeTeam;
  final List<Team> opponentTeams;
  final ValueChanged<Team> onOpponentTeamSelected;

  const TeamsScreenOpponentList({
    super.key,
    required this.activeTeam,
    required this.opponentTeams,
    required this.onOpponentTeamSelected,
  });

  @override
  State<TeamsScreenOpponentList> createState() =>
      _TeamsScreenOpponentListState();
}

class _TeamsScreenOpponentListState
    extends State<TeamsScreenOpponentList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.activeTeam == null) {
      return const Center(child: Text("Sélectionnez d’abord une équipe."));
    }

    final String query = _searchQuery.trim().toLowerCase();
    final List<Team> filteredOpponentTeams = query.isEmpty
        ? widget.opponentTeams
        : widget.opponentTeams
            .where((team) => team.nom.toLowerCase().contains(query))
            .toList();

    if (widget.opponentTeams.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Aucune autre équipe dans ce tournoi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (widget.opponentTeams.length > 5) ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Rechercher une équipe adverse…",
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
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: filteredOpponentTeams.isEmpty
              ? const Center(
                  child: Text(
                    "Aucune équipe ne correspond à la recherche.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  children: [
                    for (final Team opponentTeam
                        in filteredOpponentTeams)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0x1F2196F3),
                            child: Icon(
                              Icons.shield_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            opponentTeam.nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            "Équipe adverse du tournoi — Cliquez pour ouvrir",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          onTap: () => widget.onOpponentTeamSelected(
                            opponentTeam,
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
