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

/// Heroes of Rokugan services a character's giri may answer to (Q5), and the
/// campaign title each one carries (Q20). Rōnin must serve a Regent (every
/// service except the clan champion).
const horServiceTitles = {
  'Clan Champion': 'Agent of the Clan Champion',
  'Emerald Magistrates': 'Emerald Magistrate (HoR)',
  'Jade Magistrates': 'Jade Magistrate',
  'Imperial Legions': 'Imperial Legionnaire',
  'Imperial Bureaucracy': 'Imperial Bureaucrat',
  'Imperial Court': 'Imperial Courtier',
};

/// HoR Q8: the traditional-training skills of the orthodox option (the
/// divergent option reuses [question8Skills]).
const horQ8PosSkills = [
  'Composition',
  'Courtesy',
  'Culture',
  'Government',
  'Meditation',
  'Theology',
];

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

  // ---- Heroes of Rokugan mode (campaign Twenty Questions) ----
  // Captured once from horController when the shell constructs the state, so
  // a wizard in flight can never change rulesets mid-run.
  bool horMode = false;
  String horService = ''; // Q5 key of [horServiceTitles]
  String horQ5Skill = '';
  String horQ6Skill = '';
  String horRoninRing = ''; // Q1 rōnin any-ring pick
  String horBackground = ''; // Q2 rōnin background name
  String horBackgroundRing = '';
  List<String> horBackgroundSkills = []; // sized by [selectHorBackground]
  String horQ19Technique = '';

  bool get isSamurai => characterType == characterTypeSamurai;

  /// Switches the character type and clears every answer the new type
  /// invalidates — including the HoR service (a rōnin cannot keep a
  /// clan-champion giri chosen as a samurai).
  void setCharacterType(String value) {
    characterType = value;
    clan = '';
    family = '';
    familyRing = '';
    region = '';
    upbringing = '';
    upbringingRing = '';
    upbringingSkills = ['', '', ''];
    school = '';
    schoolSkills = [];
    horRoninRing = '';
    horBackground = '';
    horBackgroundRing = '';
    horBackgroundSkills = [];
    horService = '';
    horQ5Skill = '';
    horQ6Skill = '';
  }

  /// Selects the HoR rōnin background and sizes the skill-pick list to its
  /// skill_choices count, so data with any number of choices renders and
  /// validates without indexing past a fixed-length list.
  void selectHorBackground(String name) {
    horBackground = name;
    horBackgroundRing = '';
    final background = gameData.hor.backgroundByName(name);
    horBackgroundSkills =
        List.filled(background?.skillChoices.length ?? 0, '', growable: true);
  }

  String get heritage =>
      chosenAncestor == 1 ? ancestor1 : (chosenAncestor == 2 ? ancestor2 : '');

  /// The campaign title granted by Q20 for the chosen service.
  String get horCampaignTitle => horServiceTitles[horService] ?? '';

  HeritageEntry? get heritageEntry {
    if (heritage.isEmpty) return null;
    // Several campaign heritage results share a name with a Core entry; in
    // HoR mode the campaign table must win the lookup.
    if (horMode) {
      for (final h in gameData.hor.heritage) {
        if (h.result == heritage) return h;
      }
    }
    return gameData.heritageByResult(heritage);
  }

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
    } else if (horMode) {
      // HoR rōnin: any-ring clan block + background ring, no region or
      // upbringing.
      bump(horRoninRing);
      bump(horBackgroundRing);
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
      if (replacement.isEmpty || overflow <= 0) continue;
      // HoR overflow must land under the cap too; stock keeps its original
      // blind redistribution byte-for-byte.
      if (horMode && (rings[replacement] ?? 0) >= 3) continue;
      rings[replacement] = (rings[replacement] ?? 0) + 1;
      overflow--;
    }
    return (rings: rings, overflow: overflow);
  }

  /// Grows [replacementRings] so page 7 can offer one picker per overflow
  /// point (HoR ring stacking can overflow past the stock two slots).
  void ensureReplacementRingSlots(int count) {
    while (replacementRings.length < count) {
      replacementRings.add('');
    }
  }

  /// Writes replacement ring slot [index], growing the list as needed — so
  /// the page-7 widgets never have to mutate the list during build.
  void setReplacementRing(int index, String value) {
    ensureReplacementRingSlots(index + 1);
    replacementRings[index] = value;
  }

  /// Clears HoR replacement picks whose ring has since reached the cap of 3
  /// (an earlier-page edit can push a picked ring to 3, which would
  /// otherwise strand overflow behind a slot that renders blank). Simulates
  /// the redistribution order [calcRings] uses. No-op in stock mode.
  void pruneStaleReplacementRings() {
    if (!horMode) return;
    final rings = rawRings();
    for (final entry in rings.entries.toList()) {
      if (entry.value > 3) rings[entry.key] = 3;
    }
    for (var i = 0; i < replacementRings.length; i++) {
      final replacement = replacementRings[i];
      if (replacement.isEmpty) continue;
      if ((rings[replacement] ?? 0) >= 3) {
        replacementRings[i] = '';
      } else {
        rings[replacement] = (rings[replacement] ?? 0) + 1;
      }
    }
  }

  /// Whether the chosen heritage effect grants a bonus skill.
  bool _heritageGrantsSkill() {
    final entry = heritageEntry;
    if (entry == null) return false;
    return effectKindOf(entry) == HeritageEffectKind.skill;
  }

  /// Creation cap for [skill]: 3 as printed, 2 in HoR mode — where only the
  /// Q13 mentor-disadvantage skill is exempt (the campaign's one exception).
  int skillCap(String skill) {
    if (!horMode) return 3;
    if (q13PickedAdvantage == false && skill == q13Skill) return 3;
    return 2;
  }

  /// Every source a skill rank comes from during creation, in page order.
  /// Shared by [rawSkills] (which counts) and [unheldSkillOptions] (which
  /// excludes) so the two can never drift; [includeHeritage] is off for the
  /// unheld list, matching its pre-HoR behavior.
  List<String> _skillSources({bool includeHeritage = true}) => [
        ...gameData.clanByName(clan)?.skillIncrease != null && isSamurai
            ? [gameData.clanByName(clan)!.skillIncrease]
            : <String>[],
        if (isSamurai)
          ...gameData.familyByName(clan, family)?.skillIncrease ?? <String>[],
        if (!isSamurai && !horMode)
          gameData.regionByName(region)?.skillIncrease ?? '',
        if (!isSamurai && horMode) ...[
          gameData.hor.roninSkillIncrease,
          ...horBackgroundSkills,
        ],
        ...upbringingSkills,
        ...schoolSkills,
        if (horMode) ...[horQ5Skill, horQ6Skill],
        q7Skill,
        q8Skill,
        if (q13PickedAdvantage == false) q13Skill,
        parentSkill,
        if (includeHeritage && _heritageGrantsSkill()) q18OtherEffects,
      ];

  /// Skill list before cap enforcement (page 7 calcSkills, pre-overflow).
  Map<String, int> rawSkills() {
    final skills = <String, int>{};
    for (final skill in _skillSources()) {
      if (skill.isEmpty) continue;
      skills[skill] = (skills[skill] ?? 0) + 1;
    }
    return skills;
  }

  /// Final skill map with the creation cap enforced; overflow redistributed
  /// via [replacementSkills].
  ({Map<String, int> skills, int overflow}) calcSkills() {
    final skills = rawSkills();
    var overflow = 0;
    for (final entry in skills.entries.toList()) {
      final cap = skillCap(entry.key);
      if (entry.value > cap) {
        overflow += entry.value - cap;
        skills[entry.key] = cap;
      }
    }
    for (final replacement in replacementSkills) {
      if (replacement.isEmpty || overflow <= 0) continue;
      // HoR overflow must land under the cap too; stock keeps its original
      // blind redistribution byte-for-byte.
      if (horMode && (skills[replacement] ?? 0) >= skillCap(replacement)) {
        continue;
      }
      skills[replacement] = (skills[replacement] ?? 0) + 1;
      overflow--;
    }
    return (skills: skills, overflow: overflow);
  }

  /// Grows [replacementSkills] so page 7 can offer one picker per overflow
  /// point (cap 2 can overflow more than the stock three slots).
  void ensureReplacementSkillSlots(int count) {
    while (replacementSkills.length < count) {
      replacementSkills.add('');
    }
  }

  /// Writes replacement slot [index], growing the list as needed — so the
  /// page-7 widgets never have to mutate the list during build.
  void setReplacementSkill(int index, String value) {
    ensureReplacementSkillSlots(index + 1);
    replacementSkills[index] = value;
  }

  /// Clears HoR replacement picks whose skill has since reached its cap
  /// (an earlier-page edit can push a picked skill to cap 2, which would
  /// otherwise strand overflow behind a slot that renders blank). Simulates
  /// the redistribution order [calcSkills] uses. No-op in stock mode.
  void pruneStaleReplacementSkills() {
    if (!horMode) return;
    final skills = rawSkills();
    for (final entry in skills.entries.toList()) {
      final cap = skillCap(entry.key);
      if (entry.value > cap) skills[entry.key] = cap;
    }
    for (var i = 0; i < replacementSkills.length; i++) {
      final replacement = replacementSkills[i];
      if (replacement.isEmpty) continue;
      if ((skills[replacement] ?? 0) >= skillCap(replacement)) {
        replacementSkills[i] = '';
      } else {
        skills[replacement] = (skills[replacement] ?? 0) + 1;
      }
    }
  }

  // ---------------------------------------------------------------------
  // Option lists for the pages
  // ---------------------------------------------------------------------

  List<String> schoolOptions() {
    if (horMode) {
      final bans = gameData.hor.bans;
      if (isSamurai) {
        // No cross-clan schools in HoR, so no unrestricted branch.
        return [
          for (final school in gameData.schoolsOf(clan))
            if (!bans.schools.contains(school.name) &&
                !bans.schoolBooks.contains(school.reference.book))
              school.name
        ];
      }
      return [
        for (final name in bans.roninSchools)
          if (gameData.schoolByName(name) != null) name
      ];
    }
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
    final held = {..._skillSources(includeHeritage: false)}..remove(except);
    return [
      for (final skill in gameData.allSkills())
        if (!held.contains(skill)) skill
    ];
  }

  // ---------------------------------------------------------------------
  // Heroes of Rokugan option lists
  // ---------------------------------------------------------------------

  /// Advantage/disadvantage names for the HoR pickers: stock entries minus
  /// the campaign ban list, plus the campaign's own additions.
  List<String> horTraitNames(String category) {
    final banned = {
      ...gameData.hor.bans.advantages,
      ...gameData.hor.bans.advantagesCreationOnly,
    };
    return [
      for (final a in gameData.advDisadvByCategory(category))
        if (!banned.contains(a.name)) a.name,
      for (final a in gameData.horAdvDisadvByCategory(category)) a.name,
    ];
  }

  /// HoR Q7 skill options. Positive: skills listed for another family of the
  /// clan (rōnin backgrounds double as families). Negative: skills no family
  /// of the clan lists. "Any"-style choice sets list nothing specific.
  List<String> horQ7SkillOptions({required bool positive}) {
    final allFamilySkills = <String>{};
    final ownFamilySkills = <String>{};
    if (isSamurai) {
      for (final f in gameData.familiesOf(clan)) {
        allFamilySkills.addAll(f.skillIncrease);
        if (f.name == family) ownFamilySkills.addAll(f.skillIncrease);
      }
    } else {
      for (final b in gameData.hor.roninBackgrounds) {
        final skills = [for (final choice in b.skillChoices) ...choice];
        allFamilySkills.addAll(skills);
        if (b.name == horBackground) ownFamilySkills.addAll(skills);
      }
    }
    if (positive) {
      return allFamilySkills.difference(ownFamilySkills).toList()..sort();
    }
    return [
      for (final skill in gameData.allSkills())
        if (!allFamilySkills.contains(skill)) skill
    ];
  }

  /// HoR Q19: one extra technique — from the school's available categories,
  /// an unpicked starting-technique option, or a rank-1 curriculum
  /// technique. All at school rank 1.
  List<String> horQ19Options() {
    final schoolData = gameData.schoolByName(school);
    if (schoolData == null) return [];
    final options = <String>{};
    for (final category in schoolData.techniquesAvailable) {
      for (final t
          in gameData.techniquesByGroup(category, minRank: 1, maxRank: 1)) {
        options.add(t.name);
      }
    }
    for (final set in schoolData.startingTechniques) {
      options.addAll(expandTechniqueOptions(set));
    }
    for (final c in schoolData.curriculum) {
      if (c.rank == 1 && c.type == 'technique') options.add(c.advance);
    }
    options.removeAll(techChoices);
    return options.toList()..sort();
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
      case 'One Weapon of Rarity 5 or Lower':
        return weaponNames(5);
      case 'One Weapon of Rarity 6 or Lower':
        return weaponNames(6);
      case 'One Weapon of Rarity 7 or Lower':
        return weaponNames(7);
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
    if (horMode) {
      if (!isSamurai && horBackground.isNotEmpty) {
        buffer.write('\n\n2. Rōnin Background: \n$horBackground');
      }
      if (horService.isNotEmpty) {
        buffer.write('\n\n5. Service: \n$horService');
      }
      if (heritage == 'Battle of One Thousand Years' &&
          q18Secondary.isNotEmpty) {
        buffer.write('\n\n18. Battle of One Thousand Years: \nYour '
            '$q18Secondary bears the Sacred and Forbidden qualities; it is '
            'yours only while the Imperial Treasurer stays silent. If it is '
            'lost, replace it with a normal version of the same item.');
      }
      if (horCampaignTitle.isNotEmpty) {
        final title = gameData.titleByName(horCampaignTitle);
        final stipend = title != null && title.stipendKoku > 0
            ? ' (stipend: ${title.stipendKoku} koku per module)'
            : '';
        buffer.write('\n\n20. Campaign Title: \n$horCampaignTitle$stipend');
      }
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
    } else if (horMode) {
      // HoR rōnin: campaign clan block + background, and the campaign
      // heritage table applies to rōnin like everyone else.
      status = gameData.hor.roninStatus;
      final background = gameData.hor.backgroundByName(horBackground);
      glory = background?.glory ?? 0;
      final wealth = background?.startingWealth ?? const Price();
      switch (wealth.unit) {
        case 'koku':
          koku = wealth.value;
        case 'bu':
          bu = wealth.value;
        default:
          zeni = wealth.value;
      }
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
    if (horMode) {
      // Q7/Q8 both carry a skill on either branch; the attribute swings are
      // the campaign's (+5/−5 glory, +5/−3 honor).
      if (q7Positive == true) glory += 5;
      if (q7Positive == false) glory -= 5;
      if (q8Choice == 'pos') honor += 5;
      if (q8Choice == 'neg') honor -= 3;
      // Heritage: Material Success (+5 koku).
      if (heritageData?.otherEffects.type == 'Wealth') koku += 5;
      // Q20: the mandatory campaign title sets Status to 40.
      if (horCampaignTitle.isNotEmpty) status = 40;
    } else {
      if (q7Positive == true) glory += 5;
      if (q8Choice == 'pos') honor += 10;
    }

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
    } else if (horMode) {
      // The background is not a family name anything downstream can look
      // up (PDF export, derived stats), so it lives in the notes instead.
      character.clan = characterTypeRonin;
      character.family = '';
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
    if (horMode && horCampaignTitle.isNotEmpty) {
      character.titles = [horCampaignTitle];
    }

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
    if (horMode && horQ19Technique.isNotEmpty) {
      character.techniques.add(horQ19Technique);
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
    // Q14: the personal accessory is samurai-and-rōnin alike in HoR.
    if (!isSamurai || horMode) {
      if (q14Item.isNotEmpty) items.addAll(itemsFor(q14Item));
    }
    if (!isSamurai && q8Item.isNotEmpty) items.addAll(itemsFor(q8Item));
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
      // HoR Battle of One Thousand Years: mark the chosen outfit item.
      if (horMode &&
          heritageData.otherEffects.type == 'Outfit Item' &&
          q18Secondary.isNotEmpty) {
        for (final item in items) {
          if (item.name == q18Secondary) {
            item.qualities = [...item.qualities, 'Sacred', 'Forbidden'];
          }
        }
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
      // The adversity is the price of the marked item; grant neither
      // without the other (page 6 validation requires the pick, this is
      // the engine-level guarantee).
      if (horMode &&
          heritageData.otherEffects.type == 'Outfit Item' &&
          q18Secondary.isNotEmpty) {
        traits.add('Blackmailed by the Imperial Treasurer');
      }
    }
    character.advDisadv = traits;

    character.ninjo = q6Text;
    character.giri = q5Text;
    character.hor = horMode;
    character.notes = buildNotes();
    // Chargen is done: lock identity so the finished fields can't be edited
    // by accident. The user unlocks per-session via IdentityLockButton.
    character.identityLocked = true;
    character.touch();
  }
}
