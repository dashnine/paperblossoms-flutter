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

/// End-to-end sanity for the Spanish locale, mirroring
/// i18n_fr_smoke_test.dart: the interface renders in Spanish, data names
/// translate at display while saves keep canonical English, and every
/// failure path falls back to English without throwing.
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
    tempDir = await Directory.systemTemp.createTemp('pb_es_smoke');
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

  testWidgets('chooser and tools render in Spanish', (tester) async {
    await tester.pumpWidget(testApp(const CharacterChooser(),
        locale: const Locale('es')));
    // Plain pump: the chooser shows an indeterminate spinner until its
    // real-IO character list resolves, which never settles under fake async.
    await tester.pump();
    expect(find.text('Nuevo personaje'), findsOneWidget);

    await tester.pumpWidget(
        testApp(const ToolsPage(), locale: const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);
  });

  testWidgets('wizard page 1 shows translated clan names from the overlay',
      (tester) async {
    // Asset load must escape the fake zone.
    await tester.runAsync(() => dataL10n.setLocale('es'));
    // Inject the selection instead of opening the menu; the closed field
    // renders the selected value through trData.
    final state = WizardState()..clan = 'Crab';
    await tester.pumpWidget(testApp(NewCharacterWizard(initialState: state),
        locale: const Locale('es')));
    await tester.pumpAndSettle();
    expect(find.text('Parte 1: Clan y familia'), findsOneWidget);
    expect(find.text('Cangrejo'), findsWidgets);
    expect(find.text('Crab'), findsNothing);
  });

  test('saves keep canonical English names regardless of content locale',
      () async {
    await dataL10n.setLocale('es');
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
    await dataL10n.setLocale('es');
    expect(dataL10n.tr('Water'), 'Agua');
    expect(dataL10n.tr('Curriculum'), 'Plan de estudios');
    expect(dataL10n.tr('My Homebrew Sword'), 'My Homebrew Sword');
    expect(dataL10n.trCondition('Lightly Wounded (Fire)'),
        'Herido leve (Fuego)');
  });

  test('a corrupt overlay asset falls back to pure English, no throw',
      () async {
    const assetKey = 'assets/i18n/data_es.json';
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

    await dataL10n.setLocale('es');
    expect(dataL10n.tr('Water'), 'Water');
  });
}
