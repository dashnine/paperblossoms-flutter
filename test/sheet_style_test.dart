import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/sheet_style_controller.dart';
import 'package:paperblossoms/user_data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to structured when no preference is stored', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = SheetStyleController();
    await controller.load();
    expect(controller.value, SheetStyle.structured);
  });

  test('loads a stored minimalist preference', () async {
    SharedPreferences.setMockInitialValues({'sheet_style': 'minimalist'});
    final controller = SheetStyleController();
    await controller.load();
    expect(controller.value, SheetStyle.minimalist);
  });

  test('set persists across a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = SheetStyleController();
    await controller.set(SheetStyle.minimalist);
    final reloaded = SheetStyleController();
    await reloaded.load();
    expect(reloaded.value, SheetStyle.minimalist);
  });

  group('tools page picker', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('pb_sheet_style_test');
      userDataStore.documentsDirectory = () async => tempDir;
    });

    tearDownAll(() async {
      await tempDir.delete(recursive: true);
    });

    testWidgets('selects the minimalist sheet style', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await sheetStyleController.load();
      await tester.pumpWidget(testApp(const ToolsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Character sheet style'), findsOneWidget);
      await tester.tap(find.text('Structured'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minimalist').last);
      await tester.pumpAndSettle();

      expect(sheetStyleController.value, SheetStyle.minimalist);
      await sheetStyleController.set(SheetStyle.structured);
    });
  });
}
