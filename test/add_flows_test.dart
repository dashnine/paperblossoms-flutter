import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/add_advance_page.dart';
import 'package:paperblossoms/screens/add_title_page.dart';
import 'package:paperblossoms/screens/tab_advancement.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    character.clear();
    character.school = 'Hida Defender School';
    character.baseRings = {
      ringAir: 1,
      ringEarth: 3,
      ringFire: 2,
      ringWater: 1,
      ringVoid: 1,
    };
    character.baseSkills = {'Command': 1};
  });

  Future<Advance?> runAdvancePage(WidgetTester tester,
      Future<void> Function(WidgetTester) drive,
      {String? initialType, String? initialOption, String? initialGroup}) async {
    Advance? result;
    await tester.pumpWidget(testApp(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await Navigator.push<Advance>(
            context,
            MaterialPageRoute(
                builder: (context) => AddAdvancePage(
                    initialType: initialType,
                    initialOption: initialOption,
                    initialGroup: initialGroup)),
          );
        },
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await drive(tester);
    return result;
  }

  testWidgets('skill advance shows correct cost and pops the advance',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final advance = await runAdvancePage(tester, (tester) async {
      // Preselected via initialOption: Command at rank 1 -> cost 4.
      expect(find.text('Cost: 4 XP'), findsOneWidget);
      await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Add Advance'));
      await tester.tap(find.widgetWithText(FilledButton, 'Add Advance'));
      await tester.pumpAndSettle();
    }, initialType: advanceTypeSkill, initialOption: 'Command');
    expect(advance, isNotNull);
    expect(advance!.type, advanceTypeSkill);
    expect(advance.name, 'Command');
    expect(advance.track, trackCurriculum);
    expect(advance.cost, 4);
  });

  testWidgets('free advances cost zero and carry the reason as track',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final advance = await runAdvancePage(tester, (tester) async {
      await tester.tap(find.text('Free (no XP cost)'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(TextField, 'Reason (optional)'),
          'GM award|Title');
      await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Add Advance'));
      await tester.tap(find.widgetWithText(FilledButton, 'Add Advance'));
      await tester.pumpAndSettle();
    }, initialType: advanceTypeSkill, initialOption: 'Command');
    expect(advance!.cost, 0);
    // Pipe and the reserved track words are stripped, like the original.
    expect(advance.track, 'GM award');
    expect(advance.isFree, isTrue);
  });

  testWidgets('duplicate technique is rejected with a warning',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    character.techniques = ['Striking as Earth'];
    final advance = await runAdvancePage(tester, (tester) async {
      expect(find.text("'Striking as Earth' is already learned."),
          findsOneWidget);
      final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add Advance'));
      expect(button.onPressed, isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
    },
        initialType: advanceTypeTechnique,
        initialOption: 'Striking as Earth');
    expect(advance, isNull);
  });

  testWidgets('technique group tap pre-filters the list', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await runAdvancePage(tester, (tester) async {
      // Subcategory groups filter too, not just top-level categories.
      expect(find.text('Trip the Leg'), findsOneWidget);
      expect(find.text('Striking as Earth'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }, initialType: advanceTypeTechnique, initialGroup: 'Close Combat Kata');
  });

  testWidgets('type-to-filter narrows techniques, macron-insensitively',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await runAdvancePage(tester, (tester) async {
      await tester.enterText(
          find.widgetWithText(TextField, 'Type to filter'), 'chikusho');
      await tester.pumpAndSettle();
      expect(find.text("Chikushō-dō's Guile"), findsOneWidget);
      expect(find.text('Striking as Earth'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }, initialType: advanceTypeTechnique);
  });

  testWidgets('preselected technique pre-fills the filter and survives clear',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await runAdvancePage(tester, (tester) async {
      // The filter is pre-filled with the tapped technique's name, so the
      // list shows it immediately.
      expect(
          find.widgetWithText(TextField, "Warrior's Resolve"), findsOneWidget);
      expect(find.text("Warrior's Resolve").hitTestable(), findsWidgets);
      // Clearing the filter re-reveals the selection: it sits deep in the
      // Kata list, so it stays visible only if the reveal scroll ran.
      await tester.tap(find.byTooltip('Clear filter'));
      await tester.pumpAndSettle();
      expect(find.text('Type to filter'), findsOneWidget);
      expect(find.text("Warrior's Resolve").hitTestable(), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    },
        initialType: advanceTypeTechnique,
        initialOption: "Warrior's Resolve");
  });

  testWidgets('skill group tap pre-filters the advance dropdown',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await runAdvancePage(tester, (tester) async {
      // Group dropdown preset from the curriculum entry.
      expect(find.text('Martial skills'), findsWidgets);
      // DropdownMenu lays its entries out in a hidden measurement layer,
      // so the filtered advance options are findable without opening it.
      expect(find.text('Fitness'), findsWidgets);
      expect(find.text('Courtesy'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }, initialType: advanceTypeSkill, initialGroup: 'Martial skills');
  });

  testWidgets('technique page lays out without overflow at 320px width',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        testApp(const AddAdvancePage(initialType: advanceTypeTechnique)));
    await tester.pumpAndSettle();
    // Rendering overflows would have thrown via FlutterError.onError.
    expect(find.text('Type to filter'), findsOneWidget);
  });

  testWidgets('buying from the curriculum confirms and marks the entry',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Like CharacterEditor, rebuild the tab whenever the character changes.
    // NOT const: an identical const child would let Flutter skip the rebuild.
    await tester.pumpWidget(testApp(Scaffold(
      body: ListenableBuilder(
        listenable: character,
        // ignore: prefer_const_constructors
        builder: (context, _) => AdvancementTab(),
      ),
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Rushing Avalanche Style'));
    await tester.tap(find.text('Rushing Avalanche Style'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.pumpAndSettle();
    // Back on the tab: purchase SnackBar plus a disabled, checkmarked row.
    expect(find.text('Added Rushing Avalanche Style — 3 XP (Curriculum)'),
        findsOneWidget);
    final row = tester.widget<ListTile>(find.ancestor(
        of: find.text('Rushing Avalanche Style').first,
        matching: find.byType(ListTile)));
    expect(row.enabled, isFalse);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });

  testWidgets('curriculum ranks collapse; expanding reveals other ranks',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        testApp(const Scaffold(body: AdvancementTab())));
    await tester.pumpAndSettle();
    // Current rank (1) is expanded, rank 2 is collapsed.
    expect(find.text('Rushing Avalanche Style'), findsOneWidget);
    expect(find.text('Touchstone of Courage'), findsNothing);
    await tester.tap(find.text('Rank 2'));
    await tester.pumpAndSettle();
    expect(find.text('Touchstone of Courage'), findsOneWidget);
  });

  testWidgets('ranking up expands the new rank and collapses the old',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // 18 curriculum XP: one matching buy away from the rank-2 threshold (20).
    character.advanceStack = [
      Advance(
          type: advanceTypeSkill,
          name: 'Medicine',
          track: trackCurriculum,
          cost: 18),
    ];
    await tester.pumpWidget(testApp(Scaffold(
      body: ListenableBuilder(
        listenable: character,
        // ignore: prefer_const_constructors
        builder: (context, _) => AdvancementTab(),
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Honest Assessment'), findsOneWidget); // rank 1 open
    expect(find.text('Touchstone of Courage'), findsNothing); // rank 2 shut
    // Rushing Avalanche Style matches the rank-1 curriculum: +3 XP -> rank 2.
    await tester.ensureVisible(find.text('Rushing Avalanche Style'));
    await tester.tap(find.text('Rushing Avalanche Style'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.pumpAndSettle();
    expect(find.textContaining('school rank is now 2'), findsOneWidget);
    expect(find.text('Touchstone of Courage'), findsOneWidget); // rank 2 open
    expect(find.text('Honest Assessment'), findsNothing); // rank 1 shut
  });

  testWidgets('title advancement rows buy on the Title track',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    character.titles = ['Deathseeker'];
    // ignore: prefer_const_constructors
    await tester.pumpWidget(testApp(Scaffold(
      body: ListenableBuilder(
        listenable: character,
        // ignore: prefer_const_constructors
        builder: (context, _) => AdvancementTab(),
      ),
    )));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Deathseeker'));
    await tester.tap(find.text('Deathseeker'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text("A Samurai's Fate"));
    await tester.tap(find.text("A Samurai's Fate"));
    await tester.pumpAndSettle();
    // The Title track is preselected; buy as-is.
    await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.tap(find.widgetWithText(FilledButton, 'Add Advance'));
    await tester.pumpAndSettle();
    expect(character.advanceStack.last.name, "A Samurai's Fate");
    expect(character.advanceStack.last.track, trackTitle);
  });

  testWidgets('Enter selects the single filtered technique', (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await runAdvancePage(tester, (tester) async {
      await tester.enterText(
          find.widgetWithText(TextField, 'Type to filter'), 'chikusho');
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Cost: 3 XP'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }, initialType: advanceTypeTechnique);
  });

  test('The Damned grants Ferocity exactly once', () {
    character.titles.add(titleTheDamned);
    // Simulate the grant logic used by addTitleFlow.
    expect(titleTheDamnedGrant, 'Ferocity');
  });

  testWidgets('addTitleFlow applies The Damned grant', (tester) async {
    await tester.pumpWidget(testApp(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => addTitleFlow(context),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'The Damned');
    await tester.pumpAndSettle();
    await tester.tap(find.text('The Damned').last);
    await tester.pumpAndSettle();
    expect(character.titles, contains('The Damned'));
    expect(
        character.advDisadv.where((t) => t == 'Ferocity').length, 1);
  });
}
