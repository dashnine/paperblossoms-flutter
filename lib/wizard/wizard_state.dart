// The Twenty Questions engine: holds every answer the wizard collects
// (the original app's registerField values) and assembles the final
// Character. Ported from src/characterwizard/newcharwizardpage1-7.cpp;
// UI-free so the assembly rules are unit-testable.

import '../character.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../item.dart';
import '../rules_constants.dart';

/// Skills every character may pick from when diverging from Bushidō (Q8).
const question8Skills = [
  'Commerce',
  'Labor',
  'Medicine',
  'Seafaring',
  'Skulduggery',
  'Survival',
];

/// Heritage-table source books, in the original's order.
const heritageSources = ['Core', 'SL', 'CoS', 'CR', 'FoV', 'WotW', 'CotFW'];

/// How a heritage's other_effects type maps onto UI + assembly behavior.
enum HeritageEffectKind {
  skill, // outcome (or a chosen option) is a bonus skill
  trait, // outcome is an advantage/disadvantage added directly
  startingItem, // roll/choose an item category, then a concrete item + 2 qualities
  lostHeirloom, // like startingItem but recorded in notes, not gear
  technique, // outcome is a technique group; secondary picks the technique
  ringExchange, // raise one ring, lower another
  namedItem, // outcome maps directly to a named item added to gear
  mixed, // per-outcome behavior (e.g. "other": ring exchange vs item)
  none,
}

class WizardState {
  // ---- Page 1: clan & family (Q1-2) ----
  String characterType = characterTypeSamurai; // Samurai|Rōnin|Peasant|Gaijin
  String clan = '';
  String family = '';
  String familyRing = '';
  String region = '';
  String upbringing = '';
  String upbringingRing = '';
  List<String> upbringingSkills = ['', '', ''];

  // ---- Page 2: role & school (Q3-4) ----
  String school = '';
  bool unrestrictedSchool = false;
  List<String> schoolSkills = [];
  List<String> ringChoices = []; // one entry per school ring increase
  String schoolSpecialRing = ''; // Q4 standout ring (samurai)
  List<String> techChoices = [];
  List<String> equipChoices = [];
  List<String> equipSpecialChoices = [];
  String kitsuneSchool = ''; // Kitsune Impersonator: whose outfit to copy
  String schoolOtherChoice = ''; // Mazoku's Enforcer: Haunting/Omen of Bad Luck
  String q4Text = '';

  // ---- Page 3: honor & glory (Q5-8) ----
  String q5Text = ''; // samurai: lord & duty (giri) / rōnin: past
  String q6Text = ''; // ninjō
  String q7Text = '';
  String q8Text = '';
  bool? q7Positive; // true: +5 glory, false: bonus skill
  String q7Skill = '';
  String q8Choice = ''; // pos | mid | neg (mid = rōnin item)
  String q8Skill = '';
  String q8Item = '';

  // ---- Page 4: strengths & weaknesses (Q9-13) ----
  String distinction = '';
  String adversity = '';
  String passion = '';
  String anxiety = '';
  bool? q13PickedAdvantage; // true: advantage, false: disadvantage + skill
  String q13Skill = '';
  String q13Advantage = '';
  String q13Disadvantage = '';
  String q9Text = '';
  String q10Text = '';
  String q11Text = '';
  String q12Text = '';
  String q13Text = '';

  // ---- Page 5: personality (Q14-16) ----
  String q14Text = '';
  String q14Item = ''; // rōnin prized possession
  String q15Text = '';
  String q16Text = '';
  String q16Item = '';

  // ---- Page 6: ancestry (Q17-18) ----
  String parentSkill = '';
  String q17Text = '';
  String heritageSource = 'Core';
  String ancestor1 = '';
  String ancestor2 = '';
  int chosenAncestor = 0; // 0 = none, 1 or 2
  String q18OtherEffects = '';
  String q18Secondary = '';
  String q18Special1 = '';
  String q18Special2 = '';
  String roninBond = '';
  String q17RoninText = '';

  // ---- Page 7 ----
  String personalName = '';
  String q20Text = '';
  List<String> replacementRings = ['', ''];
  List<String> replacementSkills = ['', '', ''];

  bool get isSamurai => characterType == characterTypeSamurai;

  String get heritage =>
      chosenAncestor == 1 ? ancestor1 : (chosenAncestor == 2 ? ancestor2 : '');

  HeritageEntry? get heritageEntry =>
      heritage.isEmpty ? null : gameData.heritageByResult(heritage);

  // ---------------------------------------------------------------------
  // Heritage effect classification (page 6 buildq18UI, data-driven from
  // other_effects.type instead of the original's per-heritage switch).
  // ---------------------------------------------------------------------

  static HeritageEffectKind effectKindOf(HeritageEntry entry) {
    final type = entry.otherEffects.type;
    switch (type) {
      case 'Artisan skills':
      case 'Social skill':
      case 'Scholar skill':
      case 'Martial skill':
      case 'Trade skill':
      case 'Skill':
      case 'Adversity and Skill': // auto-trait + skill choice
        return HeritageEffectKind.skill;
      case 'Distinction':
      case 'Adversity':
      case 'Advantage':
      case 'Anxiety':
        return HeritageEffectKind.trait;
      case 'starting item':
        return HeritageEffectKind.startingItem;
      case 'lost family heirloom':
        return HeritageEffectKind.lostHeirloom;
      case 'Technique':
        return HeritageEffectKind.technique;
      case 'Ring':
      case 'Anxiety and other': // auto-trait + Void ring exchange
        return HeritageEffectKind.ringExchange;
      case 'Personal Effect':
      case 'Invocation':
      case 'Ancestral Horse Line':
      case 'starting item and distinction':
        return HeritageEffectKind.namedItem;
      case 'other':
        return HeritageEffectKind.mixed;
      default:
        return HeritageEffectKind.none;
    }
  }

  /// Effects auto-granted by specific heritages (page 7's hardcoded list).
  static const autoGrantedTraits = {
    'Vengeance for the Fallen': 'Haunting',
    'Tainted Blood': 'Fallen Ancestor',
    'Unforgivable Performance': "Benten's Curse",
    'Elegant Craftsman': 'Isolation',
    'Associated with a Natural Disaster': 'Whispers of Failure',
    'Heart of the Horse': 'Karmic Tie',
  };

  /// Heritage → fixed item grants (page 7's horse/estate mappings).
  static const namedItemGrants = {
    'Heart of the Horse': 'Horse',
    'Sacred Wilderness': "Estate somewhere in your clan's territory",
  };

  static const horseLineItems = {
    'Utaku Horse': 'Utaku Warhorse',
    'Shinjo Horse': 'Shinjo Courser',
    'Iuchi Horse': 'Iuchi Riding Steed',
    'Ide Horse': 'Ide Traveling Pony',
    'Moto Horse': 'Moto Charger',
  };

  /// Primary choice options for the selected heritage (otherComboBox).
  List<String> heritageEffectOptions() {
    final entry = heritageEntry;
    if (entry == null) return [];
    var options = [for (final o in entry.otherEffects.outcomes) o.outcome];
    // Auto-granted placeholders are not choices (page 6 removes them).
    final auto = autoGrantedTraits[entry.result];
    if (auto != null) options = [for (final o in options) if (o != auto) o];
    return options;
  }

  // ---------------------------------------------------------------------
  // Running ring/skill maps (pages 1-7 calcCurrentRings/calcSkills)
  // ---------------------------------------------------------------------

  /// Ring map before cap enforcement (page 7 calcRings, pre-overflow).
  Map<String, int> rawRings() {
    final rings = {for (final ring in gameData.ringNames()) ring: 1};
    void bump(String ring, [int by = 1]) {
      if (ring.isEmpty) return;
      rings[ring] = (rings[ring] ?? 0) + by;
    }

    if (isSamurai) {
      bump(gameData.clanByName(clan)?.ringIncrease ?? '');
      bump(familyRing);
    } else {
      bump(gameData.regionByName(region)?.ringIncrease ?? '');
      bump(upbringingRing);
    }
    for (final ring in ringChoices) {
      bump(ring);
    }
    bump(schoolSpecialRing);

    // Heritage ring exchanges (page 7 calcRings).
    if (q18OtherEffects == 'Ring Exchange' ||
        q18OtherEffects == 'Void ring exchange' ||
        q18OtherEffects == 'Air/Fire ring exchange') {
      bump(q18Special1);
      bump(q18Special2, -1);
    }
    if (q18OtherEffects.endsWith(' Ring') &&
        heritageEntry?.otherEffects.type == 'Ring' &&
        q18Special2.isNotEmpty) {
      bump(q18OtherEffects.split(' ').first);
      bump(q18Special2, -1);
    }
    return rings;
  }

  /// Final ring map with the creation cap of 3 enforced; overflow points are
  /// redistributed via [replacementRings].
  ({Map<String, int> rings, int overflow}) calcRings() {
    final rings = rawRings();
    var overflow = 0;
    for (final entry in rings.entries.toList()) {
      if (entry.value > 3) {
        overflow += entry.value - 3;
        rings[entry.key] = 3;
      }
    }
    for (final replacement in replacementRings) {
      if (replacement.isNotEmpty && overflow > 0) {
        rings[replacement] = (rings[replacement] ?? 0) + 1;
        overflow--;
      }
    }
    return (rings: rings, overflow: overflow);
  }

  /// Whether the chosen heritage effect grants a bonus skill.
  bool _heritageGrantsSkill() {
    final entry = heritageEntry;
    if (entry == null) return false;
    return effectKindOf(entry) == HeritageEffectKind.skill;
  }

  /// Skill list before cap enforcement (page 7 calcSkills, pre-overflow).
  Map<String, int> rawSkills() {
    final sources = <String>[
      ...gameData.clanByName(clan)?.skillIncrease != null && isSamurai
          ? [gameData.clanByName(clan)!.skillIncrease]
          : <String>[],
      if (isSamurai)
        ...gameData.familyByName(clan, family)?.skillIncrease ?? <String>[],
      if (!isSamurai) gameData.regionByName(region)?.skillIncrease ?? '',
      ...upbringingSkills,
      ...schoolSkills,
      q7Skill,
      q8Skill,
      if (q13PickedAdvantage == false) q13Skill,
      parentSkill,
      if (_heritageGrantsSkill()) q18OtherEffects,
    ];
    final skills = <String, int>{};
    for (final skill in sources) {
      if (skill.isEmpty) continue;
      skills[skill] = (skills[skill] ?? 0) + 1;
    }
    return skills;
  }

  /// Final skill map with the creation cap of 3; overflow redistributed via
  /// [replacementSkills].
  ({Map<String, int> skills, int overflow}) calcSkills() {
    final skills = rawSkills();
    var overflow = 0;
    for (final entry in skills.entries.toList()) {
      if (entry.value > 3) {
        overflow += entry.value - 3;
        skills[entry.key] = 3;
      }
    }
    for (final replacement in replacementSkills) {
      if (replacement.isNotEmpty && overflow > 0) {
        skills[replacement] = (skills[replacement] ?? 0) + 1;
        overflow--;
      }
    }
    return (skills: skills, overflow: overflow);
  }

  // ---------------------------------------------------------------------
  // Option lists for the pages
  // ---------------------------------------------------------------------

  List<String> schoolOptions() {
    if (isSamurai) {
      final schools = unrestrictedSchool
          ? gameData.schools
          : gameData.schoolsOf(clan);
      return [for (final school in schools) school.name];
    }
    if (characterType == characterTypeGaijin) {
      final subtype = gameData.regionByName(region)?.subtype ?? '';
      return [
        for (final school in gameData.schools)
          if (school.clan == subtype ||
              school.clan == characterTypeRonin ||
              unrestrictedSchool)
            school.name
      ];
    }
    // Rōnin and Peasant characters use rōnin schools.
    return [
      for (final school in gameData.schools)
        if (school.clan == characterTypeRonin || unrestrictedSchool)
          school.name
    ];
  }

  /// Skills the character does not already have (Q7 negative / Q17).
  /// [except] keeps the asking dropdown's own current selection in its list
  /// — without it, picking a skill would immediately remove that skill from
  /// the very dropdown showing it.
  List<String> unheldSkillOptions({String except = ''}) {
    final held = {
      ...schoolSkills,
      if (isSamurai) gameData.clanByName(clan)?.skillIncrease ?? '',
      ...(isSamurai
          ? gameData.familyByName(clan, family)?.skillIncrease ?? <String>[]
          : <String>[]),
      if (!isSamurai) gameData.regionByName(region)?.skillIncrease ?? '',
      ...upbringingSkills,
      q7Skill,
      q8Skill,
      if (q13PickedAdvantage == false) q13Skill,
      parentSkill,
    }..remove(except);
    return [
      for (final skill in gameData.allSkills())
        if (!held.contains(skill)) skill
    ];
  }

  /// Expands a school starting-technique option set like the original: a
  /// subcategory name becomes all rank-1 techniques of that subcategory.
  List<String> expandTechniqueOptions(ChoiceSet set) {
    final subcategories = {
      for (final tech in gameData.techniques) tech.subcategory
    };
    final options = <String>[];
    for (final option in set.options) {
      if (subcategories.contains(option)) {
        options.addAll([
          for (final tech
              in gameData.techniquesByGroup(option, minRank: 1, maxRank: 1))
            tech.name
        ]);
      } else {
        options.add(option);
      }
    }
    return options;
  }

  /// Starting-outfit special directives → concrete pickable options
  /// (page 2 handleSpecCases).
  static List<String>? equipmentSpecialOptions(String directive) {
    List<String> weaponNames(int rarity, {String? category}) => [
          for (final weapon
              in gameData.weaponsUnderRarity(rarity, category: category))
            weapon.name
        ];
    List<String> itemNames(int rarity) => [
          for (final weapon in gameData.weaponsUnderRarity(rarity))
            weapon.name,
          for (final armor in gameData.armorUnderRarity(rarity)) armor.name,
          for (final effect in gameData.personalEffectsUnderRarity(rarity))
            effect.name,
        ];
    switch (directive) {
      case 'One Weapon of Rarity 6 or Lower':
        return weaponNames(6);
      case 'Two Weapons of Rarity 6 or Lower':
        return weaponNames(6); // caller adds two pickers
      case 'Two Weapons of Rarity 7 or Lower':
        return weaponNames(7);
      case 'One Sword of Rarity 7 or Lower':
        return weaponNames(7, category: 'Swords');
      case 'One weapon of your signature weapon category of rarity 8 or lower':
        return weaponNames(8);
      case 'Two Items of Rarity 4 or Lower':
      case 'One Item of Rarity 4 or Lower':
        return itemNames(4);
      case 'One Item of Rarity 3 or Lower':
        return itemNames(3);
      case 'One Item of Rarity 5 or Lower':
        return itemNames(5);
      case 'One Item of Rarity 6 or Lower':
        return itemNames(6);
      case 'Two Items of Rarity 2 or Lower that the Nezumi Scavenged':
        return itemNames(2);
      default:
        return null;
    }
  }

  static int equipmentSpecialCount(String directive) =>
      directive.startsWith('Two ') ? 2 : 1;

  // ---------------------------------------------------------------------
  // Assembly (page 7)
  // ---------------------------------------------------------------------

  /// Builds items for [name] the way page 7 populateItemFields does: weapons
  /// get one item per grip, unknown names become a bare personal effect.
  static List<Item> itemsFor(String name,
      {List<String> extraQualities = const []}) {
    if (name.isEmpty) return [];
    final weapon = gameData.weaponByName(name);
    if (weapon != null) {
      return [
        for (final grip in weapon.grips)
          Item.fromWeapon(weapon, grip)
            ..qualities = [...weapon.qualities, ...extraQualities]
      ];
    }
    final armor = gameData.armorByName(name);
    if (armor != null) {
      return [
        Item.fromArmor(armor)
          ..qualities = [...armor.qualities, ...extraQualities]
      ];
    }
    final effect = gameData.personalEffectByName(name);
    if (effect != null) {
      return [Item.fromPersonalEffect(effect)..qualities = extraQualities];
    }
    return [Item(type: itemTypePersonalEffect, name: name)];
  }

  String buildNotes() {
    final buffer = StringBuffer();
    if (isSamurai) {
      buffer
        ..write('4. Standing out in school:\n$q4Text')
        ..write('\n\n7. Clan Relationship: \n$q7Text');
    } else {
      buffer
        ..write('4. In and out of trouble:\n$q4Text')
        ..write('\n\n7. Known for: \n$q7Text');
    }
    buffer
      ..write('\n\n8. Bushido: \n$q8Text')
      ..write('\n\n9. Accomplishment: \n$q9Text')
      ..write('\n\n10. Setback: \n$q10Text')
      ..write('\n\n11. At Peace: \n$q11Text')
      ..write('\n\n12. Anxiety: \n$q12Text')
      ..write('\n\n13. Important Relationship: \n$q13Text');
    if (isSamurai) {
      buffer
        ..write('\n\n14. Distinctive Traits and Behaviors: \n$q14Text')
        ..write('\n\n15. Under Stress: \n$q15Text')
        ..write(
            '\n\n16. Existing Relationships With Other Groups: \n$q16Text')
        ..write('\n\n17. Parents: \n$q17Text');
    } else {
      buffer
        ..write('\n\n14. Prized Possession: \n$q14Text')
        ..write('\n\n15. Under Stress: \n$q15Text')
        ..write(
            '\n\n16. Existing Relationships With Other Groups: \n$q16Text')
        ..write('\n\n17. Shared History: \n$q17RoninText')
        ..write('\n\n18. Who raised you: \n$q17Text');
    }
    if (heritage == 'Glorious Sacrifice' && q18Secondary.isNotEmpty) {
      buffer.write(
          '\n\n18. Glorious Sacrifice: \nOne of your ancestors perished '
          'honorably in battle, and their signature $q18Special1 '
          '$q18Special2 $q18Secondary was lost. ');
    }
    buffer.write('\n\n20. Death:\n$q20Text');
    return buffer.toString();
  }

  /// Assembles the wizard's answers into the global [character]
  /// (page 7 initializePage + validatePage).
  void assemble() {
    character.clear();
    character.name = personalName;

    final schoolData = gameData.schoolByName(school);
    final heritageData = heritageEntry;

    // Social stats.
    var honor = schoolData?.honor ?? 0;
    var glory = 0;
    var status = 0;
    var koku = 0;
    var bu = 0;
    var zeni = 0;
    if (isSamurai) {
      status = gameData.clanByName(clan)?.status ?? 0;
      final familyData = gameData.familyByName(clan, family);
      glory = familyData?.glory ?? 0;
      koku = familyData?.wealth ?? 0;
      honor += heritageData?.honor ?? 0;
      glory += heritageData?.glory ?? 0;
      status += heritageData?.status ?? 0;
    } else {
      status = characterType == characterTypeRonin
          ? 24
          : (characterType == characterTypeGaijin ? 0 : 15);
      final upbringingData = gameData.upbringingByName(upbringing);
      status += upbringingData?.statusModification ?? 0;
      if (status < 0) status = 0;
      glory = gameData.regionByName(region)?.glory ?? 0;
      final wealth = upbringingData?.startingWealth ?? const Price();
      switch (wealth.unit) {
        case 'koku':
          koku = wealth.value;
        case 'bu':
          bu = wealth.value;
        default:
          zeni = wealth.value;
      }
    }
    if (q7Positive == true) glory += 5;
    if (q8Choice == 'pos') honor += 10;

    character.honor = honor;
    character.glory = glory;
    character.status = status;
    character.koku = koku;
    character.bu = bu;
    character.zeni = zeni;

    if (isSamurai) {
      character.clan = clan;
      character.family = family;
      character.heritage = heritage;
    } else {
      character.clan = region;
      character.family = upbringing;
      character.heritage = 'None';
      if (roninBond.isNotEmpty) {
        character.bonds = [CharacterBond(name: roninBond)];
      }
    }
    character.school = school;

    character.baseRings = calcRings().rings;
    character.baseSkills = calcSkills().skills;

    // Techniques.
    character.techniques = [
      for (final tech in techChoices)
        if (tech.isNotEmpty) tech
    ];
    if (heritageData != null &&
        effectKindOf(heritageData) == HeritageEffectKind.technique &&
        q18Secondary.isNotEmpty) {
      character.techniques.add(q18Secondary);
    }

    // Equipment.
    final items = <Item>[];
    // Fixed outfit rows (single-option sets that aren't special directives).
    for (final set in schoolData?.startingOutfit ?? <ChoiceSet>[]) {
      if (set.options.length == 1) {
        final only = set.options.single;
        if (only.isEmpty) continue;
        if (equipmentSpecialOptions(only) != null) continue; // chosen already
        if (only == 'Yumi and quiver of arrows with three special arrows') {
          continue; // expanded via equipChoices below
        }
        items.addAll(itemsFor(only));
      }
    }
    for (final choice in equipChoices) {
      if (choice.isEmpty || equipmentSpecialOptions(choice) != null) continue;
      if (choice == 'Yumi and quiver of arrows with three special arrows') {
        items.addAll(itemsFor('Yumi'));
        items.addAll(itemsFor('armor-piercing arrow'));
        items.addAll(itemsFor('flesh-cutter arrow'));
        items.addAll(itemsFor('humming-bulb arrow'));
      } else {
        items.addAll(itemsFor(choice));
      }
    }
    for (final choice in equipSpecialChoices) {
      if (choice.isNotEmpty) items.addAll(itemsFor(choice));
    }
    final upbringingItem =
        gameData.upbringingByName(upbringing)?.startingItem ?? '';
    if (upbringingItem.isNotEmpty) {
      for (final piece in upbringingItem.split(', ')) {
        items.addAll(itemsFor(piece));
      }
    }
    if (!isSamurai) {
      if (q14Item.isNotEmpty) items.addAll(itemsFor(q14Item));
      if (q8Item.isNotEmpty) items.addAll(itemsFor(q8Item));
    }
    if (q16Item.isNotEmpty) items.addAll(itemsFor(q16Item));

    // Heritage items.
    if (heritageData != null) {
      switch (effectKindOf(heritageData)) {
        case HeritageEffectKind.startingItem:
          if (q18Secondary.isNotEmpty) {
            items.addAll(itemsFor(q18Secondary, extraQualities: [
              if (q18Special1.isNotEmpty) q18Special1,
              if (q18Special2.isNotEmpty) q18Special2,
            ]));
          }
        case HeritageEffectKind.namedItem:
          final type = heritageData.otherEffects.type;
          if (type == 'Ancestral Horse Line') {
            final horse = horseLineItems[q18OtherEffects];
            if (horse != null) items.addAll(itemsFor(horse));
          } else if (namedItemGrants.containsKey(heritageData.result)) {
            items.addAll(itemsFor(namedItemGrants[heritageData.result]!));
          } else if (q18OtherEffects.isNotEmpty) {
            items.addAll(itemsFor(q18OtherEffects));
          }
        case HeritageEffectKind.mixed:
          if (q18OtherEffects == 'Item (Rank 6 or Lower)' &&
              q18Secondary.isNotEmpty) {
            items.addAll(itemsFor(q18Secondary));
          }
        default:
          break;
      }
      // Writ of the Wilds: item chosen directly as the effect.
      if (heritageData.result == 'At One with Nature' &&
          q18OtherEffects.isNotEmpty) {
        items.addAll(itemsFor(q18OtherEffects));
      }
    }
    character.equipment = items;

    // Advantages / disadvantages.
    final traits = <String>[
      if (distinction.isNotEmpty) distinction,
      if (adversity.isNotEmpty) adversity,
      if (passion.isNotEmpty) passion,
      if (anxiety.isNotEmpty) anxiety,
      ...schoolData?.advDisadv ?? <String>[],
      if (schoolOtherChoice.isNotEmpty) schoolOtherChoice,
      if (q13PickedAdvantage == true && q13Advantage.isNotEmpty) q13Advantage,
      if (q13PickedAdvantage == false && q13Disadvantage.isNotEmpty)
        q13Disadvantage,
    ];
    if (heritageData != null) {
      if (effectKindOf(heritageData) == HeritageEffectKind.trait &&
          q18OtherEffects.isNotEmpty) {
        traits.add(q18OtherEffects);
      }
      if (heritageData.result == 'Mighty Conqueror' &&
          q18OtherEffects == 'Glorious Deeds') {
        traits.add(q18OtherEffects);
      }
      final auto = autoGrantedTraits[heritageData.result];
      if (auto != null) traits.add(auto);
    }
    character.advDisadv = traits;

    character.ninjo = q6Text;
    character.giri = q5Text;
    character.notes = buildNotes();
    // Chargen is done: lock identity so the finished fields can't be edited
    // by accident. The user unlocks per-session via IdentityLockButton.
    character.identityLocked = true;
    character.touch();
  }
}
