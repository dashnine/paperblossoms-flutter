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

WizardState completeBuild() => WizardState()
  ..characterType = characterTypeSamurai
  ..clan = 'Crab'
  ..family = 'Hida'
  ..familyRing = 'Fire' // avoid Earth overflow so no replacement is needed
  ..school = 'Hida Defender School'
  ..schoolSkills = [
    'Fitness',
    'Martial Arts [Melee]',
    'Meditation',
    'Survival',
    'Tactics',
  ]
  ..ringChoices = ['Earth', 'Water']
  ..schoolSpecialRing = 'Void'
  ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
  ..equipChoices = ['Tetsubō']
  ..q7Positive = true
  ..q8Choice = 'pos'
  ..distinction = 'Ambidexterity'
  ..adversity = "Bishamon's Curse"
  ..passion = 'Armament'
  ..anxiety = 'Battle Trauma'
  ..q13PickedAdvantage = true
  ..q13Advantage = 'Paragon of Loyalty'
  ..q16Item = 'Blanket'
  ..personalName = 'Tetsu';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_wizard_test');
    characterStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  setUp(() => character.clear());

  testWidgets('walking a complete build through all pages finishes into the '
      'editor with the assembled character', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: NewCharacterWizard(initialState: completeBuild()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Part 1: Clan and Family'), findsOneWidget);

    for (var page = 1; page <= 6; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Part 7: Death'), findsOneWidget);
    expect(find.text('Finish'), findsOneWidget);

    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    // Landed in the editor with the assembled character. (Persistence of
    // the save file is covered by the plain async test below — real file
    // I/O never completes inside the widget-test fake-async zone.)
    expect(find.byType(CharacterEditor), findsOneWidget);
    expect(character.name, 'Tetsu');
    expect(character.school, 'Hida Defender School');
    expect(character.baseRings[ringEarth], 3);
    expect(character.baseRings[ringFire], 2);
  });

  test('assembled character saves and reloads through the store', () async {
    completeBuild().assemble();
    await characterStore.save();
    final summaries = await characterStore.list();
    expect([for (final s in summaries) s.name], contains('Hida Tetsu'));
    final uuid = character.uuid;
    character.clear();
    await characterStore.load(uuid);
    expect(character.name, 'Tetsu');
    expect(character.baseRings[ringEarth], 3);
  });

  testWidgets('validation blocks advancing with unanswered questions',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: NewCharacterWizard()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // Still on page 1, with the error snackbar naming the missing answer.
    expect(find.text('Part 1: Clan and Family'), findsOneWidget);
    expect(find.text('Choose a clan (Question 1).'), findsOneWidget);
  });

  testWidgets('page 4 blocks advancing without the Q9-12 traits',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final build = completeBuild()..passion = '';
    await tester.pumpWidget(MaterialApp(
      home: NewCharacterWizard(initialState: build),
    ));
    await tester.pumpAndSettle();
    for (var page = 1; page <= 3; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Part 4: Strengths and Weaknesses'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // Still on page 4, with the error snackbar naming the missing answer.
    expect(find.text('Part 4: Strengths and Weaknesses'), findsOneWidget);
    expect(find.text('Choose a passion (Question 11).'), findsOneWidget);

    build.passion = 'Armament';
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Part 5: Personality and Behavior'), findsOneWidget);
  });

  testWidgets('page 4 blocks an empty Question 13 follow-up choice',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final build = completeBuild()..q13Advantage = '';
    await tester.pumpWidget(MaterialApp(
      home: NewCharacterWizard(initialState: build),
    ));
    await tester.pumpAndSettle();
    for (var page = 1; page <= 3; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Part 4: Strengths and Weaknesses'), findsOneWidget);
    expect(find.text('Choose an advantage for Question 13.'), findsOneWidget);
  });

  testWidgets('ring overflow demands a replacement before finishing',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final build = completeBuild()..familyRing = 'Earth'; // Earth 4 -> capped
    await tester.pumpWidget(MaterialApp(
      home: NewCharacterWizard(initialState: build),
    ));
    await tester.pumpAndSettle();
    for (var page = 1; page <= 6; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Please select replacement ring(s).'), findsOneWidget);
    expect(find.byType(CharacterEditor), findsNothing);

    build.replacementRings[0] = 'Fire';
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.byType(CharacterEditor), findsOneWidget);
    expect(character.baseRings[ringFire], 2);
  });
}
