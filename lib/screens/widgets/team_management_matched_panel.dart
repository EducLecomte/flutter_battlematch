import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../utils/error_snack_bar_presenter.dart';
import '../team_management_controller.dart';

/// Panel « Appariements » de la gestion d'équipe.
///
/// Les équipes adverses, leurs joueurs et les appariements sont chargés à
/// la demande (point 6 MEMO) : au lieu d'un panneau « Équipes adverses &
/// Appariements » chargé systématiquement (plusieurs requêtes par équipe
/// adverse), l'écran ne déclenche ces requêtes que quand l'utilisateur
/// affiche la section.
class TeamManagementMatchedPanel extends StatelessWidget {
  final TeamManagementController controller;
  final VoidCallback onStateChanged;

  const TeamManagementMatchedPanel({
    super.key,
    required this.controller,
    required this.onStateChanged,
  });

  Joueur? _findPairedMember(
    List<Matched> matched,
    String teamMetaId,
    List<Map<String, dynamic>> members,
  ) {
    for (final pairing in matched) {
      if (pairing.teamMetaId != teamMetaId) continue;
      for (final member in members) {
        final Joueur player = member['joueur'];
        if (player.id == pairing.joueurId) return player;
      }
    }
    return null;
  }

  // Déclenche le chargement paresseux des adversaires, puis notifie
  // l'écran du changement d'état.
  Future<void> _handleLoadOpponentsTap(BuildContext context) async {
    final String? errorMessage =
        await controller.loadOpponentsForSelectedTeam();
    if (!context.mounted) return;
    onStateChanged();
    if (errorMessage != null) {
      showErrorSnackBar(
        context,
        "Erreur de chargement des adversaires : $errorMessage",
      );
    }
  }

  Future<void> _handlePairingTap(
    BuildContext context,
    Team opponentTeam,
    TeamMeta opponent,
  ) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<Map<String, dynamic>> members = controller.members;
    final List<Matched> currentMatched =
        controller.matchedByOpponentTeamId[opponentTeam.id] ?? [];

    final Set<String> pairedPlayerIds =
        currentMatched.map((pairing) => pairing.joueurId).toSet();

    final String opponentLabel = opponent.nomJo.isNotEmpty
        ? opponent.nomJo
        : "Adversaire";

    final Joueur? selectedPlayer = await showDialog<Joueur>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Apparier à : $opponentLabel"),
        content: SizedBox(
          width: 320,
          child: members.isEmpty
              ? const Text("Aucun membre dans l'équipe.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final Joueur player = member['joueur'];
                    final isAccepted = member['statut'] == 'accepted';
                    final isAlreadyPaired =
                        pairedPlayerIds.contains(player.id);
                    final isCurrentlyAssigned = currentMatched.any(
                      (pairing) =>
                          pairing.joueurId == player.id &&
                          pairing.teamMetaId == opponent.id,
                    );

                    if (!isAccepted) {
                      return ListTile(
                        title: Text(player.nom),
                        subtitle: const Text("Invitation en attente"),
                        enabled: false,
                      );
                    }

                    return ListTile(
                      leading: Icon(
                        isCurrentlyAssigned
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isCurrentlyAssigned
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(player.nom),
                      subtitle: isAlreadyPaired && !isCurrentlyAssigned
                          ? const Text(
                              "Déjà apparié ailleurs",
                              style: TextStyle(color: Colors.orange),
                            )
                          : null,
                      onTap: isAlreadyPaired && !isCurrentlyAssigned
                          ? null
                          : () => Navigator.of(dialogContext).pop(player),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );

    if (selectedPlayer == null) return;

    final bool success = await controller.toggleMatched(
      opponentTeam,
      selectedPlayer,
      opponent,
    );

    if (!context.mounted) return;

    if (success) {
      onStateChanged();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Appariement : ${selectedPlayer.nom} → $opponentLabel",
          ),
          backgroundColor: Colors.green,
          duration: snackBarDisplayDuration,
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            "Appariement impossible : joueur ou liste déjà engagé.",
          ),
          backgroundColor: Colors.redAccent,
          duration: snackBarDisplayDuration,
        ),
      );
    }
  }

  // Carte affichée tant que les adversaires ne sont pas chargés :
  // spinner pendant le chargement, sinon le bouton de chargement à la demande.
  Widget _buildLoadCard(BuildContext context) {
    if (controller.isLoadingOpponents) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link),
        title: const Text("Afficher les adversaires"),
        subtitle: const Text(
          "Charge les équipes adverses et leurs appariements au besoin.",
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _handleLoadOpponentsTap(context),
      ),
    );
  }

  // Cartes par équipe adverse une fois les données chargées.
  List<Widget> _buildOpponentCards(BuildContext context) {
    final List<Team> opponentTeams = controller.opponentTeams;

    if (opponentTeams.isEmpty) {
      return const [
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Aucune équipe adverse avec des joueurs enregistrés.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ];
    }

    return opponentTeams.map((opponentTeam) {
      final opponents =
          controller.opponentsByOpponentTeamId[opponentTeam.id] ?? [];
      final matched =
          controller.matchedByOpponentTeamId[opponentTeam.id] ?? [];

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ExpansionTile(
          title: Text(
            "Adversaire : ${opponentTeam.nom}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: opponents.isEmpty
              ? const [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Aucun adversaire pour cette équipe.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ]
              : opponents.map((opponent) {
                  final pairedMember = _findPairedMember(
                    matched,
                    opponent.id,
                    controller.members,
                  );
                  final String oppPseudo = opponent.nomJo.isNotEmpty
                      ? opponent.nomJo
                      : "Adversaire";
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person, size: 20),
                    ),
                    title: Text(
                      oppPseudo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pairedMember != null
                              ? "Apparié : ${pairedMember.nom}"
                              : "Non apparié",
                          style: TextStyle(
                            color: pairedMember != null
                                ? Colors.green
                                : Colors.grey,
                            fontWeight: pairedMember != null
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    trailing: controller.isCaptain()
                        ? IconButton(
                            icon: const Icon(Icons.link),
                            tooltip: "Apparier",
                            onPressed: () => _handlePairingTap(
                              context,
                              opponentTeam,
                              opponent,
                            ),
                          )
                        : pairedMember != null
                            ? const Icon(Icons.lock, size: 16)
                            : null,
                  );
                }).toList(),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appariements",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (controller.opponentsLoaded) ..._buildOpponentCards(context)
        else _buildLoadCard(context),
      ],
    );
  }
}
