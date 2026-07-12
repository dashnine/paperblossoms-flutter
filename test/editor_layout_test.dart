import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/item.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/screens/character_editor.dart';
import 'package:paperblossoms/theme.dart';
import 'package:paperblossoms/widgets/identity_lock_button.dart';

// 1×1 transparent PNG, valid image bytes for Image.memory.
const _tinyPngB64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
    'DwAChwGA60e6kgAAAABJRU5ErkJggg==';

void seedCharacter() {
  character.clear();
  character.name = 'Tetsu';
  character.family = 'Hida';
  character.clan = 'Crab';
  character.school = 'Hida Defender School';
  character.ninjo = 'Protect the weak';
  character.giri = 'Guard the Wall';
  character.heritage = 'Glorious Sacrifice';
  character.baseRings = {
    ringAir: 1,
    ringEarth: 3,
    ringFire: 2,
    ringWater: 1,
    ringVoid: 1,
  };
  character.baseSkills = {'Tactics': 1, 'Command': 1, 'Fitness': 2};
  character.honor = 40;
  character.glory = 44;
  character.status = 30;
  character.koku = 3;
  character.techniques = ['Striking as Earth'];
  character.advDisadv = ['Blunt'];
  character.titles = ['Deathseeker'];
  character.bonds = [CharacterBond(name: 'Companion')];
  character.advanceStack = [
    Advance(
        type: advanceTypeSkill,
        name: 'Command',
        track: trackCurriculum,
        cost: 4),
    Advance(
        type: advanceTypeTechnique,
        name: 'Striking as Water',
        track: trackTitle,
        cost: 3),
  ];
  character.equipment = [
    Item.fromWeapon(gameData.weaponByName('Katana')!,
        gameData.weaponByName('Katana')!.grips.first),
    Item.fromArmor(gameData.armorByName('Ashigaru Armor')!),
    Item.fromPersonalEffect(gameData.personalEffectByName('Blanket') ??
        gameData.personalEffects.first),
  ];
}

Future<void> pumpEditor(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: lightTheme(),
    home: const CharacterEditor(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(seedCharacter);

  for (final (label, size) in [
    ('phone', const Size(400, 800)),
    ('tablet', const Size(800, 1100)),
    ('desktop', const Size(1400, 900)),
  ]) {
    testWidgets('all editor tabs render at $label size', (tester) async {
      await pumpEditor(tester, size);
      expect(find.text('Hida Tetsu'), findsOneWidget);

      final tabs = [
        'Background',
        'Traits',
        'Bonds',
        'Techniques',
        'Equipment',
        'Advancement',
      ];
      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
      }
      // Advancement tab shows the rank status and the advance stack (scroll
      // down first: lazy lists don't build below-the-fold sections).
      expect(find.text('School Rank'), findsOneWidget);
      // On compact/medium the tab is a lazy ListView; scroll below-the-fold
      // sections into existence. On expanded everything is already built.
      if (find.text('Advances Taken').evaluate().isEmpty) {
        final scrollable = find
            .descendant(
                of: find.byType(ListView), matching: find.byType(Scrollable))
            .first;
        await tester.scrollUntilVisible(find.text('Advances Taken'), 200,
            scrollable: scrollable);
      }
      expect(find.text('Advances Taken'), findsOneWidget);
      expect(find.text('Striking as Water'), findsWidgets);
    });
  }

  testWidgets('mutating the character updates the editor reactively',
      (tester) async {
    await pumpEditor(tester, const Size(1400, 900));
    expect(find.text('Hida Tetsu'), findsOneWidget);
    character.name = 'Osamu';
    character.touch();
    await tester.pumpAndSettle();
    expect(find.text('Hida Osamu'), findsOneWidget);
  });

  testWidgets('adding an advance refreshes visible totals immediately',
      (tester) async {
    await pumpEditor(tester, const Size(1400, 900));
    await tester.tap(find.text('Advancement'));
    await tester.pumpAndSettle();
    // Seeded advances: 4 + 3 = 7 XP spent.
    expect(find.text('7'), findsWidgets);
    character.advanceStack.add(Advance(
        type: advanceTypeSkill,
        name: 'Command',
        track: trackCurriculum,
        cost: 6));
    character.touch();
    await tester.pumpAndSettle();
    // The tab must re-render the new total without switching tabs.
    expect(find.text('13'), findsWidgets,
        reason: 'XP Spent stat should show 7+6 after the advance lands');
  });

  testWidgets('picked portrait appears without switching tabs', (tester) async {
    await pumpEditor(tester, const Size(1400, 900));
    expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    // Simulate what PortraitPicker._pick does after the file dialog returns.
    character.portraitB64 = _tinyPngB64;
    character.touch();
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_a_photo_outlined), findsNothing,
        reason: 'portrait must replace the placeholder on the same frame, '
            'not after a tab switch');
    expect(
        find.descendant(
            of: find.byType(InkWell), matching: find.byType(Image)),
        findsOneWidget);
    // decode the 1×1 image before teardown so no pending work leaks
    await tester.runAsync(
        () => precacheImage(MemoryImage(base64Decode(_tinyPngB64)),
            tester.element(find.byType(Image))));
  });

  testWidgets('corrupt portrait data shows the placeholder, not an error',
      (tester) async {
    character.portraitB64 = 'not valid base64!!';
    await pumpEditor(tester, const Size(1400, 900));
    expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('identity lock disables name, family, ninjō, and giri',
      (tester) async {
    await pumpEditor(tester, const Size(1400, 900));
    TextField fieldWithText(String text) =>
        tester.widget<TextField>(find.widgetWithText(TextField, text));
    expect(fieldWithText('Tetsu').enabled, isTrue);
    await tester.tap(find.byType(IdentityLockButton));
    await tester.pumpAndSettle();
    expect(character.identityLocked, isTrue);
    expect(fieldWithText('Tetsu').enabled, isFalse);
    expect(fieldWithText('Hida').enabled, isFalse);

    await tester.tap(find.text('Background'));
    await tester.pumpAndSettle();
    expect(fieldWithText('Protect the weak').enabled, isFalse);
    expect(fieldWithText('Guard the Wall').enabled, isFalse);
    // Notes stay editable even while locked.
    expect(tester
        .widgetList<TextField>(find.byType(TextField))
        .where((f) => f.enabled ?? true), hasLength(1));

    // The Background tab's own button unlocks again.
    await tester.tap(find.byType(IdentityLockButton));
    await tester.pumpAndSettle();
    expect(character.identityLocked, isFalse);
    expect(fieldWithText('Protect the weak').enabled, isTrue);
  });

  testWidgets('removing an advance from the stack recalculates', (tester) async {
    await pumpEditor(tester, const Size(1400, 900));
    await tester.tap(find.text('Advancement'));
    await tester.pumpAndSettle();
    expect(character.advanceStack, hasLength(2));
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pumpAndSettle();
    expect(character.advanceStack, hasLength(1));
  });
}
