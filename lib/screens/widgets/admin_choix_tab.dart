// ===========================================================================
// Onglet "Appréciations" de l'écran d'administration (admin_choix_tab.dart)
// Liste le référentiel des appréciations et permet de créer, modifier ou
// supprimer une appréciation (dialogue : admin_choix_edit_dialog.dart).
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';
import '../admin_controller.dart';
import 'admin_choix_edit_dialog.dart';

class AdminChoixTab extends StatelessWidget {
  final AdminController controller;
  final VoidCallback onStateChanged;
  final void Function(String message, bool isFailure) onMessage;

  const AdminChoixTab({
    super.key,
    required this.controller,
    required this.onStateChanged,
    required this.onMessage,
  });

  Future<void> _saveChoix(Choix? existingChoix, String libelle, String short,
      String couleurHex) async {
    final String? errorMessage = await controller.saveChoix(
      choixId: existingChoix?.id ?? '',
      libelle: libelle,
      short: short,
      couleurHex: couleurHex,
      onStateChanged: onStateChanged,
    );
    if (errorMessage != null) {
      onMessage(errorMessage, true);
    } else {
      onMessage(existingChoix == null
          ? "Appréciation créée."
          : "Appréciation enregistrée.",
          false);
    }
  }

  void _openEditDialog(BuildContext context, Choix? existingChoix) {
    showChoixEditDialog(
      dialogContext: context,
      existingChoix: existingChoix,
      onSave: (String libelle, String short, String couleurHex) =>
          _saveChoix(existingChoix, libelle, short, couleurHex),
    );
  }

  Future<void> _handleDeleteChoix(BuildContext context, Choix choix) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Supprimer cette appréciation ?"),
        content:
            Text('"${choix.libelle}" sera retirée du référentiel.'),
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
        await controller.deleteChoix(choix.id, onStateChanged: onStateChanged);
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
            label: const Text("Ajouter une appréciation"),
          ),
        ),
        Expanded(
          child: controller.listeChoix.isEmpty
              ? const Center(child: Text("Aucune appréciation."))
              : ListView.builder(
                  itemCount: controller.listeChoix.length,
                  itemBuilder: (listContext, int index) {
                    final Choix choix = controller.listeChoix[index];
                    final Color? couleurEchantillon =
                        HexColorParser.parseHexadecimalColor(choix.couleurHex);
                    return ListTile(
                      leading: Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: couleurEchantillon ?? Colors.transparent,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      title: Text(choix.libelle),
                      subtitle: Text(choix.short),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: "Modifier",
                            onPressed: enLectureSeule
                                ? null
                                : () => _openEditDialog(context, choix),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: "Supprimer",
                            onPressed: enLectureSeule
                                ? null
                                : () => _handleDeleteChoix(context, choix),
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
