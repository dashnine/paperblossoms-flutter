import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';

// Starting-outfit entries that are wizard directives rather than item names;
// page 7 of the wizard resolves these specially.
const specialOutfitEntries = {
  'Traveling Pack',
  'Kitsune Starting Outfit',
  'Yumi and quiver of arrows with three special arrows',
};

bool isRarityDirective(String entry) =>
    entry.startsWith('One ') || entry.startsWith('Two ');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  group('asset loading', () {
    test('all data files parse into non-empty lists', () {
      expect(gameData.clans, isNotEmpty);
      expect(gameData.schools, isNotEmpty);
      expect(gameData.skillGroups, isNotEmpty);
      expect(gameData.rings, hasLength(5));
      expect(gameData.techniques, isNotEmpty);
      expect(gameData.advantagesDisadvantages, isNotEmpty);
      expect(gameData.bonds, isNotEmpty);
      expect(gameData.weapons, isNotEmpty);
      expect(gameData.armor, isNotEmpty);
      expect(gameData.personalEffects, isNotEmpty);
      expect(gameData.qualities, isNotEmpty);
      expect(gameData.itemPatterns, isNotEmpty);
      expect(gameData.heritageEntries, isNotEmpty);
      expect(gameData.regions, isNotEmpty);
      expect(gameData.upbringings, isNotEmpty);
      expect(gameData.titles, isNotEmpty);
      expect(gameData.question8Options, isNotEmpty);
    });

    test('rings are the five canonical elements', () {
      expect(gameData.ringNames(),
          containsAll(['Air', 'Earth', 'Fire', 'Water', 'Void']));
    });

    test('no duplicate names within a data type', () {
      for (final (label, names) in [
        ('clans', [for (final c in gameData.clans) c.name]),
        ('schools', [for (final s in gameData.schools) s.name]),
        ('techniques', [for (final t in gameData.techniques) t.name]),
        ('titles', [for (final t in gameData.titles) t.name]),
        ('bonds', [for (final b in gameData.bonds) b.name]),
        // Weapons are keyed by (category, name): the same weapon may be
        // listed under two categories (e.g. Moshi Sun Ax in Axes and
        // Polearms).
        ('weapons', [for (final w in gameData.weapons) '${w.category}/${w.name}']),
      ]) {
        expect(names.toSet().length, names.length,
            reason: 'duplicate $label names would make name-keyed lookups '
                'ambiguous');
      }
    });
  });

  group('cross-references', () {
    test(
        'every school clan resolves to a clan, a gaijin region subtype, '
        'Rōnin, or is empty', () {
      final clanNames = {for (final c in gameData.clans) c.name};
      final regionSubtypes = {for (final r in gameData.regions) r.subtype};
      for (final school in gameData.schools) {
        expect(
            school.clan.isEmpty ||
                clanNames.contains(school.clan) ||
                regionSubtypes.contains(school.clan) ||
                school.clan == 'Rōnin',
            isTrue,
            reason: 'school "${school.name}" references unknown clan '
                '"${school.clan}" — neither the clan picker nor the gaijin '
                'region picker could ever offer it');
      }
    });

    test('clan and family ring increases resolve to rings', () {
      final rings = gameData.ringNames().toSet();
      for (final clan in gameData.clans) {
        expect(rings, contains(clan.ringIncrease),
            reason: 'clan ${clan.name}');
        for (final family in clan.families) {
          for (final ring in family.ringIncrease) {
            expect(rings, contains(ring),
                reason: 'family ${family.name} of ${clan.name}');
          }
        }
      }
    });

    test('clan and family skill increases resolve to skills', () {
      final skills = gameData.allSkills().toSet();
      for (final clan in gameData.clans) {
        expect(skills, contains(clan.skillIncrease),
            reason: 'clan ${clan.name}');
        for (final family in clan.families) {
          for (final skill in family.skillIncrease) {
            expect(skills, contains(skill),
                reason: 'family ${family.name} of ${clan.name}');
          }
        }
      }
    });

    test(
        'every curriculum advance resolves to a skill, skill group, '
        'technique, or technique category', () {
      // The upstream data sometimes mislabels the `type` field, so the
      // advancement engine resolves names across all four namespaces; this
      // test guards that the union always resolves.
      final union = {
        ...gameData.allSkills(),
        for (final g in gameData.skillGroups) g.name,
        for (final t in gameData.techniques) t.name,
        for (final t in gameData.techniques) t.category,
        for (final t in gameData.techniques) t.subcategory,
      };
      for (final school in gameData.schools) {
        for (final entry in school.curriculum) {
          expect(union, contains(entry.advance),
              reason: 'school "${school.name}" rank ${entry.rank} advance '
                  '"${entry.advance}" resolves nowhere — the advancement '
                  'engine could never match it');
        }
      }
      for (final title in gameData.titles) {
        for (final adv in title.advancements) {
          expect(union, contains(adv.name),
              reason: 'title "${title.name}" advancement "${adv.name}" '
                  'resolves nowhere');
        }
      }
    });

    test(
        'every curriculum/title type label matches what its name resolves '
        'to', () {
      // The XP engine sorts entries into namespaces BY THE LABEL
      // (isInCurriculum/isInTitle): a mislabeled entry silently never counts
      // as in-curriculum and the player banks half XP toward rank. Upstream
      // shipped 17 such labels, patched in our copy of schools.json and
      // titles.json — see docs/UPSTREAM_NOTES.md. This test keeps the class
      // of error extinct, including in future data updates and homebrew.
      final skills = gameData.allSkills().toSet();
      final skillGroups = {for (final g in gameData.skillGroups) g.name};
      final techniques = {for (final t in gameData.techniques) t.name};
      final techniqueGroups = {
        for (final t in gameData.techniques) t.category,
        for (final t in gameData.techniques) t.subcategory,
      };
      final rings = gameData.ringNames().toSet();

      List<String> kindsOf(String name) => [
            if (skills.contains(name)) 'skill',
            if (skillGroups.contains(name)) 'skill_group',
            if (techniques.contains(name)) 'technique',
            if (techniqueGroups.contains(name)) 'technique_group',
            if (rings.contains(name)) 'ring',
          ];

      for (final school in gameData.schools) {
        for (final entry in school.curriculum) {
          final kinds = kindsOf(entry.advance);
          if (kinds.isEmpty) continue; // covered by the resolution test
          expect(kinds, contains(entry.type),
              reason: 'school "${school.name}" rank ${entry.rank}: '
                  '"${entry.advance}" is labeled ${entry.type} but is '
                  'actually ${kinds.join('/')} — the XP engine would '
                  'silently award half XP for it');
        }
      }
      for (final title in gameData.titles) {
        for (final adv in title.advancements) {
          final kinds = kindsOf(adv.name);
          if (kinds.isEmpty) continue;
          expect(kinds, contains(adv.type),
              reason: 'title "${title.name}": "${adv.name}" is labeled '
                  '${adv.type} but is actually ${kinds.join('/')} — the XP '
                  'engine would silently award half XP for it');
        }
      }
    });

    test('Kitsu Realm Wanderer cites Celestial Realms, not Core', () {
      // Upstream labels this school "Core" p.85, but Core p.85 is the Shinjo
      // Outrider and the school actually comes from Celestial Realms p.85.
      // Patched in our schools.json — see docs/UPSTREAM_NOTES.md #5. Guards
      // against re-syncs reintroducing the wrong source.
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Kitsu Realm Wanderer School');
      expect(school.reference.book, 'CR');
      expect(school.reference.page, '85');
    });

    test('Elixir of Recovery is spelled correctly', () {
      // Upstream misspells this Path of Waves ritual "Elxir of Recovery".
      // Patched in our techniques.json — see docs/UPSTREAM_NOTES.md #6.
      // Guards against re-syncs reintroducing the typo.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, contains('Elixir of Recovery'));
      expect(names, isNot(contains('Elxir of Recovery')));
    });

    test('No Sacrifice Too Great is spelled correctly', () {
      // Upstream misspells the Emerald Empire Yōjimbō title ability
      // "No Sacrifice Too Greate". Patched in our titles.json — see
      // docs/UPSTREAM_NOTES.md #7. Guards against re-syncs.
      final abilities = gameData.titles.map((t) => t.titleAbility);
      expect(abilities, contains('No Sacrifice Too Great'));
      expect(abilities, isNot(contains('No Sacrifice Too Greate')));
    });

    test('Inspired Creations matches the book name', () {
      // Upstream calls the Courts of Stone Master Artisan title ability
      // "Inspired Creation"; the book (CoS p. 131) prints "Inspired
      // Creations". Patched in our titles.json — see UPSTREAM_NOTES.md #8.
      final abilities = gameData.titles.map((t) => t.titleAbility);
      expect(abilities, contains('Inspired Creations'));
      expect(abilities, isNot(contains('Inspired Creation')));
    });

    test('Siege Weapons category is spelled correctly', () {
      // Upstream misspells the Shadowlands weapon category "Siege Wepaons".
      // Patched in our weapons.json — see docs/UPSTREAM_NOTES.md #9.
      final categories = gameData.weapons.map((w) => w.category);
      expect(categories, contains('Siege Weapons'));
      expect(categories, isNot(contains('Siege Wepaons')));
    });

    test('Asako Inquisitor School matches the family name', () {
      // Upstream calls the Shadowlands Phoenix school "Asaka Inquisitor
      // School"; the book (SL p. 88) prints "Asako", the Phoenix family.
      // Patched in our schools.json — see docs/UPSTREAM_NOTES.md #10.
      final names = gameData.schools.map((s) => s.name);
      expect(names, contains('Asako Inquisitor School'));
      expect(names, isNot(contains('Asaka Inquisitor School')));
    });

    test('Kansen Whispers matches the book name', () {
      // Upstream spells the alternative Air Taint disadvantage
      // "Shadowlands Taint [Kaisen Whispers]"; the book (SL p. 98) prints
      // "Kansen Whispers" (kansen are the corrupt kami mahō entreats).
      // Patched in our advantages_disadvantages.json — UPSTREAM_NOTES.md #11.
      final names = gameData.advantagesDisadvantages.map((a) => a.name);
      expect(names, contains('Shadowlands Taint [Kansen Whispers]'));
      expect(names, isNot(contains('Shadowlands Taint [Kaisen Whispers]')));
    });

    test('school starting skills resolve to skills', () {
      final skills = gameData.allSkills().toSet();
      for (final school in gameData.schools) {
        for (final skill in school.startingSkills.options) {
          expect(skills, contains(skill), reason: 'school ${school.name}');
        }
      }
    });

    test('school starting techniques resolve to techniques or item patterns',
        () {
      final valid = {
        for (final t in gameData.techniques) t.name,
        // A subcategory name means "pick any technique from it".
        for (final t in gameData.techniques) t.subcategory,
        // Smith schools start with an item pattern (e.g. "Kakita Pattern").
        for (final p in gameData.itemPatterns) p.name,
      };
      for (final school in gameData.schools) {
        for (final set in school.startingTechniques) {
          for (final tech in set.options) {
            expect(valid, contains(tech), reason: 'school ${school.name}');
          }
        }
      }
    });

    test(
        'school starting outfit entries resolve to items or known wizard '
        'directives', () {
      final items = {
        for (final w in gameData.weapons) w.name,
        for (final a in gameData.armor) a.name,
        for (final p in gameData.personalEffects) p.name,
      };
      for (final school in gameData.schools) {
        for (final set in school.startingOutfit) {
          for (final entry in set.options) {
            expect(
                items.contains(entry) ||
                    specialOutfitEntries.contains(entry) ||
                    isRarityDirective(entry),
                isTrue,
                reason: 'school "${school.name}" outfit entry "$entry" is '
                    'neither an item nor a known directive — the wizard '
                    'could not grant it');
          }
        }
      }
    });

    test(
        'school techniques_available resolve to technique categories or '
        'subcategories', () {
      final categories = {
        ...gameData.techniqueCategories(),
        for (final t in gameData.techniques) t.subcategory,
      };
      for (final school in gameData.schools) {
        for (final cat in school.techniquesAvailable) {
          expect(categories, contains(cat), reason: 'school ${school.name}');
        }
      }
    });

    test('region and upbringing increases resolve', () {
      final rings = gameData.ringNames().toSet();
      final skills = gameData.allSkills().toSet();
      for (final region in gameData.regions) {
        expect(rings, contains(region.ringIncrease),
            reason: 'region ${region.name}');
        expect(skills, contains(region.skillIncrease),
            reason: 'region ${region.name}');
      }
      // 'any' is a directive meaning the player picks freely.
      for (final upbringing in gameData.upbringings) {
        for (final ring in upbringing.ringIncrease.options) {
          expect({...rings, 'any'}, contains(ring),
              reason: 'upbringing ${upbringing.name}');
        }
        for (final set in upbringing.skillIncreases) {
          for (final skill in set.options) {
            expect({...skills, 'any'}, contains(skill),
                reason: 'upbringing ${upbringing.name}');
          }
        }
      }
    });
  });

  group('heritage tables', () {
    test('each source tiles rolls 1-10 without gaps or overlaps', () {
      final sources = {for (final h in gameData.heritageEntries) h.source};
      for (final source in sources) {
        final entries = gameData.heritagesBySource(source);
        final covered = <int>[];
        for (final entry in entries) {
          for (var roll = entry.rollMin; roll <= entry.rollMax; roll++) {
            covered.add(roll);
          }
        }
        covered.sort();
        expect(covered, List.generate(10, (i) => i + 1),
            reason: 'heritage source "$source" must cover d10 rolls 1-10 '
                'exactly once');
      }
    });

    test('heritageByRoll resolves every roll for every source', () {
      final sources = {for (final h in gameData.heritageEntries) h.source};
      for (final source in sources) {
        for (var roll = 1; roll <= 10; roll++) {
          expect(gameData.heritageByRoll(source, roll), isNotNull,
              reason: 'source $source roll $roll');
        }
      }
    });
  });

  group('lookups', () {
    test('weapon grips and rarity filtering behave', () {
      final katana = gameData.weaponByName('Katana');
      expect(katana, isNotNull);
      expect(katana!.category, 'Swords');
      expect(katana.grips, isNotEmpty);
      expect(gameData.weaponsUnderRarity(0), isEmpty);
      expect(gameData.weaponsUnderRarity(9), isNotEmpty);
    });

    test('technique group filtering respects rank bounds', () {
      final all = gameData.techniquesByGroup('Kata');
      expect(all, isNotEmpty);
      final lowRank = gameData.techniquesByGroup('Kata', maxRank: 1);
      expect(lowRank.length, lessThan(all.length));
      expect([for (final t in lowRank) t.rank], everyElement(equals(1)));
    });

    test('itemTypeOf distinguishes the three item types', () {
      expect(gameData.itemTypeOf('Katana'), 'Weapon');
      expect(gameData.itemTypeOf('Ashigaru Armor'), 'Armor');
      expect(gameData.itemTypeOf('Nonexistent Thing'), '');
    });
  });
}
