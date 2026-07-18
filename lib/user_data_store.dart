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

  /// Homebrew files that failed to parse during the last load. A failed
  /// schools.json is set aside (`.bad`) before the store ever rewrites it,
  /// so hand-edits stay recoverable.
  final Set<String> failedHomebrewFiles = {};

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
        for (final entry in raw) Description.fromJson(entry),
      ];
    } catch (_) {
      // Leave whatever is already loaded; a corrupt or wrong-shaped file
      // (bad JSON throws FormatException, a non-list or wrong-typed field
      // throws TypeError) must not brick startup.
    }
  }

  /// Sets one description in memory without persisting, dropping the entry
  /// entirely when both fields are cleared. Callers batch several updates,
  /// then call [saveDescriptions] once.
  void updateDescription(String name, String description, String shortDesc) {
    gameData.descriptions.removeWhere((d) => d.name == name);
    if (description.isNotEmpty || shortDesc.isNotEmpty) {
      gameData.descriptions.add(
        Description(name: name, description: description, shortDesc: shortDesc),
      );
    }
  }

  /// Saves [gameData.descriptions] (called by the descriptions editor).
  Future<void> saveDescriptions() async {
    final file = await _descriptionsFile();
    await file.writeAsString(
      jsonEncode([for (final d in gameData.descriptions) d.toJson()]),
    );
  }

  /// Sets one description, dropping the entry entirely when both fields are
  /// cleared.
  Future<void> setDescription(
    String name,
    String description,
    String shortDesc,
  ) async {
    updateDescription(name, description, shortDesc);
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
          Description.fromJson(entry),
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
            if (line.trim().isNotEmpty) _parseCsvLine(line),
        ]
        .where((row) => row.length == 3 && row[0].isNotEmpty)
        .map(
          (row) =>
              Description(name: row[0], description: row[1], shortDesc: row[2]),
        )
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

  String _decodeCsvField(String field) => field.trim().replaceAll('%0A', '\n');

  /// Homebrew schools currently merged: the in-memory authority that
  /// `homebrew/schools.json` mirrors. Mutated synchronously before disk
  /// writes so callers (and widget tests) never race the file.
  List<School> homebrewSchools = [];

  Future<File> _homebrewSchoolsFile() async =>
      File('${(await homebrewDir()).path}/schools.json');

  /// The schools in `homebrew/schools.json` as stored on disk; empty when
  /// the file is absent or unparseable.
  Future<List<School>> readHomebrewSchools() async {
    final file = await _homebrewSchoolsFile();
    if (!await file.exists()) return [];
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final e in raw) School.fromJson(e)];
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeHomebrewSchools(List<School> schools) async {
    final file = await _homebrewSchoolsFile();
    // Never silently overwrite a file the loader could not parse — the
    // hand-edits in it may be one typo away from valid. Set it aside once.
    if (failedHomebrewFiles.remove('schools.json') && await file.exists()) {
      await file.copy('${file.path}.bad');
    }
    if (schools.isEmpty) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert([for (final s in schools) s.toJson()]),
    );
  }

  /// Insert-or-replace [school] by name in memory and in
  /// `homebrew/schools.json`. [replacingName] additionally removes the
  /// entry it renames. Memory is updated before the returned future's disk
  /// write, mirroring the character wizard's save-in-background pattern.
  Future<void> saveHomebrewSchool(School school, {String? replacingName}) {
    bool replaced(School s) => s.name == school.name || s.name == replacingName;
    homebrewSchools
      ..removeWhere(replaced)
      ..add(school);
    gameData.schools
      ..removeWhere(replaced)
      ..add(school);
    if (!loadedHomebrewFiles.contains('schools.json')) {
      loadedHomebrewFiles.add('schools.json');
    }
    return _writeHomebrewSchools(homebrewSchools);
  }

  /// Reloads bundled data plus both overlays from scratch — the only way to
  /// resurrect a bundled entry a homebrew file had overridden by name.
  Future<void> reloadAll() async {
    await gameData.load();
    await loadDescriptions();
    await loadHomebrew();
  }

  /// Removes [name] from the homebrew schools, then reloads bundled data
  /// plus overlays from scratch: a homebrew school may have overridden a
  /// bundled one by name, and only a full reload resurrects the original.
  Future<void> deleteHomebrewSchool(String name) async {
    homebrewSchools.removeWhere((s) => s.name == name);
    await _writeHomebrewSchools(homebrewSchools);
    await reloadAll();
  }

  /// Removes every homebrew school in one pass (single reload, unlike
  /// deleting them one by one).
  Future<void> deleteAllHomebrewSchools() async {
    homebrewSchools.clear();
    await _writeHomebrewSchools(homebrewSchools);
    await reloadAll();
  }

  /// Serializes the homebrew schools for file export, in the same shape
  /// [loadHomebrew] reads.
  String exportHomebrewSchoolsJson() => const JsonEncoder.withIndent(
    '  ',
  ).convert([for (final s in homebrewSchools) s.toJson()]);

  /// Imports schools from a JSON array (this app's export, or a hand-written
  /// schools.json) and merges them in: imported entries overwrite same-name
  /// ones, everything else is kept. Returns the number of schools imported.
  /// Throws [FormatException] on unparseable input, leaving the loaded data
  /// untouched.
  Future<int> importHomebrewSchools(String content) async {
    final raw = jsonDecode(content);
    if (raw is! List) {
      throw const FormatException('Expected a JSON array of schools');
    }
    // Last entry wins on duplicate names within the file, so the merge
    // below can't end up holding the same name twice. Wrong-typed fields
    // inside an entry throw TypeError; convert to the FormatException the
    // import UI's error contract expects.
    final byName = <String, School>{};
    for (final e in raw) {
      if (e is! Map<String, dynamic> || (e['name'] ?? '').toString().isEmpty) {
        continue;
      }
      try {
        byName['${e['name']}'] = School.fromJson(e);
      } catch (_) {
        throw FormatException('Malformed school entry "${e['name']}"');
      }
    }
    final imported = [...byName.values];
    if (imported.isEmpty) {
      throw const FormatException('No schools found in file');
    }
    final names = {for (final s in imported) s.name};
    homebrewSchools
      ..removeWhere((s) => names.contains(s.name))
      ..addAll(imported);
    gameData.schools
      ..removeWhere((s) => names.contains(s.name))
      ..addAll(imported);
    if (!loadedHomebrewFiles.contains('schools.json')) {
      loadedHomebrewFiles.add('schools.json');
    }
    await _writeHomebrewSchools(homebrewSchools);
    return imported.length;
  }

  /// Merges homebrew JSON files into the loaded game data. File names must
  /// match the bundled data files (e.g. `weapons.json`, `titles.json`);
  /// entries are appended after the official content.
  Future<void> loadHomebrew() async {
    loadedHomebrewFiles = [];
    failedHomebrewFiles.clear();
    homebrewSchools = [];
    final dir = await homebrewDir();
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final name = entity.uri.pathSegments.last;
      try {
        final raw = jsonDecode(await entity.readAsString()) as List<dynamic>;
        if (_mergeHomebrew(name.replaceAll('.json', ''), raw)) {
          loadedHomebrewFiles.add(name);
        }
      } catch (_) {
        // Skip unparseable or wrong-shaped files (bad JSON is a
        // FormatException, a wrong-typed field a TypeError); the tools
        // screen simply won't list them, and [_writeHomebrewSchools] backs
        // a failed schools.json up before ever overwriting it.
        failedHomebrewFiles.add(name);
      }
    }
  }

  bool _mergeHomebrew(String kind, List<dynamic> raw) {
    switch (kind) {
      case 'clans':
        gameData.clans.addAll([for (final e in raw) Clan.fromJson(e)]);
      case 'schools':
        // Replace-by-name so an in-session save followed by a reload never
        // duplicates, and homebrew may override a bundled school (same
        // precedent as descriptions import: imported wins on name). Last
        // entry wins on duplicate names within the file itself.
        final incoming = [
          ...{for (final e in raw) '${e['name']}': School.fromJson(e)}.values,
        ];
        final names = {for (final s in incoming) s.name};
        homebrewSchools = incoming;
        gameData.schools.removeWhere((s) => names.contains(s.name));
        gameData.schools.addAll(incoming);
      case 'skill_groups':
        gameData.skillGroups.addAll([
          for (final e in raw) SkillGroup.fromJson(e),
        ]);
      case 'bonds':
        gameData.bonds.addAll([for (final e in raw) Bond.fromJson(e)]);
      case 'armor':
        gameData.armor.addAll([for (final e in raw) Armor.fromJson(e)]);
      case 'personal_effects':
        gameData.personalEffects.addAll([
          for (final e in raw) PersonalEffect.fromJson(e),
        ]);
      case 'qualities':
        gameData.qualities.addAll([for (final e in raw) Quality.fromJson(e)]);
      case 'item_patterns':
        gameData.itemPatterns.addAll([
          for (final e in raw) ItemPattern.fromJson(e),
        ]);
      case 'samurai_heritage':
        gameData.heritageEntries.addAll([
          for (final e in raw) HeritageEntry.fromJson(e),
        ]);
      case 'regions':
        gameData.regions.addAll([for (final e in raw) Region.fromJson(e)]);
      case 'upbringings':
        gameData.upbringings.addAll([
          for (final e in raw) Upbringing.fromJson(e),
        ]);
      case 'titles':
        gameData.titles.addAll([for (final e in raw) Title.fromJson(e)]);
      case 'techniques':
        gameData.techniques.addAll([
          for (final category in raw)
            for (final subcategory in category['subcategories'] ?? [])
              for (final t in subcategory['techniques'] ?? [])
                Technique.fromJson(
                  t,
                  category: category['name'] ?? '',
                  subcategory: subcategory['name'] ?? '',
                ),
        ]);
      case 'advantages_disadvantages':
        gameData.advantagesDisadvantages.addAll([
          for (final category in raw)
            for (final e in category['entries'] ?? [])
              AdvDisadv.fromJson(e, category: category['name'] ?? ''),
        ]);
      case 'weapons':
        gameData.weapons.addAll([
          for (final category in raw)
            for (final e in category['entries'] ?? [])
              Weapon.fromJson(e, category: category['name'] ?? ''),
        ]);
      default:
        return false;
    }
    return true;
  }
}

final userDataStore = UserDataStore();
