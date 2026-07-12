import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'character.dart';

/// One row in the chooser list; read from the index without decoding whole
/// character files.
class CharacterSummary {
  final String uuid;
  final String name;

  const CharacterSummary({required this.uuid, required this.name});
}

/// Disk persistence for characters: one `<uuid>.json` per character plus an
/// `index.json` (uuid -> display name) in the app documents directory.
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
      for (final entry in index.entries)
        CharacterSummary(uuid: entry.key, name: entry.value.toString())
    ];
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }

  /// Saves the global [character] and updates the index.
  Future<void> save() async {
    final file = await _characterFile(character.uuid);
    await file.writeAsString(jsonEncode(character.toJson()));
    final index = await _readIndex();
    index[character.uuid] = _displayName(character);
    await _writeIndex(index);
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
