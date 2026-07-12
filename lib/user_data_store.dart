import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'game_data.dart';
import 'game_data_models.dart';

/// User-entered rules descriptions and homebrew game data. The bundled data
/// intentionally ships no rules text (copyright); users who own the books
/// enter their own, like the original's user_descriptions table. Homebrew
/// content works like the original's user_* tables: JSON files with the same
/// shape as the bundled data, dropped in a homebrew folder and merged on
/// load.
class UserDataStore {
  static final UserDataStore _instance = UserDataStore._internal();
  factory UserDataStore() => _instance;
  UserDataStore._internal();

  /// Overridable for tests.
  Future<Directory> Function() documentsDirectory =
      getApplicationDocumentsDirectory;

  /// Homebrew files merged during the last load, for the tools screen.
  List<String> loadedHomebrewFiles = [];

  Future<Directory> _baseDir() async {
    final docs = await documentsDirectory();
    final dir = Directory('${docs.path}/paperblossoms');
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> _descriptionsFile() async =>
      File('${(await _baseDir()).path}/user_descriptions.json');

  Future<Directory> homebrewDir() async {
    final dir = Directory('${(await _baseDir()).path}/homebrew');
    await dir.create(recursive: true);
    return dir;
  }

  /// Loads user descriptions into [gameData.descriptions].
  Future<void> loadDescriptions() async {
    final file = await _descriptionsFile();
    if (!await file.exists()) return;
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      gameData.descriptions = [
        for (final entry in raw) Description.fromJson(entry)
      ];
    } on FormatException {
      // Leave whatever is already loaded; a corrupt file must not brick
      // startup.
    }
  }

  /// Saves [gameData.descriptions] (called by the descriptions editor).
  Future<void> saveDescriptions() async {
    final file = await _descriptionsFile();
    await file.writeAsString(jsonEncode(
        [for (final d in gameData.descriptions) d.toJson()]));
  }

  /// Sets one description, dropping the entry entirely when both fields are
  /// cleared.
  Future<void> setDescription(
      String name, String description, String shortDesc) async {
    gameData.descriptions.removeWhere((d) => d.name == name);
    if (description.isNotEmpty || shortDesc.isNotEmpty) {
      gameData.descriptions.add(Description(
          name: name, description: description, shortDesc: shortDesc));
    }
    await saveDescriptions();
  }

  /// Serializes [gameData.descriptions] for file export, in the same shape
  /// [loadDescriptions] reads.
  String exportDescriptionsJson() =>
      jsonEncode([for (final d in gameData.descriptions) d.toJson()]);

  /// Imports descriptions from [content] — either this app's JSON export or
  /// the original Qt app's `user_descriptions.csv` — and merges them in:
  /// imported entries overwrite same-name ones, everything else is kept.
  /// Returns the number of entries imported. Throws [FormatException] on
  /// unparseable input, leaving the loaded descriptions untouched.
  Future<int> importDescriptions(String content) async {
    final imported = content.trimLeft().startsWith('[')
        ? _parseDescriptionsJson(content)
        : _parseDescriptionsCsv(content);
    if (imported.isEmpty) {
      throw const FormatException('No descriptions found in file');
    }
    final names = {for (final d in imported) d.name};
    gameData.descriptions.removeWhere((d) => names.contains(d.name));
    gameData.descriptions.addAll(imported);
    await saveDescriptions();
    return imported.length;
  }

  List<Description> _parseDescriptionsJson(String content) {
    final raw = jsonDecode(content);
    if (raw is! List) {
      throw const FormatException('Expected a JSON array of descriptions');
    }
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic> &&
            (entry['name'] ?? '').toString().isNotEmpty)
          Description.fromJson(entry)
    ];
  }

  /// Parses the Qt app's CSV export: no header row, three double-quoted
  /// fields per line (name, description, short_desc), `""` for embedded
  /// quotes and `%0A` for newlines. Rows without exactly three fields are
  /// skipped, as in the original (its INSERT into the three-column table
  /// failed silently for them).
  List<Description> _parseDescriptionsCsv(String content) {
    return [
      for (final line in content.split('\n'))
        if (line.trim().isNotEmpty) _parseCsvLine(line)
    ]
        .where((row) => row.length == 3 && row[0].isNotEmpty)
        .map((row) => Description(
            name: row[0], description: row[1], shortDesc: row[2]))
        .toList();
  }

  /// Port of the Qt app's DataAccessLayer::parseCSV quote-state machine.
  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    final value = StringBuffer();
    var inQuote = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (!inQuote) {
        if (c == ',') {
          fields.add(_decodeCsvField(value.toString()));
          value.clear();
        } else if (c == '"') {
          inQuote = true;
        } else {
          value.write(c);
        }
      } else {
        if (c == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            value.write('"');
            i++;
          } else {
            inQuote = false;
          }
        } else {
          value.write(c);
        }
      }
    }
    fields.add(_decodeCsvField(value.toString()));
    return fields;
  }

  String _decodeCsvField(String field) =>
      field.trim().replaceAll('%0A', '\n');

  /// Merges homebrew JSON files into the loaded game data. File names must
  /// match the bundled data files (e.g. `weapons.json`, `titles.json`);
  /// entries are appended after the official content.
  Future<void> loadHomebrew() async {
    loadedHomebrewFiles = [];
    final dir = await homebrewDir();
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final name = entity.uri.pathSegments.last;
      try {
        final raw = jsonDecode(await entity.readAsString()) as List<dynamic>;
        if (_mergeHomebrew(name.replaceAll('.json', ''), raw)) {
          loadedHomebrewFiles.add(name);
        }
      } on FormatException {
        // Skip unparseable files; the tools screen simply won't list them.
      }
    }
  }

  bool _mergeHomebrew(String kind, List<dynamic> raw) {
    switch (kind) {
      case 'clans':
        gameData.clans.addAll([for (final e in raw) Clan.fromJson(e)]);
      case 'schools':
        gameData.schools.addAll([for (final e in raw) School.fromJson(e)]);
      case 'skill_groups':
        gameData.skillGroups
            .addAll([for (final e in raw) SkillGroup.fromJson(e)]);
      case 'bonds':
        gameData.bonds.addAll([for (final e in raw) Bond.fromJson(e)]);
      case 'armor':
        gameData.armor.addAll([for (final e in raw) Armor.fromJson(e)]);
      case 'personal_effects':
        gameData.personalEffects
            .addAll([for (final e in raw) PersonalEffect.fromJson(e)]);
      case 'qualities':
        gameData.qualities
            .addAll([for (final e in raw) Quality.fromJson(e)]);
      case 'item_patterns':
        gameData.itemPatterns
            .addAll([for (final e in raw) ItemPattern.fromJson(e)]);
      case 'samurai_heritage':
        gameData.heritageEntries
            .addAll([for (final e in raw) HeritageEntry.fromJson(e)]);
      case 'regions':
        gameData.regions.addAll([for (final e in raw) Region.fromJson(e)]);
      case 'upbringings':
        gameData.upbringings
            .addAll([for (final e in raw) Upbringing.fromJson(e)]);
      case 'titles':
        gameData.titles.addAll([for (final e in raw) Title.fromJson(e)]);
      case 'techniques':
        gameData.techniques.addAll([
          for (final category in raw)
            for (final subcategory in category['subcategories'] ?? [])
              for (final t in subcategory['techniques'] ?? [])
                Technique.fromJson(t,
                    category: category['name'] ?? '',
                    subcategory: subcategory['name'] ?? '')
        ]);
      case 'advantages_disadvantages':
        gameData.advantagesDisadvantages.addAll([
          for (final category in raw)
            for (final e in category['entries'] ?? [])
              AdvDisadv.fromJson(e, category: category['name'] ?? '')
        ]);
      case 'weapons':
        gameData.weapons.addAll([
          for (final category in raw)
            for (final e in category['entries'] ?? [])
              Weapon.fromJson(e, category: category['name'] ?? '')
        ]);
      default:
        return false;
    }
    return true;
  }
}

final userDataStore = UserDataStore();
