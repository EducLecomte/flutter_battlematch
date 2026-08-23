import 'package:flutter/material.dart';

class ImportNewRecruitManualTab extends StatelessWidget {
  final TextEditingController manualTextController;
  final VoidCallback onRunManualImport;

  const ImportNewRecruitManualTab({
    super.key,
    required this.manualTextController,
    required this.onRunManualImport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Collez le JSON brut ou la liste textuelle d'équipe copiée depuis New Recruit.",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: TextFormField(
            controller: manualTextController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            expands: true,
            decoration: const InputDecoration(
              hintText: "Collez ici...\nFormat attendu:\nJoueur 1 (Armée)\nListe...\n====================\nJoueur 2...",
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: onRunManualImport,
          icon: const Icon(Icons.analytics_outlined),
          label: const Text("Analyser et Charger"),
        ),
      ],
    );
  }
}
