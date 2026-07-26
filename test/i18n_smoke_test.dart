import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/data_l10n.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/character_chooser.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/wizard/wizard_shell.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

import 'temp_stores.dart';
import 'test_app.dart';

/// End-to-end sanity per supported locale: the interface renders in the
/// language, data names translate at display while saves keep canonical
/// English, and every failure path falls back to English without throwing.
///
/// Fake-async rules observed throughout (hangs otherwise):
/// - Asset loads (dataL10n.setLocale) never complete inside a testWidgets
///   body's fake zone — do them in setUp/tearDown/plain test(), or wrap in
///   tester.runAsync (loads only; never tap inside runAsync).
/// - Screens with indeterminate spinners over real IO (CharacterChooser)
///   can't pumpAndSettle — use plain pump().
class _L10nCase {
  const _L10nCase({
    required this.locale,
    required this.language,
    required this.newCharacter,
    required this.languageLabel,
    required this.appearance,
    required this.part1,
    required this.crab,
    required this.water,
    required this.curriculum,
    required this.lightlyWoundedFire,
  });

  final String locale;
  final String language;
  final String newCharacter;
  final String languageLabel;
  final String appearance;
  final String part1;
  final String crab;
  final String water;
  final String curriculum;
  final String lightlyWoundedFire;
}

const _cases = [
  _L10nCase(
    locale: 'fr',
    language: 'French',
    newCharacter: 'Nouveau personnage',
    languageLabel: 'Langue',
    appearance: 'Apparence',
    part1: 'Partie 1 : Clan et famille',
    crab: 'Crabe',
    water: 'Eau',
    curriculum: 'Cursus',
    lightlyWoundedFire: 'Légèrement blessé (Feu)',
  ),
  _L10nCase(
    locale: 'de',
    language: 'German',
    newCharacter: 'Neuer Charakter',
    languageLabel: 'Sprache',
    appearance: 'Erscheinungsbild',
    part1: 'Teil 1: Klan und Familie',
    crab: 'Krabbe',
    water: 'Wasser',
    curriculum: 'Lehrplan',
    lightlyWoundedFire: 'Leicht verwundet (Feuer)',
  ),
  _L10nCase(
    locale: 'es',
    language: 'Spanish',
    newCharacter: 'Nuevo personaje',
    languageLabel: 'Idioma',
    appearance: 'Apariencia',
    part1: 'Parte 1: Clan y familia',
    crab: 'Cangrejo',
    water: 'Agua',
    curriculum: 'Plan de estudios',
    lightlyWoundedFire: 'Herido leve (Fuego)',
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  useTempStores('pb_i18n_smoke');

  setUpAll(() async {
    await gameData.load();
  });

  // Runs in the real zone: safe, and keeps the overlay from leaking into
  // other test files.
  tearDown(() async {
    await dataL10n.setLocale('en');
  });

  for (final c in _cases) {
    group(c.language, () {
      testWidgets('chooser and tools render in ${c.language}',
          (tester) async {
        await tester.pumpWidget(
            testApp(const CharacterChooser(), locale: Locale(c.locale)));
        // Plain pump: the chooser shows an indeterminate spinner until its
        // real-IO character list resolves, which never settles under fake
        // async.
        await tester.pump();
        expect(find.text(c.newCharacter), findsOneWidget);

        await tester
            .pumpWidget(testApp(const ToolsPage(), locale: Locale(c.locale)));
        await tester.pumpAndSettle();
        expect(find.text(c.languageLabel), findsOneWidget);
        expect(find.text(c.appearance), findsOneWidget);
      });

      testWidgets('wizard page 1 shows translated clan names from the overlay',
          (tester) async {
        // Asset load must escape the fake zone.
        await tester.runAsync(() => dataL10n.setLocale(c.locale));
        // Inject the selection instead of opening the menu; the closed field
        // renders the selected value through trData.
        final state = WizardState()..clan = 'Crab';
        await tester.pumpWidget(testApp(
            NewCharacterWizard(initialState: state),
            locale: Locale(c.locale)));
        await tester.pumpAndSettle();
        expect(find.text(c.part1), findsOneWidget);
        expect(find.text(c.crab), findsWidgets);
        expect(find.text('Crab'), findsNothing);
      });

      test('saves keep canonical English names regardless of content locale',
          () async {
        await dataL10n.setLocale(c.locale);
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
        await dataL10n.setLocale(c.locale);
        expect(dataL10n.tr('Water'), c.water);
        expect(dataL10n.tr('Curriculum'), c.curriculum);
        expect(dataL10n.tr('My Homebrew Sword'), 'My Homebrew Sword');
        expect(dataL10n.trCondition('Lightly Wounded (Fire)'),
            c.lightlyWoundedFire);
      });

      test('a corrupt overlay asset falls back to pure English, no throw',
          () async {
        final assetKey = 'assets/i18n/data_${c.locale}.json';
        // rootBundle caches loadString results; evict so the mock is
        // consulted.
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

        await dataL10n.setLocale(c.locale);
        expect(dataL10n.tr('Water'), 'Water');
      });
    });
  }
}
