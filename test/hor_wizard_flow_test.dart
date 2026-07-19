import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/character_editor.dart';
import 'package:paperblossoms/wizard/wizard_shell.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

import 'test_app.dart';

/// A complete HoR Crab build ready to walk through every wizard page.
WizardState horCompleteBuild() => WizardState()
  ..horMode = true
  ..characterType = characterTypeSamurai
  ..clan = 'Crab'
  ..family = 'Hida'
  ..familyRing = 'Fire' // avoid Earth ring overflow
  ..school = 'Hida Defender School'
  ..schoolSkills = [
    ...gameData.schoolByName('Hida Defender School')!.startingSkills.options
  ]
  ..ringChoices = ['Earth', 'Water']
  ..schoolSpecialRing = 'Void'
  ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
  ..equipChoices = ['Tetsubō']
  ..horService = 'Clan Champion'
  ..horQ5Skill = 'Command'
  ..horQ6Skill = 'Courtesy'
  ..q7Positive = true
  ..q7Skill = 'Commerce'
  ..q8Choice = 'pos'
  ..q8Skill = 'Theology'
  ..distinction = 'Ambidexterity'
  ..adversity = "Bishamon's Curse"
  ..passion = 'Armament'
  ..anxiety = 'Battle Trauma'
  ..q13PickedAdvantage = true
  ..q13Advantage = 'Paragon of Loyalty'
  ..q14Item = 'Calligraphy Set'
  ..q16Item = 'Blanket'
  ..ancestor1 = 'Material Success'
  ..chosenAncestor = 1
  ..horQ19Technique = 'Striking as Water'
  ..personalName = 'Tetsu';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_hor_wizard_test');
    characterStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  setUp(() => character.clear());

  testWidgets('an HoR build walks through all pages and assembles a '
      'campaign-legal character', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        testApp(NewCharacterWizard(initialState: horCompleteBuild())));
    await tester.pumpAndSettle();
    expect(find.text('Part 1: Clan and Family'), findsOneWidget);

    for (var page = 1; page <= 6; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Part 7: Death'), findsOneWidget);
    // The campaign title is announced on the final page.
    expect(find.textContaining('Agent of the Clan Champion'), findsWidgets);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.byType(CharacterEditor), findsOneWidget);
    expect(character.titles, ['Agent of the Clan Champion']);
    expect(character.status, 40);
  });

  testWidgets('HoR validation blocks a missing service on page 3',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final wizard = horCompleteBuild()..horService = '';
    await tester
        .pumpWidget(testApp(NewCharacterWizard(initialState: wizard)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next')); // to page 2
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next')); // to page 3
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next')); // blocked
    await tester.pump();
    expect(find.text('Choose whom your character serves.'), findsOneWidget);
  });

  testWidgets('the HoR wizard hides the cross-clan checkbox and the stock '
      'wizard keeps it', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final wizard = horCompleteBuild();
    await tester
        .pumpWidget(testApp(NewCharacterWizard(initialState: wizard)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Part 2: Role and School'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNothing);
  });
}
