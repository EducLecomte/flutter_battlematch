// ===========================================================================
// Contrôleur de l'écran des Tournois (tournois_controller.dart)
// Détient l'état de la liste de tournois et des champs d'ajout, et pilote
// les opérations PocketBase (chargement, création, suppression).
// ===========================================================================

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';

class TournoiController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  // Liste des tournois chargés
  List<Tournoi> tournois = [];

  // Profil de l'utilisateur courant (droits admin inclus)
  Joueur? profilJoueurCourant;

  bool get estAdministrateur => profilJoueurCourant?.admin ?? false;

  // Contrôleurs pour l'ajout
  final TextEditingController nomController = TextEditingController();
  final TextEditingController lienController = TextEditingController();

  // Indique si le chargement est en cours
  bool isLoading = true;

  // Charge la liste des tournois depuis PocketBase.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> loadTournois({required VoidCallback onStateChanged}) async {
    isLoading = true;
    onStateChanged();

    try {
      profilJoueurCourant = await _pocketbaseService.getCurrentJoueurProfile();
      final listeTournois = await _pocketbaseService.getTournois();
      tournois = listeTournois;
      return null;
    } catch (loadError) {
      return "Erreur de chargement : ${loadError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // Crée un nouveau tournoi à partir des champs du formulaire.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> addTournoi({required VoidCallback onStateChanged}) async {
    final String tournoiNom = nomController.text.trim();
    final String tournoiLien = lienController.text.trim();

    if (tournoiNom.isEmpty || tournoiLien.isEmpty) {
      return "Le nom et le lien New Recruit sont obligatoires.";
    }

    try {
      await _pocketbaseService.createTournoi(tournoiNom, tournoiLien);

      nomController.clear();
      lienController.clear();
      return null;
    } catch (addError) {
      return "Erreur d'ajout : ${addError.toString()}";
    }
  }

  // Supprime un tournoi et sa sous-structure associée.
  // Retourne null en succès, ou un message d'erreur.
  Future<String?> deleteTournoi(String tournoiId) async {
    try {
      await _pocketbaseService.deleteTournoi(tournoiId);
      return null;
    } catch (deleteError) {
      return "Erreur de suppression : ${deleteError.toString()}";
    }
  }

  // Libère les contrôleurs de texte.
  void dispose() {
    nomController.dispose();
    lienController.dispose();
  }
}
