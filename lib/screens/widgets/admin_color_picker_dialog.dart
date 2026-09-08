// ===========================================================================
// Sélecteur de couleur de l'écran d'administration
// (admin_color_picker_dialog.dart)
// Grille de teintes Material proposée au tap sur l'échantillon du dialogue
// d'appréciation (admin_choix_edit_dialog.dart) ; la saisie manuelle
// hexadécimale reste disponible dans le dialogue parent.
// ===========================================================================

import 'package:flutter/material.dart';

import '../../utils/hex_color_parser.dart';

/// Taille (côté) d'un échantillon de la grille du sélecteur.
const double adminColorPickerSwatchTaille = 44.0;

/// Espace entre les échantillons de la grille (horizontale et verticale).
const double adminColorPickerEspacement = 8.0;

/// Nombre d'échantillons par ligne de la grille.
const int adminColorPickerColonnes = 6;

/// Largeur maximale de la grille (les lignes de [adminColorPickerColonnes]
/// échantillons ne doivent pas étirer le dialogue sur toute la largeur).
const double adminColorPickerGrilleLargeur =
    adminColorPickerColonnes * adminColorPickerSwatchTaille +
        (adminColorPickerColonnes - 1) * adminColorPickerEspacement;

/// Teintes 500 des familles Material proposées par le sélecteur, dans
/// l'ordre de la palette Material.
const List<Color> adminPalettesCouleurs = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey,
];

/// Ouvre le sélecteur ; renvoie la couleur choisie, ou `null` si annulé.
Future<Color?> showAdminColorPickerDialog({
  required BuildContext context,
  required Color? initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (dialogContext) =>
        AdminColorPickerDialog(initialColor: initialColor),
  );
}

/// Grille de teintes ; le tap sélectionne, « Valider » ferme le dialogue.
class AdminColorPickerDialog extends StatefulWidget {
  final Color? initialColor;

  const AdminColorPickerDialog({super.key, this.initialColor});

  @override
  State<AdminColorPickerDialog> createState() =>
      _AdminColorPickerDialogState();
}

class _AdminColorPickerDialogState extends State<AdminColorPickerDialog> {
  late Color? _selection = widget.initialColor;

  /// Échantillon tappable ; la sélection est marquée d'une bordure primaire.
  Widget _buildSwatch(BuildContext context, Color couleur) {
    final bool selectionnee =
        _selection != null && _selection!.toARGB32() == couleur.toARGB32();
    return SizedBox(
      width: adminColorPickerSwatchTaille,
      height: adminColorPickerSwatchTaille,
      child: InkWell(
        key: ValueKey(HexColorParser.colorToHexString(couleur)),
        onTap: () => setState(() => _selection = couleur),
        child: Container(
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: selectionnee
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
              width: selectionnee ? 3.0 : 1.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Choisir une couleur"),
      content: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: adminColorPickerGrilleLargeur),
        child: Wrap(
          spacing: adminColorPickerEspacement,
          runSpacing: adminColorPickerEspacement,
          children: [
            for (final Color couleur in adminPalettesCouleurs)
              _buildSwatch(context, couleur),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _selection == null
              ? null
              : () => Navigator.of(context).pop(_selection),
          child: const Text("Valider"),
        ),
      ],
    );
  }
}
