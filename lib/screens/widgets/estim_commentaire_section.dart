// ===========================================================================
// Section des commentaires (estim_commentaire_section.dart)
// Champ de saisie des notes tactiques libres.
// ===========================================================================

import 'package:flutter/material.dart';

class EstimCommentaireSection extends StatelessWidget {
  final TextEditingController commentController;

  const EstimCommentaireSection({
    super.key,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: commentController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: "Commentaires tactiques / Notes",
        hintText: "Ex: Table avec décors denses recommandée...",
        border: OutlineInputBorder(),
      ),
    );
  }
}
