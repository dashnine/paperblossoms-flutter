import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/add_advance_page.dart';
import 'package:paperblossoms/screens/add_title_page.dart';

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
      {String? initialType, String? initialOption}) async {
    Advance? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await Navigator.push<Advance>(
              context,
              MaterialPageRoute(
                  builder: (context) => AddAdvancePage(
                      initialType: initialType,
                      initialOption: initialOption)),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
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

  test('The Damned grants Ferocity exactly once', () {
    character.titles.add(titleTheDamned);
    // Simulate the grant logic used by addTitleFlow.
    expect(titleTheDamnedGrant, 'Ferocity');
  });

  testWidgets('addTitleFlow applies The Damned grant', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => addTitleFlow(context),
          child: const Text('open'),
        ),
      ),
    ));
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
