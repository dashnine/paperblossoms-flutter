import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/item.dart';
import 'package:paperblossoms/screens/character_editor.dart';
import 'package:paperblossoms/screens/tab_equipment.dart';
import 'package:paperblossoms/theme.dart';
import 'package:paperblossoms/widgets/int_spinner.dart';
import 'package:paperblossoms/wizard/wizard_shell.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  group('IntSpinner direct entry', () {
    testWidgets('tapping the value opens a dialog and clamps to max',
        (tester) async {
      int? result;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IntSpinner(
            label: 'Glory',
            value: 40,
            max: 100,
            onChanged: (v) => result = v,
          ),
        ),
      ));
      await tester.tap(find.text('40'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.enterText(
          find.descendant(
              of: find.byType(AlertDialog), matching: find.byType(TextField)),
          '250');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(result, 100); // clamped to max
    });
  });

  group('editor unsaved-changes guard', () {
    Future<NavigatorState> pumpEditorRoute(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: lightTheme(),
        home: const Scaffold(body: Text('chooser')),
      ));
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(
          MaterialPageRoute(builder: (context) => const CharacterEditor()));
      await tester.pumpAndSettle();
      return nav;
    }

    testWidgets('clean character pops without a dialog', (tester) async {
      character.clear();
      final nav = await pumpEditorRoute(tester);
      nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(CharacterEditor), findsNothing);
      expect(find.text('chooser'), findsOneWidget);
    });

    testWidgets('dirty character shows the dialog; Discard closes',
        (tester) async {
      character.clear();
      final nav = await pumpEditorRoute(tester);
      character.name = 'Osamu';
      character.touch();
      await tester.pumpAndSettle();

      nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterEditor), findsOneWidget);

      nav.maybePop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(CharacterEditor), findsNothing);
    });
  });

  group('wizard discard guard', () {
    Future<NavigatorState> pumpWizardRoute(
        WidgetTester tester, WizardState state) async {
      await tester.pumpWidget(MaterialApp(
        theme: lightTheme(),
        home: const Scaffold(body: Text('chooser')),
      ));
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(MaterialPageRoute(
          builder: (context) => NewCharacterWizard(initialState: state)));
      await tester.pumpAndSettle();
      return nav;
    }

    testWidgets('blank wizard pops freely', (tester) async {
      final nav = await pumpWizardRoute(tester, WizardState());
      nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(NewCharacterWizard), findsNothing);
    });

    testWidgets('answered wizard asks before discarding', (tester) async {
      final nav = await pumpWizardRoute(tester, WizardState()..clan = 'Crab');
      nav.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Discard this character?'), findsOneWidget);

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(find.byType(NewCharacterWizard), findsOneWidget);

      nav.maybePop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.byType(NewCharacterWizard), findsNothing);
    });
  });

  group('equipment removal undo', () {
    testWidgets('Undo restores the removed item', (tester) async {
      // Compact width: cards keep the remove button on-screen (the wide
      // layout puts it at the end of a horizontally scrolled DataTable).
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      character.clear();
      final katana = gameData.weaponByName('Katana')!;
      character.equipment = [Item.fromWeapon(katana, katana.grips.first)];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: character,
            builder: (context, _) => const EquipmentTab(),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remove').first);
      // Let the snackbar finish animating in before tapping its action.
      await tester.pumpAndSettle();
      expect(character.equipment, isEmpty);
      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(character.equipment, hasLength(1));
      expect(character.equipment.single.name, 'Katana');
    });
  });

  group('character store index', () {
    test('legacy string entries and new map entries both list', () async {
      final temp = await Directory.systemTemp.createTemp('pb_index_test');
      addTearDown(() => temp.delete(recursive: true));
      characterStore.documentsDirectory = () async => temp;

      final dir = Directory('${temp.path}/paperblossoms/characters');
      dir.createSync(recursive: true);
      File('${dir.path}/index.json').writeAsStringSync(jsonEncode({
        'legacy-uuid': 'Old Name',
        'new-uuid': {
          'name': 'Hida Tetsu',
          'clan': 'Crab',
          'school': 'Hida Defender School',
          'rank': 2,
        },
      }));

      final summaries = await characterStore.list();
      final legacy = summaries.singleWhere((s) => s.uuid == 'legacy-uuid');
      expect(legacy.name, 'Old Name');
      expect(legacy.clan, '');
      expect(legacy.rank, 0);

      final fresh = summaries.singleWhere((s) => s.uuid == 'new-uuid');
      expect(fresh.name, 'Hida Tetsu');
      expect(fresh.clan, 'Crab');
      expect(fresh.school, 'Hida Defender School');
      expect(fresh.rank, 2);
    });

    test('save writes chooser details and clears the dirty flag', () async {
      final temp = await Directory.systemTemp.createTemp('pb_save_test');
      addTearDown(() => temp.delete(recursive: true));
      characterStore.documentsDirectory = () async => temp;

      character.clear();
      character.name = 'Tetsu';
      character.family = 'Hida';
      character.clan = 'Crab';
      character.school = 'Hida Defender School';
      character.touch();
      expect(character.dirty, isTrue);

      await characterStore.save();
      expect(character.dirty, isFalse);

      final summaries = await characterStore.list();
      final saved = summaries.singleWhere((s) => s.uuid == character.uuid);
      expect(saved.name, 'Hida Tetsu');
      expect(saved.clan, 'Crab');
      expect(saved.school, 'Hida Defender School');
      expect(saved.rank, 1);
    });
  });
}
