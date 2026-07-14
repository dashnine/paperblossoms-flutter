import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/derived_stats.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/tab_character_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  // Earth 3 + Fire 1 → endurance 8; Earth 3 + Water 2 → composure 10.
  void seedRings() {
    character.clear();
    character.baseRings = {
      ringAir: 1,
      ringEarth: 3,
      ringFire: 1,
      ringWater: 2,
      ringVoid: 1,
    };
  }

  group('derived conditions', () {
    test('incapacitated only when fatigue exceeds endurance', () {
      seedRings();
      final rings = effectiveRingRanks(character);
      character.fatigue = 8;
      expect(isIncapacitated(character, rings), isFalse);
      character.fatigue = 9;
      expect(isIncapacitated(character, rings), isTrue);
    });

    test('compromised only when strife exceeds composure', () {
      seedRings();
      final rings = effectiveRingRanks(character);
      character.strife = 10;
      expect(isCompromised(character, rings), isFalse);
      character.strife = 11;
      expect(isCompromised(character, rings), isTrue);
    });
  });

  group('critical strike rules (Table 6-6)', () {
    test('band boundaries match the core book', () {
      expect(critBand(0).name, 'Close Call');
      expect(critBand(2).name, 'Close Call');
      expect(critBand(3).name, 'Flesh Wound');
      expect(critBand(4).name, 'Flesh Wound');
      expect(critBand(5).name, 'Debilitating Gash');
      expect(critBand(6).name, 'Debilitating Gash');
      expect(critBand(7).name, 'Permanent Injury');
      expect(critBand(8).name, 'Permanent Injury');
      expect(critBand(9).name, 'Maiming Blow');
      expect(critBand(11).name, 'Maiming Blow');
      expect(critBand(12).name, 'Agonizing Death');
      expect(critBand(13).name, 'Agonizing Death');
      expect(critBand(14).name, 'Swift Death');
      expect(critBand(15).name, 'Swift Death');
      expect(critBand(16).name, 'Instant Death');
      expect(critBand(16).fatal, isTrue);
    });

    test('fitness check reduces severity by 1 plus bonus successes', () {
      expect(mitigatedSeverity(7, false, 3), 7);
      expect(mitigatedSeverity(7, true, 0), 6);
      expect(mitigatedSeverity(7, true, 2), 4);
      expect(mitigatedSeverity(2, true, 5), 0); // floors at 0
    });

    test('crit conditions resolve ring, razor-edged, and dying rounds', () {
      expect(critConditions(critBand(4), ringFire, razorEdged: false),
          ['Lightly Wounded (Fire)']);
      expect(critConditions(critBand(4), ringFire, razorEdged: true),
          ['Lightly Wounded (Fire)', 'Bleeding']);
      expect(critConditions(critBand(6), ringEarth, razorEdged: false),
          ['Severely Wounded (Earth)']);
      // Scar bands bleed outright, razor-edged or not.
      expect(critConditions(critBand(8), ringAir, razorEdged: false),
          ['Bleeding']);
      expect(critBand(8).scar, isTrue);
      expect(critConditions(critBand(12), ringWater, razorEdged: false),
          ['Severely Wounded (Water)', 'Bleeding', 'Dying (3 rounds)']);
      expect(critConditions(critBand(14), ringWater, razorEdged: false),
          ['Severely Wounded (Water)', 'Bleeding', 'Dying (1 round)']);
      expect(critConditions(critBand(0), ringVoid, razorEdged: true), isEmpty);
    });

    test('addCondition dedupes and escalates wounds per the book', () {
      seedRings();
      expect(addCondition(character, 'Bleeding'), isTrue);
      expect(addCondition(character, 'Bleeding'), isFalse);
      expect(character.conditions, ['Bleeding']);

      // Lightly Wounded again for the same ring becomes Severely Wounded.
      expect(addCondition(character, 'Lightly Wounded (Fire)'), isTrue);
      expect(addCondition(character, 'Lightly Wounded (Fire)'), isTrue);
      expect(character.conditions, ['Bleeding', 'Severely Wounded (Fire)']);

      // A light wound never downgrades an existing severe one.
      expect(addCondition(character, 'Lightly Wounded (Fire)'), isFalse);
      expect(character.conditions, ['Bleeding', 'Severely Wounded (Fire)']);

      // Other rings track independently.
      expect(addCondition(character, 'Lightly Wounded (Water)'), isTrue);
      expect(character.conditions, contains('Lightly Wounded (Water)'));
    });
  });

  group('condition tracking UI', () {
    // The real editor wraps the tabs in a ListenableBuilder on [character];
    // mirror that so touch() rebuilds the tab under test.
    Future<void> pumpTab(WidgetTester tester) async {
      // Expanded (three-column) layout tall enough that the Conditions
      // section is on-screen and hit-testable.
      tester.view.physicalSize = const Size(2000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: character,
            // NOT const — an identical const child would let Flutter skip
            // rebuilding on notify (same pitfall noted in character_editor).
            // ignore: prefer_const_constructors
            builder: (context, _) => CharacterDataTab(),
          ),
        ),
      ));
    }

    testWidgets('chips appear when thresholds are exceeded', (tester) async {
      seedRings();
      character.fatigue = 9;
      character.strife = 11;
      await pumpTab(tester);
      expect(find.text('Incapacitated'), findsOneWidget);
      expect(find.text('Compromised'), findsOneWidget);
    });

    testWidgets('unmask clears strife and its chip', (tester) async {
      seedRings();
      character.strife = 11;
      await pumpTab(tester);
      expect(find.text('Compromised'), findsOneWidget);
      await tester.tap(find.text('Unmask'));
      await tester.pumpAndSettle();
      expect(character.strife, 0);
      expect(find.text('Compromised'), findsNothing);
    });

    testWidgets('recover clears fatigue and its chip', (tester) async {
      seedRings();
      character.fatigue = 9;
      await pumpTab(tester);
      expect(find.text('Incapacitated'), findsOneWidget);
      await tester.tap(find.text('Recover'));
      await tester.pumpAndSettle();
      expect(character.fatigue, 0);
      expect(find.text('Incapacitated'), findsNothing);
    });

    testWidgets('conditions can be added from the picker and deleted',
        (tester) async {
      seedRings();
      await pumpTab(tester);
      expect(find.text('No conditions.'), findsOneWidget);

      await tester.tap(find.byTooltip('Add condition'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prone'));
      await tester.pumpAndSettle();
      expect(character.conditions, ['Prone']);
      expect(find.text('Prone'), findsOneWidget);

      await tester.tap(find.byTooltip('Delete')); // InputChip delete affordance
      await tester.pumpAndSettle();
      expect(character.conditions, isEmpty);
      expect(find.text('No conditions.'), findsOneWidget);
    });

    testWidgets('critical strike flow applies Table 6-6 and adds a scar',
        (tester) async {
      seedRings();
      await pumpTab(tester);

      await tester.tap(find.text('Critical strike…'));
      await tester.pumpAndSettle();
      expect(find.text('Critical strike'), findsOneWidget);

      // Raise severity to 8: Permanent Injury (resist ring defaults to Air).
      final plus = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byIcon(Icons.add_circle_outline));
      for (var i = 0; i < 8; i++) {
        await tester.tap(plus);
        await tester.pump();
      }
      expect(find.textContaining('Permanent Injury'), findsWidgets);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      // The scar picker opens; choose an Air scar from Table 6-6.
      await tester.tap(find.text('Maimed Visage'));
      await tester.pumpAndSettle();

      expect(character.conditions, ['Bleeding']);
      expect(character.advDisadv, contains('Maimed Visage'));
      expect(find.text('Bleeding'), findsWidgets);

      // Let the confirmation snackbar's timer expire.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('successful fitness check downgrades the crit band',
        (tester) async {
      seedRings();
      await pumpTab(tester);

      await tester.tap(find.text('Critical strike…'));
      await tester.pumpAndSettle();
      final plus = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byIcon(Icons.add_circle_outline));
      for (var i = 0; i < 5; i++) {
        await tester.tap(plus);
        await tester.pump();
      }
      expect(find.textContaining('Debilitating Gash'), findsOneWidget);

      await tester.tap(find.text('TN 1 Fitness check succeeded'));
      await tester.pumpAndSettle();
      // Severity 5 − 1 = 4: Flesh Wound instead.
      expect(find.textContaining('Flesh Wound'), findsOneWidget);

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(character.conditions, ['Lightly Wounded (Air)']);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}
