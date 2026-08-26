import 'package:flutter/material.dart';
import '../../models/models.dart';

class TeamManagementTeamInvitePanel extends StatelessWidget {
  final TextEditingController searchController;
  final List<Joueur> searchResults;
  final bool isSearching;
  final ValueChanged<String> onSearchTextChanged;
  final ValueChanged<String> onSendInvite;

  const TeamManagementTeamInvitePanel({
    super.key,
    required this.searchController,
    required this.searchResults,
    required this.isSearching,
    required this.onSearchTextChanged,
    required this.onSendInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Inviter un joueur",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Rechercher par pseudo/email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchTextChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun joueur trouvé",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final player = searchResults[index];
                            return ListTile(
                              title: Text(player.nom),
                              subtitle: Text(player.email),
                              trailing: IconButton(
                                icon: const Icon(Icons.person_add_alt_1, color: Colors.blueAccent),
                                onPressed: () => onSendInvite(player.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
