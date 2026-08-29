// ===========================================================================
// Boîte de dialogue d'ajout d'adversaire (add_opponent_dialog.dart)
// Formulaire : nom du joueur adverse, armée/faction, liste d'armée texte.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../utils/error_snack_bar_presenter.dart';
import '../team_dashboard_controller.dart';

void showAddOpponentDialog(
  BuildContext context,
  TeamDashboardController controller,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AddOpponentDialog(controller: controller),
  );
}

class AddOpponentDialog extends StatefulWidget {
  final TeamDashboardController controller;

  const AddOpponentDialog({super.key, required this.controller});

  @override
  State<AddOpponentDialog> createState() => _AddOpponentDialogState();
}

class _AddOpponentDialogState extends State<AddOpponentDialog> {
  final _opponentNameController = TextEditingController();
  final _armyListController = TextEditingController();
  Armee? _selectedArmy;

  @override
  void initState() {
    super.initState();
    if (widget.controller.armies.isNotEmpty) {
      _selectedArmy = widget.controller.armies.first;
    }
  }

  Future<void> _submitOpponent() async {
    final selectedArmy = _selectedArmy;
    if (_opponentNameController.text.trim().isEmpty || selectedArmy == null) {
      return;
    }

    try {
      await widget.controller.addOpponent(
        _opponentNameController.text.trim(),
        _armyListController.text.trim(),
        selectedArmy,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: const Text("Adversaire ajouté !"),
          backgroundColor: Colors.green,
          duration: snackBarDisplayDuration,
        ),
      );
    } catch (addError) {
      if (mounted) {
        showErrorSnackBar(context, "Erreur d'ajout : ${addError.toString()}");
      }
    }
  }

  @override
  void dispose() {
    _opponentNameController.dispose();
    _armyListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ajouter un Adversaire"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _opponentNameController,
                decoration: const InputDecoration(
                  labelText: "Nom du joueur adverse",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Armee>(
                decoration: const InputDecoration(
                  labelText: "Armée / Faction",
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedArmy,
                items: widget.controller.armies.map((army) {
                  return DropdownMenuItem<Armee>(
                    value: army,
                    child: Text(army.nom),
                  );
                }).toList(),
                onChanged: (selectedArmy) {
                  setState(() {
                    _selectedArmy = selectedArmy;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _armyListController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Liste d'armée (texte)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submitOpponent,
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}
