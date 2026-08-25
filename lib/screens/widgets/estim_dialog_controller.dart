// Contrôleur du formulaire d'estimation, séparé de la boîte de dialogue
// pour conserver la taille et les responsabilités du widget limitées.

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';

/// Détient l'état du formulaire et orchestre la validation/sauvegarde.
class EstimDialogController extends ChangeNotifier {
  final Joueur currentJoueur;
  final MetaAdv currentOpponent;
  final List<Choix> orderedChoiceList;
  final TextEditingController commentaireController = TextEditingController();

  String? selectedChoiceId;
  String confidenceLevel;
  int minimumScore;
  int maximumScore;
  bool isSaving;
  String? validationMessage;

  EstimDialogController({
    required this.currentJoueur,
    required this.currentOpponent,
    required List<Choix> choiceList,
    Estim? existingEstim,
  })  : orderedChoiceList = AppreciationScale.scaleChoices(choiceList),
        selectedChoiceId = existingEstim?.choixId ??
            AppreciationScale.choiceByCode(
              choiceList,
              AppreciationScale.defaultCode,
            )?.id,
        confidenceLevel = existingEstim?.confiance ?? estimConfianceDefault,
        minimumScore = existingEstim?.scoreMin ?? estimScoreDefault,
        maximumScore = existingEstim?.scoreMax ?? estimScoreDefault,
        isSaving = false {
    commentaireController.text = existingEstim?.commentaire ?? '';
  }

  void selectChoice(Choix choice) {
    selectedChoiceId = choice.id;
    notifyListeners();
  }

  void setConfidenceLevel(String level) {
    confidenceLevel = level;
    notifyListeners();
  }

  void setMinimumScore(int value) {
    minimumScore = value;
    notifyListeners();
  }

  void setMaximumScore(int value) {
    maximumScore = value;
    notifyListeners();
  }

  String? validationError() {
    final selectedChoice =
        AppreciationScale.choiceById(orderedChoiceList, selectedChoiceId);
    if (selectedChoice == null) {
      return 'Sélectionnez une appréciation.';
    }
    if (maximumScore < minimumScore) {
      return 'Le score maximum doit être au moins égal au score minimum.';
    }
    return null;
  }

  Estim? buildEstim() {
    final choiceId = selectedChoiceId;
    if (choiceId == null || validationError() != null) {
      return null;
    }
    final commentValue = commentaireController.text.trim();
    return Estim(
      joueurId: currentJoueur.id,
      rencontreId: currentOpponent.rencontreId,
      metaAdvId: currentOpponent.id,
      choixId: choiceId,
      scoreMin: minimumScore,
      scoreMax: maximumScore,
      confiance: confidenceLevel,
      commentaire: commentValue.isEmpty ? null : commentValue,
    );
  }

  Future<void> save({
    required Future<String?> Function(Estim estim) onSave,
  }) async {
    final validation = validationError();
    validationMessage = validation;
    if (validation != null) {
      notifyListeners();
      return;
    }

    final estim = buildEstim();
    if (estim == null) {
      return;
    }

    isSaving = true;
    notifyListeners();
    String? saveErrorMessage;
    try {
      saveErrorMessage = await onSave(estim);
    } catch (saveError) {
      saveErrorMessage = 'Échec de la sauvegarde : $saveError';
    }
    isSaving = false;
    validationMessage = saveErrorMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    commentaireController.dispose();
    super.dispose();
  }
}
