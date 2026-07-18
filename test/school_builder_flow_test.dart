import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/derived_stats.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/user_data_store.dart';
import 'package:paperblossoms/wizard/school_builder/school_builder_shell.dart';
import 'package:paperblossoms/wizard/school_builder/school_builder_state.dart';

import 'test_app.dart';

/// A complete Bushi school, mirroring school_builder_state_test's fixture.
SchoolBuilderState completeSchool() {
  final state = SchoolBuilderState()
    ..roles = ['Bushi']
    ..applyRoleDefaults();
  state
    ..clan = 'Crab'
    ..summary = 'A wall-guard tradition.'
    ..summaryShort = 'Guards the Wall.'
    ..abilityName = 'Way of the Wall'
    ..abilityText = 'Do wall things.'
    ..ringIncrease = ['Earth', 'Water']
    ..masteryName = 'The Wall Endures'
    ..masteryText = 'Do great wall things.'
    ..name = 'Wall Warden School'
    ..techniquesAvailable = ['Kata', 'Rituals', 'Shūji']
    ..accessTouched = true;
  state.startingTechniques[0].options = ['Striking as Earth'];
  state.startingTechniques[1].options = [
    'Rushing Avalanche Style',
    'Iron Forest Style'
  ];
  for (var rank = 1; rank <= 5; rank++) {
    final slots = state.curriculum[rank]!;
    slots[0].advance = 'Martial skills';
    slots[1].advance = 'Command';
    slots[2].advance = 'Labor';
    slots[3].advance = 'Survival';
    slots[4].advance = 'Kata';
    slots[5].advance = 'Striking as Water';
    slots[6].advance = 'Rushing Avalanche Style';
  }
  return state;
}

/// Host page so the wizard has a route to pop back to on save.
Widget host({SchoolBuilderState? initial}) => testApp(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SchoolBuilderWizard(initialState: initial),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    await gameData.load();
    tempDir = await Directory.systemTemp.createTemp('pb_school_builder');
    userDataStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  testWidgets('a complete school walks through all nine steps and saves',
      (tester) async {
    await tester.pumpWidget(host(initial: completeSchool()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    for (var page = 0; page < 8; page++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Save school'));
    await tester.pumpAndSettle();

    // Back on the host page with the school merged in memory (disk writes
    // finish in the background; the file round trip is covered by
    // user_data_store_test).
    expect(find.text('open'), findsOneWidget);
    final school = gameData.schoolByName('Wall Warden School');
    expect(school, isNotNull);
    expect(school!.curriculum, hasLength(35));
    expect(userDataStore.homebrewSchools, isNotEmpty);
    expect(gameData.descriptionFor('Wall Warden School'),
        'A wall-guard tradition.');
    expect(gameData.shortDescFor('Wall Warden School'), 'Guards the Wall.');
    expect(gameData.descriptionFor('Way of the Wall'), 'Do wall things.');
    expect(gameData.descriptionFor('The Wall Endures'),
        'Do great wall things.');

    await tester.runAsync(
        () => userDataStore.deleteHomebrewSchool('Wall Warden School'));
  });

  testWidgets('page 1 blocks Next without a role and soft-warns on three',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Choose at least one role.'), findsOneWidget);

    for (final role in ['Bushi', 'Monk', 'Sage']) {
      await tester.tap(find.text(role));
      await tester.pumpAndSettle();
    }
    expect(find.text('The book recommends at most two roles.'),
        findsOneWidget);
  });

  testWidgets('all nine pages lay out at phone width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (var page = 0; page < 9; page++) {
      await tester.pumpWidget(testApp(SchoolBuilderWizard(
          initialState: completeSchool(), initialPage: page)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'page ${page + 1}');
      // Compact layout: no side panel; the summary lives behind the app-bar
      // icon as a bottom sheet.
      expect(find.byType(VerticalDivider), findsNothing,
          reason: 'page ${page + 1}');
      expect(find.byIcon(Icons.donut_small_outlined), findsOneWidget,
          reason: 'page ${page + 1}');
    }

    // The curriculum page's rank selector is the squeeze-prone widget
    // (SegmentedButton compresses silently): check the German label too.
    await tester.pumpWidget(testApp(
        SchoolBuilderWizard(
            initialState: completeSchool(), initialPage: 6),
        locale: const Locale('de')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('the advancement engine honors a built school', () async {
    final school = completeSchool().toSchool();
    await userDataStore.saveHomebrewSchool(school);

    // Full-cost curriculum matches: a listed skill, a skill inside the
    // rank's group, and the special-access technique by name.
    expect(
        isInCurriculum('Command', advanceTypeSkill, school.name, 1), isTrue);
    expect(
        isInCurriculum('Fitness', advanceTypeSkill, school.name, 1), isTrue,
        reason: 'Fitness is a Martial skill');
    expect(isInCurriculum('Rushing Avalanche Style', advanceTypeTechnique,
            school.name, 1),
        isTrue,
        reason: 'special-access name match bypasses rank bounds');
    expect(
        isInCurriculum('Courtesy', advanceTypeSkill, school.name, 1), isFalse);

    // Purchasable techniques at rank 1: open-access rank 1, the
    // special-access rank-2 kata, but not an above-rank open-access kata.
    final c = Character()..school = school.name;
    final legal = {for (final t in legalTechniques(c)) t.name};
    expect(legal, contains('Striking as Earth'));
    expect(legal, contains('Rushing Avalanche Style'));
    final rank3Kata = gameData
        .techniquesByGroup('Kata', minRank: 3, maxRank: 3)
        .firstWhere((t) => t.name != 'Rushing Avalanche Style');
    expect(legal, isNot(contains(rank3Kata.name)));
    // Invocations are closed to this school entirely.
    final rank1Invocation =
        gameData.techniquesByGroup('Invocations', maxRank: 1).first;
    expect(legal, isNot(contains(rank1Invocation.name)));

    await userDataStore.deleteHomebrewSchool(school.name);
  });
}
