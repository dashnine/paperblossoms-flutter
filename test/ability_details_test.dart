import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' hide Description;
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
import 'package:paperblossoms/screens/tab_character_data.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    character.clear();
    gameData.descriptions = [
      const Description(
          name: 'Way of the Crab',
          description: 'Full rules text for Way of the Crab.',
          shortDesc: 'Reduce damage by school rank.'),
    ];
  });

  tearDown(() {
    gameData.descriptions = [];
  });

  Future<void> pumpTab(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(testApp(Scaffold(
      body: ListenableBuilder(
        listenable: character,
        // ignore: prefer_const_constructors
        builder: (context, _) => CharacterDataTab(),
      ),
    )));
  }

  testWidgets(
      'school ability shows page reference and full rules text, collapsible',
      (tester) async {
    character.school = 'Hida Defender School';
    await pumpTab(tester);
    await tester.pumpAndSettle();

    // Expanded by default: headline, book/page, and full rules text.
    expect(find.text('Way of the Crab — Reduce damage by school rank.'),
        findsOneWidget);
    expect(find.text('Core p.57'), findsOneWidget);
    expect(
        find.text('Full rules text for Way of the Crab.'), findsOneWidget);

    // Tapping the headline collapses the details.
    await tester
        .tap(find.text('Way of the Crab — Reduce damage by school rank.'));
    await tester.pumpAndSettle();
    expect(find.text('Core p.57'), findsNothing);
    expect(find.text('Full rules text for Way of the Crab.'), findsNothing);
  });

  testWidgets('bond ability shows the bond\'s page reference',
      (tester) async {
    character.bonds = [CharacterBond(name: 'Family')];
    await pumpTab(tester);
    await tester.pumpAndSettle();

    expect(find.text('Strong Roots Grow Deep'), findsOneWidget);
    expect(find.text('CoS p.136'), findsOneWidget);
  });

  testWidgets(
      'bond ability falls back to the bond\'s description when the ability '
      'name has none', (tester) async {
    character.bonds = [CharacterBond(name: 'Family')];
    gameData.descriptions = [
      const Description(
          name: 'Family',
          description: 'Kinship obligations, with the ability rules inside.',
          shortDesc: ''),
    ];
    await pumpTab(tester);
    await tester.pumpAndSettle();

    expect(find.text('Strong Roots Grow Deep'), findsOneWidget);
    expect(find.text('Kinship obligations, with the ability rules inside.'),
        findsOneWidget);

    // An entry under the ability name itself still wins over the fallback.
    gameData.descriptions = [
      const Description(
          name: 'Family',
          description: 'Kinship obligations, with the ability rules inside.',
          shortDesc: ''),
      const Description(
          name: 'Strong Roots Grow Deep',
          description: 'Ability-specific rules text.',
          shortDesc: ''),
    ];
    character.touch();
    await tester.pumpAndSettle();
    expect(find.text('Ability-specific rules text.'), findsOneWidget);
    expect(find.text('Kinship obligations, with the ability rules inside.'),
        findsNothing);
  });
}
