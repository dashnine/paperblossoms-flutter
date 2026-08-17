import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/hor_controller.dart';
import 'package:paperblossoms/screens/homebrew_schools_page.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'temp_stores.dart';
import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  useTempStores('pb_tools_test');

  testWidgets('tools page shows description import/export tiles',
      (tester) async {
    gameData.descriptions = [];
    await tester.pumpWidget(testApp(const ToolsPage()));
    await tester.pumpAndSettle();

    // The list builds lazily; scroll the tiles into build range (the
    // Language section above pushes them below the initial viewport).
    await tester.scrollUntilVisible(
        find.text('Export descriptions…'), 100,
        scrollable: find.byType(Scrollable));
    expect(find.text('Import descriptions…'), findsOneWidget);
    expect(find.text('Export descriptions…'), findsOneWidget);

    // Export opens an options dialog; with nothing entered and the template
    // box unchecked it reports instead of opening a save dialog.
    await tester.tap(find.text('Export descriptions…'));
    await tester.pumpAndSettle();
    expect(find.text('Include empty entries'), findsOneWidget);
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(find.text('No descriptions to export.'), findsOneWidget);
  });

  testWidgets('export dialog cancel closes without exporting or reporting',
      (tester) async {
    gameData.descriptions = [];
    await tester.pumpWidget(testApp(const ToolsPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Export descriptions…'), 100,
        scrollable: find.byType(Scrollable));
    await tester.tap(find.text('Export descriptions…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Include empty entries'), findsNothing);
    expect(find.text('No descriptions to export.'), findsNothing);
  });

  testWidgets('Heroes of Rokugan switch is present and defaults off',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await horController.load();
    await tester.pumpWidget(testApp(const ToolsPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Heroes of Rokugan mode'), 100,
        scrollable: find.byType(Scrollable));
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(tile.value, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(horController.value, isTrue);
    await horController.set(false);
  });

  testWidgets('custom schools tile opens the homebrew schools page',
      (tester) async {
    await tester.pumpWidget(testApp(const ToolsPage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Custom schools'), 100,
        scrollable: find.byType(Scrollable));
    await tester.ensureVisible(find.text('Custom schools'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom schools'));
    await tester.pumpAndSettle();

    expect(find.byType(HomebrewSchoolsPage), findsOneWidget);
    expect(find.text('Build a new school'), findsOneWidget);
  });
}
