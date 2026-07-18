import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/game_data_models.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/wizard/school_builder/school_builder_data.dart';
import 'package:paperblossoms/wizard/school_builder/school_builder_state.dart';

/// A complete Bushi school built the way the PoW walkthrough would.
SchoolBuilderState bushiBuild() {
  final state = SchoolBuilderState()
    ..roles = ['Bushi']
    ..applyRoleDefaults();
  state
    ..clan = 'Crab'
    ..summary = 'A wall-guard tradition.'
    ..abilityName = 'Way of the Wall'
    ..abilityText = 'Do wall things.'
    ..ringIncrease = ['Earth', 'Water']
    ..masteryName = 'The Wall Endures'
    ..masteryText = 'Do great wall things.'
    ..name = 'Wall Warden School'
    ..techniquesAvailable = ['Kata', 'Rituals', 'Shūji']
    ..accessTouched = true;
  state.startingTechniques[0].options = ['Striking as Earth'];
  state.startingTechniques[1].options = [
    'Rushing Avalanche Style',
    'Iron Forest Style'
  ];
  for (var rank = 1; rank <= 5; rank++) {
    final slots = state.curriculum[rank]!;
    slots[0].advance = 'Martial skills';
    slots[1].advance = 'Command';
    slots[2].advance = 'Labor';
    slots[3].advance = 'Survival';
    slots[4].advance = 'Kata';
    slots[5].advance = 'Striking as Water';
    slots[6].advance = 'Rushing Avalanche Style';
  }
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  group('role defaults', () {
    test('Bushi prefills Table 2-5/2-7/2-8 values', () {
      final state = SchoolBuilderState()
        ..roles = ['Bushi']
        ..applyRoleDefaults();
      expect(state.ringIncrease.first, 'Earth');
      expect(state.startingSkills, hasLength(7));
      expect(state.skillPicks, 5);
      expect(state.startingTechniques, hasLength(2));
      expect(state.techniquesAvailable, ['Rituals']);
      expect(state.honor, 45);
      expect(state.startingOutfit, isNotEmpty);
    });

    test('Sage gets 6/3 skills and four starting technique rows', () {
      final state = SchoolBuilderState()
        ..roles = ['Sage']
        ..applyRoleDefaults();
      expect(state.startingSkills, hasLength(6));
      expect(state.skillPicks, 3);
      expect(state.startingTechniques, hasLength(4));
    });

    test('Shugenja prefills Commune with the Spirits and Invocations', () {
      final state = SchoolBuilderState()
        ..roles = ['Shugenja']
        ..applyRoleDefaults();
      expect(state.startingTechniques.first.options, [communeWithSpirits]);
      expect(state.techniquesAvailable, contains('Invocations'));
      expect(state.ringIncrease.first, isEmpty); // "attuned element" hint
    });

    test('touched sections survive a role change', () {
      final state = SchoolBuilderState()
        ..roles = ['Bushi']
        ..applyRoleDefaults();
      state
        ..ringIncrease = ['Fire', 'Fire']
        ..ringsTouched = true
        ..roles = ['Sage']
        ..applyRoleDefaults();
      expect(state.ringIncrease, ['Fire', 'Fire']);
      expect(state.skillPicks, 3); // untouched section did update
    });
  });

  group('special-access derivation', () {
    test('matches the bundled convention', () {
      final state = SchoolBuilderState()
        ..techniquesAvailable = ['Kata', 'Rituals', 'Shūji'];
      // Rank-2 kata in a rank-1 slot, category open (Hida Defender pattern).
      expect(state.techniqueNeedsSpecialAccess('Rushing Avalanche Style', 1),
          isTrue);
      // Rank-1 shūji, category open, at rank.
      expect(
          state.techniqueNeedsSpecialAccess('Honest Assessment', 1), isFalse);
      // Category closed entirely.
      expect(state.techniqueNeedsSpecialAccess('Cleansing Spirit', 5), isTrue);
      // Open category group vs closed category group.
      expect(state.groupNeedsSpecialAccess('Kata'), isFalse);
      expect(state.groupNeedsSpecialAccess('Invocations'), isTrue);
      // A subcategory whose parent category is open counts as open.
      expect(state.groupNeedsSpecialAccess('Earth Shūji'), isFalse);
      expect(state.groupNeedsSpecialAccess('Air Invocations'), isTrue);
    });
  });

  group('toSchool', () {
    test('emits the schools.json shape with derived flags', () {
      final school = bushiBuild().toSchool();
      expect(school.name, 'Wall Warden School');
      expect(school.role, ['Bushi']);
      expect(school.startingSkills.size, 5);
      expect(school.startingSkills.options, hasLength(7));
      expect(school.curriculum, hasLength(35));
      final rank1 = [
        for (final e in school.curriculum)
          if (e.rank == 1) e
      ];
      expect([for (final e in rank1) e.type], [
        entryTypeSkillGroup,
        entryTypeSkill,
        entryTypeSkill,
        entryTypeSkill,
        entryTypeTechniqueGroup,
        entryTypeTechnique,
        entryTypeTechnique,
      ]);
      // Rushing Avalanche Style is rank 2: special access at rank 1 only.
      CurriculumEntry rush(int rank) => school.curriculum.firstWhere((e) =>
          e.rank == rank && e.advance == 'Rushing Avalanche Style');
      expect(rush(1).specialAccess, isTrue);
      expect(rush(2).specialAccess, isFalse);
      final json = school.toJson();
      expect(json['starting_skills']['size'], 5);
      expect(json['curriculum'], hasLength(35));
    });

    test('technique-group rank bounds emit allowable_rank with min 1', () {
      final state = bushiBuild();
      state.curriculum[2]![4]
        ..advance = 'Invocations'
        ..maxAllowableRank = 3;
      final school = state.toSchool();
      final entry = school.curriculum.firstWhere(
          (e) => e.rank == 2 && e.type == entryTypeTechniqueGroup);
      expect(entry.minAllowableRank, 1);
      expect(entry.maxAllowableRank, 3);
      // Invocations aren't open to this school: the row is special access.
      expect(entry.specialAccess, isTrue);
      expect(entry.toJson()['allowable_rank'], '1-3');
    });
  });

  group('loadFrom round trips', () {
    test('a wizard-built school survives unchanged', () {
      final school = bushiBuild().toSchool();
      final reloaded = SchoolBuilderState()..loadFrom(school);
      expect(reloaded.toSchool().toJson(), school.toJson());
    });

    test('a doubled-ring school keeps both copies', () {
      final tensai = gameData.schools
          .firstWhere((s) => s.name == 'Isawa Tensai School (Fire)');
      final state = SchoolBuilderState()..loadFrom(tensai);
      expect(state.ringIncrease, ['Fire', 'Fire']);
    });

    test('missing ring increases pad to the two slots step 4 renders', () {
      final school = bushiBuild().toSchool();
      final bare = School.fromJson(
          school.toJson()..['ring_increase'] = <String>[]);
      final state = SchoolBuilderState()..loadFrom(bare);
      expect(state.ringIncrease, ['', '']);
    });

    test('curriculum entries outside ranks 1-5 survive a round trip', () {
      final school = bushiBuild().toSchool();
      final json = school.toJson();
      (json['curriculum'] as List).add({
        'rank': 7,
        'advance': 'Fitness',
        'type': entryTypeSkill,
        'special_access': false,
      });
      final state = SchoolBuilderState()..loadFrom(School.fromJson(json));
      final out = state.toSchool();
      expect(out.curriculum.length, school.curriculum.length + 1);
      final extra = out.curriculum.last;
      expect((extra.rank, extra.advance), (7, 'Fitness'));
    });

    test('hand-shaped ranks and unexposed fields survive', () {
      // Matsu Beastmaster carries advantage_disadvantage; find a school
      // whose rank shape deviates from 1/3/1/2 to prove slots follow the
      // data, not the recipe.
      final beastmaster = gameData.schools
          .firstWhere((s) => s.name == 'Matsu Beastmaster School');
      final state = SchoolBuilderState()..loadFrom(beastmaster);
      expect(state.advDisadv, isNotEmpty);
      expect(state.toSchool().toJson()['advantage_disadvantage'],
          beastmaster.toJson()['advantage_disadvantage']);

      final deviant = gameData.schools.firstWhere((s) {
        final state = SchoolBuilderState()..loadFrom(s);
        return [1, 2, 3, 4, 5].any(state.rankShapeDeviates);
      });
      final deviantState = SchoolBuilderState()..loadFrom(deviant);
      final counts = {
        for (var r = 1; r <= 5; r++)
          r: deviant.curriculum.where((e) => e.rank == r).length
      };
      for (var r = 1; r <= 5; r++) {
        expect(deviantState.curriculum[r], hasLength(counts[r]!),
            reason: '${deviant.name} rank $r');
      }
    });

    test('every bundled school round-trips its curriculum advances', () {
      // The flag is re-derived (behavior-neutral, see the state docs) and
      // allowable_rank min-0 becomes 1; everything else must be identical.
      for (final school in gameData.schools) {
        final state = SchoolBuilderState()..loadFrom(school);
        final out = state.toSchool();
        expect(out.curriculum.length, school.curriculum.length,
            reason: school.name);
        for (var i = 0; i < out.curriculum.length; i++) {
          final a = school.curriculum[i];
          final b = out.curriculum[i];
          expect((b.rank, b.advance, b.type, b.maxAllowableRank),
              (a.rank, a.advance, a.type, a.maxAllowableRank),
              reason: '${school.name} #$i');
        }
        expect(out.toJson()['starting_outfit'],
            school.toJson()['starting_outfit'],
            reason: school.name);
        expect(out.toJson()['starting_techniques'],
            school.toJson()['starting_techniques'],
            reason: school.name);
      }
    });
  });

  group('shell helpers', () {
    test('rank completeness and skill-in-group detection', () {
      final state = bushiBuild();
      expect(state.rankComplete(1), isTrue);
      // Command/Labor/Survival all sit outside Martial skills.
      expect(state.skillsInsideRankGroup(1), isEmpty);
      state.curriculum[1]![1].advance = 'Fitness';
      expect(state.skillsInsideRankGroup(1), ['Fitness']);
      state.curriculum[1]![1].advance = '';
      expect(state.rankComplete(1), isFalse);
      expect(state.filledSlots(1), 6);
      expect(state.rankShapeDeviates(1), isFalse);
      state.curriculum[1]!.add(CurriculumSlot(entryTypeTechnique,
          advance: 'Striking as Earth'));
      expect(state.rankShapeDeviates(1), isTrue);
    });
  });
}
