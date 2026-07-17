import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/screens/tools_page.dart';

import 'test_app.dart';

/// Guards the language control against silent label truncation. Material
/// controls never overflow when crowded — SegmentedButton (the previous
/// control here) squeezed and clipped its labels without any RenderFlex
/// error, so screenshots at generous window sizes looked fine while narrow
/// windows truncated. This opens the dropdown at a narrow window and
/// asserts every menu label renders at its full intrinsic width, in every
/// UI locale.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

      var measured = 0;
      for (final text in find.byType(Text).evaluate()) {
        final rp = text.renderObject;
        if (rp is! RenderParagraph || !rp.attached) continue;
        final label = rp.text.toPlainText();
        if (!const [
          'English', 'Français', 'Deutsch', 'Español',
          'System', 'Système', 'Sistema',
        ].contains(label)) {
          continue;
        }
        measured++;
        final intrinsic = rp.getMaxIntrinsicWidth(double.infinity);
        expect(rp.size.width, greaterThanOrEqualTo(intrinsic - 0.5),
            reason: 'language label "$label" is squeezed: needs '
                '${intrinsic.toStringAsFixed(1)}px, got '
                '${rp.size.width.toStringAsFixed(1)}px');
      }
      // The open menu shows all five choices; a lower count means the
      // finder no longer sees the menu — fix the test rather than letting
      // it pass vacuously.
      expect(measured, greaterThanOrEqualTo(5),
          reason: 'expected to measure every language menu label');
    });
  }
}
