import 'package:flutter/material.dart';

class AddEncounterDialog extends StatefulWidget {
  final Future<void> Function(String opponentName) onCreateEncounter;

  const AddEncounterDialog({super.key, required this.onCreateEncounter});

  @override
  State<AddEncounterDialog> createState() => _AddEncounterDialogState();
}

class _AddEncounterDialogState extends State<AddEncounterDialog> {
  final TextEditingController _opponentNameController = TextEditingController();

  @override
  void dispose() {
    _opponentNameController.dispose();
    super.dispose();
  }

  Future<void> _submitEncounterName() async {
    final String opponentName = _opponentNameController.text.trim();
    if (opponentName.isEmpty) return;

    Navigator.of(context).pop();
    await widget.onCreateEncounter(opponentName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Créer une rencontre"),
      content: TextFormField(
        controller: _opponentNameController,
        decoration: const InputDecoration(
          labelText: "Nom de l'adversaire (ex: Ronde 1 - Belgique)",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submitEncounterName,
          child: const Text("Créer"),
        ),
      ],
    );
  }
}
