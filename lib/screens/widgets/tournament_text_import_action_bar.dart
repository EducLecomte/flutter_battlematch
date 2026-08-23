import 'package:flutter/material.dart';

class TournamentTextImportActionBar extends StatelessWidget {
  final bool isLoading;
  final bool canImport;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  const TournamentTextImportActionBar({
    super.key,
    required this.isLoading,
    required this.canImport,
    required this.onCancel,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Annuler')),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: isLoading || !canImport ? null : onImport,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Importer'),
        ),
      ],
    );
  }
}
