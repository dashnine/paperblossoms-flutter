import '../../game_data.dart';
import '../../game_data_models.dart';
import '../../rules_constants.dart';
import 'school_builder_data.dart';

/// One curriculum advance under construction. [type] is fixed when the slot
/// is created (the PoW recipe fixes the mix per rank; extra slots keep the
/// type they were added or loaded with).
class CurriculumSlot {
  final String type;
  String advance;
  int minAllowableRank;
  int maxAllowableRank;

  CurriculumSlot(
    this.type, {
    this.advance = '',
    this.minAllowableRank = 0,
    this.maxAllowableRank = 0,
  });
}

/// A mutable "choose [size] of [options]" row (starting techniques, outfit).
class EditableChoiceSet {
  int size;
  List<String> options;

  EditableChoiceSet({this.size = 1, List<String>? options})
    : options = options ?? [];

  ChoiceSet toChoiceSet() => ChoiceSet(size: size, options: [...options]);
}

/// Answers for the PoW "Building a School" wizard (pp. 76-84). UI-free and
/// unit-testable, mirroring [WizardState]. [toSchool] emits the exact
/// schools.json shape; [loadFrom] is its lossless inverse for edit mode.
class SchoolBuilderState {
  // Step 1: roles, ordered, primary first.
  List<String> roles = [];

  // Step 2: affiliation and summary. The summary and short summary become
  // the description entry for the school's own name.
  String clan = '';
  String summary = '';
  String summaryShort = '';

  // Step 3: school ability (name into the school record, text into a
  // description entry).
  String abilityName = '';
  String abilityText = '';
  String abilityShort = '';

  // Step 4: two +1 ring increases (the same ring twice is legal — the Isawa
  // Tensai schools double up).
  List<String> ringIncrease = ['', ''];

  // Step 5: skills the school offers and how many a player picks.
  List<String> startingSkills = [];
  int skillPicks = 5;

  // Step 6: open technique categories and starting technique choice sets.
  List<String> techniquesAvailable = [ritualsCategory];
  List<EditableChoiceSet> startingTechniques = [];

  // Step 7: ranks 1-5 of advances plus the rank-6 mastery ability.
  final Map<int, List<CurriculumSlot>> curriculum = {
    for (var rank = 1; rank <= 5; rank++) rank: defaultRankSlots(),
  };
  String masteryName = '';
  String masteryText = '';
  String masteryShort = '';

  // Step 8: starting outfit rows.
  List<EditableChoiceSet> startingOutfit = [];

  // Step 9: name and the fields the book never charts.
  String name = '';
  int honor = 40;
  String refBook = schoolBuilderRefBook;
  String refPage = schoolBuilderRefPage;

  /// Preserved verbatim for fields the wizard doesn't edit (five bundled
  /// schools grant advantages/disadvantages; homebrew may too).
  List<String> advDisadv = [];

  /// Curriculum entries outside ranks 1-5 (hand-edited JSON can hold them);
  /// preserved verbatim like [advDisadv] so a round trip never drops them.
  List<CurriculumEntry> curriculumPassthrough = [];

  // Sections the user has edited; role-default prefills skip these.
  bool ringsTouched = false;
  bool skillsTouched = false;
  bool accessTouched = false;
  bool startingTechniquesTouched = false;
  bool outfitTouched = false;
  bool honorTouched = false;

  String get primaryRole => roles.isEmpty ? '' : roles.first;

  RoleDefaults? get defaults => roleDefaults[primaryRole];

  /// The PoW recipe: 1 skill group, 3 skills, 1 technique group,
  /// 2 techniques.
  static List<CurriculumSlot> defaultRankSlots() => [
    CurriculumSlot(entryTypeSkillGroup),
    CurriculumSlot(entryTypeSkill),
    CurriculumSlot(entryTypeSkill),
    CurriculumSlot(entryTypeSkill),
    CurriculumSlot(entryTypeTechniqueGroup),
    CurriculumSlot(entryTypeTechnique),
    CurriculumSlot(entryTypeTechnique),
  ];

  /// Prefills sections the user hasn't touched from the primary role's
  /// tables. Called whenever the primary role changes.
  void applyRoleDefaults() {
    final d = defaults;
    if (d == null) return;
    if (!ringsTouched) {
      ringIncrease = [
        d.suggestedRings.length == 1 ? d.suggestedRings.single : '',
        '',
      ];
    }
    if (!skillsTouched) {
      startingSkills = d.commonSkills.take(d.skillCount).toList();
      skillPicks = d.skillChoose;
    }
    if (!accessTouched) {
      techniquesAvailable = [ritualsCategory, ...d.suggestedTechCategories];
    }
    if (!startingTechniquesTouched) {
      startingTechniques = [
        for (var i = 0; i < d.startingTechniqueSlots; i++)
          EditableChoiceSet(
            options: i == 0 && primaryRole == 'Shugenja'
                ? [communeWithSpirits]
                : [],
          ),
      ];
    }
    if (!outfitTouched) {
      startingOutfit = [
        for (final row in d.suggestedOutfit)
          EditableChoiceSet(size: row.size, options: [...row.options]),
      ];
    }
    if (!honorTouched) honor = d.suggestedHonor;
  }

  // ---- Special-access derivation ----
  //
  // Bundled convention (verified against the core schools): a technique row
  // is special access when the technique sits above the curriculum rank or
  // its category isn't open to the school; a group row is special access
  // when the group isn't open. The engine treats a false flag on an
  // at-rank in-access row identically, so re-deriving is behavior-neutral
  // on round trips.

  bool _isOpenCategory(String category, String subcategory) =>
      techniquesAvailable.contains(category) ||
      techniquesAvailable.contains(subcategory) ||
      universalTechniqueCategories.contains(category);

  bool techniqueNeedsSpecialAccess(String techName, int rank) {
    final tech = gameData.techniqueByName(techName);
    if (tech == null) return false;
    return tech.rank > rank ||
        !_isOpenCategory(tech.category, tech.subcategory);
  }

  bool groupNeedsSpecialAccess(String group) {
    if (techniquesAvailable.contains(group)) return false;
    final members = gameData.techniquesByGroup(group);
    if (members.isEmpty) return true;
    return !_isOpenCategory(members.first.category, group);
  }

  bool slotNeedsSpecialAccess(CurriculumSlot slot, int rank) =>
      switch (slot.type) {
        entryTypeTechnique => techniqueNeedsSpecialAccess(slot.advance, rank),
        entryTypeTechniqueGroup => groupNeedsSpecialAccess(slot.advance),
        _ => false,
      };

  // ---- Progress helpers for the shell ----

  int filledSlots(int rank) =>
      curriculum[rank]!.where((s) => s.advance.isNotEmpty).length;

  bool rankComplete(int rank) =>
      curriculum[rank]!.isNotEmpty &&
      curriculum[rank]!.every((s) => s.advance.isNotEmpty);

  /// Skills at [rank] that fall inside that rank's chosen skill group —
  /// the book says the three skills should come from outside it.
  List<String> skillsInsideRankGroup(int rank) {
    final slots = curriculum[rank]!;
    final groups = {
      for (final s in slots)
        if (s.type == entryTypeSkillGroup && s.advance.isNotEmpty) s.advance,
    };
    final covered = {for (final g in groups) ...gameData.skillsByGroup(g)};
    return [
      for (final s in slots)
        if (s.type == entryTypeSkill && covered.contains(s.advance)) s.advance,
    ];
  }

  /// True when a rank deviates from the book's 1/3/1/2 recipe.
  bool rankShapeDeviates(int rank) {
    final slots = curriculum[rank]!;
    int count(String type) => slots.where((s) => s.type == type).length;
    return count(entryTypeSkillGroup) != 1 ||
        count(entryTypeSkill) != 3 ||
        count(entryTypeTechniqueGroup) != 1 ||
        count(entryTypeTechnique) != 2;
  }

  // ---- Serialization ----

  School toSchool() => School(
    name: name,
    clan: clan,
    role: [...roles],
    ringIncrease: [...ringIncrease],
    startingSkills: ChoiceSet(size: skillPicks, options: [...startingSkills]),
    honor: honor,
    techniquesAvailable: [...techniquesAvailable],
    startingTechniques: [
      for (final set in startingTechniques) set.toChoiceSet(),
    ],
    schoolAbility: abilityName,
    masteryAbility: masteryName,
    startingOutfit: [for (final set in startingOutfit) set.toChoiceSet()],
    curriculum: [
      for (var rank = 1; rank <= 5; rank++)
        for (final slot in curriculum[rank]!)
          CurriculumEntry(
            rank: rank,
            advance: slot.advance,
            type: slot.type,
            specialAccess: slotNeedsSpecialAccess(slot, rank),
            minAllowableRank:
                slot.minAllowableRank == 0 && slot.maxAllowableRank > 0
                ? 1
                : slot.minAllowableRank,
            maxAllowableRank: slot.maxAllowableRank,
          ),
      ...curriculumPassthrough,
    ],
    advDisadv: [...advDisadv],
    reference: Reference(book: refBook, page: refPage),
  );

  /// Inverse of [toSchool] for edit mode. Curriculum slots mirror the
  /// school's entries in their original order, so hand-shaped ranks (the
  /// bundled data deviates in 36 places) survive a round trip. Marks every
  /// section touched so role defaults never clobber loaded values.
  void loadFrom(School school) {
    name = school.name;
    clan = school.clan;
    roles = [...school.role];
    // Pad to at least the two slots step 4 renders (hand-edited JSON may
    // hold zero or one ring increase).
    ringIncrease = [
      ...school.ringIncrease,
      for (var i = school.ringIncrease.length; i < 2; i++) '',
    ];
    startingSkills = [...school.startingSkills.options];
    skillPicks = school.startingSkills.size;
    honor = school.honor;
    techniquesAvailable = [...school.techniquesAvailable];
    startingTechniques = [
      for (final set in school.startingTechniques)
        EditableChoiceSet(size: set.size, options: [...set.options]),
    ];
    abilityName = school.schoolAbility;
    masteryName = school.masteryAbility;
    startingOutfit = [
      for (final set in school.startingOutfit)
        EditableChoiceSet(size: set.size, options: [...set.options]),
    ];
    curriculumPassthrough = [
      for (final e in school.curriculum)
        if (e.rank < 1 || e.rank > 5) e,
    ];
    for (var rank = 1; rank <= 5; rank++) {
      final entries = [
        for (final e in school.curriculum)
          if (e.rank == rank) e,
      ];
      curriculum[rank] = entries.isEmpty
          ? defaultRankSlots()
          : [
              for (final e in entries)
                CurriculumSlot(
                  e.type,
                  advance: e.advance,
                  minAllowableRank: e.minAllowableRank,
                  maxAllowableRank: e.maxAllowableRank,
                ),
            ];
    }
    advDisadv = [...school.advDisadv];
    refBook = school.reference.book;
    refPage = school.reference.page;
    ringsTouched = true;
    skillsTouched = true;
    accessTouched = true;
    startingTechniquesTouched = true;
    outfitTouched = true;
    honorTouched = true;
  }
}
