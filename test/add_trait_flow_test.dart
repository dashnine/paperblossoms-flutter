import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/add_trait_page.dart';

import 'test_app.dart';

/// The in-play trait picker: a priced trait shows its cost and asks for the
/// track before charging; everything else is added outright.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() => character.clear());

  Widget opener() => testApp(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => addTraitFlow(context, category: 'Distinctions'),
          child: const Text('open'),
        ),
      ));

  Future<void> pickStudent(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Student of Akodo');
    await tester.pumpAndSettle();
    expect(find.textContaining('Cost: 3 XP'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Student of Akodo'));
    await tester.pumpAndSettle();
  }

  testWidgets('a priced trait asks for the track and charges it',
      (tester) async {
    character.titles = ['Deathseeker'];
    await tester.pumpWidget(opener());
    await pickStudent(tester);
    expect(find.textContaining('half credit'), findsOneWidget);
    await tester.tap(find.widgetWithText(RadioListTile<String>, 'Title'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(character.advDisadv, ['Student of Akodo']);
    final advance = character.advanceStack.single;
    expect(advance.isAdvantage, isTrue);
    expect(advance.track, trackTitle);
    expect(advance.cost, 3);
  });

  testWidgets('without a title only the curriculum track is offered',
      (tester) async {
    await tester.pumpWidget(opener());
    await pickStudent(tester);
    expect(find.widgetWithText(RadioListTile<String>, 'Curriculum'),
        findsOneWidget);
    expect(find.widgetWithText(RadioListTile<String>, 'Title'), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(character.advanceStack.single.track, trackCurriculum);
  });

  testWidgets('cancelling the track dialog adds nothing', (tester) async {
    await tester.pumpWidget(opener());
    await pickStudent(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(character.advDisadv, isEmpty);
    expect(character.advanceStack, isEmpty);
  });

  testWidgets('a free trait is added without a dialog', (tester) async {
    await tester.pumpWidget(opener());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Large Stature');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Large Stature'));
    await tester.pumpAndSettle();
    expect(character.advDisadv, ['Large Stature']);
    expect(character.advanceStack, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
