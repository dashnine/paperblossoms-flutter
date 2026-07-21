import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/tab_advancement.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    character.clear();
    character.baseRings = {
      ringAir: 1,
      ringEarth: 1,
      ringFire: 1,
      ringWater: 1,
      ringVoid: 1,
    };
  });

  // Rebuild the tab on every character change, like CharacterEditor. NOT
  // const: an identical const child would let Flutter skip the rebuild.
  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(Scaffold(
      body: ListenableBuilder(
        listenable: character,
        // ignore: prefer_const_constructors
        builder: (context, _) => AdvancementTab(),
      ),
    )));
    await tester.pumpAndSettle();
  }

  testWidgets('no bonus curriculum section for a non-Waves school',
      (tester) async {
    character.school = 'Hida Defender School';
    await pumpTab(tester);
    expect(find.text('Bonus curriculum skills'), findsNothing);
  });

  testWidgets('Worldly Rōnin can pick a bonus skill up to the school rank',
      (tester) async {
    character.school = 'Worldly Rōnin Path';
    await pumpTab(tester);

    // Rank 1 allows exactly one pick.
    expect(find.text('Bonus curriculum skills'), findsOneWidget);
    expect(find.text('0 / 1 chosen'), findsOneWidget);

    await tester.tap(find.byTooltip('Add bonus curriculum skill'));
    await tester.pumpAndSettle();
    // The picker lists skills; choose Meditation.
    await tester.ensureVisible(find.text('Meditation').last);
    await tester.tap(find.text('Meditation').last);
    await tester.pumpAndSettle();

    expect(find.text('1 / 1 chosen'), findsOneWidget);
    // The pick shows as a row and the add button is now disabled.
    expect(find.widgetWithText(ListTile, 'Meditation'), findsOneWidget);
    expect(find.byTooltip('Add bonus curriculum skill'), findsNothing);
    expect(find.byTooltip('All picks for your school rank used'),
        findsOneWidget);
  });

  testWidgets('removing a bonus skill frees the slot and offers undo',
      (tester) async {
    character.school = 'Worldly Rōnin Path';
    character.bonusCurriculumSkills = ['Meditation'];
    await pumpTab(tester);
    expect(find.text('1 / 1 chosen'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Remove'));
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('0 / 1 chosen'), findsOneWidget);
    // Undo restores the pick.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 1 chosen'), findsOneWidget);
  });
}
