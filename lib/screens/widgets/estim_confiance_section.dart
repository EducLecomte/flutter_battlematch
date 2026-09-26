// ===========================================================================
// Section du niveau de confiance (estim_confiance_section.dart)
// Bouton segmenté : Faible / Moyen / Élevé.
// ===========================================================================

import 'package:flutter/material.dart';

class EstimConfianceSection extends StatelessWidget {
  final String confiance;
  final ValueChanged<String> onConfianceChanged;

  const EstimConfianceSection({
    super.key,
    required this.confiance,
    required this.onConfianceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confiance stratégique :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'faible',
                label: Text("Faible"),
                icon: Icon(Icons.star_border),
              ),
              ButtonSegment<String>(
                value: 'moyen',
                label: Text("Moyen"),
                icon: Icon(Icons.star_half),
              ),
              ButtonSegment<String>(
                value: 'eleve',
                label: Text("Élevé"),
                icon: Icon(Icons.star),
              ),
            ],
            selected: {confiance},
            onSelectionChanged: (newSelection) {
              onConfianceChanged(newSelection.first);
            },
          ),
        ),
      ],
    );
  }
}
