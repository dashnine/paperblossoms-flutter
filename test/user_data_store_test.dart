import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/user_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_userdata_test');
    userDataStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  test('descriptions roundtrip through disk and clear when emptied',
      () async {
    await userDataStore.setDescription(
        'Striking as Earth', 'Full text here', 'Reduce damage');
    expect(gameData.descriptionFor('Striking as Earth'), 'Full text here');
    expect(gameData.shortDescFor('Striking as Earth'), 'Reduce damage');

    // Reload from disk into a clean list.
    gameData.descriptions = [];
    await userDataStore.loadDescriptions();
    expect(gameData.descriptionFor('Striking as Earth'), 'Full text here');

    // Clearing both fields removes the entry.
    await userDataStore.setDescription('Striking as Earth', '', '');
    expect(gameData.descriptionFor('Striking as Earth'), '');
    gameData.descriptions = [];
    await userDataStore.loadDescriptions();
    expect(gameData.descriptionFor('Striking as Earth'), '');
  });

  test('import merges JSON: imported wins on name, others survive', () async {
    gameData.descriptions = [];
    await userDataStore.setDescription('Striking as Fire', 'old fire', 'f');
    await userDataStore.setDescription('Striking as Water', 'keep me', 'w');

    final count = await userDataStore.importDescriptions(jsonEncode([
      {'name': 'Striking as Fire', 'description': 'new fire', 'short_desc': ''},
      {'name': 'Striking as Air', 'description': 'air text', 'short_desc': 'a'},
    ]));

    expect(count, 2);
    expect(gameData.descriptionFor('Striking as Fire'), 'new fire');
    expect(gameData.shortDescFor('Striking as Fire'), '');
    expect(gameData.descriptionFor('Striking as Water'), 'keep me');
    expect(gameData.descriptionFor('Striking as Air'), 'air text');

    // The merge is persisted.
    gameData.descriptions = [];
    await userDataStore.loadDescriptions();
    expect(gameData.descriptionFor('Striking as Fire'), 'new fire');
    expect(gameData.descriptionFor('Striking as Water'), 'keep me');
  });

  test('export and import round-trip exactly', () async {
    gameData.descriptions = [];
    await userDataStore.setDescription('A', 'text "quoted", with comma\nand newline', 'short');
    await userDataStore.setDescription('B', 'plain', '');
    final exported = userDataStore.exportDescriptionsJson();

    gameData.descriptions = [];
    await userDataStore.importDescriptions(exported);
    expect(gameData.descriptions.length, 2);
    expect(gameData.descriptionFor('A'), 'text "quoted", with comma\nand newline');
    expect(gameData.shortDescFor('A'), 'short');
    expect(gameData.descriptionFor('B'), 'plain');
  });

  test('imports the Qt CSV export format', () async {
    gameData.descriptions = [];
    const csv = '"Striking as Earth","Reduce damage, by 1%0Aper rank","Defense"\n'
        '\n'
        '"Quoted ""Name""","body","short"\n'
        '"orphan line without enough fields"\n';
    final count = await userDataStore.importDescriptions(csv);

    expect(count, 2);
    expect(gameData.descriptionFor('Striking as Earth'),
        'Reduce damage, by 1\nper rank');
    expect(gameData.shortDescFor('Striking as Earth'), 'Defense');
    expect(gameData.descriptionFor('Quoted "Name"'), 'body');
  });

  test('garbage import throws and leaves descriptions untouched', () async {
    gameData.descriptions = [];
    await userDataStore.setDescription('Keep', 'kept', '');
    final before = gameData.descriptions.length;

    await expectLater(userDataStore.importDescriptions('[{broken json'),
        throwsFormatException);
    await expectLater(userDataStore.importDescriptions('["strings only"]'),
        throwsFormatException);
    expect(gameData.descriptions.length, before);
    expect(gameData.descriptionFor('Keep'), 'kept');
  });

  test('homebrew weapons file merges after official content', () async {
    final dir = await userDataStore.homebrewDir();
    await File('${dir.path}/weapons.json').writeAsString(jsonEncode([
      {
        'name': 'Homebrew Blades',
        'entries': [
          {
            'name': 'Test Cleaver',
            'reference': {'book': 'HB', 'page': 1},
            'skill': 'Melee',
            'range': {'min': 1, 'max': 1},
            'damage': 9,
            'deadliness': 9,
            'grips': [
              {'name': '1-hand', 'effects': []}
            ],
            'qualities': ['Razor-Edged'],
            'rarity': 3,
            'price': {'value': 5, 'unit': 'koku'},
          }
        ],
      }
    ]));
    final weaponCount = gameData.weapons.length;
    await userDataStore.loadHomebrew();
    expect(userDataStore.loadedHomebrewFiles, contains('weapons.json'));
    expect(gameData.weapons.length, weaponCount + 1);
    final cleaver = gameData.weaponByName('Test Cleaver')!;
    expect(cleaver.category, 'Homebrew Blades');
    expect(cleaver.damage, 9);
  });

  test('unknown and malformed homebrew files are skipped', () async {
    final dir = await userDataStore.homebrewDir();
    await File('${dir.path}/nonsense.json').writeAsString('[{"name":"x"}]');
    await File('${dir.path}/titles.json').writeAsString('{not json');
    await userDataStore.loadHomebrew();
    expect(userDataStore.loadedHomebrewFiles,
        isNot(contains('nonsense.json')));
    expect(userDataStore.loadedHomebrewFiles, isNot(contains('titles.json')));
  });
}
