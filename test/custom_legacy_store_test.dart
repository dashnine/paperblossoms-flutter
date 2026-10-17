import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/user_data_store.dart';

import 'temp_stores.dart';

/// Custom Legacy templates (Legacies of War p. 12) live in
/// homebrew/legacies.json with the same memory-first contract as custom NPCs.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tempDir = useTempStores('pb_custom_legacy_store_test');

  setUpAll(() async {
    await gameData.load();
  });

  AdvDisadv custom(String name, {String ring = ringFire}) => AdvDisadv(
        name: name,
        category: categoryLegacies,
        ring: ring,
        types: const ['Interpersonal', 'Mental'],
        reference: const Reference(
            book: customLegacyRefBook, page: customLegacyRefPage),
      );

  File legaciesFile() =>
      File('${tempDir().path}/paperblossoms/homebrew/legacies.json');

  test('saves, merges, survives reload, and deletes', () async {
    await userDataStore.saveCustomLegacy(custom('Legacy of Test'));
    expect(userDataStore.customLegacies.map((a) => a.name), ['Legacy of Test']);
    final merged = gameData.advDisadvByName('Legacy of Test')!;
    expect(merged.category, categoryLegacies);
    expect('${merged.reference}', 'LoW p.12');
    expect(gameData.advDisadvByCategory(categoryLegacies).length, 11);
    expect(userDataStore.loadedHomebrewFiles, contains('legacies.json'));

    final raw = jsonDecode(await legaciesFile().readAsString()) as List;
    expect(raw.single['name'], 'Legacy of Test');
    expect(raw.single['category'], categoryLegacies);
    expect(raw.single.containsKey('xp'), isFalse);

    await userDataStore.reloadAll();
    expect(
        gameData.advantagesDisadvantages
            .where((a) => a.name == 'Legacy of Test')
            .length,
        1);
    expect(userDataStore.customLegacies.length, 1);

    await userDataStore.deleteCustomLegacy('Legacy of Test');
    expect(gameData.advDisadvByName('Legacy of Test'), isNull);
    expect(userDataStore.customLegacies, isEmpty);
    expect(await legaciesFile().exists(), isFalse);
    expect(gameData.advDisadvByCategory(categoryLegacies).length, 10);
  });

  test('replacingName renames without leaving a stale entry', () async {
    await userDataStore.saveCustomLegacy(custom('Legacy of Old'));
    await userDataStore.saveCustomLegacy(custom('Legacy of New', ring: ringWater),
        replacingName: 'Legacy of Old');
    expect(gameData.advDisadvByName('Legacy of Old'), isNull);
    expect(gameData.advDisadvByName('Legacy of New')!.ring, ringWater);
    expect(userDataStore.customLegacies.length, 1);

    await userDataStore.deleteAllCustomLegacies();
    expect(userDataStore.customLegacies, isEmpty);
    expect(gameData.advDisadvByCategory(categoryLegacies).length, 10);
  });

  test('a hand-authored entry shadowing a bundled Legacy resurrects it on'
      ' delete', () async {
    await legaciesFile().create(recursive: true);
    await legaciesFile()
        .writeAsString(jsonEncode([custom('Heroic Life', ring: ringVoid).toJson()]));
    await userDataStore.reloadAll();
    expect(
        gameData.advantagesDisadvantages
            .where((a) => a.name == 'Heroic Life')
            .length,
        1);
    expect(gameData.advDisadvByName('Heroic Life')!.ring, ringVoid);

    await userDataStore.deleteCustomLegacy('Heroic Life');
    expect(gameData.advDisadvByName('Heroic Life')!.ring, ringWater);
    expect(gameData.advDisadvByCategory(categoryLegacies).length, 10);
  });
}
