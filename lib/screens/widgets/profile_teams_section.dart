import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Section listant les équipes et tournois de l'utilisateur.
class ProfileTeamsSection extends StatelessWidget {
  final List<Team> userTeams;
  final Map<String, Tournoi> userTournois;
  final String? currentUserId;

  const ProfileTeamsSection({
    super.key,
    required this.userTeams,
    required this.userTournois,
    required this.currentUserId,
  });

  bool _estCapitaine(Team team) =>
      team.capitaineId != null && team.capitaineId == currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Mes équipes et tournois",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (userTeams.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Aucune équipe pour le moment.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...userTeams.map((team) {
            final tournoi = userTournois[team.tournoiId];
            final String tournoiNom =
                tournoi?.nom ?? (team.tournoiId.isEmpty ? "Sans tournoi" : "Tournoi inconnu");
            final bool estCapitaine = _estCapitaine(team);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  estCapitaine ? Icons.star : Icons.group_outlined,
                  color: estCapitaine ? Colors.amber : Colors.grey,
                ),
                title: Text(
                  team.nom,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(tournoiNom),
                trailing: estCapitaine
                    ? const Text(
                        "Capitaine",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            );
          }),
      ],
    );
  }
}
