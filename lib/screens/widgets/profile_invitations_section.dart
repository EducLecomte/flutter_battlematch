import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Section listant les invitations d'équipe en attente
/// (carte vide ou liste avec boutons Accepter / Refuser).
class ProfileInvitationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;
  final void Function(Team team, bool accept) onRespondToInvite;

  const ProfileInvitationsSection({
    super.key,
    required this.invitations,
    required this.onRespondToInvite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Invitations d'équipes en attente",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (invitations.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Aucune invitation d'équipe reçue.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final Team team = invitations[index]['team'];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    team.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    "Vous êtes invité à rejoindre cette équipe",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => onRespondToInvite(team, true),
                        tooltip: "Accepter",
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => onRespondToInvite(team, false),
                        tooltip: "Refuser",
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
