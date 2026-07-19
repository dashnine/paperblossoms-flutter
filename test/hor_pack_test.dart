import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/user_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pb_hor_pack_test');
    userDataStore.documentsDirectory = () async => tempDir;
    await userDataStore.reloadAll();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  test('install applies erratas; uninstall restores stock byte-for-byte',
      () async {
    // Stock facts before install.
    final stockNodachi = gameData.weaponByName('Nodachi')!;
    expect(stockNodachi.qualities, isNot(contains('Cumbersome')));
    expect(gameData.weaponByName('Shinobigatana'), isNotNull);
    final stockIkoma = gameData.schoolByName('Ikoma Bard School')!;
    expect(stockIkoma.startingSkills.options,
        contains('Martial Arts [Ranged]'));
    final stockWeaponCount = gameData.weapons.length;

    expect(await userDataStore.horPackInstalled(), isFalse);
    final count = await userDataStore.installHorPack();
    expect(count, greaterThan(0));
    expect(await userDataStore.horPackInstalled(), isTrue);

    // Weapon overrides replaced, not duplicated.
    final nodachi = gameData.weaponByName('Nodachi')!;
    expect(nodachi.qualities, containsAll(['Cumbersome', 'Wargear']));
    expect([
      for (final w in gameData.weapons)
        if (w.name == 'Nodachi') w
    ], hasLength(1));
    expect(gameData.weaponByName('Jitte')!.qualities, contains('Quick-draw'));
    expect(gameData.weaponByName('Magari Yari')!.rarity, 7);
    // Removals.
    expect(gameData.weaponByName('Shinobigatana'), isNull);
    expect(gameData.weaponByName('Kaiu no Oyumi'), isNull);
    expect(gameData.weaponByName('Catalpa Bow'), isNull);
    // School erratas.
    final ikoma = gameData.schoolByName('Ikoma Bard School')!;
    expect(ikoma.startingSkills.options, contains('Martial Arts [Unarmed]'));
    expect(
        ikoma.startingSkills.options, isNot(contains('Martial Arts [Ranged]')));
    expect(gameData.schoolByName('Kitsune Mediator School')!.clan, 'Lion');
    final duelist = gameData.schoolByName('Kakita Duelist School')!;
    final outfit = [
      for (final set in duelist.startingOutfit) ...set.options
    ];
    expect(outfit, contains('Rokugani Pony'));
    expect(outfit, isNot(contains('Attendant')));
    // Quick-draw quality resolves.
    expect([for (final q in gameData.qualities) q.name],
        contains('Quick-draw'));

    // Uninstall restores everything.
    await userDataStore.uninstallHorPack();
    expect(await userDataStore.horPackInstalled(), isFalse);
    expect(gameData.weaponByName('Nodachi')!.qualities,
        isNot(contains('Cumbersome')));
    expect(gameData.weaponByName('Shinobigatana'), isNotNull);
    expect(gameData.weapons.length, stockWeaponCount);
    expect(gameData.schoolByName('Ikoma Bard School')!.startingSkills.options,
        contains('Martial Arts [Ranged]'));
    expect(gameData.schoolByName('Kitsune Mediator School')!.clan, 'Fox');
    expect([for (final q in gameData.qualities) q.name],
        isNot(contains('Quick-draw')));
    expect(userDataStore.homebrewSchools, isEmpty);
  });

  test('install and uninstall leave existing user homebrew untouched',
      () async {
    // A user school (override of a bundled one by name) and user qualities
    // exist before the pack arrives.
    final custom =
        gameData.schoolByName('Hida Defender School')!.toJson();
    custom['name'] = 'My Custom School';
    await userDataStore
        .importHomebrewSchools(jsonEncode([custom]));
    final dir = await userDataStore.homebrewDir();
    final qualitiesFile = File('${dir.path}/qualities.json');
    await qualitiesFile.writeAsString(jsonEncode([
      {
        'name': 'My Quality',
        'reference': {'book': 'Custom', 'page': 1}
      }
    ]));
    await userDataStore.reloadAll();
    expect(gameData.schoolByName('My Custom School'), isNotNull);

    await userDataStore.installHorPack();
    expect(gameData.schoolByName('My Custom School'), isNotNull);
    expect([for (final q in gameData.qualities) q.name],
        containsAll(['My Quality', 'Quick-draw']));

    await userDataStore.uninstallHorPack();
    expect(gameData.schoolByName('My Custom School'), isNotNull);
    expect([for (final q in gameData.qualities) q.name],
        contains('My Quality'));
    expect([for (final q in gameData.qualities) q.name],
        isNot(contains('Quick-draw')));
    // The user's qualities file survives with only their entry.
    final kept = jsonDecode(await qualitiesFile.readAsString()) as List;
    expect(kept, hasLength(1));

    // Cleanup for other tests.
    await userDataStore.deleteHomebrewSchool('My Custom School');
    await qualitiesFile.delete();
    await userDataStore.reloadAll();
  });

  test('pack-only merge kinds are ignored without the pack manifest',
      () async {
    final dir = await userDataStore.homebrewDir();
    final file = File('${dir.path}/removals.json');
    await file.writeAsString(jsonEncode([
      {
        'kind': 'weapons',
        'names': ['Katana']
      }
    ]));
    await userDataStore.reloadAll();
    // No manifest → the file is skipped entirely and Katana survives.
    expect(gameData.weaponByName('Katana'), isNotNull);
    expect(userDataStore.loadedHomebrewFiles, isNot(contains('removals.json')));
    expect(userDataStore.failedHomebrewFiles, isNot(contains('removals.json')));
    await file.delete();
    await userDataStore.reloadAll();
  });

  test('pack does not touch schools already matching the campaign text',
      () async {
    // Ability renames the upstream data already carries need no pack entry:
    // guard that they hold so a data-audit regression is caught here.
    expect(gameData.schoolByName('Kakita Swordsmith School')!.schoolAbility,
        'Sacred Art of Steel');
    expect(gameData.schoolByName('Treasure Hunter')!.schoolAbility,
        'Risk and Reward');
    expect(gameData.schoolByName('Ishiken Initiate School')!.clan, 'Phoenix');
  });
}
