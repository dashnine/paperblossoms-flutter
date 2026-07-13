import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

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

    test("Kirifu's Oath matches the book name", () {
      // Upstream names the Fields of Victory Deathseeker title ability
      // "Kifu's Oath"; the book (FoV p. 132) prints "Kirifu's Oath", after
      // Kirifu, the first Deathseeker. Patched in our titles.json — see
      // docs/UPSTREAM_NOTES.md #12.
      final abilities = gameData.titles.map((t) => t.titleAbility);
      expect(abilities, contains("Kirifu's Oath"));
      expect(abilities, isNot(contains("Kifu's Oath")));
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

    test('Rejuvenating Breath is spelled correctly', () {
      // Upstream spells the Writ of the Wilds Earth kihō "Rejuvinating
      // Breath" in both techniques.json and the Temple Abbot curriculum in
      // titles.json; the book (WotW p. 109, and the Temple Abbot curriculum
      // itself on p. 143) prints "Rejuvenating Breath". Patched in both
      // files — see docs/UPSTREAM_NOTES.md #14.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, contains('Rejuvenating Breath'));
      expect(names, isNot(contains('Rejuvinating Breath')));
      final advances = [
        for (final t in gameData.titles)
          for (final a in t.advancements) a.name,
      ];
      expect(advances, contains('Rejuvenating Breath'));
      expect(advances, isNot(contains('Rejuvinating Breath')));
    });

    test("Eternal Mind's Gate matches the book name", () {
      // Upstream names the Writ of the Wilds Void kihō "Eternal Mind's
      // Gates" in techniques.json and the Awakened Soul curriculum in
      // titles.json; the book (WotW p. 114) prints "Eternal Mind's Gate".
      // Patched in both files — see docs/UPSTREAM_NOTES.md #15.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, contains("Eternal Mind's Gate"));
      expect(names, isNot(contains("Eternal Mind's Gates")));
      final advances = [
        for (final t in gameData.titles)
          for (final a in t.advancements) a.name,
      ];
      expect(advances, contains("Eternal Mind's Gate"));
      expect(advances, isNot(contains("Eternal Mind's Gates")));
    });

    test('Logical Conclusion is spelled correctly', () {
      // Upstream names the CotFW Scholar of al-Zawira mastery ability
      // "Logical Comclusion"; the book (CotFW p. 89) prints "Logical
      // Conclusion". Patched in schools.json — see UPSTREAM_NOTES.md #16.
      final abilities = gameData.schools.map((s) => s.masteryAbility);
      expect(abilities, contains('Logical Conclusion'));
      expect(abilities, isNot(contains('Logical Comclusion')));
    });

    test('Meishōdō Secrets matches the book name', () {
      // Upstream garbles the CotFW Student of Names title ability as
      // "Meishŭdŭ Secrets" (u-breve mojibake); the book (CotFW p. 137)
      // prints "Meishōdō Secrets". Patched in titles.json — see
      // docs/UPSTREAM_NOTES.md #17.
      final abilities = gameData.titles.map((t) => t.titleAbility);
      expect(abilities, contains('Meishōdō Secrets'));
      expect(abilities, isNot(contains('Meishŭdŭ Secrets')));
    });

    test('Mirror Armor is spelled correctly', () {
      // Upstream spells the CotFW riding armor "Mirror Armour"; the book
      // (CotFW p. 103, Table 2-5) prints "Mirror Armor", matching the
      // spelling used throughout the data. Patched in armor.json — see
      // docs/UPSTREAM_NOTES.md #18.
      final names = gameData.armor.map((a) => a.name);
      expect(names, contains('Mirror Armor'));
      expect(names, isNot(contains('Mirror Armour')));
    });

    test('Ganzu Ring Ax matches the book name', () {
      // Upstream names the CotFW weapon "Ganzu Ring Axe" in weapons.json
      // and the Ganzu Guardian starting outfit in schools.json; the book
      // (CotFW p. 99-100) prints "Ganzu Ring Ax" (matching FoV's "Ichirō
      // Sapper Ax"). Both patched — see docs/UPSTREAM_NOTES.md #19.
      final names = gameData.weapons.map((w) => w.name);
      expect(names, contains('Ganzu Ring Ax'));
      expect(names, isNot(contains('Ganzu Ring Axe')));
    });

    test("Kisshōten's Blessing heritage outcome resolves", () {
      // Upstream's WotW "Revered Parent" heritage offers "Kisshūten's
      // Blessing", which matches no advantage entry; the book (WotW p. 107,
      // Core p. 108) prints "Kisshōten's Blessing". Patched in
      // samurai_heritage.json — see docs/UPSTREAM_NOTES.md #20.
      final advNames =
          gameData.advantagesDisadvantages.map((a) => a.name).toSet();
      final revered = gameData.heritageEntries
          .firstWhere((h) => h.result == 'Revered Parent');
      for (final o in revered.otherEffects.outcomes) {
        expect(advNames, contains(o.outcome), reason: 'Revered Parent grant');
      }
    });

    test('Spiritual Debt ring die mapping matches the book', () {
      // Upstream copies Spirit Companion's 1-2 Air … 7-8 Fire mapping onto
      // Spiritual Debt; the book (CotFW p. 98) rolls 1-2 Fire, 3-4 Earth,
      // 5-6 Water, 7-8 Air, 9-10 Void. Patched in samurai_heritage.json —
      // see docs/UPSTREAM_NOTES.md #21.
      final debt = gameData.heritageEntries
          .firstWhere((h) => h.result == 'Spiritual Debt');
      expect([for (final o in debt.otherEffects.outcomes) o.outcome],
          ['Fire Ring', 'Earth Ring', 'Water Ring', 'Air Ring', 'Void Ring']);
    });

    test('Heart of the Horse matches the book name', () {
      // The book (CotFW p. 98) prints "Heart of the Horse", not upstream's
      // "Heart of a Horse", and the wizard's auto-grant maps key on the
      // exact string. Patched in samurai_heritage.json + wizard_state.dart
      // — see docs/UPSTREAM_NOTES.md #22.
      final results = gameData.heritageEntries.map((h) => h.result);
      expect(results, contains('Heart of the Horse'));
      expect(results, isNot(contains('Heart of a Horse')));
      expect(WizardState.autoGrantedTraits, contains('Heart of the Horse'));
      expect(WizardState.namedItemGrants, contains('Heart of the Horse'));
    });

    test('Cutting Wind Talons is rank 2', () {
      // Upstream says rank 4; the book (WotW p. 109) prints Rank 2 — the
      // Air kihō line runs 2/3/4 like every other ring's. Patched in
      // techniques.json — see docs/UPSTREAM_NOTES.md #23.
      final t = gameData.techniques
          .firstWhere((t) => t.name == 'Cutting Wind Talons');
      expect(t.rank, 2);
    });

    test('Solidify Gratitude is rank 2', () {
      // Upstream says rank 3 (taken from a curriculum table's rank column);
      // the technique block (CotFW p. 114) prints Rank 2. Patched in
      // techniques.json — see docs/UPSTREAM_NOTES.md #24.
      final t = gameData.techniques
          .firstWhere((t) => t.name == 'Solidify Gratitude');
      expect(t.rank, 2);
    });

    test('Dragonfly school matches the book (WotW p. 96)', () {
      // Three deviations patched (docs/UPSTREAM_NOTES.md #25): the school
      // starts with BOTH listed invocations (upstream made it a choice of
      // one), rank 3 also lists Performance, and ranks 4-5 open ALL
      // invocations (upstream kept them Air/Water only).
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Dragonfly Grace of the Spirits School');
      expect(school.startingTechniques.first.size, 2);
      final r3Skills = [
        for (final c in school.curriculum)
          if (c.rank == 3 && c.type == 'skill') c.advance
      ];
      expect(r3Skills, contains('Performance'));
      final lateGroups = [
        for (final c in school.curriculum)
          if (c.rank >= 4 && c.type == 'technique_group') c.advance
      ];
      expect(lateGroups, ['Invocations', 'Invocations']);
    });

    test('Naga Seer rank-5 capstone is learnable', () {
      // Ever-Changing Waves is a rank-5 Water invocation and Invocations
      // are not otherwise available to the tradition; the book (WotW p. 98)
      // marks it special access, upstream did not — the capstone was
      // unlearnable. Patched in schools.json — docs/UPSTREAM_NOTES.md #26.
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Shinomen Naga Seer Tradition');
      final entry = school.curriculum
          .firstWhere((c) => c.advance == 'Ever-Changing Waves');
      expect(entry.specialAccess, isTrue);
    });

    test('Kitsune Mediator has exactly two starting technique sets', () {
      // Upstream added a third choice (Call to Ride / Shallow Waters)
      // copy-pasted from the Iuchi Horse Lord Disciple; the book (CotFW
      // p. 86) grants only Commune with the Spirits plus one shūji choice.
      // Patched in schools.json — see docs/UPSTREAM_NOTES.md #27.
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Kitsune Mediator School');
      expect(school.startingTechniques, hasLength(2));
    });

    test('Ujik Nomad rank 2 teaches Stalking Leopard Style', () {
      // Upstream duplicated Sudden Downpour Style into rank 2; the book
      // (CotFW p. 92) lists Stalking Leopard Style there (Sudden Downpour
      // Style stays at rank 3). Patched in schools.json —
      // docs/UPSTREAM_NOTES.md #28.
      final school =
          gameData.schools.firstWhere((s) => s.name == 'Ujik Nomad Tradition');
      final r2 = [
        for (final c in school.curriculum)
          if (c.rank == 2 && c.type == 'technique') c.advance
      ];
      expect(r2, contains('Stalking Leopard Style'));
      expect(r2, isNot(contains('Sudden Downpour Style')));
    });

    test('Syncretic Philosophy is a Water distinction', () {
      // Upstream says Air; the book header (CotFW p. 93) prints (Water).
      // Patched in advantages_disadvantages.json — UPSTREAM_NOTES.md #29.
      final e = gameData.advantagesDisadvantages
          .firstWhere((a) => a.name == 'Syncretic Philosophy');
      expect(e.ring, 'Water');
    });

    test('Saddle Cutter is a range 0-1 weapon', () {
      // Upstream says range 1-2; the book (CotFW p. 100, Table 2-2) prints
      // 0-1. Patched in weapons.json — see docs/UPSTREAM_NOTES.md #30.
      final w =
          gameData.weapons.firstWhere((w) => w.name == 'Saddle Cutter');
      expect(w.rangeMin, 0);
      expect(w.rangeMax, 1);
    });

    test('audited WotW/CotFW page references match the books', () {
      // Assorted page-reference corrections from the book audit
      // (docs/UPSTREAM_NOTES.md #31): the five later CotFW rituals sit on
      // pp. 111-112 (not 110), Tip of the Tongue on p. 97, Temple Abbot on
      // WotW p. 143, and Doomhunter on CotFW p. 134.
      String techPage(String name) =>
          gameData.techniques.firstWhere((t) => t.name == name).reference.page;
      expect(techPage('Spiritual Survey'), '111');
      expect(techPage('Shadow of Days'), '111');
      expect(techPage('Protection of the Flock'), '111');
      expect(techPage("Traveler's Experience"), '112');
      expect(techPage("Wayfinder's Instincts"), '112');
      expect(
          gameData.advantagesDisadvantages
              .firstWhere((a) => a.name == 'Tip of the Tongue')
              .reference
              .page,
          '97');
      String titlePage(String name) =>
          gameData.titles.firstWhere((t) => t.name == name).reference.page;
      expect(titlePage('Temple Abbot'), '143');
      expect(titlePage('Doomhunter'), '134');
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
