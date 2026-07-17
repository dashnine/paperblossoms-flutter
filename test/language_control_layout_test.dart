import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/add_advance_page.dart';
import 'package:paperblossoms/screens/add_item_page.dart';
import 'package:paperblossoms/screens/tools_page.dart';

import 'test_app.dart';

/// Guards localized controls against silent label truncation. Material
/// controls never overflow when crowded — SegmentedButton (previously used
/// for these controls) squeezed and clipped its labels without any
/// RenderFlex error, so screenshots at generous window sizes looked fine
/// while narrow windows truncated, in English as well as in the longer
/// locales. These tests render each control at a constrained window and
/// assert every label paints at its full intrinsic width, in every UI
/// locale.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async => gameData.load());

  /// Asserts every Text inside [root] whose content is in [labels] renders
  /// unsqueezed, and that at least [expected] of them were seen.
  void expectLabelsUnsqueezed(
      WidgetTester tester, Finder root, Set<String> labels, int expected) {
    var measured = 0;
    for (final text in find
        .descendant(of: root, matching: find.byType(Text))
        .evaluate()) {
      final rp = text.renderObject;
      if (rp is! RenderParagraph || !rp.attached) continue;
      final label = rp.text.toPlainText();
      if (!labels.contains(label)) continue;
      measured++;
      final intrinsic = rp.getMaxIntrinsicWidth(double.infinity);
      expect(rp.size.width, greaterThanOrEqualTo(intrinsic - 0.5),
          reason: 'label "$label" is squeezed: needs '
              '${intrinsic.toStringAsFixed(1)}px, got '
              '${rp.size.width.toStringAsFixed(1)}px');
    }
    expect(measured, greaterThanOrEqualTo(expected),
        reason: 'expected to measure at least $expected labels — the finder '
            'no longer sees the control; fix the test rather than letting '
            'it pass vacuously');
  }

  for (final code in ['en', 'fr', 'de', 'es']) {
    testWidgets('language menu labels are not squeezed [$code]',
        (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
          testApp(const ToolsPage(), locale: Locale(code)));
      await tester.pump();

      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // The open menu shows all five choices.
      expectLabelsUnsqueezed(tester, find.byType(MaterialApp), const {
        'English', 'Français', 'Deutsch', 'Español',
        'System', 'Système', 'Sistema',
      }, 5);
    });

    testWidgets('add-item and add-advance chips fit a 320px phone [$code]',
        (tester) async {
      character.clear();
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
          testApp(const AddItemPage(), locale: Locale(code)));
      await tester.pump();
      expectLabelsUnsqueezed(
          tester, find.byType(ChoiceChip), _anyLocaleChipLabels, 3);

      await tester.pumpWidget(
          testApp(const AddAdvancePage(), locale: Locale(code)));
      await tester.pump();
      expectLabelsUnsqueezed(
          tester, find.byType(ChoiceChip), _anyLocaleChipLabels, 3);
    });
  }
}

/// The item-type and advance-type chip labels across all shipped locales.
const _anyLocaleChipLabels = {
  'Weapon', 'Armor', 'Personal Effect',
  'Arme', 'Armure', 'Effet personnel',
  'Waffe', 'Rüstung', 'Pers. Gegenstand',
  'Arma', 'Armadura', 'Efecto personal',
  'Skill', 'Ring', 'Technique',
  'Compétence', 'Anneau',
  'Fähigkeit', 'Technik',
  'Habilidad', 'Anillo', 'Técnica',
};
