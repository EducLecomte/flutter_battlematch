// ===========================================================================
// Onglet "Joueurs" de l'écran d'administration (admin_joueurs_tab.dart)
// Liste tous les comptes joueurs : bascule du rôle `admin` et suppression
// de compte (le compte connecté ne peut pas se supprimer lui-même).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../admin_controller.dart';

class AdminJoueursTab extends StatelessWidget {
  final AdminController controller;
  final VoidCallback onStateChanged;
  final void Function(String message, bool isFailure) onMessage;

  const AdminJoueursTab({
    super.key,
    required this.controller,
    required this.onStateChanged,
    required this.onMessage,
  });

  Future<void> _handleToggleAdmin(Joueur joueur, bool nouvelleValeur) async {
    final String? errorMessage = await controller.toggleJoueurAdmin(joueur,
        nouvelleValeur, onStateChanged: onStateChanged);
    if (errorMessage == null) {
      onMessage(nouvelleValeur
          ? "${joueur.nom} est maintenant administrateur."
          : "Rôle administrateur retiré à ${joueur.nom}.",
          false);
    } else {
      onMessage(errorMessage, true);
    }
  }

  Future<void> _handleDeleteJoueur(BuildContext context, Joueur joueur) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer ce compte joueur ?"),
        content:
            Text('Le compte de "${joueur.nom}" (${joueur.email}) sera'
                ' définitivement supprimé, ainsi que ses données rattachées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final String? errorMessage =
        await controller.deleteJoueur(joueur, onStateChanged: onStateChanged);
    if (errorMessage != null) onMessage(errorMessage, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool enLectureSeule = controller.isWorking;
    final String? currentJoueurId = controller.currentJoueurId;
    return controller.listeJoueurs.isEmpty
        ? const Center(child: Text("Aucun joueur."))
        : ListView.builder(
            itemCount: controller.listeJoueurs.length,
            itemBuilder: (listContext, int index) {
              final Joueur joueur = controller.listeJoueurs[index];
              final bool estLeCompteConnecte =
                  joueur.id == currentJoueurId;
              return ListTile(
                leading: Icon(joueur.admin
                    ? Icons.workspace_premium
                    : Icons.person),
                title: Text(
                  joueur.nom,
                ),
                subtitle: Text(joueur.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8.0),
                    const Text("Admin"),
                    const SizedBox(width: 4.0),
                    Switch(
                      value: joueur.admin,
                      onChanged: enLectureSeule
                          ? null
                          : (bool nouvelleValeur) =>
                              _handleToggleAdmin(joueur, nouvelleValeur),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: estLeCompteConnecte
                          ? "Impossible de supprimer votre propre compte"
                          : "Supprimer le compte",
                      onPressed: enLectureSeule || estLeCompteConnecte
                          ? null
                          : () => _handleDeleteJoueur(context, joueur),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
