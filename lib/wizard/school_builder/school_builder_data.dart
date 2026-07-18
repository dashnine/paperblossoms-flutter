// Constant tables from Path of Waves' "Building a School" (pp. 76-84),
// keyed by the canonical data names used in the bundled JSON (including
// diacritics); school_builder_data_test.dart asserts each name exists in the
// loaded data. Per the app's no-rules-text policy, ability templates carry a
// short paraphrase label and a page pointer only, never book text.

/// PoW Table 2-3 roles, book order. These match the `role` values used in
/// the bundled schools.json.
const schoolBuilderRoles = [
  'Artisan',
  'Bushi',
  'Courtier',
  'Monk',
  'Sage',
  'Shinobi',
  'Shugenja',
];

/// One "choose [size] of [options]" outfit row suggestion.
class OutfitRow {
  final int size;
  final List<String> options;
  const OutfitRow(this.options, {this.size = 1});
}

/// Per-primary-role defaults drawn from PoW Tables 2-5 (ring), 2-7 (skills),
/// 2-8 (starting techniques), and 2-11 (outfit). [suggestedHonor] is not in
/// the book (which never charts honor); it is the median of bundled schools
/// sharing the primary role.
class RoleDefaults {
  /// Suggested first ring increase; empty for Shugenja ("the element the
  /// school is attuned to"), which is rendered as a hint instead.
  final List<String> suggestedRings;

  /// Skills the school offers ("Skills Available") and how many of those a
  /// player picks at character creation ("Skill Picks").
  final int skillCount;
  final int skillChoose;

  /// Table 2-7 "Common Skills Available" starter list. May exceed
  /// [skillCount] (Bushi lists eight); pages pre-check the first
  /// [skillCount].
  final List<String> commonSkills;

  /// Table 2-8 number of starting techniques (low end of "4-5" ranges; the
  /// editor allows adding rows).
  final int startingTechniqueSlots;

  /// Open-access categories to pre-check beyond the near-universal Rituals.
  final List<String> suggestedTechCategories;

  /// Table 2-11 suggested starting outfit, mirroring the bundled encoding
  /// (mostly single-item rows, choices as small sets).
  final List<OutfitRow> suggestedOutfit;

  final int suggestedHonor;

  const RoleDefaults({
    this.suggestedRings = const [],
    required this.skillCount,
    required this.skillChoose,
    this.commonSkills = const [],
    required this.startingTechniqueSlots,
    this.suggestedTechCategories = const [],
    this.suggestedOutfit = const [],
    required this.suggestedHonor,
  });
}

const roleDefaults = <String, RoleDefaults>{
  'Artisan': RoleDefaults(
    suggestedRings: ['Fire', 'Water'],
    skillCount: 7,
    skillChoose: 5,
    commonSkills: [
      'Aesthetics',
      'Composition',
      'Courtesy',
      'Culture',
      'Design',
      'Martial Arts [Melee]',
      'Smithing',
    ],
    startingTechniqueSlots: 3,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Ceremonial Clothes']),
      OutfitRow(['Ashigaru Armor']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['Yumi']),
      OutfitRow(['Quiver of Arrows']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Scroll Satchel']),
      OutfitRow(['Calligraphy Set', 'Musical Instrument (common)']),
      OutfitRow(['Journal']),
    ],
    suggestedHonor: 44,
  ),
  'Bushi': RoleDefaults(
    suggestedRings: ['Earth'],
    skillCount: 7,
    skillChoose: 5,
    commonSkills: [
      'Command',
      'Fitness',
      'Government',
      'Martial Arts [Melee]',
      'Martial Arts [Ranged]',
      'Martial Arts [Unarmed]',
      'Meditation',
      'Tactics',
    ],
    startingTechniqueSlots: 2,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Ashigaru Armor', 'Lacquered Armor']),
      OutfitRow(['Katana']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['Yari', 'Yumi', 'Naginata']),
      OutfitRow(['Quiver of Arrows']),
      OutfitRow(['Traveling Pack']),
    ],
    suggestedHonor: 45,
  ),
  'Courtier': RoleDefaults(
    suggestedRings: ['Air'],
    skillCount: 7,
    skillChoose: 5,
    commonSkills: [
      'Composition',
      'Courtesy',
      'Culture',
      'Government',
      'Martial Arts [Ranged]',
      'Performance',
      'Sentiment',
    ],
    startingTechniqueSlots: 2,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Ceremonial Clothes']),
      OutfitRow(['Katana']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['Yumi']),
      OutfitRow(['Quiver of Arrows']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Calligraphy Set']),
      OutfitRow(['Scroll Satchel']),
    ],
    suggestedHonor: 45,
  ),
  'Monk': RoleDefaults(
    suggestedRings: ['Void'],
    skillCount: 6,
    skillChoose: 4,
    commonSkills: [
      'Fitness',
      'Martial Arts [Melee]',
      'Martial Arts [Unarmed]',
      'Meditation',
      'Survival',
      'Theology',
    ],
    startingTechniqueSlots: 3,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Katana']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['One Weapon of Rarity 6 or Lower']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Journal']),
    ],
    suggestedHonor: 40,
  ),
  'Sage': RoleDefaults(
    suggestedRings: ['Void'],
    skillCount: 6,
    skillChoose: 3,
    commonSkills: [
      'Courtesy',
      'Games',
      'Labor',
      'Meditation',
      'Survival',
      'Theology',
    ],
    startingTechniqueSlots: 4,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Sanctified Robes', 'Concealed Armor']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['One Weapon of Rarity 5 or Lower']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Scroll Satchel']),
      OutfitRow(['Calligraphy Set']),
      OutfitRow(['Set of glass vials']),
    ],
    suggestedHonor: 45,
  ),
  'Shinobi': RoleDefaults(
    suggestedRings: ['Air'],
    skillCount: 7,
    skillChoose: 5,
    commonSkills: [
      'Courtesy',
      'Culture',
      'Skulduggery',
      'Martial Arts [Melee]',
      'Martial Arts [Ranged]',
      'Medicine',
      'Performance',
    ],
    startingTechniqueSlots: 2,
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Concealed Armor']),
      OutfitRow(['Common Clothes']),
      OutfitRow(['Katana']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['One Weapon of Rarity 7 or Lower']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Knife']),
      OutfitRow(['Knife']),
      OutfitRow(['Makeup Kit']),
      OutfitRow(['Poison (per vial)']),
    ],
    suggestedHonor: 23,
  ),
  'Shugenja': RoleDefaults(
    suggestedRings: [],
    skillCount: 6,
    skillChoose: 3,
    commonSkills: [
      'Composition',
      'Courtesy',
      'Culture',
      'Games',
      'Meditation',
      'Theology',
    ],
    startingTechniqueSlots: 4,
    suggestedTechCategories: ['Invocations'],
    suggestedOutfit: [
      OutfitRow(['Traveling Clothes']),
      OutfitRow(['Sanctified Robes']),
      OutfitRow(['Wakizashi']),
      OutfitRow(['Yumi', 'Bō']),
      OutfitRow(['Quiver of Arrows']),
      OutfitRow(['Traveling Pack']),
      OutfitRow(['Scroll Satchel']),
      OutfitRow(['Calligraphy Set']),
      OutfitRow(['Knife']),
    ],
    suggestedHonor: 40,
  ),
};

/// Shugenja starting techniques must include this ritual (Table 2-8).
const communeWithSpirits = 'Commune with the Spirits';

/// The four common open-access technique categories (plus Rituals, which
/// nearly every school has). Ninjutsu and Mahō exist but get a warning.
const commonTechniqueCategories = ['Kata', 'Kihō', 'Invocations', 'Shūji'];
const ritualsCategory = 'Rituals';
const warnTechniqueCategories = ['Ninjutsu', 'Mahō'];

/// A generic ability template: a short menu label (our wording) plus the
/// book's full template text, which prefills the rules-text field when
/// picked. Shipping this text is a deliberate exception to the app's
/// no-rules-text policy (maintainer decision): the templates exist solely
/// so players can write their own homebrew, and the dice symbols are
/// rendered by name ("ring die", "Opportunity") as in user descriptions.
/// [roles] empty = usable by any role.
class AbilityTemplate {
  final List<String> roles;
  final String label;
  final String text;
  final String page;
  const AbilityTemplate(
    this.label, {
    required this.text,
    this.roles = const [],
    this.page = '78',
  });
}

/// PoW Table 2-4 (p. 78): generic school ability templates.
const schoolAbilityTemplates = <AbilityTemplate>[
  AbilityTemplate(
    'Treat one skill group\'s ranks as your school rank',
    text:
        'Choose one skill group when you create this school ability. '
        'When you perform a check using a skill from that group, you may '
        'treat your ranks in the skill as being equal to your school '
        'rank. If your ranks in that skill are equal to or higher than '
        'your school rank, or if you have 5 ranks in the skill, you may '
        'add one kept ring die set to an Opportunity result instead.',
  ),
  AbilityTemplate(
    'Once per scene, add kept Opportunity dice to one skill',
    text:
        'Choose one skill when you create this school ability. Once '
        'per scene, when you make a check using this skill, you may add '
        'a number of kept ring dice set to Opportunity results equal to '
        'your school rank.',
  ),
  AbilityTemplate(
    'Take strife to reduce an Artisan skill check\'s TN',
    roles: ['Artisan'],
    text:
        'Choose one Artisan skill when you create this school ability. '
        'Before you make a check using that skill, you may receive '
        'strife up to your school rank to reduce the TN by that amount.',
  ),
  AbilityTemplate(
    'Take fatigue for bonus successes with one weapon type',
    roles: ['Bushi'],
    text:
        'Choose one weapon type or unarmed when you create this school '
        'ability. When you make a skill check using this weapon type, if '
        'you succeed, you may receive fatigue up to your school rank to '
        'add that many bonus successes.',
  ),
  AbilityTemplate(
    'Negate strife symbols on a Scholar or Social skill',
    roles: ['Courtier'],
    text:
        'Choose one Scholar or Social skill when you create this '
        'school ability. When you make a check using that skill, you may '
        'negate a number of strife symbols up to your school rank.',
  ),
  AbilityTemplate(
    'Exchange ring dice for skill dice on one action type',
    roles: ['Monk'],
    text:
        'Choose an action type (Attack, Movement, Scheme, or Support) '
        'when you create this school ability. When you make a check to '
        'perform an action of this type, before rolling, you may '
        'exchange a number of ring dice up to your school rank for skill '
        'dice. When you provide assistance on an action of this type, '
        'the character you assist may exchange one ring die for a skill '
        'die.',
  ),
  AbilityTemplate(
    'Cast invocations with an Artisan or Scholar skill',
    roles: ['Sage'],
    text:
        'Choose one Artisan or Scholar skill when you create this '
        'school ability. You may use this skill for invocations, and you '
        'cannot channel invocations (see pages 189–190 of the core '
        'rulebook). Once per scene, when you succeed on a check to use '
        'an invocation technique, you may receive a number of strife up '
        'to your school rank to add that many bonus successes.',
  ),
  AbilityTemplate(
    'Reserve dropped dice from one skill for later checks',
    roles: ['Shinobi'],
    text:
        'Choose one Social or Trade skill when you create this school '
        'ability. Once per scene when you make a check using that skill, '
        'you may choose a number of dropped dice up to your school rank '
        'and reserve them. Until the end of the scene, when you make a '
        'check using a different skill, you may add one of the reserved '
        'dice to the check as a kept die, set to the result it had when '
        'it was reserved. This expends that reserved die.',
  ),
  AbilityTemplate(
    'Reroll strife dice on one effect keyword',
    roles: ['Shugenja'],
    text:
        'Choose an effect keyword (Augment, Bind, Curse, Mend, Purify, '
        'Scry, Smite, Summon, etc.; see pages 192 and 225 of the core '
        'rulebook) when you create this school ability. When you make a '
        'check for an action that uses that keyword, you may choose a '
        'number of your rolled dice up to your school rank containing '
        'strife symbols and reroll them.',
  ),
];

/// PoW Table 2-10 (p. 83): generic mastery ability templates.
const masteryAbilityTemplates = <AbilityTemplate>[
  AbilityTemplate(
    'Endurance increased by your Fitness ranks',
    page: '83',
    text: 'Increase your endurance by your ranks in Fitness.',
  ),
  AbilityTemplate(
    'Composure increased by your Meditation ranks',
    page: '83',
    text: 'Increase your composure by your ranks in Meditation.',
  ),
  AbilityTemplate(
    'Gain access to one new technique category',
    page: '83',
    text:
        'Choose one technique category the school does not already '
        'have available (kata, kihō, invocations, shūji, etc.) '
        'when you gain this mastery ability. That technique type becomes '
        'available to you.',
  ),
  AbilityTemplate(
    'Spend a Void point to reuse your school ability',
    page: '83',
    text:
        'If your school ability can be used a limited number of times '
        'per scene, you may spend 1 Void point to use it one additional '
        'time per scene.',
  ),
  AbilityTemplate(
    'Your school ability applies to one more chosen entry',
    page: '83',
    text:
        'If your school ability requires you to choose something from '
        'a list (a skill, a skill group, a technique category, etc.), '
        'choose one additional entry from that list when you create this '
        'mastery ability. Your school ability applies to both chosen '
        'entries.',
  ),
  AbilityTemplate(
    'Once per session, reroll all dice on one skill',
    page: '83',
    text:
        'Choose one skill when you create this mastery ability. Once '
        'per game session when you make a check using that skill, you '
        'may reroll all of your dice. If you do not succeed after '
        'rerolling, gain 1 Void point.',
  ),
  AbilityTemplate(
    'Resistances equal to your Theology ranks',
    roles: ['Monk', 'Sage', 'Shugenja'],
    page: '83',
    text:
        'When you defend against damage, you may treat your physical '
        'resistance and supernatural resistance as equal to your ranks '
        'in Theology.',
  ),
  AbilityTemplate(
    'Train one ring to rank 6',
    roles: ['Monk', 'Sage', 'Shugenja'],
    page: '83',
    text:
        'Choose one ring when you create this mastery ability. You may '
        'train that ring to rank 6 (paying 18 XP).',
  ),
  AbilityTemplate(
    'Train one skill group\'s skills to rank 6',
    roles: ['Artisan', 'Bushi', 'Courtier', 'Shinobi'],
    page: '83',
    text:
        'Choose one skill group when you choose this mastery ability. '
        'You may train skills in that group to rank 6 (paying 12 XP per '
        'skill raised from rank 5 to rank 6 this way).',
  ),
  AbilityTemplate(
    'Reduce one curriculum technique\'s activation TN',
    roles: ['Artisan', 'Bushi', 'Courtier', 'Shinobi'],
    page: '83',
    text:
        'Choose one technique on the curriculum that requires a check '
        'to activate when you create this mastery ability. You treat the '
        'TN of this check as reduced by your ranks in the skill to '
        'activate it (to a minimum of TN 1).',
  ),
  AbilityTemplate(
    'Bonus Opportunity on one curriculum technique',
    roles: ['Artisan', 'Bushi', 'Courtier', 'Shinobi'],
    page: '83',
    text:
        'Choose one technique on the curriculum that requires spending '
        'one or more Opportunity to activate when you create this '
        'mastery ability. When you spend at least the minimum amount of '
        'Opportunity to activate that technique, you count as spending '
        'that amount of Opportunity plus two additional Opportunity '
        'instead.',
  ),
];

/// Affiliation strings seen in the bundled data beyond the clan list: gaijin
/// factions match region subtypes, Rōnin gates the rōnin/peasant path, and
/// clanless schools are reachable only via the "unrestricted" checkbox.
const extraAffiliations = [
  'Rōnin',
  'The Imperial Families',
  'Ivory Kingdoms',
  'Qamarist',
  'Ujik',
];

/// The default reference stamped on built schools: the "Building a School"
/// rules themselves.
const schoolBuilderRefBook = 'Path of Waves';
const schoolBuilderRefPage = '76';
