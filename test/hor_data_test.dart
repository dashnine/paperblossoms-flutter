import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

// Heroes of Rokugan bundled data: every name in the HoR files must resolve
// against the loaded stock data (typo/diacritic guard), and the campaign
// container must stay out of the stock lists.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  test('all HoR data files parse into non-empty structures', () {
    expect(gameData.hor.titles, hasLength(6));
    expect(gameData.hor.advantages, isNotEmpty);
    expect(gameData.hor.heritage, hasLength(10));
    expect(gameData.hor.roninBackgrounds, hasLength(6));
    expect(gameData.hor.bans.schools, isNotEmpty);
    expect(gameData.hor.bans.advantages, isNotEmpty);
    expect(gameData.hor.roninStatus, 22);
  });

  test('HoR entries never appear in the stock lists', () {
    final stockTitles = {for (final t in gameData.titles) t.name};
    for (final t in gameData.hor.titles) {
      expect(stockTitles, isNot(contains(t.name)));
    }
    final stockHeritage =
        {for (final h in gameData.heritageEntries) h.source};
    expect(stockHeritage, isNot(contains('HoR')));
    final stockAdv =
        {for (final a in gameData.advantagesDisadvantages) a.name};
    for (final a in gameData.hor.advantages) {
      expect(stockAdv, isNot(contains(a.name)),
          reason: '${a.name} would shadow or be shadowed by a stock entry');
    }
  });

  test('every banned school name resolves against loaded schools', () {
    for (final name in gameData.hor.bans.schools) {
      expect(gameData.schoolByName(name), isNotNull,
          reason: 'banned school not found: $name');
    }
  });

  test('every banned book code exists in the school data', () {
    final books = {for (final s in gameData.schools) s.reference.book};
    for (final book in gameData.hor.bans.schoolBooks) {
      expect(books, contains(book), reason: 'unknown book code: $book');
    }
  });

  test('every allowed ronin school resolves and is not otherwise banned', () {
    for (final name in gameData.hor.bans.roninSchools) {
      expect(gameData.schoolByName(name), isNotNull,
          reason: 'ronin school not found: $name');
      expect(gameData.hor.bans.schools, isNot(contains(name)));
    }
  });

  test('every banned advantage name resolves against loaded entries', () {
    for (final name in [
      ...gameData.hor.bans.advantages,
      ...gameData.hor.bans.advantagesCreationOnly,
    ]) {
      expect(gameData.advDisadvByName(name), isNotNull,
          reason: 'banned advantage not found: $name');
    }
  });

  test('HoR title advancements resolve against loaded data', () {
    final skillGroups = {for (final g in gameData.skillGroups) g.name};
    final categories = gameData.techniqueCategories().toSet();
    for (final title in gameData.hor.titles) {
      expect(title.xpToCompletion, 30);
      expect(title.stipendKoku, greaterThan(0));
      for (final a in title.advancements) {
        switch (a.type) {
          case 'skill':
            expect(gameData.allSkills(), contains(a.name),
                reason: '${title.name}: unknown skill ${a.name}');
          case 'skill_group':
            expect(skillGroups, contains(a.name),
                reason: '${title.name}: unknown skill group ${a.name}');
          case 'technique':
            expect(gameData.techniqueByName(a.name), isNotNull,
                reason: '${title.name}: unknown technique ${a.name}');
          case 'technique_group':
            // "Any technique with a clan Kami's name" is a curriculum
            // description, not a resolvable category.
            if (!a.name.startsWith('Any ')) {
              expect(categories, contains(a.name),
                  reason: '${title.name}: unknown category ${a.name}');
            }
        }
      }
    }
  });

  test('HoR heritage entries map to known effect kinds or the two new ones',
      () {
    for (final h in gameData.hor.heritage) {
      final type = h.otherEffects.type;
      final known =
          WizardState.effectKindOf(h) != HeritageEffectKind.none ||
              type == 'Wealth' ||
              type == 'Outfit Item';
      expect(known, isTrue,
          reason: '${h.result}: unhandled effect type $type');
    }
  });

  test('HoR heritage skill outcomes resolve against loaded skills', () {
    for (final h in gameData.hor.heritage) {
      if (WizardState.effectKindOf(h) != HeritageEffectKind.skill) continue;
      for (final o in h.otherEffects.outcomes) {
        expect(gameData.allSkills(), contains(o.outcome),
            reason: '${h.result}: unknown skill ${o.outcome}');
      }
    }
  });

  test('HoR heritage technique outcomes resolve against categories', () {
    final categories = gameData.techniqueCategories().toSet();
    final entry = gameData.heritageByResult('Stolen Knowledge');
    expect(entry, isNotNull);
    // Stock lookup wins: the Core entry of the same name resolves first.
    expect(entry!.source, 'Core');
    final horEntry = gameData.hor.heritage
        .firstWhere((h) => h.result == 'Stolen Knowledge');
    for (final o in horEntry.otherEffects.outcomes) {
      expect(categories, contains(o.outcome),
          reason: 'unknown technique category ${o.outcome}');
    }
  });

  test('ronin background skills and rings resolve', () {
    final rings = gameData.ringNames().toSet();
    for (final b in gameData.hor.roninBackgrounds) {
      for (final ring in b.ringOptions) {
        expect(rings, contains(ring), reason: '${b.name}: bad ring $ring');
      }
      for (final choice in b.skillChoices) {
        for (final skill in choice) {
          expect(gameData.allSkills(), contains(skill),
              reason: '${b.name}: unknown skill $skill');
        }
      }
      expect(b.glory, greaterThan(0));
      expect(b.startingWealth.value, greaterThan(0));
    }
  });

  test('heritage auto-grants resolve via the name lookup fall-through', () {
    expect(gameData.advDisadvByName('Support of the Brotherhood'), isNotNull);
    expect(gameData.advDisadvByName('Blackmailed by the Imperial Treasurer'),
        isNotNull);
  });
}
