import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/user_data_store.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pb_tools_test');
    userDataStore.documentsDirectory = () async => tempDir;
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

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

    // Export with nothing entered reports instead of opening a save dialog.
    await tester.tap(find.text('Export descriptions…'));
    await tester.pump();
    expect(find.text('No descriptions to export.'), findsOneWidget);
  });
}
