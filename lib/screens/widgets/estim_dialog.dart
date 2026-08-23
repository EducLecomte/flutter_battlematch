// ===========================================================================
// Boîte de Dialogue d'Estimation (estim_dialog.dart)
// Formulaire permettant d'ajouter ou de modifier une estimation détaillée.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'estim_choix_section.dart';
import 'estim_commentaire_section.dart';
import 'estim_confiance_section.dart';
import 'estim_score_section.dart';

class EstimDialog extends StatefulWidget {
  final Joueur joueur;
  final MetaAdv opponent;
  final List<Choix> listChoix;
  final Estim? currentEstim;
  final Function(Estim estim) onSave;

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
  // Choix d'estimation sélectionné
  String? _selectedChoixId;

  // Confiance stratégique
  String _confiance = 'moyen';

  // Commentaires
  final _commentController = TextEditingController();

  // Scores minimum et maximum
  int _scoreMin = 10;
  int _scoreMax = 10;

  @override
  void initState() {
    super.initState();
    // Pré-remplissage si une estimation existe déjà
    if (widget.currentEstim != null) {
      final currentEstim = widget.currentEstim!;
      _selectedChoixId = currentEstim.choixId;
      _confiance = currentEstim.confiance;
      _commentController.text = currentEstim.commentaire ?? '';
      _scoreMin = currentEstim.scoreMin ?? 10;
      _scoreMax = currentEstim.scoreMax ?? 10;
    } else {
      // Par défaut, on choisit le choix "=" du référentiel
      _selectedChoixId = choixEstimationDefautId;
    }
  }

  // Enregistre l'estimation
  void _submit() {
    if (_selectedChoixId == null) return;
    if (_scoreMin > _scoreMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le score minimum ne peut pas être supérieur au score maximum",
          ),
        ),
      );
      return;
    }

    final newEstim = Estim(
      joueurId: widget.joueur.id,
      rencontreId: widget.opponent.rencontreId,
      metaAdvId: widget.opponent.id,
      choixId: _selectedChoixId!,
      scoreMin: _scoreMin,
      scoreMax: _scoreMax,
      confiance: _confiance,
      commentaire: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    widget.onSave(newEstim);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Estimation de ${widget.joueur.nom}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Choix visuels de l'estimation
              EstimChoixSection(
                listChoix: widget.listChoix,
                selectedChoixId: _selectedChoixId,
                onChoixSelected: (choixId) {
                  setState(() {
                    _selectedChoixId = choixId;
                  });
                },
              ),
              const SizedBox(height: 24),

              // 2. Curseur double de score attendu (0-20)
              EstimScoreSection(
                scoreMin: _scoreMin,
                scoreMax: _scoreMax,
                onScoreChanged: (scoreMin, scoreMax) {
                  setState(() {
                    _scoreMin = scoreMin;
                    _scoreMax = scoreMax;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 3. Niveau de confiance
              EstimConfianceSection(
                confiance: _confiance,
                onConfianceChanged: (confiance) {
                  setState(() {
                    _confiance = confiance;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 4. Notes / Commentaires
              EstimCommentaireSection(commentController: _commentController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(onPressed: _submit, child: const Text("Valider")),
      ],
    );
  }
}
