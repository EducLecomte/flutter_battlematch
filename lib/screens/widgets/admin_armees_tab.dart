// ===========================================================================
// Onglet "Armées" de l'écran d'administration (admin_armees_tab.dart)
// Liste le référentiel des armées et permet de créer, modifier ou
// supprimer une armée (dialogue : admin_armee_edit_dialog.dart).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../admin_controller.dart';
import 'admin_armee_edit_dialog.dart';

class AdminArmeesTab extends StatelessWidget {
  final AdminController controller;
  final VoidCallback onStateChanged;
  final void Function(String message, bool isFailure) onMessage;

  const AdminArmeesTab({
    super.key,
    required this.controller,
    required this.onStateChanged,
    required this.onMessage,
  });

  Future<void> _saveArmee(
      Armee? existingArmee, String nom, String short) async {
    final String? errorMessage = await controller.saveArmee(
      armeeId: existingArmee?.id ?? '',
      nom: nom,
      short: short,
      onStateChanged: onStateChanged,
    );
    if (errorMessage != null) {
      onMessage(errorMessage, true);
    } else {
      onMessage(existingArmee == null ? "Armée créée." : "Armée enregistrée.",
          false);
    }
  }

  void _openEditDialog(BuildContext context, Armee? existingArmee) {
    showArmeeEditDialog(
      dialogContext: context,
      existingArmee: existingArmee,
      onSave: (String nom, String short) =>
          _saveArmee(existingArmee, nom, short),
    );
  }

  Future<void> _handleDeleteArmee(BuildContext context, Armee armee) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer cette armée ?"),
        content: Text(
            '"${armee.nom}" sera retirée du référentiel. Les métas adverses'
            ' qui l\'utilisent passeront en inconnues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final String? errorMessage =
        await controller.deleteArmee(armee.id, onStateChanged: onStateChanged);
    if (errorMessage != null) onMessage(errorMessage, true);
  }

  @override
  Widget build(BuildContext context) {
    final bool enLectureSeule = controller.isWorking;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: enLectureSeule
                ? null
                : () => _openEditDialog(context, null),
            icon: const Icon(Icons.add),
            label: const Text("Ajouter une armée"),
          ),
        ),
        Expanded(
          child: controller.listeArmees.isEmpty
              ? const Center(child: Text("Aucune armée."))
              : ListView.builder(
                  itemCount: controller.listeArmees.length,
                  itemBuilder: (listContext, int index) {
                    final Armee armee = controller.listeArmees[index];
                    return ListTile(
                      leading: const Icon(Icons.military_tech),
                      title: Text(armee.nom),
                      subtitle: Text(armee.short),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: "Modifier",
                            onPressed: enLectureSeule
                                ? null
                                : () => _openEditDialog(context, armee),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: "Supprimer",
                            onPressed: enLectureSeule
                                ? null
                                : () => _handleDeleteArmee(context, armee),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
