import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/encounter.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/generate_pdf_npc.dart';
import 'package:paperblossoms/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  final strings = lookupAppLocalizations(const Locale('en'));

  test('single NPC stat block renders for every bundled sample', () async {
    // Every sample once — catches layout crashes from any block shape
    // (no societal panel, ∞ composure, empty gear, no disadvantages...).
    for (final npc in gameData.npc.samples) {
      final bytes = await buildNpcPdf(npc, strings: strings);
      expect(bytes.length, greaterThan(1000), reason: npc.name);
    }
  });

  test('encounter PDF renders with roster, ranks, and repeated blocks',
      () async {
    final encounter = Encounter(
      name: 'Bandit Ambush',
      entries: [
        EncounterEntry(npc: 'Desperate Bandit', count: 4),
        EncounterEntry(npc: 'Experienced Bandit'),
      ],
      notes: 'Scouts picked the caravan this morning.',
    );
    final roster = [
      for (final e in encounter.entries)
        (npc: gameData.npc.sampleByName(e.npc)!, count: e.count)
    ];
    final bytes =
        await buildEncounterPdf(encounter, roster, strings: strings);
    expect(bytes.length, greaterThan(1000));
  });

  test('an NPC with template-added techniques renders', () async {
    final npc = gameData.npc.sampleByName('Loyal Bushi')!.clone()
      ..techniques = ['Iaijutsu Cut: Crossing Blade', 'Battle in the Mind'];
    final bytes = await buildNpcPdf(npc, strings: strings);
    expect(bytes.length, greaterThan(1000));
  });
}
