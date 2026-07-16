import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/data_l10n.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/character_chooser.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/user_data_store.dart';
import 'package:paperblossoms/wizard/wizard_shell.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

import 'test_app.dart';

/// End-to-end sanity for the French locale: the interface renders in
/// French, data names translate at display while saves keep canonical
/// English, and every failure path falls back to English without throwing.
///
/// Fake-async rules observed throughout (hangs otherwise):
/// - Asset loads (dataL10n.setLocale) never complete inside a testWidgets
///   body's fake zone — do them in setUp/tearDown/plain test(), or wrap in
///   tester.runAsync (loads only; never tap inside runAsync).
/// - Screens with indeterminate spinners over real IO (CharacterChooser)
///   can't pumpAndSettle — use plain pump().
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_fr_smoke');
    userDataStore.documentsDirectory = () async => tempDir;
    characterStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  // Runs in the real zone: safe, and keeps the overlay from leaking into
  // other test files.
  tearDown(() async {
    await dataL10n.setLocale('en');
  });

  testWidgets('chooser and tools render in French', (tester) async {
    await tester.pumpWidget(testApp(const CharacterChooser(),
        locale: const Locale('fr')));
    // Plain pump: the chooser shows an indeterminate spinner until its
    // real-IO character list resolves, which never settles under fake async.
    await tester.pump();
    expect(find.text('Nouveau personnage'), findsOneWidget);

    await tester.pumpWidget(
        testApp(const ToolsPage(), locale: const Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Langue'), findsOneWidget);
    expect(find.text('Apparence'), findsOneWidget);
  });

  testWidgets('wizard page 1 shows translated clan names from the overlay',
      (tester) async {
    // Asset load must escape the fake zone.
    await tester.runAsync(() => dataL10n.setLocale('fr'));
    // Inject the selection instead of opening the menu; the closed field
    // renders the selected value through trData.
    final state = WizardState()..clan = 'Crab';
    await tester.pumpWidget(testApp(NewCharacterWizard(initialState: state),
        locale: const Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('Partie 1 : Clan et famille'), findsOneWidget);
    expect(find.text('Crabe'), findsWidgets);
    expect(find.text('Crab'), findsNothing);
  });

  test('saves keep canonical English names regardless of content locale',
      () async {
    await dataL10n.setLocale('fr');
    character.clear();
    character.name = 'Tetsu';
    character.clan = 'Crab';
    character.school = 'Hida Defender School';
    final json = jsonDecode(characterStore.exportJson());
    expect(json['clan'], 'Crab');
    expect(json['school'], 'Hida Defender School');
  });

  test('overlay translates known strings and passes homebrew through',
      () async {
    await dataL10n.setLocale('fr');
    expect(dataL10n.tr('Water'), 'Eau');
    expect(dataL10n.tr('Curriculum'), 'Cursus');
    expect(dataL10n.tr('My Homebrew Sword'), 'My Homebrew Sword');
    expect(dataL10n.trCondition('Lightly Wounded (Fire)'),
        'Légèrement blessé (Feu)');
  });

  test('a corrupt overlay asset falls back to pure English, no throw',
      () async {
    const assetKey = 'assets/i18n/data_fr.json';
    // rootBundle caches loadString results; evict so the mock is consulted.
    rootBundle.evict(assetKey);
    addTearDown(() => rootBundle.evict(assetKey));

    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = utf8.decode(message!.buffer
          .asUint8List(message.offsetInBytes, message.lengthInBytes));
      if (key == assetKey) {
        return ByteData.sublistView(
            Uint8List.fromList(utf8.encode('{ not json !!')));
      }
      return null;
    });
    addTearDown(
        () => messenger.setMockMessageHandler('flutter/assets', null));

    await dataL10n.setLocale('fr');
    expect(dataL10n.tr('Water'), 'Water');
  });
}
