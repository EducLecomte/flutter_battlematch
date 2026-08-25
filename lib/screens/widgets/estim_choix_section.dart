// ===========================================================================
// Section du choix d'estimation (estim_choix_section.dart)
// Affichage des badges colorés du référentiel de choix, avec sélection.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';

class EstimChoixSection extends StatelessWidget {
  static const double choicePaddingHorizontal = 16;
  static const double choicePaddingVertical = 10;
  static const double choiceBorderRadius = 8;
  static const double choiceSpacing = 8;
  static const double choiceFontSize = 16;

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
    final theme = Theme.of(context);
    final choices = AppreciationScale.scaleChoices(listChoix);

    if (choices.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Appréciation générale :",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Aucune appréciation disponible. "
            "Lancez le seed de référence pour charger les 7 niveaux.",
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }

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
          spacing: choiceSpacing,
          runSpacing: choiceSpacing,
          alignment: WrapAlignment.center,
          children: choices.map((choice) {
            final bool isSelected = selectedChoixId == choice.id;
            final Color? parsedColor =
                HexColorParser.parseHexadecimalColor(choice.couleurHex);
            final Color badgeColor = parsedColor ?? theme.disabledColor;

            return InkWell(
              onTap: () => onChoixSelected(choice.id),
              borderRadius: BorderRadius.circular(choiceBorderRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: choicePaddingHorizontal,
                  vertical: choicePaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? badgeColor
                      : badgeColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: isSelected ? Colors.white : badgeColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(choiceBorderRadius),
                ),
                child: Text(
                  choice.short,
                  style: TextStyle(
                    color: isSelected ? Colors.white : badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: choiceFontSize,
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
