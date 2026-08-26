// ===========================================================================
// Contrôleur de l'écran d'administration (admin_controller.dart)
// Charge les référentiels (armées, appréciations) et la liste des joueurs,
// puis pilote les opérations CRUD réservées aux comptes marqués `admin`.
// ===========================================================================

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/pocketbase_data_service.dart';
import '../utils/hex_color_parser.dart';

class AdminController {
  final PocketbaseDataService _pocketbaseService =
      PocketbaseDataService.instance;

  List<Armee> listeArmees = [];
  List<Choix> listeChoix = [];
  List<Joueur> listeJoueurs = [];
  bool isLoading = false;
  bool isWorking = false;

  /// Identifiant du compte connecté (pour protéger son propre compte).
  String? get currentJoueurId => _pocketbaseService.currentUserId;

  Future<String?> loadAdministration({
    required VoidCallback onStateChanged,
  }) async {
    isLoading = true;
    onStateChanged();
    try {
      final List<Armee> armeesChargees = await _pocketbaseService.getArmees();
      final List<Choix> choixChargees = await _pocketbaseService.getChoix();
      final List<Joueur> joueursChargees =
          await _pocketbaseService.getJoueursAdministration();
      listeArmees = armeesChargees;
      listeChoix = choixChargees;
      listeJoueurs = joueursChargees;
      return null;
    } catch (loadError) {
      return "Erreur de chargement : ${loadError.toString()}";
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  // -------------------------------------------------------------------
  // Armées : `armeeId` vide = création
  // -------------------------------------------------------------------

  Future<String?> saveArmee({
    required String armeeId,
    required String nom,
    required String short,
    required VoidCallback onStateChanged,
  }) async {
    if (nom.trim().isEmpty || short.trim().isEmpty) {
      return "Nom et initiales sont obligatoires";
    }
    isWorking = true;
    onStateChanged();
    try {
      if (armeeId.isEmpty) {
        await _pocketbaseService.createArmee(nom.trim(), short.trim());
      } else {
        await _pocketbaseService.updateArmee(armeeId, nom.trim(), short.trim());
      }
      listeArmees = await _pocketbaseService.getArmees();
      return null;
    } catch (saveError) {
      return "Erreur de sauvegarde : ${saveError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }

  Future<String?> deleteArmee(String armeeId,
      {required VoidCallback onStateChanged}) async {
    isWorking = true;
    onStateChanged();
    try {
      await _pocketbaseService.deleteArmee(armeeId);
      listeArmees = await _pocketbaseService.getArmees();
      return null;
    } catch (deleteError) {
      return "Erreur de suppression : ${deleteError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }

  // -------------------------------------------------------------------
  // Appréciations : `choixId` vide = création
  // -------------------------------------------------------------------

  Future<String?> saveChoix({
    required String choixId,
    required String libelle,
    required String short,
    required String couleurHex,
    required VoidCallback onStateChanged,
  }) async {
    if (libelle.trim().isEmpty || short.trim().isEmpty) {
      return "Libellé et initiales sont obligatoires";
    }
    final String? couleurNormalisee =
        HexColorParser.normalizeHexadecimalColor(couleurHex);
    if (couleurNormalisee == null) {
      return "Couleur invalide (format attendu : #RRGGBB)";
    }
    isWorking = true;
    onStateChanged();
    try {
      if (choixId.isEmpty) {
        await _pocketbaseService
            .createChoix(libelle.trim(), short.trim(), couleurNormalisee);
      } else {
        await _pocketbaseService.updateChoix(
            choixId, libelle.trim(), short.trim(), couleurNormalisee);
      }
      listeChoix = await _pocketbaseService.getChoix();
      return null;
    } catch (saveError) {
      return "Erreur de sauvegarde : ${saveError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }

  Future<String?> deleteChoix(String choixId,
      {required VoidCallback onStateChanged}) async {
    isWorking = true;
    onStateChanged();
    try {
      await _pocketbaseService.deleteChoix(choixId);
      listeChoix = await _pocketbaseService.getChoix();
      return null;
    } catch (deleteError) {
      return "Erreur de suppression : ${deleteError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }

  // -------------------------------------------------------------------
  // Joueurs : rôle admin et suppression de compte
  // -------------------------------------------------------------------

  Future<String?> toggleJoueurAdmin(
      Joueur joueur, bool nouvelleValeur,
      {required VoidCallback onStateChanged}) async {
    isWorking = true;
    onStateChanged();
    try {
      await _pocketbaseService.setJoueurAdmin(joueur.id, nouvelleValeur);
      listeJoueurs = await _pocketbaseService.getJoueursAdministration();
      return null;
    } catch (toggleError) {
      return "Erreur de mise à jour : ${toggleError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }

  Future<String?> deleteJoueur(Joueur joueur,
      {required VoidCallback onStateChanged}) async {
    isWorking = true;
    onStateChanged();
    try {
      await _pocketbaseService.deleteJoueur(joueur.id);
      listeJoueurs = await _pocketbaseService.getJoueursAdministration();
      return null;
    } catch (deleteError) {
      return "Erreur de suppression : ${deleteError.toString()}";
    } finally {
      isWorking = false;
      onStateChanged();
    }
  }
}
