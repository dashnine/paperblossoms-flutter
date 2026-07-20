import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

/// A campaign-legal HoR Crab bushi: all starting skills granted, service to
/// the clan champion, Material Success heritage.
WizardState horHidaBuild() {
  final wizard = WizardState()
    ..horMode = true
    ..characterType = characterTypeSamurai
    ..clan = 'Crab'
    ..family = 'Hida'
    ..familyRing = 'Earth'
    ..school = 'Hida Defender School'
    ..schoolSkills = [
      ...gameData.schoolByName('Hida Defender School')!.startingSkills.options
    ]
    ..ringChoices = ['Earth', 'Water']
    ..schoolSpecialRing = 'Void'
    ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
    ..equipChoices = ['Tetsubō']
    ..personalName = 'Tetsu'
    ..horService = 'Clan Champion'
    ..horQ5Skill = 'Command'
    ..horQ6Skill = 'Courtesy'
    ..q7Positive = true
    ..q7Skill = 'Commerce' // listed for another Crab family (Yasuki)
    ..q8Choice = 'pos'
    ..q8Skill = 'Theology'
    ..distinction = 'Large Stature'
    ..adversity = 'Bluntness'
    ..passion = 'Architecture'
    ..anxiety = 'Whispers of Impiety' // campaign-added adversity family
    ..q13PickedAdvantage = true
    ..q13Advantage = 'Paragon of Loyalty'
    ..q14Item = 'Calligraphy Set'
    ..ancestor1 = 'Material Success'
    ..chosenAncestor = 1;
  return wizard;
}

/// A campaign-legal HoR rōnin with a Criminal Past background serving the
/// Emerald Magistrates.
WizardState horRoninBuild() {
  final wizard = WizardState()
    ..horMode = true
    ..characterType = characterTypeRonin
    ..horRoninRing = 'Void'
    ..horBackground = 'Criminal Past'
    ..horBackgroundRing = 'Air'
    ..horBackgroundSkills = ['Commerce', 'Skulduggery']
    ..school = 'Worldly Rōnin Path'
    ..schoolSkills = [
      ...gameData.schoolByName('Worldly Rōnin Path')!.startingSkills.options
    ]
    ..ringChoices = ['Fire', 'Water']
    ..schoolSpecialRing = 'Earth'
    ..techChoices = ['Pelting Hail Style', 'All in Jest']
    ..personalName = 'Kaze'
    ..horService = 'Emerald Magistrates'
    ..horQ5Skill = 'Government'
    ..horQ6Skill = 'Sentiment'
    ..q7Positive = false
    ..q7Skill = 'Aesthetics' // no background lists it
    ..q8Choice = 'neg'
    ..q8Skill = 'Medicine'
    ..distinction = 'Large Stature'
    ..adversity = 'Bluntness'
    ..passion = 'Architecture'
    ..anxiety = 'Anxious Nature'
    ..q13PickedAdvantage = true
    ..q13Advantage = 'Paragon of Loyalty'
    ..q14Item = 'Calligraphy Set'
    ..ancestor1 = 'Religious Patron'
    ..chosenAncestor = 1
    ..q18OtherEffects = 'Support of the Brotherhood';
  return wizard;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() => character.clear());

  group('skill cap 2', () {
    test('every skill is capped at 2 and overflow is reported', () {
      // Fitness: clan (Crab) + school = 2; push it to 3 with the Q5 skill.
      final wizard = horHidaBuild()..horQ5Skill = 'Fitness';
      final skills = wizard.calcSkills();
      expect(skills.skills['Fitness'], 2);
      expect(skills.overflow, 1);
    });

    test('the Q13 mentor-disadvantage skill may reach 3', () {
      final wizard = horHidaBuild()
        ..q13PickedAdvantage = false
        ..q13Disadvantage = 'Bluntness'
        ..q13Skill = 'Fitness';
      // Fitness: clan + school + Q13 = 3, allowed only via the exception.
      final skills = wizard.calcSkills();
      expect(skills.skills['Fitness'], 3);
      expect(skills.overflow, 0);
    });

    test('replacement redistribution respects the cap', () {
      final wizard = horHidaBuild()
        ..horQ5Skill = 'Fitness' // 1 overflow
        ..replacementSkills = ['Tactics', 'Courtesy', ''];
      // Tactics is already at 2 (family + school): the point must skip it
      // and land on Courtesy... but Courtesy is at 1 from Q6, so it fits.
      final skills = wizard.calcSkills();
      expect(skills.skills['Tactics'], 2);
      expect(skills.skills['Courtesy'], 2);
      expect(skills.overflow, 0);
    });

    test('stock mode still caps at 3', () {
      final wizard = horHidaBuild()..horMode = false;
      expect(wizard.skillCap('Fitness'), 3);
    });

    test('ensureReplacementSkillSlots grows past the stock three', () {
      final wizard = horHidaBuild()..ensureReplacementSkillSlots(5);
      expect(wizard.replacementSkills, hasLength(5));
    });

    test('setReplacementSkill pads the list instead of throwing', () {
      final wizard = horHidaBuild()..setReplacementSkill(4, 'Games');
      expect(wizard.replacementSkills, hasLength(5));
      expect(wizard.replacementSkills[4], 'Games');
    });

    test('pruneStaleReplacementSkills clears picks pushed to cap', () {
      // Commerce is at 1 (Q7); a replacement pick of Commerce is legal.
      final wizard = horHidaBuild()
        ..horQ5Skill = 'Fitness' // 1 overflow to redistribute
        ..replacementSkills = ['Commerce', '', ''];
      expect(wizard.calcSkills().overflow, 0);
      // An earlier-page edit pushes Commerce to cap 2: the pick is stale.
      wizard.horQ6Skill = 'Commerce';
      wizard.pruneStaleReplacementSkills();
      expect(wizard.replacementSkills[0], '');
      // Stock mode: prune is a no-op.
      final stock = horHidaBuild()
        ..horMode = false
        ..replacementSkills = ['Commerce', '', ''];
      stock.pruneStaleReplacementSkills();
      expect(stock.replacementSkills[0], 'Commerce');
    });
  });

  group('ring cap 3', () {
    // Every HoR rōnin ring source stacked on Water: base 1 + any-ring clan
    // block + background + two school choices + standout = 6.
    WizardState waterStacked() => horRoninBuild()
      ..horRoninRing = 'Water'
      ..horBackgroundRing = 'Water'
      ..ringChoices = ['Water', 'Water']
      ..schoolSpecialRing = 'Water';

    test('a ring stacked to 6 is capped and reports 3 overflow', () {
      final rings = waterStacked().calcRings();
      expect(rings.rings['Water'], 3);
      expect(rings.overflow, 3);
    });

    test('three replacement slots absorb the overflow', () {
      final wizard = waterStacked()
        ..replacementRings = ['Air', 'Earth', 'Fire'];
      final rings = wizard.calcRings();
      expect(rings.overflow, 0);
      expect(rings.rings['Air'], 2);
      expect(rings.rings['Earth'], 2);
      expect(rings.rings['Fire'], 2);
    });

    test('replacement redistribution respects the cap', () {
      final wizard = horRoninBuild()
        ..horRoninRing = 'Water'
        ..horBackgroundRing = 'Water'
        ..ringChoices = ['Water', 'Fire'] // Water 4: 1 overflow; Fire 2
        ..schoolSpecialRing = 'Fire' // Fire 3
        ..replacementRings = ['Fire', 'Air'];
      // Fire is already at 3: the point must skip it and land on Air.
      final rings = wizard.calcRings();
      expect(rings.rings['Fire'], 3);
      expect(rings.rings['Air'], 2);
      expect(rings.overflow, 0);
    });

    test('setReplacementRing pads the list instead of throwing', () {
      final wizard = horRoninBuild()..setReplacementRing(3, 'Air');
      expect(wizard.replacementRings, hasLength(4));
      expect(wizard.replacementRings[3], 'Air');
    });

    test('pruneStaleReplacementRings clears picks pushed to cap', () {
      final wizard = horRoninBuild()
        ..horRoninRing = 'Water'
        ..horBackgroundRing = 'Water'
        ..ringChoices = ['Water', 'Fire'] // 1 overflow; Fire at 2
        ..schoolSpecialRing = 'Air'
        ..replacementRings = ['Fire', ''];
      expect(wizard.calcRings().overflow, 0);
      // An earlier-page edit pushes Fire to 3: the pick is stale.
      wizard.schoolSpecialRing = 'Fire';
      wizard.pruneStaleReplacementRings();
      expect(wizard.replacementRings[0], '');
      // Stock mode: prune is a no-op.
      final stock = horRoninBuild()
        ..horMode = false
        ..replacementRings = ['Fire', ''];
      stock.pruneStaleReplacementRings();
      expect(stock.replacementRings[0], 'Fire');
    });
  });

  group('Q5-Q8 mechanics', () {
    test('giri and ninjō skills land in the raw skills', () {
      final skills = horHidaBuild().rawSkills();
      expect(skills['Command'], 2); // family + Q5
      expect(skills['Courtesy'], 1); // Q6
    });

    test('Q7 skill counts on the positive branch too', () {
      final skills = horHidaBuild().calcSkills().skills;
      expect(skills['Commerce'], 1);
    });

    test('Q7 options: another family\'s skills vs no family\'s skills', () {
      final wizard = horHidaBuild();
      final positive = wizard.horQ7SkillOptions(positive: true);
      expect(positive, contains('Commerce')); // Yasuki
      expect(positive, isNot(contains('Command'))); // own family (Hida)
      final negative = wizard.horQ7SkillOptions(positive: false);
      expect(negative, isNot(contains('Commerce')));
      expect(negative, isNot(contains('Command')));
    });

    test('Q8 orthodox branch grants a skill and +5 honor', () {
      final wizard = horHidaBuild();
      wizard.assemble();
      expect(character.baseSkills['Theology'], 1);
      expect(character.honor, 45); // school 40 + 5
    });

    test('Q7/Q8 negative swings: −5 glory, −3 honor', () {
      final wizard = horHidaBuild()
        ..q7Positive = false
        ..q7Skill = 'Commerce'
        ..q8Choice = 'neg'
        ..q8Skill = 'Medicine'
        ..ancestor1 = ''
        ..chosenAncestor = 0;
      wizard.assemble();
      expect(character.glory, 39); // family 44 − 5
      expect(character.honor, 37); // school 40 − 3
    });
  });

  group('samurai assembly', () {
    test('campaign title, status 40, and Material Success wealth', () {
      final wizard = horHidaBuild();
      wizard.assemble();
      expect(character.titles, ['Agent of the Clan Champion']);
      expect(character.status, 40);
      expect(character.koku, 9); // family 4 + Material Success 5
      expect(character.glory, 44); // family 44 + Q7 5 − heritage 5
      expect(character.heritage, 'Material Success');
    });

    test('Q14 accessory reaches samurai equipment', () {
      final wizard = horHidaBuild();
      wizard.assemble();
      expect([for (final item in character.equipment) item.name],
          contains('Calligraphy Set'));
    });

    test('Q19 extra technique is added', () {
      final wizard = horHidaBuild();
      final options = wizard.horQ19Options();
      expect(options, isNotEmpty);
      // Unpicked starting-technique options qualify; picked ones do not.
      expect(options, contains('Striking as Water'));
      expect(options, isNot(contains('Striking as Earth')));
      wizard.horQ19Technique = 'Striking as Water';
      wizard.assemble();
      expect(character.techniques, contains('Striking as Water'));
    });

    test('the hor flag serializes and round-trips', () {
      final wizard = horHidaBuild();
      wizard.assemble();
      expect(character.hor, isTrue);
      final json = character.toJson();
      expect(json['hor'], isTrue);
      character.clear();
      character.loadFromJson(json);
      expect(character.hor, isTrue);
    });

    test('notes carry service and campaign title with stipend', () {
      final wizard = horHidaBuild();
      wizard.assemble();
      expect(character.notes, contains('5. Service: \nClan Champion'));
      expect(character.notes,
          contains('20. Campaign Title: \nAgent of the Clan Champion'));
      expect(character.notes, contains('stipend: 5 koku'));
    });
  });

  group('heritage table', () {
    test('HoR entries win the name collision with Core in HoR mode', () {
      final wizard = horHidaBuild()..ancestor1 = 'Stolen Knowledge';
      expect(wizard.heritageEntry!.source, 'HoR');
      wizard.horMode = false;
      expect(wizard.heritageEntry!.source, 'Core');
    });

    test('Stolen Knowledge grants the technique and −5 honor', () {
      final wizard = horHidaBuild()
        ..ancestor1 = 'Stolen Knowledge'
        ..q18OtherEffects = 'Kihō'
        ..q18Secondary = 'Cleansing Spirit';
      wizard.assemble();
      expect(character.techniques, contains('Cleansing Spirit'));
      expect(character.honor, 40); // school 40 + Q8 5 − heritage 5
    });

    test('Battle of One Thousand Years marks the item and adds the '
        'adversity', () {
      final wizard = horHidaBuild()
        ..ancestor1 = 'Battle of One Thousand Years'
        ..q18Secondary = 'Katana';
      wizard.assemble();
      final katana = [
        for (final item in character.equipment)
          if (item.name == 'Katana') item
      ];
      expect(katana, isNotEmpty);
      for (final item in katana) {
        expect(item.qualities, containsAll(['Sacred', 'Forbidden']));
      }
      expect(character.advDisadv,
          contains('Blackmailed by the Imperial Treasurer'));
      expect(character.glory, 44); // family 44 + Q7 5 − heritage 5
    });

    test('no Blackmailed adversity without the marked item', () {
      final wizard = horHidaBuild()
        ..ancestor1 = 'Battle of One Thousand Years'
        ..q18Secondary = '';
      wizard.assemble();
      expect(character.advDisadv,
          isNot(contains('Blackmailed by the Imperial Treasurer')));
    });
  });

  group('rōnin assembly', () {
    test('rings from the clan block and background', () {
      final rings = horRoninBuild().calcRings();
      expect(rings.rings['Void'], 2); // base + any-ring pick
      expect(rings.rings['Air'], 2); // base + background
      expect(rings.rings['Earth'], 2); // base + standout
      expect(rings.overflow, 0);
    });

    test('skills: Survival clan block plus background picks', () {
      final skills = horRoninBuild().calcSkills();
      expect(skills.skills['Survival'], 1);
      expect(skills.skills['Commerce'], 1);
      expect(skills.skills['Skulduggery'], 2); // school + background
      expect(skills.overflow, 0);
    });

    test('social stats, wealth, title, and heritage', () {
      final wizard = horRoninBuild();
      wizard.assemble();
      expect(character.clan, characterTypeRonin);
      expect(character.family, '');
      expect(character.heritage, 'Religious Patron');
      expect(character.glory, 19); // background 21 + heritage 3 − Q7 5
      expect(character.honor, 27); // school 30 − Q8 3
      expect(character.bu, 4);
      expect(character.status, 40);
      expect(character.titles, ['Emerald Magistrate (HoR)']);
      expect(character.advDisadv, contains('Support of the Brotherhood'));
      expect(character.notes, contains('2. Rōnin Background: \nCriminal Past'));
    });

    test('switching character type clears the service and Q5/Q6 skills', () {
      final wizard = horHidaBuild();
      expect(wizard.horService, 'Clan Champion');
      wizard.setCharacterType(characterTypeRonin);
      expect(wizard.horService, '');
      expect(wizard.horQ5Skill, '');
      expect(wizard.horQ6Skill, '');
      expect(wizard.horBackground, '');
      wizard.assemble();
      expect(character.titles, isEmpty);
      expect(character.status, isNot(40));
    });

    test('selectHorBackground sizes the skill list to the data', () {
      final wizard = horRoninBuild()..selectHorBackground('Military Service');
      expect(wizard.horBackgroundSkills, hasLength(1)); // one choice set
      wizard.selectHorBackground('Criminal Past');
      expect(wizard.horBackgroundSkills, hasLength(2));
    });

    test('without a service the base status 22 shows through', () {
      final wizard = horRoninBuild()..horService = '';
      wizard.assemble();
      expect(character.status, 22);
      expect(character.titles, isEmpty);
    });
  });

  group('ban filtering', () {
    test('samurai school options exclude campaign-banned schools', () {
      final crab = horHidaBuild();
      final options = crab.schoolOptions();
      expect(options, contains('Hida Defender School'));
      expect(options, isNot(contains('Toritaka Phantom Hunter School')));
      final phoenix = horHidaBuild()..clan = 'Phoenix';
      expect(phoenix.schoolOptions(),
          isNot(contains('Kaito Spirit Seeker School')));
    });

    test('rōnin school options are exactly the allowed list', () {
      final options = horRoninBuild().schoolOptions();
      expect(options, hasLength(9));
      expect(options, contains('Worldly Rōnin Path'));
      expect(options, contains('Sand Road Wayfinder Tradition'));
      expect(options, isNot(contains('The Hare Bushi School')));
    });

    test('trait names drop banned entries and add campaign ones', () {
      final wizard = horHidaBuild();
      final adversities = wizard.horTraitNames('Adversities');
      expect(adversities, isNot(contains('Sworn Enemy')));
      expect(adversities, isNot(contains('Blood Feud')));
      expect(adversities, contains('Tremors'));
      expect(adversities, contains('Whispers of Impiety'));
      final distinctions = wizard.horTraitNames('Distinctions');
      expect(distinctions, isNot(contains('Blessed Lineage')));
      expect(distinctions, contains('Famously Pious'));
    });
  });

  group('stock regression', () {
    test('a stock build assembles identically with the HoR data loaded', () {
      // Mirrors the numbers asserted in wizard_state_test.dart: HoR loading
      // and the cap refactor must not shift stock math by a point.
      final wizard = WizardState()
        ..characterType = characterTypeSamurai
        ..clan = 'Crab'
        ..family = 'Hida'
        ..familyRing = 'Earth'
        ..school = 'Hida Defender School'
        ..schoolSkills = [
          'Fitness',
          'Martial Arts [Melee]',
          'Meditation',
          'Survival',
          'Tactics',
        ]
        ..ringChoices = ['Earth', 'Water']
        ..schoolSpecialRing = 'Void'
        ..techChoices = ["Lord Hida's Grip", 'Striking as Earth']
        ..q7Positive = true
        ..q8Choice = 'pos'
        ..replacementRings = ['Fire', ''];
      wizard.assemble();
      expect(character.status, 30);
      expect(character.glory, 49);
      expect(character.honor, 50);
      expect(character.titles, isEmpty);
      expect(character.baseSkills['Fitness'], 2);
      expect(character.baseRings['Earth'], 3);
      // Stock save files must stay byte-identical: no hor key at all.
      expect(character.hor, isFalse);
      expect(character.toJson().containsKey('hor'), isFalse);
    });
  });
}
