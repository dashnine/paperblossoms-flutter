import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/item.dart';
import 'package:paperblossoms/rules_constants.dart';
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

    test('Jitte is a damage 3, deadliness 2 weapon', () {
      // Upstream says damage 2 / deadliness 4; the book (Core p. 231,
      // Table 5-1) prints DMG 3 / DLS 2, and no errata changes it.
      // Patched in weapons.json — see docs/UPSTREAM_NOTES.md #33.
      final w = gameData.weapons.firstWhere((w) => w.name == 'Jitte');
      expect(w.damage, 3);
      expect(w.deadliness, 2);
    });

    test('Kama is Concealable, not Ceremonial', () {
      // Upstream gives the kama the Ceremonial quality; the book (Core
      // p. 237, Table 5-2) prints Concealable, and no errata changes it.
      // Patched in weapons.json — see docs/UPSTREAM_NOTES.md #34.
      final w = gameData.weapons.firstWhere((w) => w.name == 'Kama');
      expect(w.qualities, contains('Concealable'));
      expect(w.qualities, isNot(contains('Ceremonial')));
    });

    test('Ikoma Bard School matches the book name', () {
      // Upstream spells the Lion courtier school "Ikomo Bard School"; the
      // family (and the book, Core p. 71) is Ikoma. Patched in schools.json
      // — see docs/UPSTREAM_NOTES.md #36.
      final names = gameData.schools.map((s) => s.name);
      expect(names, contains('Ikoma Bard School'));
      expect(names, isNot(contains('Ikomo Bard School')));
    });

    test('Hands of the Tides matches the book name', () {
      // Upstream drops the article: "Hands of Tides". The technique block
      // (Core p. 208) and the book index both print "Hands of the Tides".
      // Patched in techniques.json plus every curriculum that lists it —
      // see docs/UPSTREAM_NOTES.md #37.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, contains('Hands of the Tides'));
      expect(names, isNot(contains('Hands of Tides')));
      final advances = [
        for (final s in gameData.schools)
          for (final c in s.curriculum) c.advance,
        for (final t in gameData.titles)
          for (final a in t.advancements) a.name,
      ];
      expect(advances, contains('Hands of the Tides'));
      expect(advances, isNot(contains('Hands of Tides')));
    });

    test('The Body Is an Anvil matches the book name', () {
      // The technique block (Core p. 186) and the index capitalize "Is";
      // upstream has "The Body is an Anvil". Patched in techniques.json and
      // the one curriculum listing it — see docs/UPSTREAM_NOTES.md #38.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, contains('The Body Is an Anvil'));
      expect(names, isNot(contains('The Body is an Anvil')));
      final advances = [
        for (final s in gameData.schools)
          for (final c in s.curriculum) c.advance,
      ];
      expect(advances, isNot(contains('The Body is an Anvil')));
    });

    test('Kuni Purifier and Shinjo Outrider teach Skulduggery, not Skulk', () {
      // Upstream misread the Skulduggery skill rows as the Skulk ninjutsu
      // (Core p. 60 rank 1 and p. 85 rank 4 both print "Skulduggery Skill").
      // Patched in schools.json — see docs/UPSTREAM_NOTES.md #39.
      for (final (school, rank) in [
        ('Kuni Purifier School', 1),
        ('Shinjo Outrider School', 4),
      ]) {
        final s = gameData.schools.firstWhere((s) => s.name == school);
        final rows = [
          for (final c in s.curriculum)
            if (c.rank == rank) (c.advance, c.type)
        ];
        expect(rows, contains(('Skulduggery', 'skill')), reason: school);
        expect(rows, isNot(contains(('Skulk', 'technique'))), reason: school);
      }
    });

    test('Kaiu Engineer rank 1 includes Smithing', () {
      // Upstream omits the Smithing skill row from rank 1 (Core p. 59 lists
      // Martial Arts [Ranged], Smithing, Tactics). Patched in schools.json —
      // see docs/UPSTREAM_NOTES.md #40.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Kaiu Engineer School');
      final r1Skills = [
        for (final c in s.curriculum)
          if (c.rank == 1 && c.type == 'skill') c.advance
      ];
      expect(r1Skills, contains('Smithing'));
    });

    test('Matsu Berserker rank 3 includes Composition', () {
      // Upstream repeats Command at rank 3; the book (Core p. 73) prints
      // Composition there (Command belongs to rank 4). Patched in
      // schools.json — see docs/UPSTREAM_NOTES.md #41.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Matsu Berserker School');
      List<String> skills(int rank) => [
            for (final c in s.curriculum)
              if (c.rank == rank && c.type == 'skill') c.advance
          ];
      expect(skills(3), contains('Composition'));
      expect(skills(3), isNot(contains('Command')));
      expect(skills(4), contains('Command'));
    });

    test('Asako Loremaster rank 4 grants Cleansing Spirit', () {
      // Upstream lists the Cleansing Rite ritual; the book (Core p. 74)
      // prints Cleansing Spirit (the Earth kihō, hence the special-access
      // mark). Patched in schools.json — see docs/UPSTREAM_NOTES.md #42.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Asako Loremaster School');
      final r4 = [
        for (final c in s.curriculum)
          if (c.rank == 4 && c.type == 'technique') c.advance
      ];
      expect(r4, contains('Cleansing Spirit'));
      expect(r4, isNot(contains('Cleansing Rite')));
    });

    test('Worldly Rōnin rank 1 includes Fitness', () {
      // Upstream omits the Fitness skill row from rank 1 (Core p. 87 lists
      // Fitness, Martial Arts [Choose One], Performance). Patched in
      // schools.json — see docs/UPSTREAM_NOTES.md #43.
      final s =
          gameData.schools.firstWhere((s) => s.name == 'Worldly Rōnin Path');
      final r1Skills = [
        for (final c in s.curriculum)
          if (c.rank == 1 && c.type == 'skill') c.advance
      ];
      expect(r1Skills, contains('Fitness'));
    });

    test('Yasuki and Iuchi outfits start with traveling clothes', () {
      // Upstream's first outfit entry for both schools is a second
      // "Traveling Pack"; the books (Core pp. 61 and 83) open the lists
      // with traveling clothes. Patched in schools.json — see
      // docs/UPSTREAM_NOTES.md #44.
      for (final name in [
        'Yasuki Merchant School',
        'Iuchi Meishōdō Master School'
      ]) {
        final s = gameData.schools.firstWhere((s) => s.name == name);
        final items = [
          for (final g in s.startingOutfit) ...g.options,
        ];
        expect(items, contains('Traveling Clothes'), reason: name);
        expect(items.where((i) => i == 'Traveling Pack'), hasLength(1),
            reason: name);
      }
    });

    test('Paragon of Righteousness is a Virtue', () {
      // Upstream types it Mental/Spiritual; the book (Core p. 108) types
      // every Paragon tenet Mental/Virtue. Patched in
      // advantages_disadvantages.json — see docs/UPSTREAM_NOTES.md #45.
      final e = gameData.advantagesDisadvantages
          .firstWhere((a) => a.name == 'Paragon of Righteousness');
      expect(e.types, ['Mental', 'Virtue']);
    });

    test('Incurable Illness is typed Physical', () {
      // Upstream appends a stray "(Appearance)" qualifier; the book (Core
      // p. 123) types it plain Physical. Patched in
      // advantages_disadvantages.json — see docs/UPSTREAM_NOTES.md #46.
      final e = gameData.advantagesDisadvantages
          .firstWhere((a) => a.name == 'Incurable Illness');
      expect(e.types, ['Physical']);
    });

    test('Gaijin Name, Culture, or Appearance matches the book name', () {
      // The book (Core p. 121) uses the serial comma in the adversity's
      // name. Patched in advantages_disadvantages.json — see
      // docs/UPSTREAM_NOTES.md #47.
      final names = gameData.advantagesDisadvantages.map((a) => a.name);
      expect(names, contains('Gaijin Name, Culture, or Appearance'));
      expect(names, isNot(contains('Gaijin Name, Culture or Appearance')));
    });

    test('Utaku Stablemaster rank 1 includes the Kata group', () {
      // Upstream omits the "Rank 1 Kata" technique-group row (CR p. 88 has
      // it alongside the two special-access invocation/ritual rows).
      // Patched in schools.json — see docs/UPSTREAM_NOTES.md #49.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Utaku Stablemaster School');
      final r1Groups = [
        for (final c in s.curriculum)
          if (c.rank == 1 && c.type == 'technique_group') c.advance
      ];
      expect(r1Groups, contains('Kata'));
    });

    test('Shosuro Shadowweaver outfit has six shuriken and three vials', () {
      // Upstream grants one shuriken and one vial of poison; the book (CR
      // p. 87) grants six shuriken and three vials. Patched in schools.json
      // — see docs/UPSTREAM_NOTES.md #50.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Shosuro Shadowweaver School');
      final items = [
        for (final g in s.startingOutfit) ...g.options,
      ];
      expect(items.where((i) => i == 'Shuriken'), hasLength(6));
      expect(items.where((i) => i == 'Poison (per vial)'), hasLength(3));
    });

    test('audited CR page references match the book', () {
      // Corrections from the Celestial Realms audit (docs/UPSTREAM_NOTES.md
      // #51): the book opens the school chapter with Agasha Alchemist
      // (p. 80) and Asahina Envoy (p. 81) — upstream numbered them as if
      // they came last — and Religious Study sits on p. 91.
      String schoolPage(String name) =>
          gameData.schools.firstWhere((s) => s.name == name).reference.page;
      expect(schoolPage('Agasha Alchemist School'), '80');
      expect(schoolPage('Asahina Envoy School'), '81');
      expect(
          gameData.advantagesDisadvantages
              .firstWhere((a) => a.name == 'Religious Study')
              .reference
              .page,
          '91');
    });

    test('Wandering Blade outfit includes a trinket', () {
      // The book (PoW p. 48) ends the outfit with "and one trinket";
      // upstream omits it (every other PoW school outfit has one).
      // Patched in schools.json — see docs/UPSTREAM_NOTES.md #54.
      final s =
          gameData.schools.firstWhere((s) => s.name == 'The Wandering Blade');
      final items = [
        for (final g in s.startingOutfit) ...g.options,
      ];
      expect(items, contains('Trinket'));
    });

    test('Urumi is a range 1-2 weapon', () {
      // Upstream says range 1-3; the book (PoW p. 113, Table 3-1) prints
      // 1-2. Patched in weapons.json — see docs/UPSTREAM_NOTES.md #55.
      final w = gameData.weapons.firstWhere((w) => w.name == 'Urumi');
      expect(w.rangeMin, 1);
      expect(w.rangeMax, 2);
    });

    test('Military upbringing grants one ring choice', () {
      // Upstream grants BOTH +1 Earth and +1 Fire (size 2); the book (PoW
      // p. 45) reads "+1 Earth or +1 Fire" like every other upbringing.
      // Patched in upbringings.json — see docs/UPSTREAM_NOTES.md #56.
      final u = gameData.upbringings.firstWhere((u) => u.name == 'Military');
      expect(u.ringIncrease.size, 1);
      expect(u.ringIncrease.options, ['Earth', 'Fire']);
    });

    test('Tradesperson upbringing exists and matches the book', () {
      // Upstream omits the last of the thirteen PoW upbringings entirely
      // (PoW p. 46: +1 Air or Water, +1 Commerce, +1 Aesthetics, status -6,
      // 2 koku). Added to upbringings.json — see docs/UPSTREAM_NOTES.md #57.
      final u =
          gameData.upbringings.firstWhere((u) => u.name == 'Tradesperson');
      expect(u.ringIncrease.options, ['Air', 'Water']);
      expect(u.ringIncrease.size, 1);
      final skills = [for (final s in u.skillIncreases) ...s.options];
      expect(skills, containsAll(['Commerce', 'Aesthetics']));
      expect(u.statusModification, -6);
      expect(u.startingWealth.value, 2);
      expect(u.startingWealth.unit, 'koku');
    });

    test('audited PoW page references match the book', () {
      // Corrections from the Path of Waves audit (docs/UPSTREAM_NOTES.md
      // #53): Landslide Strike's block is on p. 89 (upstream transposed
      // 98), Balancing Salve on p. 96, and Many Mouths on p. 72.
      String techPage(String name) =>
          gameData.techniques.firstWhere((t) => t.name == name).reference.page;
      expect(techPage('Landslide Strike'), '89');
      expect(techPage('Balancing Salve'), '96');
      expect(
          gameData.advantagesDisadvantages
              .firstWhere((a) => a.name == 'Many Mouths')
              .reference
              .page,
          '72');
    });

    test('Asako Inquisitor starting skills include Meditation', () {
      // The book (SL p. 88) offers six skills to choose three from;
      // upstream dropped Meditation. Patched in schools.json — see
      // docs/UPSTREAM_NOTES.md #59.
      final s = gameData.schools
          .firstWhere((s) => s.name == 'Asako Inquisitor School');
      expect(s.startingSkills.options, contains('Meditation'));
      expect(s.startingSkills.options, hasLength(6));
      expect(s.startingSkills.size, 3);
    });

    test("Harvester's Skulk is special access", () {
      // The book (SL p. 128) marks the Skulk row "=" — required, since
      // the title is how a Crab learns ninjutsu at all. Patched in
      // titles.json — see docs/UPSTREAM_NOTES.md #60.
      final t = gameData.titles.firstWhere((t) => t.name == 'Harvester');
      final skulk = t.advancements.firstWhere((a) => a.name == 'Skulk');
      expect(skulk.specialAccess, isTrue);
    });

    test('SL ritual role restrictions match the book', () {
      // The blocks (SL p. 114) print "(Shugenja)" on Craft Shikigami and
      // "(Artisan)" on Blessing of Steel; upstream drops both. Patched in
      // techniques.json — see docs/UPSTREAM_NOTES.md #61.
      String restrictionOf(String name) => gameData.techniques
          .firstWhere((t) => t.name == name)
          .restriction;
      expect(restrictionOf('Craft Shikigami'), 'Shugenja');
      expect(restrictionOf('Blessing of Steel'), 'Artisan');
    });

    test("Hasegawa's Denial requires school rank 3", () {
      // The scroll's prerequisites (SL p. 108) include "school rank 3";
      // upstream models it rank 1 like the other two scrolls (whose
      // prerequisites carry no rank). Patched in techniques.json — see
      // docs/UPSTREAM_NOTES.md #62.
      final t =
          gameData.techniques.firstWhere((t) => t.name == "Hasegawa's Denial");
      expect(t.rank, 3);
    });

    test('The Blood Price phantom is not a learnable technique', () {
      // SL pp. 115-116 "The Blood Price" is the mahō blood-sacrifice
      // rules section, not a technique; upstream ships it as a rank-1
      // mahō entry. Removed here (nothing references it) — see
      // docs/UPSTREAM_NOTES.md #63.
      final names = gameData.techniques.map((t) => t.name);
      expect(names, isNot(contains('The Blood Price')));
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

    test('advantage-granting heritage outcomes resolve', () {
      // Generalizes the Kisshōten's Blessing regression to every heritage
      // row whose sub-table grants an advantage/disadvantage: each outcome
      // must name a real entry, or the wizard's grant silently fails.
      // "Ring Exchange" is a wizard directive (wizard_state handles it),
      // not an advantage.
      const directives = {'Ring Exchange'};
      final advNames =
          gameData.advantagesDisadvantages.map((a) => a.name).toSet();
      const advTypes = {'Distinction', 'Passion', 'Adversity', 'Anxiety'};
      for (final h in gameData.heritageEntries) {
        if (!advTypes.contains(h.otherEffects.type)) continue;
        for (final o in h.otherEffects.outcomes) {
          expect(
              advNames.contains(o.outcome) || directives.contains(o.outcome),
              isTrue,
              reason: 'heritage "${h.result}" (${h.source}) grants unknown '
                  'advantage "${o.outcome}"');
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

  group('Courts of Stone fixes', () {
    test('Esteemed Negotiator Earth Shūji group spans ranks 1-3 (CoS p.129)',
        () {
      final title =
          gameData.titles.firstWhere((t) => t.name == 'Esteemed Negotiator');
      final row = title.advancements.firstWhere((a) => a.name == 'Earth Shūji');
      expect(row.rank, 3);
      expect(row.specialAccess, isTrue);
    });

    test('title disadvantage grants resolve to real titles and entries', () {
      final titleNames = {for (final t in gameData.titles) t.name};
      final advNames = {
        for (final a in gameData.advantagesDisadvantages) a.name
      };
      titleGrants.forEach((title, grant) {
        expect(titleNames, contains(title));
        expect(advNames, contains(grant));
      });
      expect(titleGrants['Covert Agent'], 'Dark Secret');
      expect(titleGrants['Dreaded Enforcer'], 'Whispers of Cruelty');
    });

    test('Ikoma Shadow mastery ability matches book capitalization', () {
      final school =
          gameData.schools.firstWhere((s) => s.name == 'Ikoma Shadow School');
      expect(school.masteryAbility, 'Victory Is the Greatest Honor');
    });

    test('CoS items carry their printed names', () {
      final names = {for (final p in gameData.personalEffects) p.name};
      expect(names, contains("Performers' Boat"));
      expect(names, contains('Rope Ladder'));
      expect(names, contains('Mari (Ball)'));
      expect(names, isNot(contains("Perfomers' Boat")));
      expect(names, isNot(contains('Portable Ladder')));
      expect(names, isNot(contains('Mari')));
    });

    test('CoS bond abilities use the printed title case', () {
      final family = gameData.bonds.firstWhere((b) => b.name == 'Family');
      expect(family.ability, 'Strong Roots Grow Deep');
    });

    test('grip quality effects name real qualities and reach the built item',
        () {
      final qualityNames = {for (final q in gameData.qualities) q.name};
      for (final weapon in gameData.weapons) {
        for (final grip in weapon.grips) {
          for (final effect in grip.effects) {
            if (effect.attribute == 'quality') {
              expect(qualityNames, contains(effect.value),
                  reason: '${weapon.name} ${grip.name}');
            }
          }
        }
      }
      final kusarifundo = gameData.weaponByName('Kusarifundo')!;
      final twoHand = kusarifundo.grips.firstWhere((g) => g.name == '2-hand');
      final item = Item.fromWeapon(kusarifundo, twoHand);
      expect(item.qualities, contains('Snaring'));
    });
  });

  group('Fields of Victory fixes', () {
    test('Isawa Tensai variants reference their real page (FoV p.79)', () {
      final variants = [
        for (final s in gameData.schools)
          if (s.name.startsWith('Isawa Tensai School (')) s
      ];
      expect(variants, hasLength(4));
      for (final school in variants) {
        expect(school.reference.page, '79', reason: school.name);
      }
    });

    test("Beseech Doji's Wisdom is rank 2 (FoV p.96)", () {
      final tech = gameData.techniques
          .firstWhere((t) => t.name == "Beseech Doji's Wisdom");
      expect(tech.rank, 2);
    });

    test("Beseech Shinjo's Empathy cites page 97", () {
      final tech = gameData.techniques
          .firstWhere((t) => t.name == "Beseech Shinjo's Empathy");
      expect(tech.reference.page, '97');
    });

    test('Yogo Penitent outfit grants three shuriken (FoV p.81)', () {
      final school =
          gameData.schools.firstWhere((s) => s.name == 'Yogo Penitent Order');
      final shurikenSets = [
        for (final set in school.startingOutfit)
          if (set.options.contains('Shuriken')) set
      ];
      expect(shurikenSets, hasLength(3));
    });

    test('Animal Helm rarity matches the book (FoV p.90)', () {
      final helm = gameData.personalEffects
          .firstWhere((p) => p.name == 'Animal Helm');
      expect(helm.rarity, 5);
    });

    test('allowable_rank dict form parses into curriculum bounds', () {
      final tensai = gameData.schools
          .firstWhere((s) => s.name == 'Isawa Tensai School (Fire)');
      final r1Group = tensai.curriculum.firstWhere(
          (a) => a.rank == 1 && a.advance == 'Fire Invocations');
      expect(r1Group.minAllowableRank, 1);
      expect(r1Group.maxAllowableRank, 2);
      final bounded = [
        for (final school in gameData.schools)
          for (final a in school.curriculum)
            if (a.maxAllowableRank > 0) a
      ];
      expect(bounded.length, greaterThanOrEqualTo(84));
    });
  });

  group('Emerald Empire fixes', () {
    test('Miya Cartographer rank 5 has the Artisan skills group (EE p.232)',
        () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Miya Cartographer School');
      final r5 = [
        for (final a in school.curriculum)
          if (a.rank == 5) a
      ];
      expect(
          r5.any((a) => a.advance == 'Artisan skills' && a.type == 'skill_group'),
          isTrue);
      expect(r5.any((a) => a.advance == "Artisan's Appraisal"), isFalse);
    });
  });

  group('Mantis DLC fixes', () {
    test('Storm Fleet Sailor shūji is a choose-one set (Mantis p.5)', () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Storm Fleet Sailor School');
      expect(school.startingTechniques, hasLength(2));
      final shuji = school.startingTechniques[1];
      expect(shuji.size, 1);
      expect(shuji.options,
          containsAll(['All in Jest', 'Stirring the Embers']));
    });

    test('Storm Fleet Sailor outfit includes the fishing rod (Mantis p.5)',
        () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Storm Fleet Sailor School');
      expect(
          school.startingOutfit
              .any((s) => s.options.contains('Fishing Rod and Line')),
          isTrue);
    });

    test('Storm Fleet Tide Seer rank 2 studies Theology (Mantis p.6)', () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Storm Fleet Tide Seer');
      final r2 = [
        for (final a in school.curriculum)
          if (a.rank == 2) a
      ];
      expect(r2.any((a) => a.advance == 'Theology' && a.type == 'skill'),
          isTrue);
      expect(r2.any((a) => a.advance == 'Tea Ceremony'), isFalse);
    });

    test('Eku carries its printed qualities (Mantis p.8)', () {
      final eku = gameData.weaponByName('Eku')!;
      expect(eku.qualities,
          containsAll(['Cumbersome', 'Durable', 'Mundane']));
    });
  });

  // Official FFG errata (v3.0, 8/12/2020), adopted 2026-07-19 on user
  // request — supersedes the book-not-errata stance of UPSTREAM_NOTES #35.
  // See docs/UPSTREAM_NOTES.md #81 for the full item-by-item accounting.
  group('FFG errata v3.0', () {
    test('Dao is deadliness 6', () {
      final w = gameData.weaponByName('Dao')!;
      expect(w.deadliness, 6);
    });

    test('Jian 2-hand grip grants Razor-edged', () {
      final w = gameData.weaponByName('Jian')!;
      final twoHand = w.grips.firstWhere((g) => g.name == '2-hand');
      expect(
          twoHand.effects.any(
              (e) => e.attribute == 'quality' && e.value == 'Razor-edged'),
          isTrue);
    });

    test('Utaku Battle Maiden rank 1 teaches Courtier\'s Resolve', () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Utaku Battle Maiden School');
      final r1 = [
        for (final a in school.curriculum)
          if (a.rank == 1) a.advance
      ];
      expect(r1, contains("Courtier's Resolve"));
      expect(r1, isNot(contains('Striking as Air')));
    });

    test('Moto Avenger outfit includes the Unicorn Warhorse', () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Moto Avenger School');
      expect(
          school.startingOutfit
              .any((s) => s.options.contains('Unicorn Warhorse')),
          isTrue);
    });

    test('Qamarist Shield Bearer studies all shūji and owns a scimitar', () {
      final school = gameData.schools
          .firstWhere((s) => s.name == 'Qamarist Shield Bearer Tradition');
      expect(school.techniquesAvailable, contains('Shūji'));
      expect(school.techniquesAvailable, isNot(contains('Earth Shūji')));
      expect(
          school.startingOutfit.any((s) => s.options.contains('Scimitar')),
          isTrue);
    });

    test('PoW hand-held improvised weapons use Unarmed', () {
      for (final name in [
        'Chair',
        'Lute',
        'Sake Bottle & Cups',
        'Scroll Case'
      ]) {
        expect(gameData.weaponByName(name)!.skill, 'Unarmed',
            reason: '$name should be wielded with Martial Arts [Unarmed]');
      }
    });

    test('Umbrella stab grip is 2-hand', () {
      final grips = gameData.weaponByName('Umbrella')!.grips;
      expect(grips.map((g) => g.name), contains('2-hand (stab)'));
      expect(grips.map((g) => g.name), isNot(contains('1-hand (stab)')));
    });

    test('Emerald Magistrate status award is +15 to a minimum of 40', () {
      final title =
          gameData.titles.firstWhere((t) => t.name == 'Emerald Magistrate');
      final award = title.socialAwards
          .firstWhere((a) => a.awardAttribute == 'status');
      expect(award.baseAward, 15);
      expect(award.constraint?.type, 'min');
      expect(award.constraint?.value, 40);
    });
  });
}
