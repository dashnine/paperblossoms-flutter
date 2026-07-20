import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/encounter.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/screens/encounter_editor_page.dart';
import 'package:paperblossoms/screens/npc_detail_page.dart';
import 'package:paperblossoms/screens/npc_library_page.dart';
import 'package:paperblossoms/screens/npc_quick_build_page.dart';
import 'package:paperblossoms/screens/tools_page.dart';
import 'package:paperblossoms/user_data_store.dart';

import 'test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('pb_npc_pages_test');
    userDataStore.documentsDirectory = () async => tempDir;
    await gameData.load();
  });

  tearDownAll(() async {
    await tempDir.delete(recursive: true);
  });

  testWidgets('tools page shows the Game master section', (tester) async {
    await tester.pumpWidget(testApp(const ToolsPage()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Encounters'), 100,
        scrollable: find.byType(Scrollable));
    expect(find.text('Game master'), findsOneWidget);
    expect(find.text('NPCs & stat blocks'), findsOneWidget);
  });

  testWidgets('library lists samples and filters by search and type',
      (tester) async {
    await tester.pumpWidget(testApp(const NpcLibraryPage()));
    await tester.pumpAndSettle();
    expect(find.text('Bear'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bandit');
    await tester.pumpAndSettle();
    expect(find.text('Desperate Bandit'), findsOneWidget);
    expect(find.text('Experienced Bandit'), findsOneWidget);
    expect(find.text('Bear'), findsNothing);

    // Type filter narrows further: Experienced Bandit is an adversary.
    await tester.tap(find.text('Minions'));
    await tester.pumpAndSettle();
    expect(find.text('Desperate Bandit'), findsOneWidget);
    expect(find.text('Experienced Bandit'), findsNothing);
  });

  testWidgets('detail page renders the full stat block', (tester) async {
    final npc = gameData.npc.sampleByName('Seasoned Courtier')!;
    await tester.pumpWidget(testApp(NpcDetailPage(npc: npc)));
    await tester.pumpAndSettle();

    expect(find.text('Seasoned Courtier'), findsOneWidget);
    expect(find.textContaining('Conflict rank'), findsOneWidget);
    expect(find.textContaining('Shrewd'), findsWidgets);
    await tester.scrollUntilVisible(
        find.text('Whispering Winds'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('learns a rumor'), findsOneWidget);
  });

  testWidgets('minion detail shows the minion-rules footnote',
      (tester) async {
    final npc = gameData.npc.sampleByName('Desperate Bandit')!;
    await tester.pumpWidget(testApp(NpcDetailPage(npc: npc)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.textContaining('defeated when fatigue exceeds'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('defeated when fatigue exceeds'),
        findsOneWidget);
  });

  testWidgets('quick build: base + Warrior template saves a custom NPC',
      (tester) async {
    // Tall surface so the lazy list builds the whole page (result card and
    // save button included) without scroll gymnastics.
    tester.view.physicalSize = const Size(1000, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final base = gameData.npc.sampleByName('Loyal Bushi')!;
    await tester.pumpWidget(testApp(NpcQuickBuildPage(base: base)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Warrior'));
    await tester.pumpAndSettle();
    // Book-default technique picks appear as chips.
    expect(find.text('Striking as Fire'), findsWidgets);
    expect(find.text('Tactical Assessment'), findsWidgets);
    // Live result reflects the CR bumps (4+2 / 2+1).
    expect(find.textContaining('Combat 6'), findsWidgets);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = gameData.npc.sampleByName('Warrior Loyal Bushi');
    expect(saved, isNotNull);
    expect(saved!.custom, isTrue);
    expect(saved.crCombat, 6);
    expect(saved.techniques,
        ['Striking as Fire', 'Tactical Assessment']);
    // Real disk IO needs the real async zone (never tap inside runAsync).
    await tester.runAsync(() => userDataStore.deleteAllCustomNpcs());
  });

  testWidgets('encounter editor shows encounter ranks and updates on count',
      (tester) async {
    final encounter = Encounter(
      name: 'Ambush',
      entries: [
        EncounterEntry(npc: 'Desperate Bandit', count: 4),
        EncounterEntry(npc: 'Experienced Bandit'),
      ],
    );
    await tester
        .pumpWidget(testApp(EncounterEditorPage(encounter: encounter)));
    await tester.pumpAndSettle();

    // 4×(1/1) + 1×(3/2) = combat 7, intrigue 6.
    expect(find.textContaining('Combat encounter rank: 7'), findsOneWidget);
    expect(
        find.textContaining('Intrigue encounter rank: 6'), findsOneWidget);
    // Thresholds for combat 7: even 7, easy 11, hard 3 (intrigue 6 also
    // halves to hard 3, so the hard line appears under both ranks).
    expect(find.textContaining('≈ 7'), findsOneWidget);
    expect(find.textContaining('11 or more'), findsOneWidget);
    expect(find.textContaining('3 or less'), findsNWidgets(2));

    // Bump the desperate bandits 4 → 5.
    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Combat encounter rank: 8'), findsOneWidget);
  });

  testWidgets('tapping a roster row opens the NPC stat block',
      (tester) async {
    final encounter = Encounter(
      name: 'Ambush',
      entries: [EncounterEntry(npc: 'Desperate Bandit', count: 4)],
    );
    await tester
        .pumpWidget(testApp(EncounterEditorPage(encounter: encounter)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Desperate Bandit'));
    await tester.pumpAndSettle();
    // Now on the detail page: the stat block's demeanor section renders.
    expect(find.textContaining('Ambitious'), findsWidgets);
    await tester.scrollUntilVisible(
        find.textContaining('Ambush Tactics'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.textContaining('Ambush Tactics'), findsOneWidget);
  });

  testWidgets('missing roster names render as missing and skip the math',
      (tester) async {
    final encounter = Encounter(
      name: 'Ghost roster',
      entries: [
        EncounterEntry(npc: 'No Such NPC', count: 3),
        EncounterEntry(npc: 'Desperate Bandit'),
      ],
    );
    await tester
        .pumpWidget(testApp(EncounterEditorPage(encounter: encounter)));
    await tester.pumpAndSettle();
    expect(find.textContaining('No Such NPC (missing)'), findsOneWidget);
    expect(find.textContaining('Combat encounter rank: 1'), findsOneWidget);
  });
}
