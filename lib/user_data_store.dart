import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'encounter.dart';
import 'game_data.dart';
import 'game_data_models.dart';
import 'rules_constants.dart';
import 'npc_models.dart';

/// Thrown by [UserDataStore.importDescriptions] when the file parsed fine
/// but no row had any text — e.g. an export template nothing was filled into
/// yet. Distinct from [FormatException] so the UI can say so instead of
/// "could not read file".
class NoFilledDescriptionsException implements Exception {
  const NoFilledDescriptionsException();
}

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

  Future<File> _homebrewFile(String fileName) async =>
      File('${(await homebrewDir()).path}/$fileName');

  /// Writes one app-owned homebrew file (schools, npcs, legacies) as a
  /// pretty-printed JSON array, or deletes it when [rows] is empty. Never
  /// silently overwrites a file the loader could not parse (the hand-edits
  /// in it may be one typo away from valid): such a file is set aside as
  /// `.bad` once, before the first rewrite.
  Future<void> _writeHomebrewRows(
      String fileName, List<Map<String, dynamic>> rows) async {
    final file = await _homebrewFile(fileName);
    if (failedHomebrewFiles.remove(fileName) && await file.exists()) {
      await file.copy('${file.path}.bad');
    }
    if (rows.isEmpty) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(rows));
  }

  /// Lists [fileName] on the tools screen once this session has written it,
  /// even if it did not exist at load time.
  void _markLoaded(String fileName) {
    if (!loadedHomebrewFiles.contains(fileName)) {
      loadedHomebrewFiles.add(fileName);
    }
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

  /// Removes every user description and persists the empty store.
  Future<void> deleteAllDescriptions() async {
    gameData.descriptions.clear();
    await saveDescriptions();
  }

  /// Serializes descriptions for file export, in the same shape
  /// [loadDescriptions] reads but pretty-printed and sorted by name so the
  /// file is hand-editable and diffable across export passes. With
  /// [includeAll], emits one row per describable name — plus any existing
  /// entries whose names fall outside that list, e.g. homebrew school names —
  /// with empty text where the user has written none: a template for filling
  /// in outside the app.
  String exportDescriptionsJson({bool includeAll = false}) {
    final byName = {for (final d in gameData.descriptions) d.name: d};
    final names = {
      if (includeAll) ...gameData.describableNames(),
      ...byName.keys,
    }.toList()
      ..sort();
    return const JsonEncoder.withIndent(' ').convert([
      for (final name in names)
        (byName[name] ?? Description(name: name)).toJson(),
    ]);
  }

  /// Imports descriptions from [content] — either this app's JSON export or
  /// the original Qt app's `user_descriptions.csv` — and merges them in:
  /// imported entries overwrite same-name ones, everything else is kept.
  /// Rows with no text in either field are skipped, never treated as "clear
  /// my entry" — so re-importing a stale template exported with `includeAll`
  /// cannot blank out descriptions written since (clearing is done in-app).
  /// Duplicate names within the file collapse to the last row.
  ///
  /// Throws [FormatException] on unparseable input and
  /// [NoFilledDescriptionsException] when the file parsed but every row was
  /// blank (an unfilled template); both leave the loaded descriptions
  /// untouched. `unknownNames` lists imported names that match nothing in
  /// the loaded data — they are kept (harmless, and they survive the
  /// round-trip) but will never be shown anywhere.
  Future<({int added, int updated, List<String> unknownNames})>
      importDescriptions(String content) async {
    final parsed = content.trimLeft().startsWith('[')
        ? _parseDescriptionsJson(content)
        : _parseDescriptionsCsv(content);
    if (parsed.isEmpty) {
      throw const FormatException('No descriptions found in file');
    }
    final imported = <String, Description>{
      for (final d in parsed)
        if (d.description.isNotEmpty || d.shortDesc.isNotEmpty) d.name: d,
    };
    if (imported.isEmpty) throw const NoFilledDescriptionsException();
    // School names are describable too (homebrew school descriptions) but
    // aren't in describableNames(), which mirrors the editor's list.
    final known = {
      ...gameData.describableNames(),
      for (final s in gameData.schools) s.name,
    };
    final existing = {for (final d in gameData.descriptions) d.name};
    gameData.descriptions.removeWhere((d) => imported.containsKey(d.name));
    gameData.descriptions.addAll(imported.values);
    await saveDescriptions();
    return (
      added: imported.keys.where((n) => !existing.contains(n)).length,
      updated: imported.keys.where(existing.contains).length,
      unknownNames: [
        for (final n in imported.keys)
          if (!known.contains(n)) n
      ],
    );
  }

  List<Description> _parseDescriptionsJson(String content) {
    final raw = jsonDecode(content);
    if (raw is! List) {
      throw const FormatException('Expected a JSON array of descriptions');
    }
    // Coerces field values instead of using Description.fromJson: a
    // hand-edited file may hold non-string values, which must not escape as
    // an uncaught TypeError.
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic> &&
            (entry['name'] ?? '').toString().isNotEmpty)
          Description(
            name: entry['name'].toString(),
            description: (entry['description'] ?? '').toString(),
            shortDesc: (entry['short_desc'] ?? '').toString(),
          ),
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

  /// The schools in `homebrew/schools.json` as stored on disk; empty when
  /// the file is absent or unparseable.
  Future<List<School>> readHomebrewSchools() async {
    final file = await _homebrewFile('schools.json');
    if (!await file.exists()) return [];
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      return [for (final e in raw) School.fromJson(e)];
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeHomebrewSchools(List<School> schools) =>
      _writeHomebrewRows('schools.json', [for (final s in schools) s.toJson()]);

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
    _markLoaded('schools.json');
    return _writeHomebrewSchools(homebrewSchools);
  }

  /// Reloads bundled data plus both overlays from scratch — the only way to
  /// resurrect a bundled entry a homebrew file had overridden by name.
  Future<void> reloadAll() async {
    await gameData.load();
    await loadDescriptions();
    await loadHomebrew();
    await loadEncounters();
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
    _markLoaded('schools.json');
    await _writeHomebrewSchools(homebrewSchools);
    return imported.length;
  }

  /// Custom NPCs currently merged: the in-memory authority that
  /// `homebrew/npcs.json` mirrors. Same memory-first contract as
  /// [homebrewSchools].
  List<Npc> customNpcs = [];

  Future<void> _writeCustomNpcs(List<Npc> npcs) =>
      _writeHomebrewRows('npcs.json', [for (final n in npcs) n.toJson()]);

  /// Insert-or-replace [npc] by name in memory and in `homebrew/npcs.json`.
  /// [replacingName] additionally removes the entry it renames. Memory is
  /// updated before the returned future's disk write.
  Future<void> saveCustomNpc(Npc npc, {String? replacingName}) {
    npc.custom = true;
    bool replaced(Npc n) => n.name == npc.name || n.name == replacingName;
    customNpcs
      ..removeWhere(replaced)
      ..add(npc);
    gameData.npc.samples
      ..removeWhere(replaced)
      ..add(npc);
    _markLoaded('npcs.json');
    return _writeCustomNpcs(customNpcs);
  }

  /// Removes [name] from the custom NPCs, then reloads from scratch: a
  /// custom NPC may have overridden a bundled sample by name, and only a
  /// full reload resurrects the original.
  Future<void> deleteCustomNpc(String name) async {
    customNpcs.removeWhere((n) => n.name == name);
    await _writeCustomNpcs(customNpcs);
    await reloadAll();
  }

  /// Removes every custom NPC in one pass (single reload).
  Future<void> deleteAllCustomNpcs() async {
    customNpcs.clear();
    await _writeCustomNpcs(customNpcs);
    await reloadAll();
  }

  /// Serializes the custom NPCs for file export, in the same shape
  /// [loadHomebrew] reads.
  String exportCustomNpcsJson() => const JsonEncoder.withIndent(
    '  ',
  ).convert([for (final n in customNpcs) n.toJson()]);

  /// Imports custom NPCs from a JSON array and merges them in: imported
  /// entries overwrite same-name ones, everything else is kept. Returns the
  /// number of NPCs imported. Throws [FormatException] on unparseable input.
  Future<int> importCustomNpcs(String content) async {
    final raw = jsonDecode(content);
    if (raw is! List) {
      throw const FormatException('Expected a JSON array of NPCs');
    }
    final byName = <String, Npc>{};
    for (final e in raw) {
      if (e is! Map<String, dynamic> || (e['name'] ?? '').toString().isEmpty) {
        continue;
      }
      try {
        byName['${e['name']}'] = Npc.fromJson(e)..custom = true;
      } catch (_) {
        throw FormatException('Malformed NPC entry "${e['name']}"');
      }
    }
    final imported = [...byName.values];
    if (imported.isEmpty) {
      throw const FormatException('No NPCs found in file');
    }
    final names = {for (final n in imported) n.name};
    customNpcs
      ..removeWhere((n) => names.contains(n.name))
      ..addAll(imported);
    gameData.npc.samples
      ..removeWhere((n) => names.contains(n.name))
      ..addAll(imported);
    _markLoaded('npcs.json');
    await _writeCustomNpcs(customNpcs);
    return imported.length;
  }

  // ---- Encounters ----
  //
  // Encounters are pure user data with no bundled counterpart, so they live
  // as a whole-file store beside user_descriptions.json (outside homebrew/,
  // where the merge machinery would have nothing to merge them into).

  /// Saved encounters. Loaded at startup and after [reloadAll].
  List<Encounter> encounters = [];

  Future<File> _encountersFile() async =>
      File('${(await _baseDir()).path}/encounters.json');

  Future<void> loadEncounters() async {
    final file = await _encountersFile();
    if (!await file.exists()) return;
    try {
      final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
      encounters = [for (final e in raw) Encounter.fromJson(e)];
    } catch (_) {
      // A corrupt file must not brick startup; leave what is loaded.
    }
  }

  Future<void> saveEncounters() async {
    final file = await _encountersFile();
    if (encounters.isEmpty) {
      if (await file.exists()) await file.delete();
      return;
    }
    await file.writeAsString(
      const JsonEncoder.withIndent(
        '  ',
      ).convert([for (final e in encounters) e.toJson()]),
    );
  }

  /// Insert-or-replace [encounter] by name; [replacingName] additionally
  /// removes the entry it renames.
  Future<void> saveEncounter(Encounter encounter, {String? replacingName}) {
    encounters
      ..removeWhere(
          (e) => e.name == encounter.name || e.name == replacingName)
      ..add(encounter);
    return saveEncounters();
  }

  Future<void> deleteEncounter(String name) {
    encounters.removeWhere((e) => e.name == name);
    return saveEncounters();
  }

  /// Serializes the encounters for file export, in the same shape
  /// [loadEncounters] reads.
  String exportEncountersJson() => const JsonEncoder.withIndent(
    '  ',
  ).convert([for (final e in encounters) e.toJson()]);

  /// Imports encounters from a JSON array and merges them in: imported
  /// entries overwrite same-name ones, everything else is kept. Returns the
  /// number of encounters imported. Throws [FormatException] on unparseable
  /// input.
  Future<int> importEncounters(String content) async {
    final raw = jsonDecode(content);
    if (raw is! List) {
      throw const FormatException('Expected a JSON array of encounters');
    }
    final byName = <String, Encounter>{};
    for (final e in raw) {
      if (e is! Map<String, dynamic> || (e['name'] ?? '').toString().isEmpty) {
        continue;
      }
      try {
        byName['${e['name']}'] = Encounter.fromJson(e);
      } catch (_) {
        throw FormatException('Malformed encounter entry "${e['name']}"');
      }
    }
    final imported = [...byName.values];
    if (imported.isEmpty) {
      throw const FormatException('No encounters found in file');
    }
    final names = {for (final e in imported) e.name};
    encounters
      ..removeWhere((e) => names.contains(e.name))
      ..addAll(imported);
    await saveEncounters();
    return imported.length;
  }

  // ---- Custom Legacies (Legacies of War pp. 6 and 12) ----

  /// Custom Legacy templates currently merged: the in-memory authority that
  /// `homebrew/legacies.json` mirrors. Same memory-first contract as
  /// [homebrewSchools].
  List<AdvDisadv> customLegacies = [];

  Future<void> _writeCustomLegacies(List<AdvDisadv> legacies) =>
      _writeHomebrewRows(
          'legacies.json', [for (final a in legacies) a.toJson()]);

  /// Insert-or-replace [legacy] by name in memory and in
  /// `homebrew/legacies.json`. [replacingName] additionally removes the entry
  /// it renames. Memory is updated before the returned future's disk write.
  Future<void> saveCustomLegacy(AdvDisadv legacy, {String? replacingName}) {
    bool replaced(AdvDisadv a) =>
        a.name == legacy.name || a.name == replacingName;
    customLegacies
      ..removeWhere(replaced)
      ..add(legacy);
    gameData.advantagesDisadvantages
      ..removeWhere(replaced)
      ..add(legacy);
    _markLoaded('legacies.json');
    return _writeCustomLegacies(customLegacies);
  }

  /// Removes [name] from the custom Legacies, then reloads from scratch so a
  /// hand-authored entry that shadowed a bundled one by name resurrects it
  /// (the in-app builder refuses such names, but the file is editable).
  Future<void> deleteCustomLegacy(String name) async {
    customLegacies.removeWhere((a) => a.name == name);
    await _writeCustomLegacies(customLegacies);
    await reloadAll();
  }

  /// Removes every custom Legacy in one pass (single reload).
  Future<void> deleteAllCustomLegacies() async {
    customLegacies.clear();
    await _writeCustomLegacies(customLegacies);
    await reloadAll();
  }

  /// Merges homebrew JSON files into the loaded game data. File names must
  /// match the bundled data files (e.g. `weapons.json`, `titles.json`);
  /// entries are appended after the official content.
  Future<void> loadHomebrew() async {
    loadedHomebrewFiles = [];
    failedHomebrewFiles.clear();
    homebrewSchools = [];
    customNpcs = [];
    customLegacies = [];
    final dir = await homebrewDir();
    // The pack-only kinds mutate stock data (replace/remove), so they are
    // honored only when the HoR errata pack's manifest says they belong to
    // it — a same-named file from any other origin stays ignored, exactly
    // as unrecognized kinds were before the pack existed.
    final packInstalled =
        await File('${dir.path}/$_horManifestName').exists();
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      final name = entity.uri.pathSegments.last;
      if (!packInstalled && horPackFiles.contains(name)) continue;
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

  /// Replace-by-name merge for the kinds the app itself writes (schools,
  /// npcs, legacies): [parsed] entries shadow any same-named entry already
  /// in [target], so an in-session save followed by a reload never
  /// duplicates; the last duplicate within [parsed] wins. Returns the
  /// deduplicated entries, which become the file's in-memory mirror.
  static List<T> _replaceByName<T>(
      List<T> target, Iterable<T> parsed, String Function(T) nameOf) {
    final incoming = [...{for (final e in parsed) nameOf(e): e}.values];
    final names = {for (final e in incoming) nameOf(e)};
    target.removeWhere((e) => names.contains(nameOf(e)));
    target.addAll(incoming);
    return incoming;
  }

  bool _mergeHomebrew(String kind, List<dynamic> raw) {
    switch (kind) {
      case 'clans':
        gameData.clans.addAll([for (final e in raw) Clan.fromJson(e)]);
      case 'schools':
        // Homebrew may override a bundled school by name (same precedent as
        // descriptions import: imported wins on name).
        homebrewSchools = _replaceByName(
            gameData.schools, [for (final e in raw) School.fromJson(e)],
            (s) => s.name);
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
        final patterns = [for (final e in raw) ItemPattern.fromJson(e)];
        gameData.itemPatterns.addAll(patterns);
        // Patterns double as purchasable techniques (see GameData.load).
        gameData.techniques.addAll(patterns.map(GameData.patternAsTechnique));
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
      case 'npcs':
        // A custom NPC may override a bundled Chapter 8 sample by name.
        customNpcs = _replaceByName(gameData.npc.samples,
            [for (final e in raw) Npc.fromJson(e)..custom = true], (n) => n.name);
      // The two kinds below exist for the Heroes of Rokugan errata pack;
      // plain `weapons` stays append-only so existing homebrew behaves
      // exactly as before. Files with these names only exist after an
      // explicit pack install (or a user authoring them deliberately).
      case 'weapon_overrides':
        final incoming = [
          for (final category in raw)
            for (final e in category['entries'] ?? [])
              Weapon.fromJson(e, category: category['name'] ?? ''),
        ];
        final names = {for (final w in incoming) w.name};
        gameData.weapons.removeWhere((w) => names.contains(w.name));
        gameData.weapons.addAll(incoming);
      case 'removals':
        for (final entry in raw) {
          final names = {for (final n in entry['names'] ?? []) '$n'};
          switch (entry['kind']) {
            case 'weapons':
              gameData.weapons.removeWhere((w) => names.contains(w.name));
            case 'armor':
              gameData.armor.removeWhere((a) => names.contains(a.name));
            case 'personal_effects':
              gameData.personalEffects
                  .removeWhere((p) => names.contains(p.name));
          }
        }
      case 'legacies':
        // Custom Legacy templates (Legacies of War p. 12).
        customLegacies = _replaceByName(gameData.advantagesDisadvantages, [
          for (final e in raw)
            AdvDisadv.fromJson(e,
                category: '${e['category'] ?? categoryLegacies}'),
        ], (a) => a.name);
      default:
        return false;
    }
    return true;
  }

  // ---- Heroes of Rokugan errata pack ----
  //
  // The pack ships bundled but inert under assets/data/hor/pack/ and is
  // only ever applied by copying it into the homebrew store on explicit
  // install. A manifest (deliberately not named *.json so [loadHomebrew]
  // skips it) records what the pack owns so uninstall leaves the user's
  // own homebrew untouched.

  static const horPackFiles = ['weapon_overrides.json', 'removals.json'];
  static const _horManifestName = 'hor_pack_manifest';

  Future<bool> horPackInstalled() async {
    final dir = await homebrewDir();
    return File('${dir.path}/$_horManifestName').exists();
  }

  /// Installs the pack: schools merge by name through the same path the
  /// school-builder import uses (existing custom schools survive), pack
  /// qualities append to any existing homebrew qualities.json, and the
  /// wholly pack-owned files are copied verbatim. Returns the school count.
  Future<int> installHorPack() async {
    final dir = await homebrewDir();
    final schoolsJson =
        await rootBundle.loadString('assets/data/hor/pack/schools.json');
    final count = await importHomebrewSchools(schoolsJson);

    final packQualities = jsonDecode(await rootBundle
        .loadString('assets/data/hor/pack/qualities.json')) as List;
    final qualitiesFile = File('${dir.path}/qualities.json');
    var existing = <dynamic>[];
    if (await qualitiesFile.exists()) {
      try {
        existing = jsonDecode(await qualitiesFile.readAsString()) as List;
      } catch (_) {
        // Leave an unreadable user file alone; the pack entries still merge.
        existing = [];
      }
    }
    final have = {for (final e in existing) '${e['name']}'};
    final addedQualities = [
      for (final e in packQualities)
        if (!have.contains('${e['name']}')) e,
    ];
    if (addedQualities.isNotEmpty) {
      await qualitiesFile
          .writeAsString(jsonEncode([...existing, ...addedQualities]));
    }

    for (final name in horPackFiles) {
      final content =
          await rootBundle.loadString('assets/data/hor/pack/$name');
      await File('${dir.path}/$name').writeAsString(content);
    }

    await File('${dir.path}/$_horManifestName').writeAsString(jsonEncode({
      'schools': [for (final e in jsonDecode(schoolsJson)) '${e['name']}'],
      'qualities': [for (final e in addedQualities) '${e['name']}'],
      'files': horPackFiles,
    }));
    await reloadAll();
    return count;
  }

  /// Removes exactly what the manifest says the pack owns, then reloads.
  Future<void> uninstallHorPack() async {
    final dir = await homebrewDir();
    final manifestFile = File('${dir.path}/$_horManifestName');
    if (!await manifestFile.exists()) return;
    Map<String, dynamic> manifest = {};
    try {
      manifest = jsonDecode(await manifestFile.readAsString());
    } catch (_) {}

    final schoolNames = {for (final n in manifest['schools'] ?? []) '$n'};
    if (schoolNames.isNotEmpty) {
      homebrewSchools.removeWhere((s) => schoolNames.contains(s.name));
      await _writeHomebrewSchools(homebrewSchools);
    }

    final qualityNames = {for (final n in manifest['qualities'] ?? []) '$n'};
    final qualitiesFile = File('${dir.path}/qualities.json');
    if (qualityNames.isNotEmpty && await qualitiesFile.exists()) {
      try {
        final existing =
            jsonDecode(await qualitiesFile.readAsString()) as List;
        final kept = [
          for (final e in existing)
            if (!qualityNames.contains('${e['name']}')) e,
        ];
        if (kept.isEmpty) {
          await qualitiesFile.delete();
        } else {
          await qualitiesFile.writeAsString(jsonEncode(kept));
        }
      } catch (_) {}
    }

    for (final name in manifest['files'] ?? horPackFiles) {
      final file = File('${dir.path}/$name');
      if (await file.exists()) await file.delete();
    }
    await manifestFile.delete();
    await reloadAll();
  }
}

final userDataStore = UserDataStore();
