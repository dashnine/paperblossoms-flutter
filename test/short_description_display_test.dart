import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Description;
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/add_advance_page.dart';
import 'package:paperblossoms/screens/pickers.dart';
import 'package:paperblossoms/wizard/wizard_widgets.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    gameData.descriptions = [
      const Description(
          name: 'Adopted Peasant',
          description: 'A long rules text.',
          shortDesc: 'Raised among commoners.'),
      const Description(
          name: 'Striking as Earth',
          description: 'A long rules text.',
          shortDesc: 'Guarded kata stance.'),
    ];
  });

  tearDown(() {
    gameData.descriptions = [];
  });

  testWidgets('WizDropdown shows short descriptions in menu and helper text',
      (tester) async {
    var value = '';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => WizDropdown(
            label: 'Distinction',
            value: value,
            options: const ['Adopted Peasant', 'Undescribed Option'],
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    ));
    // Closed with nothing selected: no description anywhere.
    expect(find.text('Raised among commoners.'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    expect(find.text('Raised among commoners.'), findsOneWidget);

    // The menu entry is the last 'Adopted Peasant' (the field's
    // selectedItemBuilder copies come first in the tree).
    await tester.tap(find.text('Adopted Peasant').last);
    await tester.pumpAndSettle();
    // Selected: the description remains visible as helper text.
    expect(find.text('Raised among commoners.'), findsOneWidget);
  });

  testWidgets('PickerPage shows the description line and searches it',
      (tester) async {
    await tester.pumpWidget(testApp(PickerPage<String>(
      title: 'Add Trait',
      items: const ['Adopted Peasant', 'Undescribed Option'],
      labelOf: (name) => name,
      descriptionOf: gameData.shortDescFor,
    )));
    expect(find.text('Raised among commoners.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'commoners');
    await tester.pumpAndSettle();
    expect(find.text('Adopted Peasant'), findsOneWidget);
    expect(find.text('Undescribed Option'), findsNothing);
  });

  testWidgets('advance page technique list shows short descriptions',
      (tester) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    character.clear();
    character.school = 'Hida Defender School';
    character.baseRings = {
      ringAir: 1,
      ringEarth: 3,
      ringFire: 2,
      ringWater: 1,
      ringVoid: 1,
    };
    await tester.pumpWidget(testApp(const AddAdvancePage(
        initialType: advanceTypeTechnique,
        initialOption: 'Striking as Earth')));
    await tester.pumpAndSettle();
    expect(find.text('Guarded kata stance.'), findsOneWidget);
  });
}
