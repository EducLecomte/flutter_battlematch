// ===========================================================================
// Boîte de Dialogue d'Estimation (estim_dialog.dart)
// Formulaire permettant d'ajouter ou de modifier une estimation détaillée.
// L'état est délégué à `EstimDialogController`.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'estim_choix_section.dart';
import 'estim_commentaire_section.dart';
import 'estim_confiance_section.dart';
import 'estim_dialog_controller.dart';
import 'estim_score_section.dart';

class EstimDialog extends StatefulWidget {
  final Joueur joueur;
  final MetaAdv opponent;
  final List<Choix> listChoix;
  final Estim? currentEstim;
  final Future<String?> Function(Estim estim) onSave;

  const EstimDialog({
    super.key,
    required this.joueur,
    required this.opponent,
    required this.listChoix,
    this.currentEstim,
    required this.onSave,
  });

  @override
  State<EstimDialog> createState() => _EstimDialogState();
}

class _EstimDialogState extends State<EstimDialog> {
  late final EstimDialogController controller;

  @override
  void initState() {
    super.initState();
    controller = EstimDialogController(
      currentJoueur: widget.joueur,
      currentOpponent: widget.opponent,
      choiceList: widget.listChoix,
      existingEstim: widget.currentEstim,
    );
    controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _submit() async {
    await controller.save(onSave: widget.onSave);
    if (!controller.isSaving && controller.validationMessage == null && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    controller.removeListener(_handleControllerChange);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Estimation de ${widget.joueur.nom}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final validationMessage = controller.validationMessage;
          return SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EstimChoixSection(
                    listChoix: controller.orderedChoiceList,
                    selectedChoixId: controller.selectedChoiceId,
                    onChoixSelected: (choiceId) {
                      final choice = AppreciationScale.choiceById(
                        controller.orderedChoiceList,
                        choiceId,
                      );
                      if (choice != null) {
                        controller.selectChoice(choice);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  EstimScoreSection(
                    scoreMin: controller.minimumScore,
                    scoreMax: controller.maximumScore,
                    onScoreChanged: (minimumScore, maximumScore) {
                      controller.setMinimumScore(minimumScore);
                      controller.setMaximumScore(maximumScore);
                    },
                  ),
                  const SizedBox(height: 16),
                  EstimConfianceSection(
                    confiance: controller.confidenceLevel,
                    onConfianceChanged: controller.setConfidenceLevel,
                  ),
                  const SizedBox(height: 20),
                  EstimCommentaireSection(
                    commentController: controller.commentaireController,
                  ),
                  if (validationMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      validationMessage,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  if (controller.isSaving) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: controller.isSaving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: controller.isSaving ? null : _submit,
          child: controller.isSaving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Valider"),
        ),
      ],
    );
  }
}
