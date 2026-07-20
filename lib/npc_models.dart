import 'game_data_models.dart';

/// A specialized NPC advantage or disadvantage: a name plus the ring and
/// [skill group; type] tags printed in Chapter 8 stat blocks. These are
/// distinct from the PC advantage list (Core p. 99) and carry no rules text
/// beyond their tags.
class NpcTrait {
  String name;
  String ring;
  List<String> groups;
  List<String> types;

  NpcTrait({
    this.name = '',
    this.ring = '',
    this.groups = const [],
    this.types = const [],
  });

  NpcTrait.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        ring = json['ring']?.toString() ?? '',
        groups = List<String>.from(json['groups'] ?? []),
        types = List<String>.from(json['types'] ?? []);

  Map<String, dynamic> toJson() => {
        'name': name,
        'ring': ring,
        'groups': groups,
        'types': types,
      };

  /// "Martial, Trade; Physical" — the printed tag line.
  String get tagLine => '${groups.join(', ')}; ${types.join(', ')}';
}

/// A favored-weapon line, stored exactly as printed (deadliness like "5/7"
/// for grip variants, freeform notes like "deals supernatural damage" among
/// the qualities). Never resolved against weapons.json.
class NpcWeaponLine {
  String name;
  String range;
  String damage;
  String deadliness;
  List<String> qualities;

  NpcWeaponLine({
    this.name = '',
    this.range = '',
    this.damage = '',
    this.deadliness = '',
    this.qualities = const [],
  });

  NpcWeaponLine.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        range = json['range']?.toString() ?? '',
        damage = json['damage']?.toString() ?? '',
        deadliness = json['deadliness']?.toString() ?? '',
        qualities = List<String>.from(json['qualities'] ?? []);

  Map<String, dynamic> toJson() => {
        'name': name,
        'range': range,
        'damage': damage,
        'deadliness': deadliness,
        'qualities': qualities,
      };
}

/// A named NPC ability with its full rules text (bundled deliberately so the
/// GM tools work at the table without a descriptions import).
class NpcAbility {
  String name;
  String text;
  Reference reference;

  NpcAbility({this.name = '', this.text = '', this.reference = const Reference()});

  NpcAbility.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        text = json['text']?.toString() ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  Map<String, dynamic> toJson() => {
        'name': name,
        'text': text,
        'reference': reference.toJson(),
      };
}

/// Honor/glory/status. Absent entirely on creature profiles that don't
/// interact with those systems (Core p. 320 "Simplified Profile").
class NpcSocial {
  int honor;
  int glory;
  int status;

  NpcSocial({this.honor = 0, this.glory = 0, this.status = 0});

  NpcSocial.fromJson(Map<String, dynamic> json)
      : honor = json['honor'] ?? 0,
        glory = json['glory'] ?? 0,
        status = json['status'] ?? 0;

  Map<String, dynamic> toJson() =>
      {'honor': honor, 'glory': glory, 'status': status};
}

/// Derived attributes, kept as printed. Values are display strings because
/// the book prints non-numeric ones (Composure "∞" on undead); numeric
/// helpers parse on demand.
class NpcDerived {
  String endurance;
  String composure;
  String focus;
  String vigilance;

  NpcDerived({
    this.endurance = '',
    this.composure = '',
    this.focus = '',
    this.vigilance = '',
  });

  NpcDerived.fromJson(Map<String, dynamic> json)
      : endurance = json['endurance']?.toString() ?? '',
        composure = json['composure']?.toString() ?? '',
        focus = json['focus']?.toString() ?? '',
        vigilance = json['vigilance']?.toString() ?? '';

  Map<String, dynamic> toJson() => {
        'endurance': int.tryParse(endurance) ?? endurance,
        'composure': int.tryParse(composure) ?? composure,
        'focus': int.tryParse(focus) ?? focus,
        'vigilance': int.tryParse(vigilance) ?? vigilance,
      };

  int? get enduranceValue => int.tryParse(endurance);
  int? get composureValue => int.tryParse(composure);
}

/// A complete NPC stat block — either a bundled Chapter 8 sample or a
/// user-built custom NPC. Custom NPCs are fully materialized: [base] and
/// [appliedTemplates] are display-only provenance, never re-derived from.
class Npc {
  String name;
  String type; // 'minion' | 'adversary'
  String blurb;
  int crCombat;
  int crIntrigue;
  Map<String, int> rings; // keys: Air, Earth, Fire, Water, Void
  NpcDerived derived;
  NpcSocial? social;
  String demeanor;
  Map<String, int> skillGroups;
  List<NpcTrait> advantages;
  List<NpcTrait> disadvantages;
  List<NpcWeaponLine> weapons;
  List<String> gearEquipped;
  List<String> gearOther;
  List<NpcAbility> abilities;

  /// PC technique names added via templates or editing (rules text lives in
  /// user-imported descriptions, not here).
  List<String> techniques;

  String base;
  List<String> appliedTemplates;
  Reference reference;

  /// True for user-built NPCs (set by the store, not serialized).
  bool custom;

  Npc({
    this.name = '',
    this.type = 'adversary',
    this.blurb = '',
    this.crCombat = 1,
    this.crIntrigue = 1,
    Map<String, int>? rings,
    NpcDerived? derived,
    this.social,
    this.demeanor = '',
    Map<String, int>? skillGroups,
    List<NpcTrait>? advantages,
    List<NpcTrait>? disadvantages,
    List<NpcWeaponLine>? weapons,
    List<String>? gearEquipped,
    List<String>? gearOther,
    List<NpcAbility>? abilities,
    List<String>? techniques,
    this.base = '',
    List<String>? appliedTemplates,
    this.reference = const Reference(),
    this.custom = false,
  })  : rings = rings ?? {'Air': 1, 'Earth': 1, 'Fire': 1, 'Water': 1, 'Void': 1},
        derived = derived ?? NpcDerived(),
        skillGroups = skillGroups ??
            {'Artisan': 0, 'Martial': 0, 'Scholar': 0, 'Social': 0, 'Trade': 0},
        advantages = advantages ?? [],
        disadvantages = disadvantages ?? [],
        weapons = weapons ?? [],
        gearEquipped = gearEquipped ?? [],
        gearOther = gearOther ?? [],
        abilities = abilities ?? [],
        techniques = techniques ?? [],
        appliedTemplates = appliedTemplates ?? [];

  factory Npc.fromJson(Map<String, dynamic> json) => Npc(
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? 'adversary',
        blurb: json['blurb']?.toString() ?? '',
        crCombat: json['conflict_rank']?['combat'] ?? 1,
        crIntrigue: json['conflict_rank']?['intrigue'] ?? 1,
        rings: {
          for (final e in (json['rings'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num?)?.toInt() ?? 0
        },
        derived: NpcDerived.fromJson(json['derived'] ?? {}),
        social:
            json['social'] == null ? null : NpcSocial.fromJson(json['social']),
        demeanor: json['demeanor']?.toString() ?? '',
        skillGroups: {
          for (final e in (json['skill_groups'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num?)?.toInt() ?? 0
        },
        advantages: [
          for (final e in json['advantages'] ?? []) NpcTrait.fromJson(e)
        ],
        disadvantages: [
          for (final e in json['disadvantages'] ?? []) NpcTrait.fromJson(e)
        ],
        weapons: [
          for (final e in json['weapons'] ?? []) NpcWeaponLine.fromJson(e)
        ],
        gearEquipped: List<String>.from(json['gear']?['equipped'] ?? []),
        gearOther: List<String>.from(json['gear']?['other'] ?? []),
        abilities: [
          for (final e in json['abilities'] ?? []) NpcAbility.fromJson(e)
        ],
        techniques: List<String>.from(json['techniques'] ?? []),
        base: json['base']?.toString() ?? '',
        appliedTemplates: List<String>.from(json['applied_templates'] ?? []),
        reference: Reference.fromJson(json['reference'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        if (blurb.isNotEmpty) 'blurb': blurb,
        'conflict_rank': {'combat': crCombat, 'intrigue': crIntrigue},
        'rings': rings,
        'derived': derived.toJson(),
        if (social != null) 'social': social!.toJson(),
        'demeanor': demeanor,
        'skill_groups': skillGroups,
        'advantages': [for (final a in advantages) a.toJson()],
        'disadvantages': [for (final d in disadvantages) d.toJson()],
        'weapons': [for (final w in weapons) w.toJson()],
        'gear': {'equipped': gearEquipped, 'other': gearOther},
        'abilities': [for (final a in abilities) a.toJson()],
        if (techniques.isNotEmpty) 'techniques': techniques,
        if (base.isNotEmpty) 'base': base,
        if (appliedTemplates.isNotEmpty) 'applied_templates': appliedTemplates,
        'reference': reference.toJson(),
      };

  Npc clone() => Npc.fromJson(toJson())..custom = custom;

  bool get isMinion => type == 'minion';
}

/// An NPC demeanor: Social-check TN modifiers by ring, plus (for the five
/// generic demeanors of Core p. 310) a common way of unmasking.
class Demeanor {
  final String name;
  final String description;
  final Map<String, int> modifiers;
  final String unmasking;
  final Reference reference;

  const Demeanor({
    this.name = '',
    this.description = '',
    this.modifiers = const {},
    this.unmasking = '',
    this.reference = const Reference(),
  });

  Demeanor.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        description = json['description']?.toString() ?? '',
        modifiers = {
          for (final e in (json['modifiers'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num?)?.toInt() ?? 0
        },
        unmasking = json['unmasking']?.toString() ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});

  /// "Air +2, Fire −2" — modifiers as a display line. [tr] translates the
  /// ring names (pass `trData` at display sites; the model stays UI-free).
  String modifierLine([String Function(String)? tr]) => [
        for (final e in modifiers.entries)
          '${tr == null ? e.key : tr(e.key)} '
              '${e.value > 0 ? '+' : '−'}${e.value.abs()}'
      ].join(', ');
}

/// A Chapter 8 NPC template (Core p. 311): additive deltas that specialize a
/// base profile, plus suggested traits, technique picks, and demeanors.
class NpcTemplate {
  final String name;
  final int crCombat;
  final int crIntrigue;
  final String ring;
  final Map<String, int> skillGroups;
  final List<NpcTrait> suggestedAdvantages;
  final List<NpcTrait> suggestedDisadvantages;
  final List<String> techniqueCategories;
  final int techniqueMax;
  final List<String> defaultTechniques;
  final List<String> demeanorOptions;
  final String defaultDemeanor;
  final Reference reference;

  const NpcTemplate({
    this.name = '',
    this.crCombat = 0,
    this.crIntrigue = 0,
    this.ring = '',
    this.skillGroups = const {},
    this.suggestedAdvantages = const [],
    this.suggestedDisadvantages = const [],
    this.techniqueCategories = const [],
    this.techniqueMax = 0,
    this.defaultTechniques = const [],
    this.demeanorOptions = const [],
    this.defaultDemeanor = '',
    this.reference = const Reference(),
  });

  NpcTemplate.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString() ?? '',
        crCombat = json['conflict_rank']?['combat'] ?? 0,
        crIntrigue = json['conflict_rank']?['intrigue'] ?? 0,
        ring = json['ring']?.toString() ?? '',
        skillGroups = {
          for (final e in (json['skill_groups'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num?)?.toInt() ?? 0
        },
        suggestedAdvantages = [
          for (final e in json['suggested_advantages'] ?? [])
            NpcTrait.fromJson(e)
        ],
        suggestedDisadvantages = [
          for (final e in json['suggested_disadvantages'] ?? [])
            NpcTrait.fromJson(e)
        ],
        techniqueCategories =
            List<String>.from(json['techniques']?['categories'] ?? []),
        techniqueMax = json['techniques']?['max'] ?? 0,
        defaultTechniques =
            List<String>.from(json['techniques']?['default'] ?? []),
        demeanorOptions = List<String>.from(json['demeanor_options'] ?? []),
        defaultDemeanor = json['default_demeanor']?.toString() ?? '',
        reference = Reference.fromJson(json['reference'] ?? {});
}
