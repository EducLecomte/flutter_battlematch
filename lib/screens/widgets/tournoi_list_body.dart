// ===========================================================================
// Corps de l'écran des tournois (tournoi_list_body.dart)
// Affiche l'indicateur de chargement, le message vide, ou la liste de
// TournoiCard câblée aux actions de l'écran (droits admin inclus).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'tournoi_card.dart';

class TournoiListBody extends StatelessWidget {
  final bool isLoading;
  final List<Tournoi> tournois;
  final bool estAdministrateur;
  final ValueChanged<String> onDeleteTournoi;
  final void Function(Tournoi tournoi) onOpenTournoi;
  final void Function(Tournoi tournoi) onImportTeams;
  final void Function(Tournoi tournoi) onEditTournoi;

  const TournoiListBody({
    super.key,
    required this.isLoading,
    required this.tournois,
    required this.estAdministrateur,
    required this.onDeleteTournoi,
    required this.onOpenTournoi,
    required this.onImportTeams,
    required this.onEditTournoi,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tournois.isEmpty) {
      return const Center(
        child: Text(
          "Aucun tournoi enregistré. Ajoutez-en un !",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tournois.length,
      itemBuilder: (context, index) {
        final tournoi = tournois[index];

        return TournoiCard(
          tournoi: tournoi,
          estAdministrateur: estAdministrateur,
          onDeleteTournoi: estAdministrateur ? onDeleteTournoi : null,
          onOpenTournoi: () => onOpenTournoi(tournoi),
          onImportTeams: estAdministrateur && !tournoi.importEffectue
              ? () => onImportTeams(tournoi)
              : null,
          onEditTournoi: estAdministrateur
              ? () => onEditTournoi(tournoi)
              : null,
        );
      },
    );
  }
}
