import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/custom_legacies_page.dart';
import 'package:paperblossoms/screens/custom_legacy_page.dart';
import 'package:paperblossoms/user_data_store.dart';

import 'temp_stores.dart';
import 'test_app.dart';

/// The custom Legacy form saves memory-first (disk writes are unawaited, so
/// nothing here waits on real IO) and pops the saved name.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  useTempStores('pb_custom_legacy_page_test');

  setUpAll(() async {
    await gameData.load();
  });

  /// The form is a lazily built ListView: on the default 800x600 surface
  /// the lower fields never exist, so every test uses a tall window.
  void tallWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Widget opener(void Function(String?) onPopped) => testApp(Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            onPopped(await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (_) => const CustomLegacyPage()),
            ));
          },
          child: const Text('open'),
        ),
      ));

  testWidgets('saving a custom Legacy registers it and pops its name',
      (tester) async {
    tallWindow(tester);
    String? popped;
    await tester.pumpWidget(opener((name) => popped = name));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Legacy of Asahina Ryu');
    await tester.enterText(fields.at(1), 'The predecessor had 75 glory.');
    await tester.enterText(fields.at(2), 'Remove 3 strife when praised.');
    await tester.enterText(fields.at(3), 'Reroll two dice to impress.');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(popped, 'Legacy of Asahina Ryu');
    final saved = userDataStore.customLegacies.single;
    expect(saved.name, 'Legacy of Asahina Ryu');
    expect(saved.category, categoryLegacies);
    expect(saved.ring, ringWater);
    expect(saved.types, ['Interpersonal', 'Mental']);
    expect('${saved.reference}', 'LoW p.12');
    expect(gameData.advDisadvByName('Legacy of Asahina Ryu'), isNotNull);
    expect(gameData.shortDescFor('Legacy of Asahina Ryu'),
        'The predecessor had 75 glory.');
    expect(gameData.descriptionFor('Legacy of Asahina Ryu'),
        contains('Charge: Remove 3 strife when praised.'));
  });

  testWidgets('a bundled advantage name is refused', (tester) async {
    tallWindow(tester);
    String? popped;
    await tester.pumpWidget(opener((name) => popped = name));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Heroic Life');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('That name already belongs to another advantage.'),
        findsOneWidget);
    expect(popped, isNull);
    expect(userDataStore.customLegacies.where((a) => a.name == 'Heroic Life'),
        isEmpty);
  });

  testWidgets('starting from a template prefills ring and types',
      (tester) async {
    tallWindow(tester);
    await tester.pumpWidget(testApp(const CustomLegacyPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blank'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Secret Teachings').last);
    await tester.pumpAndSettle();
    // Secret Teachings is Void; its printed type string is not one of the
    // chip options, so only Interpersonal stays selected.
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    expect(
        {for (final c in chips) (c.label as Text).data!: c.selected},
        {
          'Interpersonal': true,
          'Mental': false,
          'Physical': false,
          'Spiritual': false,
        });
    expect(find.text('Void'), findsWidgets);
  });

  testWidgets('the management page lists custom Legacies', (tester) async {
    tallWindow(tester);
    // Seeded here, not inherited from an earlier test; a real write, so it
    // runs in runAsync (loads only, never taps).
    await tester.runAsync(() => userDataStore.saveCustomLegacy(const AdvDisadv(
          name: 'Legacy of Doji Ren',
          category: categoryLegacies,
          ring: ringAir,
          types: ['Interpersonal', 'Mental'],
          reference: Reference(book: 'Homebrew', page: '3'),
        )));
    await tester.pumpWidget(testApp(const CustomLegaciesPage()));
    await tester.pumpAndSettle();
    expect(find.text('Legacy of Doji Ren'), findsOneWidget);
    expect(find.textContaining('Homebrew p.3'), findsOneWidget);
    expect(find.text('Create custom Legacy…'), findsOneWidget);
  });

  testWidgets('editing keeps a hand-authored reference', (tester) async {
    tallWindow(tester);
    final entry = gameData.advDisadvByName('Legacy of Doji Ren')!;
    await tester.pumpWidget(testApp(CustomLegacyPage(initial: entry)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(3), 'Reroll two dice.');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    final saved = gameData.advDisadvByName('Legacy of Doji Ren')!;
    expect('${saved.reference}', 'Homebrew p.3');
    expect(gameData.descriptionFor('Legacy of Doji Ren'),
        'Effects: Reroll two dice.');
  });

  group('LegacyText', () {
    test('round-trips the three sections', () {
      const text = LegacyText('Had 75 glory.', 'Remove 3 strife.', 'Reroll.');
      expect(LegacyText.parse(text.compose()).requirement, 'Had 75 glory.');
      expect(LegacyText.parse(text.compose()).charge, 'Remove 3 strife.');
      expect(LegacyText.parse(text.compose()).effects, 'Reroll.');
    });

    test('a label quoted inside a later section stays where it was', () {
      const text = LegacyText('Req.', 'Charge text.',
          'Reroll two dice.\nCharge: none while at war.');
      final parsed = LegacyText.parse(text.compose());
      expect(parsed.charge, 'Charge text.');
      expect(parsed.effects, 'Reroll two dice.\nCharge: none while at war.');
    });

    test('unlabelled text lands in effects; missing sections are empty', () {
      expect(LegacyText.parse('Plain book text.').effects, 'Plain book text.');
      expect(LegacyText.parse('Plain book text.').requirement, '');
      final partial = LegacyText.parse('Effects: Only this.');
      expect(partial.requirement, '');
      expect(partial.charge, '');
      expect(partial.effects, 'Only this.');
    });
  });
}
