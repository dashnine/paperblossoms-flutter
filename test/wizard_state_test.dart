import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

/// A complete, legal Crab bushi answered the way the rulebook example would.
WizardState hidaBuild() {
  final wizard = WizardState()
    ..characterType = characterTypeSamurai
    ..clan = 'Crab'
    ..family = 'Hida'
    ..familyRing = 'Earth' // Hida offers Earth or Fire
    ..school = 'Hida Defender School'
    ..schoolSkills = [
      'Fitness',
      'Martial Arts [Melee]',
      'Meditation',
      'Survival',
      'Tactics',
    ]
    ..ringChoices = ['Earth', 'Water'] // school ring increases (fixed)
    ..schoolSpecialRing = 'Void' // Q4 standout
    ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
    ..equipChoices = ['Tetsubō']
    ..personalName = 'Tetsu'
    ..q5Text = 'Serve Hida-ue'
    ..q6Text = 'Protect the weak'
    ..q7Positive = true // +5 glory
    ..q8Choice = 'pos' // +10 honor
    ..distinction = 'Large Stature'
    ..adversity = 'Bluntness'
    ..passion = 'Architecture'
    ..anxiety = 'Blessed Lineage'
    ..q13PickedAdvantage = true
    ..q13Advantage = 'Paragon of Loyalty';
  return wizard;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() => character.clear());

  group('samurai ring math (page 7 calcRings)', () {
    test('all rings start at 1 and bonuses accumulate', () {
      final rings = hidaBuild().calcRings();
      // Earth: 1 base + 1 clan (Crab) + 1 family choice + 1 school = 4 -> over
      // the creation cap of 3, so 1 point of overflow needs redistribution.
      expect(rings.rings[ringEarth], 3);
      expect(rings.overflow, 1);
      expect(rings.rings[ringWater], 2); // base + school
      expect(rings.rings[ringVoid], 2); // base + standout
      expect(rings.rings[ringAir], 1);
      expect(rings.rings[ringFire], 1);
    });

    test('replacement ring consumes the overflow', () {
      final wizard = hidaBuild()..replacementRings = ['Fire', ''];
      final rings = wizard.calcRings();
      expect(rings.overflow, 0);
      expect(rings.rings[ringFire], 2);
      expect(rings.rings[ringEarth], 3);
    });
  });

  group('samurai skill math (page 7 calcSkills)', () {
    test('clan, family, and school skills accumulate', () {
      final skills = hidaBuild().calcSkills();
      // Fitness: clan (Crab) + school choice = 2.
      expect(skills.skills['Fitness'], 2);
      // Command and Tactics from Hida family; Tactics also school choice.
      expect(skills.skills['Command'], 1);
      expect(skills.skills['Tactics'], 2);
      expect(skills.overflow, 0);
    });

    test('q7 negative and q13 disadvantage skills count', () {
      final wizard = hidaBuild()
        ..q7Positive = false
        ..q7Skill = 'Courtesy'
        ..q13PickedAdvantage = false
        ..q13Skill = 'Games'
        ..q13Disadvantage = 'Bluntness';
      final skills = wizard.calcSkills().skills;
      expect(skills['Courtesy'], 1);
      expect(skills['Games'], 1);
    });
  });

  group('assembly (page 7 initializePage)', () {
    test('social stats, wealth, and identity', () {
      final wizard = hidaBuild()..replacementRings = ['Fire', ''];
      wizard.assemble();
      expect(character.name, 'Tetsu');
      expect(character.clan, 'Crab');
      expect(character.family, 'Hida');
      expect(character.school, 'Hida Defender School');
      // Status = clan 30; glory = family 44 + 5 (Q7); honor = school 40 + 10
      // (Q8); wealth = family 4 koku.
      expect(character.status, 30);
      expect(character.glory, 49);
      expect(character.honor, 50);
      expect(character.koku, 4);
      expect(character.heritage, '');
      expect(character.ninjo, 'Protect the weak');
      expect(character.giri, 'Serve Hida-ue');
    });

    test('techniques, traits, and equipment land on the character', () {
      final wizard = hidaBuild()..replacementRings = ['Fire', ''];
      wizard.assemble();
      expect(character.techniques,
          containsAll(["Lord Hida's Grip", 'Striking as Earth']));
      expect(
          character.advDisadv,
          containsAll(
              ['Large Stature', 'Bluntness', 'Paragon of Loyalty']));
      final names = {for (final item in character.equipment) item.name};
      // Fixed outfit entries plus the chosen Tetsubō.
      expect(names,
          containsAll(['Lacquered Armor', 'Katana', 'Knife', 'Tetsubō']));
      // Katana produces one item per grip.
      expect(
          character.equipment.where((item) => item.name == 'Katana').length,
          gameData.weaponByName('Katana')!.grips.length);
      expect(character.notes, contains('20. Death:'));
    });

    test('heritage modifiers and skill grant apply', () {
      final wizard = hidaBuild()
        ..replacementRings = ['Fire', '']
        ..heritageSource = 'Core'
        ..ancestor1 = 'Wondrous Work'
        ..chosenAncestor = 1
        ..q18OtherEffects = 'Smithing';
      final entry = gameData.heritageByResult('Wondrous Work')!;
      wizard.assemble();
      expect(character.heritage, 'Wondrous Work');
      expect(character.glory, 49 + entry.glory);
      expect(character.baseSkills['Smithing'], 1);
    });

    test('ring exchange heritage adjusts rings', () {
      final wizard = hidaBuild()
        ..replacementRings = ['Fire', '']
        ..ancestor1 = 'Mark of the Elements'
        ..chosenAncestor = 1
        ..q18OtherEffects = 'Ring Exchange'
        ..q18Special1 = 'Air' // raise
        ..q18Special2 = 'Water'; // lower
      final rings = wizard.calcRings().rings;
      expect(rings[ringAir], 2);
      expect(rings[ringWater], 1);
    });
  });

  group('rōnin path', () {
    test('status, wealth, and upbringing effects', () {
      final wizard = WizardState()
        ..characterType = characterTypeRonin
        ..region = 'Urban region'
        ..upbringing = 'Craftsperson'
        ..upbringingRing = 'Void'
        ..upbringingSkills = ['Culture', 'Design', '']
        ..school = 'Rōnin Duelist'
        ..personalName = 'Masaru'
        ..q7Positive = false
        ..q7Skill = 'Fitness'
        ..q8Choice = 'neg'
        ..q8Skill = 'Survival'
        ..q13PickedAdvantage = true
        ..q13Advantage = 'Quick Reflexes'
        ..roninBond = gameData.bonds.first.name;
      wizard.assemble();
      // Rōnin base status 24, Craftsperson modifier -2.
      expect(character.status, 22);
      expect(character.glory, 29); // Urban region
      expect(character.koku, 1); // Craftsperson wealth
      expect(character.clan, 'Urban region');
      expect(character.family, 'Craftsperson');
      expect(character.heritage, 'None');
      expect(character.bonds.single.name, gameData.bonds.first.name);
      final rings = wizard.calcRings().rings;
      expect(rings[ringAir], 2); // urban region
      expect(rings[ringVoid], 2); // upbringing choice
      final skills = wizard.calcSkills().skills;
      expect(skills['Commerce'], 1); // region
      expect(skills['Culture'], 1);
      expect(skills['Survival'], 1); // q8 negative
    });
  });

  group('option lists', () {
    test('samurai school options are clan schools unless unrestricted', () {
      final wizard = hidaBuild();
      expect(wizard.schoolOptions(), contains('Hida Defender School'));
      expect(wizard.schoolOptions(), isNot(contains('Kakita Duelist School')));
      wizard.unrestrictedSchool = true;
      expect(wizard.schoolOptions(), contains('Kakita Duelist School'));
    });

    test('rōnin school options are rōnin schools', () {
      final wizard = WizardState()..characterType = characterTypeRonin;
      final options = wizard.schoolOptions();
      expect(options, isNotEmpty);
      for (final option in options) {
        expect(gameData.schoolByName(option)!.clan, characterTypeRonin);
      }
    });

    test('heritage effect options strip auto-granted placeholders', () {
      final wizard = WizardState()
        ..ancestor1 = 'Vengeance for the Fallen'
        ..chosenAncestor = 1;
      final options = wizard.heritageEffectOptions();
      expect(options, isNot(contains('Haunting')));
      expect(options, contains('Fitness'));
    });

    test('equipment special directives expand to rarity-filtered lists', () {
      final weapons =
          WizardState.equipmentSpecialOptions('One Weapon of Rarity 6 or Lower')!;
      expect(weapons, isNotEmpty);
      for (final name in weapons) {
        expect(gameData.weaponByName(name)!.rarity, lessThanOrEqualTo(6));
      }
      expect(
          WizardState.equipmentSpecialCount('Two Items of Rarity 4 or Lower'),
          2);
      expect(WizardState.equipmentSpecialOptions('Katana'), isNull);
    });
  });
}
