import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'rencontre_list_tile.dart';

class TeamsScreenEncounterList extends StatefulWidget {
  final Team? activeTeam;
  final List<Team> opponentTeams;
  final List<Rencontre> availableEncounters;
  final ValueChanged<Rencontre> onEncounterSelected;
  final ValueChanged<Team> onOpponentTeamSelected;
  final ValueChanged<Rencontre> onDeleteRequested;

  const TeamsScreenEncounterList({
    super.key,
    required this.activeTeam,
    required this.opponentTeams,
    required this.availableEncounters,
    required this.onEncounterSelected,
    required this.onOpponentTeamSelected,
    required this.onDeleteRequested,
  });

  @override
  State<TeamsScreenEncounterList> createState() =>
      _TeamsScreenEncounterListState();
}

class _TeamsScreenEncounterListState extends State<TeamsScreenEncounterList> {
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
      return const Center(child: Text("Sélectionnez d'abord une équipe."));
    }

    final Map<String, Rencontre> encountersByLowerName = {
      for (final encounter in widget.availableEncounters)
        encounter.nomAdversaire.trim().toLowerCase(): encounter,
    };

    // Toutes les équipes adverses du tournoi
    final List<Team> opponentTeams = widget.opponentTeams;

    // Rencontres personnalisées (hors équipes officielles du tournoi)
    final Set<String> officialTeamNamesLower = {
      for (final team in opponentTeams) team.nom.trim().toLowerCase(),
    };
    final List<Rencontre> extraEncounters = widget.availableEncounters
        .where((e) =>
            !officialTeamNamesLower.contains(e.nomAdversaire.trim().toLowerCase()))
        .toList();

    final String query = _searchQuery.trim().toLowerCase();

    final List<Team> filteredOpponentTeams = query.isEmpty
        ? opponentTeams
        : opponentTeams
            .where((t) => t.nom.toLowerCase().contains(query))
            .toList();

    final List<Rencontre> filteredExtraEncounters = query.isEmpty
        ? extraEncounters
        : extraEncounters
            .where((e) => e.nomAdversaire.toLowerCase().contains(query))
            .toList();

    final bool hasItems =
        filteredOpponentTeams.isNotEmpty || filteredExtraEncounters.isNotEmpty;

    if (opponentTeams.isEmpty && extraEncounters.isEmpty) {
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
        if (opponentTeams.length > 5) ...[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Rechercher une équipe adverse...",
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
          const SizedBox(height: 12),
        ],
        Expanded(
          child: !hasItems
              ? const Center(
                  child: Text(
                    "Aucune équipe ne correspond à la recherche.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView(
                  children: [
                    ...filteredOpponentTeams.map((opponentTeam) {
                      final Rencontre? existingEncounter =
                          encountersByLowerName[
                              opponentTeam.nom.trim().toLowerCase()];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: existingEncounter != null
                                ? const Color(0x1F2196F3)
                                : Colors.grey.shade100,
                            child: Icon(
                              Icons.shield_outlined,
                              color: existingEncounter != null
                                  ? Colors.blueAccent
                                  : Colors.grey.shade600,
                            ),
                          ),
                          title: Text(
                            opponentTeam.nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            existingEncounter != null
                                ? "Ronde configurée — Cliquez pour ouvrir la matrice"
                                : "Équipe adverse du tournoi — Cliquez pour ouvrir",
                            style: TextStyle(
                              fontSize: 12,
                              color: existingEncounter != null
                                  ? Colors.green.shade800
                                  : Colors.grey.shade700,
                            ),
                          ),
                          trailing: existingEncounter != null
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => widget
                                      .onDeleteRequested(existingEncounter),
                                  tooltip: "Supprimer la rencontre",
                                )
                              : const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            if (existingEncounter != null) {
                              widget.onEncounterSelected(existingEncounter);
                            } else {
                              widget.onOpponentTeamSelected(opponentTeam);
                            }
                          },
                        ),
                      );
                    }),
                    if (filteredExtraEncounters.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Autres rencontres personnalisées",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      ...filteredExtraEncounters.map((extraEncounter) {
                        return RencontreListTile(
                          encounter: extraEncounter,
                          onOpenDashboard: () =>
                              widget.onEncounterSelected(extraEncounter),
                          onDeleteRequested: () =>
                              widget.onDeleteRequested(extraEncounter),
                        );
                      }),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
