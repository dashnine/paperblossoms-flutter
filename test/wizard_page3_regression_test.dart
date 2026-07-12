import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/wizard/page3_honor_glory.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

// Regression: picking a Q7 skill used to remove that skill from its own
// dropdown's options, leaving the form field holding a value with zero
// matching items and tripping the framework assertion.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  testWidgets('choosing a Q7 skill keeps it selected without an assertion',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final wizard = WizardState()
      ..characterType = characterTypeSamurai
      ..clan = 'Crab'
      ..family = 'Hida'
      ..familyRing = 'Earth'
      ..school = 'Hida Defender School';

    await tester.pumpWidget(MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) => Scaffold(
          body: Page3HonorGlory(
              wizard: wizard, onChanged: () => setState(() {})),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Q7 negative reveals the skill dropdown.
    await tester.tap(
        find.text('Negative (+1 rank in a skill you do not have)'));
    await tester.pumpAndSettle();

    // Open it and pick a skill.
    await tester.tap(find.text('Skill').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Martial Arts [Ranged]').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(wizard.q7Skill, 'Martial Arts [Ranged]');
    // The selection is still visible in the (rebuilt) dropdown.
    expect(find.text('Martial Arts [Ranged]'), findsWidgets);

    // Picking a different skill afterwards also works.
    await tester.tap(find.text('Martial Arts [Ranged]').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Labor').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(wizard.q7Skill, 'Labor');
  });
}
