// Immutable models for the bundled game data assets (assets/data/*.json).
// Field names mirror the JSON keys of the original Paper Blossoms data files
// so the user homebrew overlay can round-trip through the same shapes.

class Reference {
  final String book;
  final String page;

  const Reference({this.book = '', this.page = ''});

  Reference.fromJson(Map<String, dynamic> json)
      : book = json['book']?.toString() ?? '',
        page = json['page']?.toString() ?? '';

  Map<String, dynamic> toJson() => {'book': book, 'page': page};

  @override
  String toString() => book.isEmpty ? '' : '$book p.$page';
}

/// A "choose [size] from [options]" set, used by schools and upbringings.
class ChoiceSet {
  final int size;
  final List<String> options;

  const ChoiceSet({this.size = 0, this.options = const []});

  ChoiceSet.fromJson(Map<String, dynamic> json)
      : size = json['size'] ?? 0,
        options = List<String>.from(json['set'] ?? []);

  Map<String, dynamic> toJson() => {'size': size, 'set': options};
}

class Price {
  final int value;
  final String unit; // koku | bu | zeni

  const Price({this.value = 0, this.unit = 'zeni'});

  Price.fromJson(Map<String, dynamic> json)
      : value = json['value'] ?? 0,
        unit = json['unit'] ?? 'zeni';

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit};

  @override
  String toString() => '$value $unit';
}

class Clan {
  final String name;
  final String type; // Great | Minor
  final String ringIncrease;
  final String skillIncrease;
  final int status;
  final List<Family> families;
  final Reference reference;

  const Clan({
    required this.name,
    this.type = 'Great',
    this.ringIncrease = '',
    this.skillIncrease = '',
    this.status = 0,
    this.families = const [],
    this.reference = const Reference(),
  });

  Clan.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        type = json['type'] ?? 'Great',
        ringIncrease = json['ring_increase'] ?? '',
        skillIncrease = json['skill_increase'] ?? '',
        status = json['status'] ?? 0,
        families = [
          for (final f in json['families'] ?? []) Family.fromJson(f)
        ],
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'ring_increase': ringIncrease,
        'skill_increase': skillIncrease,
        'status': status,
        'families': [for (final f in families) f.toJson()],
        'reference': reference.toJson(),
      };
}

class Family {
  final String name;
  final List<String> ringIncrease; // player picks one
  final List<String> skillIncrease; // player picks one
  final int glory;
  final int wealth; // koku
  final Reference reference;

  const Family({
    required this.name,
    this.ringIncrease = const [],
    this.skillIncrease = const [],
    this.glory = 0,
    this.wealth = 0,
    this.reference = const Reference(),
  });

  Family.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        ringIncrease = List<String>.from(json['ring_increase'] ?? []),
        skillIncrease = List<String>.from(json['skill_increase'] ?? []),
        glory = json['glory'] ?? 0,
        wealth = json['wealth'] ?? 0,
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'ring_increase': ringIncrease,
        'skill_increase': skillIncrease,
        'glory': glory,
        'wealth': wealth,
        'reference': reference.toJson(),
      };
}

class CurriculumEntry {
  final int rank;
  final String advance; // skill/technique name or group name
  final String type; // skill | skill_group | technique | technique_group
  final bool specialAccess;
  final int minAllowableRank; // parsed from "min-max"; 0 = unset
  final int maxAllowableRank; // 0 = unset

  const CurriculumEntry({
    required this.rank,
    required this.advance,
    required this.type,
    this.specialAccess = false,
    this.minAllowableRank = 0,
    this.maxAllowableRank = 0,
  });

  factory CurriculumEntry.fromJson(Map<String, dynamic> json) {
    var minRank = 0;
    var maxRank = 0;
    final range = json['allowable_rank'];
    if (range is String && range.contains('-')) {
      final parts = range.split('-');
      minRank = int.tryParse(parts[0]) ?? 0;
      maxRank = int.tryParse(parts[1]) ?? 0;
    } else if (range is Map) {
      minRank = range['min'] ?? 0;
      maxRank = range['max'] ?? 0;
    }
    return CurriculumEntry(
      rank: json['rank'] ?? 1,
      advance: json['advance'] ?? '',
      type: json['type'] ?? 'skill',
      specialAccess: json['special_access'] ?? false,
      minAllowableRank: minRank,
      maxAllowableRank: maxRank,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'advance': advance,
        'type': type,
        'special_access': specialAccess,
        if (minAllowableRank > 0 || maxAllowableRank > 0)
          'allowable_rank': '$minAllowableRank-$maxAllowableRank',
      };
}

class School {
  final String name;
  final String clan;
  final List<String> role;
  final List<String> ringIncrease;
  final ChoiceSet startingSkills;
  final int honor;
  final List<String> techniquesAvailable; // technique category names
  final List<ChoiceSet> startingTechniques;
  final String schoolAbility;
  final String masteryAbility;
  final List<ChoiceSet> startingOutfit;
  final List<CurriculumEntry> curriculum;
  final List<String> advDisadv; // granted with the school (pipe-separated)
  final Reference reference;

  const School({
    required this.name,
    this.clan = '',
    this.role = const [],
    this.ringIncrease = const [],
    this.startingSkills = const ChoiceSet(),
    this.honor = 0,
    this.techniquesAvailable = const [],
    this.startingTechniques = const [],
    this.schoolAbility = '',
    this.masteryAbility = '',
    this.startingOutfit = const [],
    this.curriculum = const [],
    this.advDisadv = const [],
    this.reference = const Reference(),
  });

  School.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        clan = json['clan'] ?? '',
        role = List<String>.from(json['role'] ?? []),
        ringIncrease = List<String>.from(json['ring_increase'] ?? []),
        startingSkills = ChoiceSet.fromJson(json['starting_skills'] ?? {}),
        honor = json['honor'] ?? 0,
        techniquesAvailable =
            List<String>.from(json['techniques_available'] ?? []),
        startingTechniques = [
          for (final t in json['starting_techniques'] ?? [])
            ChoiceSet.fromJson(t)
        ],
        schoolAbility = json['school_ability'] ?? '',
        masteryAbility = json['mastery_ability'] ?? '',
        startingOutfit = [
          for (final o in json['starting_outfit'] ?? []) ChoiceSet.fromJson(o)
        ],
        curriculum = [
          for (final c in json['curriculum'] ?? []) CurriculumEntry.fromJson(c)
        ],
        advDisadv = [
          for (final part
              in (json['advantage_disadvantage'] ?? '').toString().split('|'))
            if (part.isNotEmpty) part
        ],
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'clan': clan,
        'role': role,
        'ring_increase': ringIncrease,
        'starting_skills': startingSkills.toJson(),
        'honor': honor,
        'techniques_available': techniquesAvailable,
        'starting_techniques': [
          for (final t in startingTechniques) t.toJson()
        ],
        'school_ability': schoolAbility,
        'mastery_ability': masteryAbility,
        'starting_outfit': [for (final o in startingOutfit) o.toJson()],
        'curriculum': [for (final c in curriculum) c.toJson()],
        'advantage_disadvantage': advDisadv.join('|'),
        'reference': reference.toJson(),
      };
}

/// Flattened from techniques.json's category > subcategory > technique nesting.
class Technique {
  final String name;
  final String category; // e.g. Kata, Shūji, Mahō
  final String subcategory;
  final int rank;
  final int xp;
  final String restriction;
  final Reference reference;

  const Technique({
    required this.name,
    this.category = '',
    this.subcategory = '',
    this.rank = 1,
    this.xp = 0,
    this.restriction = '',
    this.reference = const Reference(),
  });

  Technique.fromJson(Map<String, dynamic> json,
      {this.category = '', this.subcategory = ''})
      : name = json['name'] ?? '',
        rank = json['rank'] ?? 1,
        xp = json['xp'] ?? 0,
        restriction = json['restriction'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'subcategory': subcategory,
        'rank': rank,
        'xp': xp,
        if (restriction.isNotEmpty) 'restriction': restriction,
        'reference': reference.toJson(),
      };
}

class SkillGroup {
  final String name; // Artisan, Martial, Scholar, Social, Trade
  final List<String> skills;

  const SkillGroup({required this.name, this.skills = const []});

  SkillGroup.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        skills = List<String>.from(json['skills'] ?? []);

  Map<String, dynamic> toJson() => {'name': name, 'skills': skills};
}

class Ring {
  final String name;
  final String outstandingQuality;

  const Ring({required this.name, this.outstandingQuality = ''});

  Ring.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        outstandingQuality = json['outstanding_quality'] ?? '';

  Map<String, dynamic> toJson() =>
      {'name': name, 'outstanding_quality': outstandingQuality};
}

/// One advantage or disadvantage entry; [category] is the section it came
/// from: Distinctions, Passions, Adversities, or Anxieties.
class AdvDisadv {
  final String name;
  final String category;
  final String ring;
  final List<String> types;
  final String effects;
  final Reference reference;

  const AdvDisadv({
    required this.name,
    this.category = '',
    this.ring = '',
    this.types = const [],
    this.effects = '',
    this.reference = const Reference(),
  });

  AdvDisadv.fromJson(Map<String, dynamic> json, {this.category = ''})
      : name = json['name'] ?? '',
        ring = json['ring'] ?? '',
        types = List<String>.from(json['types'] ?? []),
        effects = json['effects'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'ring': ring,
        'types': types,
        'effects': effects,
        'reference': reference.toJson(),
      };
}

class Bond {
  final String name;
  final String ability;
  final Reference reference;

  const Bond({
    required this.name,
    this.ability = '',
    this.reference = const Reference(),
  });

  Bond.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        ability = json['ability'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() =>
      {'name': name, 'ability': ability, 'reference': reference.toJson()};
}

class GripEffect {
  final String attribute; // e.g. damage, range, deadliness
  final dynamic value; // int increase or replacement value

  const GripEffect({this.attribute = '', this.value});

  GripEffect.fromJson(Map<String, dynamic> json)
      : attribute = json['attribute'] ?? '',
        value = json['value_increase'] ?? json['value'];

  Map<String, dynamic> toJson() =>
      {'attribute': attribute, 'value_increase': value};
}

class WeaponGrip {
  final String name; // 1-hand | 2-hand | ...
  final List<GripEffect> effects;

  const WeaponGrip({this.name = '', this.effects = const []});

  WeaponGrip.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        effects = [
          for (final e in json['effects'] ?? []) GripEffect.fromJson(e)
        ];

  Map<String, dynamic> toJson() =>
      {'name': name, 'effects': [for (final e in effects) e.toJson()]};
}

/// Flattened from weapons.json's category > entries nesting.
class Weapon {
  final String name;
  final String category; // Swords, Bows, ...
  final String skill;
  final int rangeMin;
  final int rangeMax;
  final int damage;
  final int deadliness;
  final List<WeaponGrip> grips;
  final List<String> qualities;
  final int rarity;
  final Price price;
  final Reference reference;

  const Weapon({
    required this.name,
    this.category = '',
    this.skill = '',
    this.rangeMin = 0,
    this.rangeMax = 0,
    this.damage = 0,
    this.deadliness = 0,
    this.grips = const [],
    this.qualities = const [],
    this.rarity = 0,
    this.price = const Price(),
    this.reference = const Reference(),
  });

  Weapon.fromJson(Map<String, dynamic> json, {this.category = ''})
      : name = json['name'] ?? '',
        skill = json['skill'] ?? '',
        rangeMin = json['range']?['min'] ?? 0,
        rangeMax = json['range']?['max'] ?? 0,
        damage = json['damage'] ?? 0,
        deadliness = json['deadliness'] ?? 0,
        grips = [
          for (final g in json['grips'] ?? []) WeaponGrip.fromJson(g)
        ],
        qualities = List<String>.from(json['qualities'] ?? []),
        rarity = json['rarity'] ?? 0,
        price = Price.fromJson(json['price'] ?? {}),
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'skill': skill,
        'range': {'min': rangeMin, 'max': rangeMax},
        'damage': damage,
        'deadliness': deadliness,
        'grips': [for (final g in grips) g.toJson()],
        'qualities': qualities,
        'rarity': rarity,
        'price': price.toJson(),
        'reference': reference.toJson(),
      };
}

class ArmorResistance {
  final String category; // Physical | Supernatural | ...
  final int value;

  const ArmorResistance({this.category = '', this.value = 0});

  ArmorResistance.fromJson(Map<String, dynamic> json)
      : category = json['category'] ?? '',
        value = json['value'] ?? 0;

  Map<String, dynamic> toJson() => {'category': category, 'value': value};
}

class Armor {
  final String name;
  final List<ArmorResistance> resistances;
  final List<String> qualities;
  final int rarity;
  final Price price;
  final Reference reference;

  const Armor({
    required this.name,
    this.resistances = const [],
    this.qualities = const [],
    this.rarity = 0,
    this.price = const Price(),
    this.reference = const Reference(),
  });

  Armor.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        resistances = [
          for (final r in json['resistance_values'] ?? [])
            ArmorResistance.fromJson(r)
        ],
        qualities = List<String>.from(json['qualities'] ?? []),
        rarity = json['rarity'] ?? 0,
        price = Price.fromJson(json['price'] ?? {}),
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'resistance_values': [for (final r in resistances) r.toJson()],
        'qualities': qualities,
        'rarity': rarity,
        'price': price.toJson(),
        'reference': reference.toJson(),
      };
}

class PersonalEffect {
  final String name;
  final Price price;
  final int rarity;
  final Reference reference;

  const PersonalEffect({
    required this.name,
    this.price = const Price(),
    this.rarity = 0,
    this.reference = const Reference(),
  });

  PersonalEffect.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        price = Price.fromJson(json['price'] ?? {}),
        rarity = json['rarity'] ?? 0,
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price.toJson(),
        'rarity': rarity,
        'reference': reference.toJson(),
      };
}

class Quality {
  final String name;
  final Reference reference;

  const Quality({required this.name, this.reference = const Reference()});

  Quality.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() =>
      {'name': name, 'reference': reference.toJson()};
}

class ItemPattern {
  final String name;
  final int xpCost;
  final int rarityModifier;
  final Reference reference;

  const ItemPattern({
    required this.name,
    this.xpCost = 0,
    this.rarityModifier = 0,
    this.reference = const Reference(),
  });

  ItemPattern.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        xpCost = json['xp_cost'] ?? 0,
        rarityModifier = json['rarity_modifier'] ?? 0,
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'xp_cost': xpCost,
        'rarity_modifier': rarityModifier,
        'reference': reference.toJson(),
      };
}

class HeritageOutcome {
  final int rollMin;
  final int rollMax;
  final String outcome;

  const HeritageOutcome({this.rollMin = 0, this.rollMax = 0, this.outcome = ''});

  HeritageOutcome.fromJson(Map<String, dynamic> json)
      : rollMin = json['roll']?['min'] ?? 0,
        rollMax = json['roll']?['max'] ?? 0,
        outcome = json['outcome'] ?? '';

  Map<String, dynamic> toJson() => {
        'roll': {'min': rollMin, 'max': rollMax},
        'outcome': outcome,
      };
}

class HeritageEffect {
  final String type; // e.g. Skill, Ring, starting item, ...
  final String instructions;
  final List<HeritageOutcome> outcomes;

  const HeritageEffect({
    this.type = '',
    this.instructions = '',
    this.outcomes = const [],
  });

  HeritageEffect.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? '',
        instructions = json['instructions'] ?? '',
        outcomes = [
          for (final o in json['outcomes'] ?? []) HeritageOutcome.fromJson(o)
        ];

  Map<String, dynamic> toJson() => {
        'type': type,
        'instructions': instructions,
        'outcomes': [for (final o in outcomes) o.toJson()],
      };
}

class HeritageEntry {
  final int rollMin;
  final int rollMax;
  final String result; // e.g. "Wondrous Work", "Glorious Sacrifice"
  final int honor;
  final int glory;
  final int status;
  final HeritageEffect otherEffects;
  final String source; // Core | SL | CoS | CR | FoV | WotW | CotFW

  const HeritageEntry({
    this.rollMin = 0,
    this.rollMax = 0,
    this.result = '',
    this.honor = 0,
    this.glory = 0,
    this.status = 0,
    this.otherEffects = const HeritageEffect(),
    this.source = 'Core',
  });

  HeritageEntry.fromJson(Map<String, dynamic> json)
      : rollMin = json['roll']?['min'] ?? 0,
        rollMax = json['roll']?['max'] ?? 0,
        result = json['result'] ?? '',
        honor = json['modifiers']?['honor'] ?? 0,
        glory = json['modifiers']?['glory'] ?? 0,
        status = json['modifiers']?['status'] ?? 0,
        otherEffects = HeritageEffect.fromJson(json['other_effects'] ?? {}),
        source = json['source'] ?? 'Core';

  Map<String, dynamic> toJson() => {
        'roll': {'min': rollMin, 'max': rollMax},
        'result': result,
        'modifiers': {'honor': honor, 'glory': glory, 'status': status},
        'other_effects': otherEffects.toJson(),
        'source': source,
      };
}

class Region {
  final String name;
  final String ringIncrease;
  final String skillIncrease;
  final int glory;
  final String type; // Rōnin | Gaijin
  final String subtype; // Gaijin culture group (e.g. Ujik); schools of that
  // culture carry it in their `clan` field
  final Reference reference;

  const Region({
    required this.name,
    this.ringIncrease = '',
    this.skillIncrease = '',
    this.glory = 0,
    this.type = '',
    this.subtype = '',
    this.reference = const Reference(),
  });

  Region.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        ringIncrease = json['ring_increase'] ?? '',
        skillIncrease = json['skill_increase'] ?? '',
        glory = json['glory'] ?? 0,
        type = json['type'] ?? '',
        subtype = json['subtype'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'ring_increase': ringIncrease,
        'skill_increase': skillIncrease,
        'glory': glory,
        'type': type,
        'subtype': subtype,
        'reference': reference.toJson(),
      };
}

class Upbringing {
  final String name;
  final ChoiceSet ringIncrease;
  final List<ChoiceSet> skillIncreases;
  final int statusModification;
  final Price startingWealth;
  final String startingItem; // free comma-separated items, e.g. Temple rations
  final Reference reference;

  const Upbringing({
    required this.name,
    this.ringIncrease = const ChoiceSet(),
    this.skillIncreases = const [],
    this.statusModification = 0,
    this.startingWealth = const Price(),
    this.startingItem = '',
    this.reference = const Reference(),
  });

  Upbringing.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        ringIncrease = ChoiceSet.fromJson(json['ring_increase'] ?? {}),
        skillIncreases = [
          for (final s in json['skill_increases'] ?? []) ChoiceSet.fromJson(s)
        ],
        statusModification = json['status_modification'] ?? 0,
        startingWealth = Price.fromJson(json['starting_wealth'] ?? {}),
        startingItem = json['starting_item'] ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'ring_increase': ringIncrease.toJson(),
        'skill_increases': [for (final s in skillIncreases) s.toJson()],
        'status_modification': statusModification,
        'starting_wealth': startingWealth.toJson(),
        'starting_item': startingItem,
        'reference': reference.toJson(),
      };
}

class TitleAdvancement {
  final String name;
  final String type; // skill | skill_group | technique | technique_group
  final bool specialAccess;
  final int rank; // some title advancements carry a rank gate

  const TitleAdvancement({
    required this.name,
    this.type = 'skill',
    this.specialAccess = false,
    this.rank = 0,
  });

  TitleAdvancement.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        type = json['type'] ?? 'skill',
        specialAccess = json['special_access'] ?? false,
        rank = json['rank'] ?? 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'special_access': specialAccess,
        if (rank > 0) 'rank': rank,
      };
}

class SocialAwardConstraint {
  final String type; // min | max | equals | between
  final dynamic value;

  const SocialAwardConstraint({this.type = '', this.value});

  SocialAwardConstraint.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? '',
        value = json['value'];

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

class SocialAward {
  final int baseAward;
  final String awardAttribute; // Honor | Glory | Status
  final SocialAwardConstraint? constraint;

  const SocialAward({
    this.baseAward = 0,
    this.awardAttribute = '',
    this.constraint,
  });

  SocialAward.fromJson(Map<String, dynamic> json)
      : baseAward = json['base_award'] ?? 0,
        awardAttribute = json['award_attribute'] ?? '',
        constraint = json['constraint'] == null
            ? null
            : SocialAwardConstraint.fromJson(json['constraint']);

  Map<String, dynamic> toJson() => {
        'base_award': baseAward,
        'award_attribute': awardAttribute,
        if (constraint != null) 'constraint': constraint!.toJson(),
      };
}

class Title {
  final String name;
  final int xpToCompletion;
  final String titleAbility;
  final List<TitleAdvancement> advancements;
  final List<SocialAward> socialAwards;
  final Reference reference;

  const Title({
    required this.name,
    this.xpToCompletion = 0,
    this.titleAbility = '',
    this.advancements = const [],
    this.socialAwards = const [],
    this.reference = const Reference(),
  });

  Title.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        xpToCompletion = json['xp_to_completion'] ?? 0,
        titleAbility = json['title_ability'] ?? '',
        advancements = [
          for (final a in json['advancements'] ?? [])
            TitleAdvancement.fromJson(a)
        ],
        socialAwards = [
          for (final s in json['social_awards'] ?? []) SocialAward.fromJson(s)
        ],
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'xp_to_completion': xpToCompletion,
        'title_ability': titleAbility,
        'advancements': [for (final a in advancements) a.toJson()],
        'social_awards': [for (final s in socialAwards) s.toJson()],
        'reference': reference.toJson(),
      };
}

/// Rōnin question 8 options: either an attribute bonus (Glory/Honor) or a
/// pick-one-skill outcome.
class Question8Option {
  final String option;
  final String attribute; // set when the outcome is a flat attribute bonus
  final int value;
  final String outcomeType; // set when the outcome is a choice (e.g. Skills)
  final List<String> values;

  const Question8Option({
    this.option = '',
    this.attribute = '',
    this.value = 0,
    this.outcomeType = '',
    this.values = const [],
  });

  Question8Option.fromJson(Map<String, dynamic> json)
      : option = json['option'] ?? '',
        attribute = json['outcome']?['attribute'] ?? '',
        value = json['outcome']?['value'] ?? 0,
        outcomeType = json['outcome']?['type'] ?? '',
        values = List<String>.from(json['outcome']?['values'] ?? []);

  Map<String, dynamic> toJson() => {
        'option': option,
        'outcome': attribute.isNotEmpty
            ? {'attribute': attribute, 'value': value}
            : {'type': outcomeType, 'values': values},
      };
}

/// A user-entered rules description (the app ships none for copyright
/// reasons); lives only in the homebrew/user overlay.
class Description {
  final String name;
  final String description;
  final String shortDesc;

  const Description({
    required this.name,
    this.description = '',
    this.shortDesc = '',
  });

  Description.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        description = json['description'] ?? '',
        shortDesc = json['short_desc'] ?? '';

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'short_desc': shortDesc,
      };
}
