// ===========================================================================
// Dialogue de création / modification d'une appréciation
// (admin_choix_edit_dialog.dart)
// Les contrôleurs de texte appartiennent au State, qui les libère dans
// dispose() ; l'aperçu de couleur se met à jour via setState ; le swatch
// de couleur ouvre le sélecteur (admin_color_picker_dialog.dart) et
// resynchronise le champ hexadécimal ; les valeurs validées sont renvoyées
// à [onSave] après fermeture du dialogue.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../utils/hex_color_parser.dart';
import 'admin_color_picker_dialog.dart';

/// Taille de l'échantillon de couleur affiché dans le dialogue.
const double adminCouleurSwatchTaille = 40.0;

/// Valeurs saisies dans le dialogue d'appréciation, renvoyées via pop.
class ChoixEditResult {
  final String libelle;
  final String short;
  final String couleurHex;

  const ChoixEditResult({
    required this.libelle,
    required this.short,
    required this.couleurHex,
  });
}

/// Ouvre le dialogue d'appréciation ; [onSave] reçoit les valeurs validées.
Future<void> showChoixEditDialog({
  required BuildContext dialogContext,
  required Choix? existingChoix,
  required Future<void> Function(
      String libelle, String short, String couleurHex) onSave,
}) async {
  final ChoixEditResult? result = await showDialog<ChoixEditResult>(
    context: dialogContext,
    builder: (context) => ChoixEditDialog(existingChoix: existingChoix),
  );
  if (result == null) return;
  await onSave(result.libelle, result.short, result.couleurHex);
}

/// Formulaire d'appréciation ; le State possède et libère les contrôleurs.
class ChoixEditDialog extends StatefulWidget {
  final Choix? existingChoix;

  const ChoixEditDialog({super.key, this.existingChoix});

  @override
  State<ChoixEditDialog> createState() => _ChoixEditDialogState();
}

class _ChoixEditDialogState extends State<ChoixEditDialog> {
  late final TextEditingController _libelleController =
      TextEditingController(text: widget.existingChoix?.libelle ?? '');
  late final TextEditingController _shortController =
      TextEditingController(text: widget.existingChoix?.short ?? '');
  late final TextEditingController _couleurController =
      TextEditingController(text: widget.existingChoix?.couleurHex ?? '');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _libelleController.dispose();
    _shortController.dispose();
    _couleurController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(ChoixEditResult(
        libelle: _libelleController.text,
        short: _shortController.text,
        couleurHex: _couleurController.text,
      ));
    }
  }

  Future<void> _openColorPicker(BuildContext context) async {
    final Color? couleur = await showAdminColorPickerDialog(
      context: context,
      initialColor:
          HexColorParser.parseHexadecimalColor(_couleurController.text),
    );
    if (couleur == null || !mounted) return;
    setState(() {
      _couleurController.text = HexColorParser.colorToHexString(couleur);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color? couleurApercu =
        HexColorParser.parseHexadecimalColor(_couleurController.text);

    return AlertDialog(
      title: Text(widget.existingChoix == null
          ? "Ajouter une appréciation"
          : "Modifier l'appréciation"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _libelleController,
              decoration: const InputDecoration(
                labelText: "Libellé (ex : Entre 8 et 12)",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? "Obligatoire"
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _shortController,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: "Initiales (ex : 8-12)",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? "Obligatoire"
                      : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _couleurController,
                    decoration: const InputDecoration(
                      labelText: "Couleur hexadécimale (ex : #FBC02D)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) =>
                        HexColorParser.normalizeHexadecimalColor(
                                value ?? '') ==
                            null
                        ? "Format #RRGGBB attendu"
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Tooltip(
                  message: "Choisir la couleur",
                  child: InkWell(
                    onTap: () => _openColorPicker(context),
                    child: Container(
                      width: adminCouleurSwatchTaille,
                      height: adminCouleurSwatchTaille,
                      decoration: BoxDecoration(
                        color: couleurApercu ?? Colors.transparent,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: couleurApercu == null
                          ? const Icon(Icons.palette,
                              size: 20.0, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }
}
