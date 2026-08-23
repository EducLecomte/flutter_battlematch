// ===========================================================================
// Section du choix d'estimation (estim_choix_section.dart)
// Affichage des badges colorés du référentiel de choix, avec sélection.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';

class EstimChoixSection extends StatelessWidget {
  final List<Choix> listChoix;
  final String? selectedChoixId;
  final ValueChanged<String> onChoixSelected;

  const EstimChoixSection({
    super.key,
    required this.listChoix,
    required this.selectedChoixId,
    required this.onChoixSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Appréciation générale :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: listChoix.map((choix) {
            final bool isSelected = selectedChoixId == choix.id;
            final Color choiceColor = Color(
              int.parse(choix.couleurHex.replaceFirst('#', '0xFF')),
            );

            return InkWell(
              onTap: () => onChoixSelected(choix.id),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? choiceColor
                      : choiceColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isSelected ? Colors.white : choiceColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  choix.short,
                  style: TextStyle(
                    color: isSelected ? Colors.white : choiceColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
