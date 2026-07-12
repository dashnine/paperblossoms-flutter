import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/user_data_store.dart';

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
    await tester.pumpWidget(const MaterialApp(home: ToolsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Import descriptions…'), findsOneWidget);
    expect(find.text('Export descriptions…'), findsOneWidget);

    // Export with nothing entered reports instead of opening a save dialog.
    await tester.ensureVisible(find.text('Export descriptions…'));
    await tester.tap(find.text('Export descriptions…'));
    await tester.pump();
    expect(find.text('No descriptions to export.'), findsOneWidget);
  });
}
