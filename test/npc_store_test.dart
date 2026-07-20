import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/encounter.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/npc_models.dart';
import 'package:paperblossoms/user_data_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_npc_store_test');
    userDataStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  Npc custom(String name) => Npc(
        name: name,
        type: 'adversary',
        crCombat: 3,
        crIntrigue: 2,
        demeanor: 'Gruff',
      );

  test('custom NPC saves, merges, survives reload, and deletes', () async {
    await userDataStore.saveCustomNpc(custom('Test Yōjimbō'));
    expect(gameData.npc.sampleByName('Test Yōjimbō'), isNotNull);
    expect(gameData.npc.sampleByName('Test Yōjimbō')!.custom, isTrue);

    await userDataStore.reloadAll();
    final reloaded = gameData.npc.sampleByName('Test Yōjimbō');
    expect(reloaded, isNotNull);
    expect(reloaded!.custom, isTrue);
    expect(reloaded.crCombat, 3);

    await userDataStore.deleteCustomNpc('Test Yōjimbō');
    expect(gameData.npc.sampleByName('Test Yōjimbō'), isNull);
    expect(gameData.npc.samples.length, 31);
  });

  test('custom NPC shadows a bundled sample by name and resurrects on'
      ' delete', () async {
    final override = custom('Loyal Bushi')..crCombat = 9;
    await userDataStore.saveCustomNpc(override);
    expect(gameData.npc.samples.where((n) => n.name == 'Loyal Bushi').length,
        1);
    expect(gameData.npc.sampleByName('Loyal Bushi')!.crCombat, 9);

    await userDataStore.reloadAll();
    expect(gameData.npc.samples.where((n) => n.name == 'Loyal Bushi').length,
        1);
    expect(gameData.npc.sampleByName('Loyal Bushi')!.crCombat, 9);

    await userDataStore.deleteCustomNpc('Loyal Bushi');
    final original = gameData.npc.sampleByName('Loyal Bushi');
    expect(original, isNotNull);
    expect(original!.crCombat, 4);
    expect(original.custom, isFalse);
  });

  test('rename via replacingName drops the old entry', () async {
    await userDataStore.saveCustomNpc(custom('Old Name'));
    await userDataStore.saveCustomNpc(custom('New Name'),
        replacingName: 'Old Name');
    expect(gameData.npc.sampleByName('Old Name'), isNull);
    expect(gameData.npc.sampleByName('New Name'), isNotNull);
    await userDataStore.deleteCustomNpc('New Name');
  });

  test('import/export round trip', () async {
    await userDataStore.saveCustomNpc(custom('Exportable'));
    final exported = userDataStore.exportCustomNpcsJson();
    await userDataStore.deleteAllCustomNpcs();
    expect(userDataStore.customNpcs, isEmpty);

    final count = await userDataStore.importCustomNpcs(exported);
    expect(count, 1);
    expect(gameData.npc.sampleByName('Exportable'), isNotNull);
    await userDataStore.deleteAllCustomNpcs();

    expect(() => userDataStore.importCustomNpcs('{"not": "a list"}'),
        throwsFormatException);
    expect(() => userDataStore.importCustomNpcs('[]'),
        throwsFormatException);
  });

  test('a full NPC round-trips losslessly through JSON', () {
    final npc = gameData.npc.sampleByName('Seasoned Courtier')!;
    final copy = Npc.fromJson(jsonDecode(jsonEncode(npc.toJson())));
    expect(jsonEncode(copy.toJson()), jsonEncode(npc.toJson()));
    // ∞ composure survives too.
    final skeleton = gameData.npc.sampleByName('Bushi Skeleton')!;
    final skeletonCopy =
        Npc.fromJson(jsonDecode(jsonEncode(skeleton.toJson())));
    expect(skeletonCopy.derived.composure, '∞');
    expect(skeletonCopy.social, isNull);
  });

  test('encounters round trip and delete', () async {
    await userDataStore.saveEncounter(Encounter(
      name: 'Bandit Ambush',
      entries: [
        EncounterEntry(npc: 'Desperate Bandit', count: 4),
        EncounterEntry(npc: 'Experienced Bandit'),
      ],
      notes: 'On the Imperial road.',
    ));
    userDataStore.encounters = [];
    await userDataStore.loadEncounters();
    expect(userDataStore.encounters.length, 1);
    final loaded = userDataStore.encounters.single;
    expect(loaded.name, 'Bandit Ambush');
    expect(loaded.entries.length, 2);
    expect(loaded.entries.first.count, 4);
    expect(loaded.notes, 'On the Imperial road.');

    await userDataStore.deleteEncounter('Bandit Ambush');
    userDataStore.encounters = [];
    await userDataStore.loadEncounters();
    expect(userDataStore.encounters, isEmpty);
  });

  test('encounter export/import round trip merges by name', () async {
    await userDataStore.saveEncounter(Encounter(
      name: 'Bandit Ambush',
      entries: [EncounterEntry(npc: 'Desperate Bandit', count: 4)],
    ));
    await userDataStore.saveEncounter(Encounter(name: 'Court Intrigue'));
    final exported = userDataStore.exportEncountersJson();

    // Imports overwrite same-name entries and keep the rest.
    await userDataStore.deleteEncounter('Bandit Ambush');
    await userDataStore.saveEncounter(Encounter(
      name: 'Court Intrigue',
      notes: 'Local edit, about to be overwritten.',
    ));
    final count = await userDataStore.importEncounters(exported);
    expect(count, 2);
    expect(userDataStore.encounters.length, 2);
    final ambush = userDataStore.encounters
        .singleWhere((e) => e.name == 'Bandit Ambush');
    expect(ambush.entries.single.count, 4);
    final court = userDataStore.encounters
        .singleWhere((e) => e.name == 'Court Intrigue');
    expect(court.notes, isEmpty);

    expect(() => userDataStore.importEncounters('{"not": "a list"}'),
        throwsFormatException);
    expect(() => userDataStore.importEncounters('[]'), throwsFormatException);

    await userDataStore.deleteEncounter('Bandit Ambush');
    await userDataStore.deleteEncounter('Court Intrigue');
  });

  test('corrupt files never brick loading', () async {
    final base = Directory('${tempDir.path}/paperblossoms');
    await File('${base.path}/encounters.json').writeAsString('not json');
    userDataStore.encounters = [];
    await userDataStore.loadEncounters();
    expect(userDataStore.encounters, isEmpty);

    await File('${base.path}/homebrew/npcs.json').writeAsString('{{{');
    await userDataStore.loadHomebrew();
    expect(userDataStore.failedHomebrewFiles, contains('npcs.json'));
    expect(gameData.npc.samples.length, 31);
    // Clean up for other tests.
    await File('${base.path}/homebrew/npcs.json').delete();
    await File('${base.path}/encounters.json').delete();
    await userDataStore.reloadAll();
  });
}
