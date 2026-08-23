import 'package:flutter/material.dart';

class TournamentTextImportAnalysisSection extends StatelessWidget {
  final TextEditingController pasteController;
  final String? errorMessage;
  final VoidCallback onAnalyze;

  const TournamentTextImportAnalysisSection({
    super.key,
    required this.pasteController,
    required this.errorMessage,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: pasteController,
          maxLines: 8,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Collez ici le texte du tournoi',
          ),
        ),
        const SizedBox(height: 12),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(errorMessage!,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ElevatedButton(onPressed: onAnalyze, child: const Text('Analyser le texte')),
      ],
    );
  }
}
