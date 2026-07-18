import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
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

  group('homebrew schools', () {
    School testSchool(String name, {String clan = 'Crab'}) => School(
          name: name,
          clan: clan,
          role: const ['Bushi'],
          ringIncrease: const ['Earth', 'Water'],
          startingSkills:
              const ChoiceSet(size: 2, options: ['Fitness', 'Tactics']),
          honor: 45,
          techniquesAvailable: const ['Kata', 'Rituals'],
          schoolAbility: 'Test Ability',
          masteryAbility: 'Test Mastery',
          curriculum: const [
            CurriculumEntry(
                rank: 1, advance: 'Martial skills', type: 'skill_group'),
          ],
        );

    int loadedCount(String name) =>
        gameData.schools.where((s) => s.name == name).length;

    test('save, re-save, rename, delete', () async {
      await userDataStore.saveHomebrewSchool(testSchool('Test School A'));
      expect(loadedCount('Test School A'), 1);
      expect(await userDataStore.readHomebrewSchools(), hasLength(1));

      // Re-save replaces rather than duplicates, in memory and on disk.
      await userDataStore
          .saveHomebrewSchool(testSchool('Test School A', clan: 'Crane'));
      expect(loadedCount('Test School A'), 1);
      expect(gameData.schoolByName('Test School A')!.clan, 'Crane');
      expect(await userDataStore.readHomebrewSchools(), hasLength(1));

      // Rename removes the old entry.
      await userDataStore.saveHomebrewSchool(testSchool('Test School B'),
          replacingName: 'Test School A');
      expect(loadedCount('Test School A'), 0);
      expect(loadedCount('Test School B'), 1);
      expect(await userDataStore.readHomebrewSchools(), hasLength(1));

      await userDataStore.deleteHomebrewSchool('Test School B');
      expect(loadedCount('Test School B'), 0);
      expect(await userDataStore.readHomebrewSchools(), isEmpty);
    });

    test('reload after save does not duplicate', () async {
      await userDataStore.saveHomebrewSchool(testSchool('Test School C'));
      await userDataStore.loadHomebrew();
      await userDataStore.loadHomebrew();
      expect(loadedCount('Test School C'), 1);
      await userDataStore.deleteHomebrewSchool('Test School C');
    });

    test('delete restores an overridden bundled school', () async {
      final original = gameData.schoolByName('Hida Defender School')!;
      await userDataStore
          .saveHomebrewSchool(testSchool('Hida Defender School'));
      expect(loadedCount('Hida Defender School'), 1);
      expect(gameData.schoolByName('Hida Defender School')!.schoolAbility,
          'Test Ability');

      await userDataStore.deleteHomebrewSchool('Hida Defender School');
      expect(loadedCount('Hida Defender School'), 1);
      expect(gameData.schoolByName('Hida Defender School')!.schoolAbility,
          original.schoolAbility);
    });

    test('import merges by name and rejects garbage without mutating',
        () async {
      await userDataStore.saveHomebrewSchool(testSchool('Test School D'));
      final count = await userDataStore.importHomebrewSchools(jsonEncode([
        testSchool('Test School D', clan: 'Lion').toJson(),
        testSchool('Test School E').toJson(),
      ]));
      expect(count, 2);
      expect(gameData.schoolByName('Test School D')!.clan, 'Lion');
      expect(loadedCount('Test School D'), 1);
      expect(loadedCount('Test School E'), 1);
      expect(await userDataStore.readHomebrewSchools(), hasLength(2));

      final before = gameData.schools.length;
      await expectLater(userDataStore.importHomebrewSchools('{not json'),
          throwsFormatException);
      await expectLater(userDataStore.importHomebrewSchools('[]'),
          throwsFormatException);
      expect(gameData.schools.length, before);

      final exported = userDataStore.exportHomebrewSchoolsJson();
      expect(jsonDecode(exported), hasLength(2));

      await userDataStore.deleteHomebrewSchool('Test School D');
      await userDataStore.deleteHomebrewSchool('Test School E');
    });

    test('import turns wrong-typed fields into FormatException', () async {
      // ring_increase must be a list; a wrong-typed field throws TypeError
      // deep in School.fromJson, which the import contract converts.
      final before = gameData.schools.length;
      await expectLater(
          userDataStore.importHomebrewSchools(
              '[{"name": "Bad School", "ring_increase": "Earth"}]'),
          throwsFormatException);
      expect(gameData.schools.length, before);
      expect(gameData.schoolByName('Bad School'), isNull);
    });

    test('duplicate names within one import collapse to the last entry',
        () async {
      final count = await userDataStore.importHomebrewSchools(jsonEncode([
        testSchool('Test School F').toJson(),
        testSchool('Test School F', clan: 'Crane').toJson(),
      ]));
      expect(count, 1);
      expect(loadedCount('Test School F'), 1);
      expect(gameData.schoolByName('Test School F')!.clan, 'Crane');
      await userDataStore.deleteHomebrewSchool('Test School F');
    });

    test('a corrupt schools.json is set aside before the first rewrite',
        () async {
      final dir = await userDataStore.homebrewDir();
      final file = File('${dir.path}/schools.json');
      await file.writeAsString('{corrupt');
      await userDataStore.loadHomebrew();
      expect(userDataStore.homebrewSchools, isEmpty);
      expect(userDataStore.failedHomebrewFiles, contains('schools.json'));

      await userDataStore.saveHomebrewSchool(testSchool('Test School G'));
      expect(await File('${file.path}.bad').readAsString(), '{corrupt');
      expect(await userDataStore.readHomebrewSchools(), hasLength(1));

      await File('${file.path}.bad').delete();
      await userDataStore.deleteHomebrewSchool('Test School G');
    });

    test('rename away from a bundled override restores the bundled school',
        () async {
      final original = gameData.schoolByName('Hida Defender School')!;
      await userDataStore
          .saveHomebrewSchool(testSchool('Hida Defender School'));
      expect(gameData.schoolByName('Hida Defender School')!.schoolAbility,
          'Test Ability');

      // The builder's finish chains reloadAll() after a rename's writes.
      await userDataStore.saveHomebrewSchool(testSchool('Test School H'),
          replacingName: 'Hida Defender School');
      await userDataStore.reloadAll();

      expect(gameData.schoolByName('Hida Defender School')!.schoolAbility,
          original.schoolAbility);
      expect(loadedCount('Hida Defender School'), 1);
      expect(loadedCount('Test School H'), 1);
      await userDataStore.deleteHomebrewSchool('Test School H');
    });
  });
}
