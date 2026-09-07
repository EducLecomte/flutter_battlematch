// ===========================================================================
// Boîte de dialogue d'invitation de joueur (teams_screen_invite_player_dialog.dart)
// Ouvre au capitaine, depuis l'écran du tournoi, un moyen d'inviter un
// joueur à rejoindre son équipe. La recherche et l'invitation vivent dans
// TeamsScreenController.
// ===========================================================================

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../utils/error_snack_bar_presenter.dart';
import 'teams_screen_controller.dart';

Future<void> showTeamsScreenInvitePlayerDialog(
  BuildContext context,
  TeamsScreenController controller,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _TeamsScreenInvitePlayerDialog(
      controller: controller,
    ),
  );
}

class _TeamsScreenInvitePlayerDialog extends StatefulWidget {
  final TeamsScreenController controller;

  const _TeamsScreenInvitePlayerDialog({required this.controller});

  @override
  State<_TeamsScreenInvitePlayerDialog> createState() =>
      _TeamsScreenInvitePlayerDialogState();
}

class _TeamsScreenInvitePlayerDialogState
    extends State<_TeamsScreenInvitePlayerDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchTextChanged(String query) async {
    await widget.controller.searchPlayers(query);
    if (mounted) setState(() {});
  }

  Future<void> _onSendInvite(String playerId) async {
    final String? errorMessage =
        await widget.controller.sendInvite(playerId);
    if (!mounted) return;
    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Invitation envoyée !"),
          backgroundColor: Colors.green,
          duration: snackBarDisplayDuration,
        ),
      );
      Navigator.of(context).pop();
    } else {
      showErrorSnackBar(context, "Erreur d'invitation : $errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = widget.controller.isSearching;
    final results = widget.controller.searchResults;
    return AlertDialog(
      title: const Text("Inviter un joueur"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Rechercher par pseudo/email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchTextChanged,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : results.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _searchController.text.trim().isEmpty
                                ? "Recherchez un joueur à inviter."
                                : "Aucun joueur trouvé",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final player = results[index];
                            return ListTile(
                              title: Text(player.nom),
                              subtitle: Text(player.email),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.person_add_alt_1,
                                  color: Colors.blueAccent,
                                ),
                                tooltip: "Inviter",
                                onPressed: () => _onSendInvite(player.id),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Fermer"),
        ),
      ],
    );
  }
}
