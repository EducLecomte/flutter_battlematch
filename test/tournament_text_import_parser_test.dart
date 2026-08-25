import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_metawar/models/models.dart';
import 'package:flutter_metawar/services/tournament_text_import_parser.dart';

void main() {
  final List<Armee> referenceArmies = [
    'Vampire Covenant',
    'Beast Herds',
    'Daemon Legions',
    'Empire of Sonnstahl',
    'Infernal Dwarves',
    'Warriors of the Dark Gods',
    'Highborn Elves',
    'Undying Dynasties',
    'Kingdom of Equitaine',
    'Sylvan Elves',
    'Ogre Khans',
    'Saurian Ancients',
  ].map((factionName) => Armee(id: factionName, nom: factionName, short: '')).toList();

  test('analyse l exemple de tournoi complet', () {
    final String rawContent = File('exemple_tournoi.txt').readAsStringSync();
    final List<Map<String, dynamic>> importedPlayers =
        const TournamentTextImportParser()
            .parseTournamentText(rawContent, referenceArmies);

    expect(importedPlayers, hasLength(18));
    expect(importedPlayers.first['teamName'], 'AOC ona');
    expect(importedPlayers.first['playerName'],
        'Albin Bouchet (Cahuete)');
    expect(importedPlayers.first['armyName'], 'Vampire Covenant');
    expect(importedPlayers.first['listText'], contains('4000'));
  });

  test('associe les joueurs sans ligne équipe à léquipe précédente', () {
    final String rawContent = File('exemple_tournoi.txt').readAsStringSync();
    final List<Map<String, dynamic>> importedPlayers =
        const TournamentTextImportParser()
            .parseTournamentText(rawContent, referenceArmies);

    final dynamic matkempo = importedPlayers
        .firstWhere((player) => player['playerName'] == 'Matkempo (Matkempo)');
    expect(matkempo['teamName'], "Les Chiennes du désert d'Al Grodard");

    final dynamic etienne = importedPlayers
        .firstWhere((player) => player['playerName'] == 'Etienne (Doud)');
    expect(etienne['teamName'], 'Sous l\'eau séant');
  });

  test('importe léquipe avec joueur combiné et armée sur ligne séparée', () {
    final String rawContent = File('exemple_tournoi.txt').readAsStringSync();
    final List<Map<String, dynamic>> importedPlayers =
        const TournamentTextImportParser()
            .parseTournamentText(rawContent, referenceArmies);

    final dynamic combinedPlayer = importedPlayers
        .firstWhere((player) => player['playerName'] == 'Kirazon/Trehka');
    expect(combinedPlayer['teamName'], "Orga Chocola'Team");
    expect(combinedPlayer['armyName'], 'Sylvan Elves');
    expect(combinedPlayer['listText'], contains('420 - 10 Pathfinders'));
  });

  test('importe un joueur avec une armée inconnue sur une ligne dash', () {
    const String rawContent = '''
Team Test
Alice (Alias) - Faction Inconnue
100 - Unité Simple
4000
''';

    final List<Map<String, dynamic>> importedPlayers =
        const TournamentTextImportParser()
            .parseTournamentText(rawContent, referenceArmies);

    expect(importedPlayers, hasLength(1));
    expect(importedPlayers.first['teamName'], 'Team Test');
    expect(importedPlayers.first['playerName'], 'Alice (Alias)');
    expect(importedPlayers.first['armyName'], 'Faction Inconnue');
    expect(importedPlayers.first['listText'], contains('Unité Simple'));
  });
}
