import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'character.dart';
import 'derived_stats.dart';

/// One row in the chooser list; read from the index without decoding whole
/// character files.
class CharacterSummary {
  final String uuid;
  final String name;
  final String clan;
  final String school;
  final int rank;

  const CharacterSummary({
    required this.uuid,
    required this.name,
    this.clan = '',
    this.school = '',
    this.rank = 0,
  });
}

/// Disk persistence for characters: one `<uuid>.json` per character plus an
/// `index.json` (uuid -> summary map, or a bare display name in saves from
/// older builds) in the app documents directory.
class CharacterStore {
  static final CharacterStore _instance = CharacterStore._internal();
  factory CharacterStore() => _instance;
  CharacterStore._internal();

  /// Overridable for tests.
  Future<Directory> Function() documentsDirectory =
      getApplicationDocumentsDirectory;

  Future<Directory> _charactersDir() async {
    final docs = await documentsDirectory();
    final dir = Directory('${docs.path}/paperblossoms/characters');
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> _characterFile(String uuid) async =>
      File('${(await _charactersDir()).path}/$uuid.json');

  Future<File> _indexFile() async =>
      File('${(await _charactersDir()).path}/index.json');

  Future<Map<String, dynamic>> _readIndex() async {
    final file = await _indexFile();
    if (!await file.exists()) return {};
    try {
      return jsonDecode(await file.readAsString());
    } on FormatException {
      return {};
    }
  }

  Future<void> _writeIndex(Map<String, dynamic> index) async {
    await (await _indexFile()).writeAsString(jsonEncode(index));
  }

  Future<List<CharacterSummary>> list() async {
    final index = await _readIndex();
    final summaries = [
      for (final entry in index.entries) _summaryFrom(entry.key, entry.value)
    ];
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }

  /// Older builds stored a bare display-name string per uuid; current builds
  /// store a map with chooser details.
  CharacterSummary _summaryFrom(String uuid, dynamic value) {
    if (value is Map) {
      return CharacterSummary(
        uuid: uuid,
        name: value['name']?.toString() ?? 'Unnamed Samurai',
        clan: value['clan']?.toString() ?? '',
        school: value['school']?.toString() ?? '',
        rank: value['rank'] is int ? value['rank'] : 0,
      );
    }
    return CharacterSummary(uuid: uuid, name: value.toString());
  }

  /// Portrait bytes for a saved character, or null when it has none (or the
  /// stored base64 is corrupt). Reads the character file lazily so the index
  /// stays tiny.
  Future<Uint8List?> portraitOf(String uuid) async {
    final file = await _characterFile(uuid);
    if (!await file.exists()) return null;
    try {
      final data = jsonDecode(await file.readAsString());
      final b64 = data['portrait']?.toString() ?? '';
      return b64.isEmpty ? null : base64Decode(b64);
    } on FormatException {
      return null;
    }
  }

  /// Saves the global [character] and updates the index.
  Future<void> save() async {
    final file = await _characterFile(character.uuid);
    await file.writeAsString(jsonEncode(character.toJson()));
    final index = await _readIndex();
    index[character.uuid] = {
      'name': _displayName(character),
      'clan': character.clan,
      'school': character.school,
      'rank': recalcRank(character).rank,
    };
    await _writeIndex(index);
    character.markSaved();
  }

  /// Loads [uuid] into the global [character].
  Future<void> load(String uuid) async {
    final file = await _characterFile(uuid);
    character.loadFromJson(jsonDecode(await file.readAsString()));
  }

  Future<void> delete(String uuid) async {
    final file = await _characterFile(uuid);
    if (await file.exists()) await file.delete();
    final index = await _readIndex();
    index.remove(uuid);
    await _writeIndex(index);
  }

  /// Serializes the global [character] for file export.
  String exportJson() => jsonEncode(character.toJson());

  /// Loads [json] (an exported character) into the global [character] under a
  /// fresh uuid, then saves it.
  Future<void> importJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    data.remove('uuid'); // never collide with an existing character
    character.loadFromJson(data);
    await save();
  }

  String _displayName(Character c) {
    final full = '${c.family} ${c.name}'.trim();
    return full.isEmpty ? 'Unnamed Samurai' : full;
  }
}

final characterStore = CharacterStore();
