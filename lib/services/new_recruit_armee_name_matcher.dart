// ===========================================================================
// Correspondance entre les noms d'armée rencontrés dans les contenus
// importés depuis New Recruit et le référentiel d'armées de l'application.
// ===========================================================================

import '../models/models.dart';

/// Recherche l'armée correspondante dans le référentiel par nom approché
/// ou intitulé court. Retourne null si aucune correspondance trouvée.
Armee? matchArmeeInReference(String armyName, List<Armee> referenceArmies) {
  if (armyName.isEmpty) return null;

  final String normalizedArmyName =
      armyName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  for (final Armee armee in referenceArmies) {
    final String normalizedArmeeName =
        armee.nom.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final String normalizedShortName = armee.short.toLowerCase();

    // Test de correspondance exacte ou approchée
    if (normalizedArmyName.contains(normalizedArmeeName) ||
        normalizedArmyName == normalizedShortName ||
        normalizedArmeeName.contains(normalizedArmyName)) {
      return armee;
    }
  }
  return null;
}
