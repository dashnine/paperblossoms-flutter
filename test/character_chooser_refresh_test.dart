import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/character_store.dart';
import 'package:paperblossoms/l10n/l10n.dart';
import 'package:paperblossoms/locale_controllers.dart';
import 'package:paperblossoms/screens/character_chooser.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pb_chooser_test');
    characterStore.documentsDirectory = () async => tempDir;
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  // Real file I/O never completes inside the widget test's fake-async zone,
  // so store-touching steps run in runAsync; taps and pumps stay outside.
  Future<void> settleIO(WidgetTester tester) async {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }

  testWidgets(
      'list refreshes when the editor pops after the wizard pushReplaced it',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: supportedUiLocales,
        navigatorObservers: [routeObserver],
        home: const CharacterChooser(),
      ));
    });
    await settleIO(tester);
    expect(find.byType(ListTile), findsNothing);

    // Wizard stand-in pushed over the chooser.
    final navigator =
        Navigator.of(tester.element(find.byType(CharacterChooser)));
    navigator.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('wizard'))));
    await tester.pumpAndSettle();

    // Finish: save the assembled character and replace the wizard with the
    // editor, exactly like wizard_shell's _next().
    character.clear();
    character.name = 'Tetsu';
    character.family = 'Hida';
    await tester.runAsync(() => characterStore.save());
    navigator.pushReplacement(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('editor'))));
    await settleIO(tester);

    // Back from the editor: the new character must appear without a restart.
    // Popping inside runAsync keeps the resulting refresh I/O in the real
    // zone where it can complete.
    await tester.runAsync(() async {
      navigator.pop();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(find.text('Hida Tetsu'), findsOneWidget);
  });
}
