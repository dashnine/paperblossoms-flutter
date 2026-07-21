import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/derived_stats.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';

Advance skill(String name, {String track = trackCurriculum, int? cost}) {
  final current = effectiveSkillRanks(character)[name] ?? 0;
  return Advance(
      type: advanceTypeSkill,
      name: name,
      track: track,
      cost: cost ?? skillAdvanceCost(current));
}

Advance ring(String name, {String track = trackCurriculum, int? cost}) {
  final current = effectiveRingRanks(character)[name] ?? 0;
  return Advance(
      type: advanceTypeRing,
      name: name,
      track: track,
      cost: cost ?? ringAdvanceCost(current));
}

Advance technique(String name, {String track = trackCurriculum}) => Advance(
    type: advanceTypeTechnique,
    name: name,
    track: track,
    cost: gameData.techniqueByName(name)?.xp ?? 0);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() {
    character.clear();
    character.school = 'Hida Defender School';
    character.baseRings = {
      ringAir: 1,
      ringEarth: 3,
      ringFire: 2,
      ringWater: 1,
      ringVoid: 1,
    };
  });

  group('derived attributes (mainwindow.cpp populateUI)', () {
    test('endurance, composure, focus', () {
      final rings = effectiveRingRanks(character);
      expect(endurance(rings), (3 + 2) * 2);
      expect(composure(rings), (3 + 1) * 2);
      expect(focus(rings), 2 + 1);
    });

    test('vigilance rounds half up per the FAQ', () {
      expect(vigilance({ringWater: 1, ringAir: 2}), 2); // 1.5 -> 2
      expect(vigilance({ringWater: 2, ringAir: 2}), 2);
      expect(vigilance({ringWater: 2, ringAir: 3}), 3); // 2.5 -> 3
    });

    test('ring advances raise effective ranks', () {
      character.advanceStack = [ring(ringWater), ring(ringWater)];
      final rings = effectiveRingRanks(character);
      expect(rings[ringWater], 3);
      expect(composure(rings), (3 + 3) * 2);
    });
  });

  group('XP costs (addadvancedialog.cpp)', () {
    test('skill cost is (current+1)*2, ring cost (current+1)*3', () {
      expect(skillAdvanceCost(0), 2);
      expect(skillAdvanceCost(2), 6);
      expect(ringAdvanceCost(1), 6);
      expect(ringAdvanceCost(2), 9);
    });

    test('half XP rounds half away from zero like qRound', () {
      expect(halfCost(2), 1);
      expect(halfCost(3), 2); // 1.5 -> 2
      expect(halfCost(9), 5); // 4.5 -> 5
    });
  });

  group('curriculum membership (advancementpage.cpp isInCurriculum)', () {
    test('direct skill and skill group entries match at rank 1', () {
      // Hida rank 1: Martial skills group, Command, Medicine, Survival.
      expect(
          isInCurriculum(
              'Command', advanceTypeSkill, character.school, 1),
          isTrue);
      expect(
          isInCurriculum(
              'Fitness', advanceTypeSkill, character.school, 1),
          isTrue,
          reason: 'Fitness is a Martial skill');
      expect(
          isInCurriculum(
              'Courtesy', advanceTypeSkill, character.school, 1),
          isFalse);
    });

    test('technique group expands bounded by the current rank', () {
      // Hida rank 1 has Kata as technique_group: rank-1 Kata are in, rank-2
      // Kata are not (maxAllowableRank defaults to the current rank).
      final rank1Kata = gameData.techniquesByGroup('Kata', maxRank: 1).first;
      final rank2Kata = gameData
          .techniquesByGroup('Kata', minRank: 2, maxRank: 2)
          .first;
      expect(
          isInCurriculum(
              rank1Kata.name, advanceTypeTechnique, character.school, 1),
          isTrue);
      expect(
          isInCurriculum(
              rank2Kata.name, advanceTypeTechnique, character.school, 1),
          isFalse);
    });

    test('special-access technique entries match by name', () {
      expect(
          isInCurriculum('Rushing Avalanche Style', advanceTypeTechnique,
              character.school, 1),
          isTrue);
    });
  });

  group('rank calculation (advancementpage.cpp recalcRank)', () {
    test('a fresh character is rank 1 with 0 XP', () {
      final result = recalcRank(character);
      expect(result.rank, 1);
      expect(result.curriculumXP, 0);
    });

    test('in-curriculum advances earn full cost, off-curriculum half', () {
      character.advanceStack = [
        skill('Command', cost: 2), // in curriculum: +2
        skill('Courtesy', cost: 2), // off curriculum: +1
      ];
      expect(recalcRank(character).curriculumXP, 3);
    });

    test('free and title advances contribute nothing to curriculum XP', () {
      character.advanceStack = [
        skill('Command', track: 'GM award', cost: 0),
        skill('Command', track: trackTitle, cost: 2),
      ];
      expect(recalcRank(character).curriculumXP, 0);
    });

    test('rank-up at 20 XP resets in-rank XP and changes the rank in force',
        () {
      // Ten in-curriculum Command purchases: costs 2,4,6,8,10 as the rank
      // climbs -- after 20 XP the character is rank 2.
      character.advanceStack = [];
      for (var i = 0; i < 6; i++) {
        character.advanceStack.add(skill('Command'));
      }
      // Costs: 2+4+6+8 = 20 -> rank 2 at the 4th advance; the 5th and 6th
      // (cost 10, 12) accumulate toward rank 2's threshold of 24.
      // Command is also in Hida's rank-2 curriculum, so they count in full.
      final result = recalcRank(character);
      expect(result.rank, 2);
      expect(result.curriculumXP, 22);
    });

    test('the rank in force mid-walk decides curriculum membership', () {
      // Costs must be computed sequentially: each purchase raises the
      // effective rank the next cost is based on (2+4+6+8 = 20 XP -> rank 2).
      for (var i = 0; i < 4; i++) {
        character.advanceStack.add(skill('Command'));
      }
      expect(recalcRank(character).rank, 2);
    });
  });

  group('School of Waves bonus curriculum skills (core p.87)', () {
    setUp(() {
      // Courtesy is a Social skill, off the Worldly Rōnin rank-1 curriculum,
      // so its crediting is decided purely by the bonus designation.
      character.school = 'Worldly Rōnin Path';
    });

    test('a designated bonus skill earns full curriculum XP at rank 1', () {
      character.advanceStack = [skill('Courtesy', cost: 2)];
      expect(recalcRank(character).curriculumXP, 1); // off-curriculum: half

      character.bonusCurriculumSkills = ['Courtesy'];
      expect(recalcRank(character).curriculumXP, 2); // now full
    });

    test('bonus skills count at all ranks (they drive the rank-up in full)',
        () {
      // Four Courtesy buys cost 2+4+6+8 = 20. As bonus curriculum they count
      // in full at every rank in the walk, reaching rank 2.
      character.bonusCurriculumSkills = ['Courtesy'];
      for (var i = 0; i < 4; i++) {
        character.advanceStack.add(skill('Courtesy'));
      }
      expect(recalcRank(character).rank, 2);
    });

    test('without the designation the same buys stay half and never rank up',
        () {
      for (var i = 0; i < 4; i++) {
        character.advanceStack.add(skill('Courtesy'));
      }
      // Half of 2+4+6+8 = 1+2+3+4 = 10, short of the 20 threshold.
      final result = recalcRank(character);
      expect(result.rank, 1);
      expect(result.curriculumXP, 10);
    });

    test('designations are inert for a school without School of Waves', () {
      character.school = 'Hida Defender School';
      character.bonusCurriculumSkills = ['Courtesy'];
      character.advanceStack = [skill('Courtesy', cost: 2)];
      expect(recalcRank(character).curriculumXP, 1); // still half
    });

    test('skillRankCap: 6 only for a designated skill once mastery is active',
        () {
      character.bonusCurriculumSkills = ['Meditation'];
      // Mastery (A Bottomless Ocean) activates above school rank 5.
      expect(skillRankCap(character, 5, 'Meditation'), 5);
      expect(skillRankCap(character, 6, 'Meditation'), 6);
      // Undesignated skills stay capped at 5 even at rank 6.
      expect(skillRankCap(character, 6, 'Fitness'), 5);
    });

    test('skillRankCap stays 5 for a school without School of Waves', () {
      character.school = 'Hida Defender School';
      character.bonusCurriculumSkills = ['Meditation'];
      expect(skillRankCap(character, 6, 'Meditation'), 5);
    });

    test('purchasableSkills keeps the 5 cap until mastery is active', () {
      character.bonusCurriculumSkills = ['Meditation'];
      character.baseSkills = {'Meditation': 5};
      // School rank 1 (empty advance stack): mastery is off, so a rank-5
      // bonus skill is not yet purchasable.
      expect(purchasableSkills(character).contains('Meditation'), isFalse);
    });

    test('at school rank 6 a rank-5 bonus skill becomes purchasable', () {
      character.bonusCurriculumSkills = ['Command', 'Meditation'];
      character.baseSkills = {'Meditation': 5, 'Tactics': 5};
      // Drive the character to school rank 6 with five full-credit curriculum
      // advances (Command is a bonus skill, so full at every rank); each
      // explicit cost clears one rank threshold [20,24,32,44,60].
      for (final cost in rankXpThresholds) {
        character.advanceStack.add(Advance(
            type: advanceTypeSkill,
            name: 'Command',
            track: trackCurriculum,
            cost: cost));
      }
      expect(recalcRank(character).rank, 6);
      // A Bottomless Ocean lifts the designated skill's cap to 6...
      expect(purchasableSkills(character).contains('Meditation'), isTrue);
      // ...but an undesignated rank-5 skill stays capped at 5.
      expect(purchasableSkills(character).contains('Tactics'), isFalse);
    });
  });

  group('title progress (mainwindow.cpp recalcTitle)', () {
    test('no titles means no title in progress', () {
      final result = recalcTitle(character);
      expect(result.currentTitle, '');
      expect(result.titleXP, 0);
    });

    test('title-track advances accrue and complete the title in order', () {
      character.titles = ['Deathseeker']; // 8 XP to complete
      character.advanceStack = [
        skill('Courtesy', track: trackTitle, cost: 2), // in track: +2
        skill('Command', track: trackTitle, cost: 4), // off track: +2
        skill('Labor', track: trackTitle, cost: 2), // in track: +2
      ];
      final result = recalcTitle(character);
      expect(result.currentTitle, 'Deathseeker');
      expect(result.titleXP, 6);

      character.advanceStack.add(skill('Theology', track: trackTitle, cost: 2));
      final done = recalcTitle(character);
      expect(done.currentTitle, '');
      expect(done.titleXP, 0);
    });

    test('completed titles grant their ability', () {
      character.titles = ['Deathseeker'];
      character.advanceStack = [
        skill('Courtesy', track: trackTitle, cost: 8),
      ];
      final title = recalcTitle(character);
      expect(title.currentTitle, '');
      final abilityList = abilities(character, 1, title.currentTitle);
      expect(abilityList,
          contains(gameData.titleByName('Deathseeker')!.titleAbility));
    });
  });

  group('advance legality (addadvancedialog.cpp)', () {
    test('skills at effective rank 5 stop being purchasable', () {
      character.baseSkills = {'Command': 3};
      character.advanceStack = [skill('Command'), skill('Command')];
      expect(purchasableSkills(character), isNot(contains('Command')));
      expect(purchasableSkills(character), contains('Courtesy'));
    });

    test('ring cap is lowest non-Void ring + Void ring', () {
      // Rings: Air 1, Earth 3, Fire 2, Water 1, Void 1 -> cap = 1 + 1 = 2.
      // Earth (3) and Fire (2) are at/over the cap; Air, Water, Void are
      // purchasable.
      final rings = purchasableRings(character);
      expect(rings, containsAll([ringAir, ringWater, ringVoid]));
      expect(rings, isNot(contains(ringEarth)));
      expect(rings, isNot(contains(ringFire)));
    });

    test('technique duplicates are blocked except the Summoning Mantra', () {
      character.techniques = ['Striking as Earth'];
      expect(alreadyLearned(character, 'Striking as Earth'), isTrue);
      character.advanceStack = [
        technique(repeatableTechnique),
      ];
      expect(alreadyLearned(character, repeatableTechnique), isFalse);
    });

    test('legal techniques honor school categories and rank gating', () {
      final legal = legalTechniques(character);
      final names = {for (final t in legal) t.name};
      // Rank-1 Kata: allowed (Hida school category, rank 1 <= 1).
      expect(names,
          contains(gameData.techniquesByGroup('Kata', maxRank: 1).first.name));
      // Rank-2 Kata: not allowed at rank 1 via the school category.
      final rank2Kata =
          gameData.techniquesByGroup('Kata', minRank: 2, maxRank: 2).first;
      expect(names, isNot(contains(rank2Kata.name)));
      // Special access by name bypasses rank: Rushing Avalanche Style is
      // rank 2 but special-access in Hida's rank-1 curriculum.
      expect(names, contains('Rushing Avalanche Style'));
      // Universal categories are always available at legal rank.
      final maho = gameData.techniquesByGroup('Mahō', maxRank: 1);
      if (maho.isNotEmpty) expect(names, contains(maho.first.name));
      // Invocations are not available to a Hida Defender.
      final invocation =
          gameData.techniquesByGroup('Invocations', maxRank: 1).first;
      expect(names, isNot(contains(invocation.name)));
    });

    test('item patterns are purchasable techniques (universal category)', () {
      // Merged from item_patterns.json at load, like the Qt database.
      final names = {for (final t in legalTechniques(character)) t.name};
      expect(names, contains('Kakita Pattern'));
      final pattern = gameData.techniqueByName('Kakita Pattern')!;
      expect(pattern.category, 'Item Patterns');
      expect(pattern.xp, 6);
      // Rank counting treats them like any other out-of-curriculum buy.
      expect(isInCurriculum('Kakita Pattern', advanceTypeTechnique,
              character.school, 1),
          isFalse);
    });

    test('removeRestrictions returns everything', () {
      expect(legalTechniques(character, removeRestrictions: true).length,
          gameData.techniques.length);
    });
  });

  group('bookkeeping', () {
    test('xpSpent sums advance costs', () {
      character.advanceStack = [
        skill('Command', cost: 2),
        ring(ringWater, cost: 6),
      ];
      expect(xpSpent(character), 8);
    });

    test('knownTechniques merges creation techniques and advances', () {
      character.techniques = ['Striking as Earth'];
      character.advanceStack = [technique('Striking as Water')];
      expect(knownTechniques(character),
          ['Striking as Earth', 'Striking as Water']);
    });
  });
}
