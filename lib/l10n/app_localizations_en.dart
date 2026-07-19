// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Paper Blossoms';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get importCharacterTooltip => 'Import character';

  @override
  String get newCharacter => 'New Character';

  @override
  String get noCharactersYet =>
      'No characters yet.\nCreate one to begin your story.';

  @override
  String deleteCharacterTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteCannotBeUndone => 'This cannot be undone.';

  @override
  String rankN(int rank) {
    return 'Rank $rank';
  }

  @override
  String get toolsTitle => 'Tools';

  @override
  String get languageSection => 'Language';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get rulesTextSection => 'Rules text';

  @override
  String get editRulesDescriptions => 'Edit rules descriptions';

  @override
  String get editRulesDescriptionsSubtitle =>
      'The bundled data ships no rules text. If you own the books, enter your own descriptions here; they appear in the editor and on the PDF sheet.';

  @override
  String get importDescriptions => 'Import descriptions…';

  @override
  String get importDescriptionsSubtitle =>
      'Merge descriptions from an exported JSON file or the original Paper Blossoms user_descriptions.csv; imported entries overwrite same-name ones.';

  @override
  String get exportDescriptions => 'Export descriptions…';

  @override
  String get exportDescriptionsSubtitle =>
      'Save all descriptions to a JSON file for backup or sharing.';

  @override
  String get homebrewSection => 'Homebrew content';

  @override
  String get homebrewFolder => 'Homebrew folder';

  @override
  String homebrewFolderSubtitle(String path) {
    return '$path\n\nDrop JSON files named like the bundled data (weapons.json, titles.json, techniques.json, …) with the same structure; entries are merged after the official content on launch.';
  }

  @override
  String get reloadHomebrew => 'Reload homebrew now';

  @override
  String get nothingMergedThisSession => 'Nothing merged this session.';

  @override
  String mergedFiles(String files) {
    return 'Merged: $files';
  }

  @override
  String get noHomebrewFilesFound => 'No homebrew files found.';

  @override
  String get horSection => 'Heroes of Rokugan';

  @override
  String get horModeTitle => 'Heroes of Rokugan mode';

  @override
  String get horModeSubtitle =>
      'New characters follow the Heroes of Rokugan 5 community campaign\'s creation rules (unofficial, not affiliated with the campaign or Edge Studio). heroes-of-rokugan.net';

  @override
  String get wizErrHorRoninRing => 'Choose the rōnin ring increase.';

  @override
  String get wizErrHorBackground => 'Choose a background.';

  @override
  String get wizErrHorBackgroundRing => 'Choose the background ring increase.';

  @override
  String wizErrHorBackgroundSkill(int n) {
    return 'Choose background skill increase $n.';
  }

  @override
  String get wizErrHorService => 'Choose whom your character serves.';

  @override
  String get wizErrHorQ5Skill => 'Choose a skill related to your giri.';

  @override
  String get wizErrHorQ6Skill =>
      'Choose a skill related to your ninjō (different from Question 5).';

  @override
  String get wizErrHorAccessory => 'Choose a personal accessory.';

  @override
  String get wizErrHorHeritage => 'Choose a heritage result.';

  @override
  String get wizErrHorQ19 => 'Choose the extra technique for Question 19.';

  @override
  String get wizErrHorOutfitItem =>
      'Choose which outfit item bears the Sacred and Forbidden qualities.';

  @override
  String horRoninStatsLine(String skill, int status) {
    return 'Rōnin: +1 to any ring, +1 $skill, Status $status';
  }

  @override
  String get horRoninRingLabel => 'Ring increase';

  @override
  String get horBackgroundLabel => 'Background';

  @override
  String horBackgroundStatsLine(int glory, String wealth) {
    return 'Glory $glory, starting wealth $wealth';
  }

  @override
  String get horBackgroundRingLabel => 'Background ring increase';

  @override
  String horBackgroundSkillN(int n) {
    return 'Background skill increase $n';
  }

  @override
  String get horAllSchoolSkills => '+1 to every starting skill:';

  @override
  String get horServiceLabel => 'Service';

  @override
  String get horRelatedSkill => 'Related skill (+1)';

  @override
  String get horQ7Positive =>
      '+5 glory and 1 rank in a skill listed for another family of your clan';

  @override
  String get horQ7Negative =>
      '−5 glory and 1 rank in a skill no family of your clan lists';

  @override
  String get horQ8Pos => '+5 honor and 1 rank in a traditional samurai skill';

  @override
  String get horQ8Neg => '−3 honor and 1 rank in a skill unbefitting a samurai';

  @override
  String get horAccessoryRarity7 =>
      'Personal accessory (non-weapon, rarity 7 or lower)';

  @override
  String get horHeritageLabel => 'Heritage (choose one)';

  @override
  String get horQ19TechniqueLabel => 'Extra technique (school rank 1)';

  @override
  String horCampaignTitleLine(String title, int stipend) {
    return 'Campaign title: $title — Status set to 40, stipend $stipend koku per module.';
  }

  @override
  String get horInstallPack => 'Install errata pack';

  @override
  String get horInstallPackSubtitle =>
      'Copies the campaign\'s school erratas and equipment changes into your homebrew folder. They apply to all play until removed.';

  @override
  String get horRemovePack => 'Remove errata pack';

  @override
  String get horRemovePackSubtitle =>
      'Removes only the entries the pack installed; your own homebrew is kept.';

  @override
  String horPackInstalledMsg(int count) {
    return 'HoR errata pack installed ($count schools).';
  }

  @override
  String get horPackRemovedMsg => 'HoR errata pack removed.';

  @override
  String get aboutSection => 'About';

  @override
  String get aboutApp => 'About Paper Blossoms';

  @override
  String get aboutAppSubtitle => 'Version, credits, and licenses.';

  @override
  String get aboutTagline =>
      'A character generator for Legend of the Five Rings 5th Edition.';

  @override
  String get aboutPortNote =>
      'A Flutter port of the original PaperBlossoms desktop application, by the same developer.';

  @override
  String get aboutLegalese =>
      'Fan-made and unaffiliated with Fantasy Flight Games, Edge Studio, or Asmodee. Legend of the Five Rings and all associated content are property of Fantasy Flight Games.';

  @override
  String importedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count descriptions.',
      one: 'Imported 1 description.',
    );
    return '$_temp0';
  }

  @override
  String exportedDescriptions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Exported $count descriptions.',
      one: 'Exported 1 description.',
    );
    return '$_temp0';
  }

  @override
  String get couldNotReadDescriptionsFile =>
      'Couldn\'t read that file as descriptions JSON or CSV.';

  @override
  String get noDescriptionsToExport => 'No descriptions to export.';

  @override
  String get tabCharacter => 'Character';

  @override
  String get tabBackground => 'Background';

  @override
  String get tabTraits => 'Traits';

  @override
  String get tabBonds => 'Bonds';

  @override
  String get tabTechniques => 'Techniques';

  @override
  String get tabEquipment => 'Equipment';

  @override
  String get tabAdvancement => 'Advancement';

  @override
  String get unnamedSamurai => 'Unnamed Samurai';

  @override
  String get saved => 'Saved';

  @override
  String get save => 'Save';

  @override
  String get saveUnsavedTooltip => 'Save (unsaved changes)';

  @override
  String get exportTooltip => 'Export';

  @override
  String get printExportPdf => 'Print / export PDF sheet…';

  @override
  String get shareCharacterJson => 'Share character JSON…';

  @override
  String get fullSkillTableOnSheet => 'Full skill table on sheet';

  @override
  String get portraitOnSheet => 'Portrait on sheet';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get saveBeforeClosing => 'Save this character before closing?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get saveAndClose => 'Save & close';

  @override
  String get characterExported => 'Character exported.';

  @override
  String get nameLabel => 'Name';

  @override
  String get familyLabel => 'Family';

  @override
  String get noClan => 'No clan';

  @override
  String get noSchool => 'No school';

  @override
  String get socialStandingSection => 'Social Standing';

  @override
  String get honor => 'Honor';

  @override
  String get glory => 'Glory';

  @override
  String get statusLabel => 'Status';

  @override
  String get wealthSection => 'Wealth';

  @override
  String get koku => 'Koku';

  @override
  String get bu => 'Bu';

  @override
  String get zeni => 'Zeni';

  @override
  String get abilitiesSection => 'Abilities';

  @override
  String get noAbilitiesYet => 'No abilities yet.';

  @override
  String get ringsSection => 'Rings';

  @override
  String get derivedAttributesSection => 'Derived Attributes';

  @override
  String get endurance => 'Endurance';

  @override
  String get composure => 'Composure';

  @override
  String get focusStat => 'Focus';

  @override
  String get vigilance => 'Vigilance';

  @override
  String get schoolRank => 'School Rank';

  @override
  String get fatigueStrifeSection => 'Fatigue & Strife';

  @override
  String fatigueOf(int max) {
    return 'Fatigue / $max';
  }

  @override
  String strifeOf(int max) {
    return 'Strife / $max';
  }

  @override
  String get clearAllFatigue => 'Clear all fatigue';

  @override
  String get recover => 'Recover';

  @override
  String get clearAllStrife => 'Clear all strife';

  @override
  String get unmask => 'Unmask';

  @override
  String get conditionsSection => 'Conditions';

  @override
  String get addCondition => 'Add condition';

  @override
  String get noConditions => 'No conditions.';

  @override
  String get incapacitatedRule =>
      'Fatigue exceeds endurance: no actions requiring checks and no defending against damage.';

  @override
  String get compromisedRule =>
      'Strife exceeds composure: cannot keep dice showing strife; vigilance counts as 1.';

  @override
  String get criticalStrike => 'Critical strike…';

  @override
  String get skillsSection => 'Skills';

  @override
  String get heritageSection => 'Heritage';

  @override
  String get ninjoSection => 'Ninjō (personal desire)';

  @override
  String get giriSection => 'Giri (duty)';

  @override
  String get notesSection => 'Notes';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get undo => 'Undo';

  @override
  String removedName(String name) {
    return 'Removed $name';
  }

  @override
  String get unknownCustomSection => 'Unknown (custom or missing data)';

  @override
  String get bondsSection => 'Bonds';

  @override
  String get addBond => 'Add bond';

  @override
  String get noBondsYet => 'No bonds formed yet — tap + to add.';

  @override
  String get rankLabel => 'Rank';

  @override
  String get techniquesSection => 'Techniques';

  @override
  String get noTechniquesYet => 'No techniques known yet.';

  @override
  String restrictionLabel(String restriction) {
    return 'Restriction: $restriction';
  }

  @override
  String get customOrUnknownTechnique => 'Custom or unknown technique';

  @override
  String get weaponsSection => 'Weapons';

  @override
  String get armorSection => 'Armor';

  @override
  String get personalEffectsSection => 'Personal Effects';

  @override
  String get addItem => 'Add item';

  @override
  String get noWeaponsYet => 'No weapons yet — tap + to add.';

  @override
  String get noArmorYet => 'No armor yet — tap + to add.';

  @override
  String get noPersonalEffectsYet => 'No personal effects yet — tap + to add.';

  @override
  String gripStats(
    String grip,
    int min,
    int max,
    String damage,
    String deadliness,
  ) {
    return '$grip: Range $min-$max · Dmg $damage · Dls $deadliness';
  }

  @override
  String armorStats(int physical, int supernatural) {
    return 'Physical $physical · Supernatural $supernatural';
  }

  @override
  String priceLine(int price, String unit, int rarity) {
    return '$price $unit · Rarity $rarity';
  }

  @override
  String get colName => 'Name';

  @override
  String get colCategory => 'Category';

  @override
  String get colSkill => 'Skill';

  @override
  String get colGrip => 'Grip';

  @override
  String get colRange => 'Range';

  @override
  String get colDamage => 'Dmg';

  @override
  String get colDeadliness => 'Dls';

  @override
  String get colQualities => 'Qualities';

  @override
  String get colPhysical => 'Physical';

  @override
  String get colSupernatural => 'Supernatural';

  @override
  String addedAdvanceRankUp(String name, int rank) {
    return 'Added $name — school rank is now $rank!';
  }

  @override
  String addedAdvance(String name, int cost, String track) {
    return 'Added $name — $cost XP ($track)';
  }

  @override
  String get xpInRank => 'XP in Rank';

  @override
  String get xpSpentLabel => 'XP Spent';

  @override
  String get noTitleInProgress => 'No title in progress';

  @override
  String currentTitleLine(String title, int xp, int total) {
    return 'Current title: $title — $xp / $total XP';
  }

  @override
  String curriculumSection(String school) {
    return 'Curriculum — $school';
  }

  @override
  String get noSchoolFallback => 'no school';

  @override
  String get addAdvance => 'Add advance';

  @override
  String get noSchoolNoCurriculum =>
      'No school chosen, so there is no curriculum.';

  @override
  String get currentLabel => 'current';

  @override
  String skillRankLabel(int rank) {
    return 'rank $rank';
  }

  @override
  String get specialAccess => 'special access';

  @override
  String ranksRange(int min, int max) {
    return 'ranks $min-$max';
  }

  @override
  String get atRank5 => 'At rank 5';

  @override
  String get alreadyLearnedLabel => 'Already learned';

  @override
  String get buyThisAdvance => 'Buy this advance';

  @override
  String get titlesSection => 'Titles';

  @override
  String get addTitle => 'Add title';

  @override
  String get finishCurrentTitleFirst => 'Finish the current title first';

  @override
  String get noTitlesYet => 'No titles yet — tap + to add.';

  @override
  String get inProgressLabel => 'In progress';

  @override
  String completedWithAbility(String ability) {
    return 'Completed — $ability';
  }

  @override
  String maxRankLabel(int rank) {
    return 'max rank $rank';
  }

  @override
  String get advancesTakenSection => 'Advances Taken';

  @override
  String get noAdvancesYet =>
      'No advances purchased yet — tap + or a curriculum entry.';

  @override
  String advanceSubtitle(String type, String track, int cost) {
    return '$type · $track · $cost XP';
  }

  @override
  String get addAdvanceTitle => 'Add Advance';

  @override
  String get advTypeSkill => 'Skill';

  @override
  String get advTypeRing => 'Ring';

  @override
  String get advTypeTechnique => 'Technique';

  @override
  String get advanceSection => 'Advance';

  @override
  String get groupLabel => 'Group';

  @override
  String get allGroups => 'All groups';

  @override
  String get mahoWarning => 'Mahō is forbidden. Learning it has consequences.';

  @override
  String get typeToFilter => 'Type to filter';

  @override
  String get clearFilter => 'Clear filter';

  @override
  String techSubtitle(String subcategory, int rank, int xp) {
    return '$subcategory · Rank $rank · $xp XP';
  }

  @override
  String get ignoreRestrictions => 'Ignore restrictions (rank, school access)';

  @override
  String get trackSection => 'Track';

  @override
  String get trackCurriculumLabel => 'Curriculum';

  @override
  String get trackTitleLabel => 'Title';

  @override
  String get trackFreeLabel => 'Free (no XP cost)';

  @override
  String get reasonOptional => 'Reason (optional)';

  @override
  String get halfXpLabel => 'Half XP (school/title discount)';

  @override
  String get chooseAnAdvance => 'Choose an advance.';

  @override
  String alreadyLearnedError(String name) {
    return '\'$name\' is already learned.';
  }

  @override
  String costXp(int cost) {
    return 'Cost: $cost XP';
  }

  @override
  String get addItemTitle => 'Add Item';

  @override
  String get itemWeapon => 'Weapon';

  @override
  String get itemArmor => 'Armor';

  @override
  String get itemPersonalEffect => 'Personal Effect';

  @override
  String get chooseWeapon => 'Choose Weapon';

  @override
  String get chooseArmor => 'Choose Armor';

  @override
  String get choosePersonalEffect => 'Choose Personal Effect';

  @override
  String weaponPickSubtitle(
    String category,
    String skill,
    String damage,
    String deadliness,
  ) {
    return '$category · $skill · Dmg $damage · Dls $deadliness';
  }

  @override
  String get chooseFromBook => 'Choose from book…';

  @override
  String get changeBaseItem => 'Change base item…';

  @override
  String get customItem => 'Custom item';

  @override
  String get detailsSection => 'Details';

  @override
  String get priceLabel => 'Price';

  @override
  String get rarityLabel => 'Rarity';

  @override
  String get qualitiesCommaSeparated => 'Qualities (comma-separated)';

  @override
  String addNGrips(int count) {
    return 'Add ($count grips)';
  }

  @override
  String gripEditorLabel(String grip) {
    return 'Grip: $grip';
  }

  @override
  String get minRange => 'Min range';

  @override
  String get maxRange => 'Max range';

  @override
  String get damageLabel => 'Damage';

  @override
  String get deadlinessLabel => 'Deadliness';

  @override
  String get addTrait => 'Add Trait';

  @override
  String addCategoryLower(String category) {
    return 'Add $category';
  }

  @override
  String get addBondTitle => 'Add Bond';

  @override
  String get addTitleTitle => 'Add Title';

  @override
  String xpAmount(int xp) {
    return '$xp XP';
  }

  @override
  String get criticalStrikeTitle => 'Critical strike';

  @override
  String get severityLabel => 'Severity (deadliness of the source)';

  @override
  String get razorEdgedLabel => 'Attack was Razor-Edged';

  @override
  String get ringUsedToResist => 'Ring used to resist';

  @override
  String get ringResistHelper =>
      'Stance ring in a conflict, any in a narrative';

  @override
  String get tnFitnessCheck => 'TN 1 Fitness check succeeded';

  @override
  String get rollOwnDice => 'Roll your own dice; enter the result';

  @override
  String get bonusSuccessesLabel =>
      'Bonus successes (severity −1 each, on top of −1)';

  @override
  String finalSeverityLine(int severity, String band) {
    return 'Final severity $severity — $band';
  }

  @override
  String get apply => 'Apply';

  @override
  String chooseScarTitle(String band, String ring) {
    return '$band: choose a scar ($ring)';
  }

  @override
  String severityResult(int severity, String band, String effect) {
    return 'Severity $severity: $band — $effect';
  }

  @override
  String get rulesDescriptionsTitle => 'Rules Descriptions';

  @override
  String get shortDescriptionLabel => 'Short description';

  @override
  String get fullDescriptionLabel => 'Full description';

  @override
  String get searchHint => 'Search…';

  @override
  String get withText => 'With text';

  @override
  String get wizPart1 => 'Part 1: Clan and Family';

  @override
  String get wizPart2 => 'Part 2: Role and School';

  @override
  String get wizPart3 => 'Part 3: Honor and Glory';

  @override
  String get wizPart4 => 'Part 4: Strengths and Weaknesses';

  @override
  String get wizPart5 => 'Part 5: Personality and Behavior';

  @override
  String get wizPart6 => 'Part 6: Ancestry and Family';

  @override
  String get wizPart7 => 'Part 7: Death';

  @override
  String get wizErrChooseClan => 'Choose a clan (Question 1).';

  @override
  String get wizErrChooseFamily => 'Choose a family (Question 2).';

  @override
  String get wizErrChooseFamilyRing => 'Choose your family ring increase.';

  @override
  String get wizErrChooseRegion => 'Choose a region (Question 1).';

  @override
  String get wizErrChooseUpbringing => 'Choose an upbringing (Question 2).';

  @override
  String get wizErrChooseUpbringingRing =>
      'Choose your upbringing ring increase.';

  @override
  String wizErrChooseUpbringingSkill(int n) {
    return 'Choose upbringing skill $n.';
  }

  @override
  String get wizErrChooseSchool => 'Choose a school.';

  @override
  String get wizErrInsufficientSkills => 'Insufficient skills selected.';

  @override
  String get wizErrSchoolRings => 'Choose your school ring increases.';

  @override
  String get wizErrStandoutRing => 'Choose your standout ring.';

  @override
  String get wizErrStartingTechniques => 'Choose your starting techniques.';

  @override
  String get wizErrQ7Option => 'Choose an option for Question 7.';

  @override
  String get wizErrQ7Skill => 'Choose a skill for Question 7.';

  @override
  String get wizErrQ8Option => 'Choose an option for Question 8.';

  @override
  String get wizErrQ8Skill => 'Choose a skill for Question 8.';

  @override
  String get wizErrQ8Item => 'Choose an item for Question 8.';

  @override
  String get wizErrDistinction => 'Choose a distinction (Question 9).';

  @override
  String get wizErrAdversity => 'Choose an adversity (Question 10).';

  @override
  String get wizErrPassion => 'Choose a passion (Question 11).';

  @override
  String get wizErrAnxiety => 'Choose an anxiety (Question 12).';

  @override
  String get wizErrQ13Option => 'Choose an option for Question 13.';

  @override
  String get wizErrQ13Advantage => 'Choose an advantage for Question 13.';

  @override
  String get wizErrQ13DisadvSkill =>
      'Choose a disadvantage and skill for Question 13.';

  @override
  String get wizErrQ16Item => 'Choose a memento item for Question 16.';

  @override
  String get wizErrReplacementRings => 'Please select replacement ring(s).';

  @override
  String get wizErrReplacementSkills => 'Please select replacement skill(s).';

  @override
  String get wizDiscardTitle => 'Discard this character?';

  @override
  String get wizDiscardBody => 'Your answers so far will be lost.';

  @override
  String get wizSummaryTooltip => 'Rings & skills so far';

  @override
  String get wizNoSkillsYet => 'No skills yet.';

  @override
  String wizStepOf(int page, int total) {
    return 'Step $page of $total';
  }

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get characterTypeLabel => 'Character type';

  @override
  String get wizQ1Clan => '1. What clan does your character belong to?';

  @override
  String get clanLabel => 'Clan';

  @override
  String clanStatsLine(
    String ring,
    String skill,
    int status,
    String reference,
  ) {
    return '+1 $ring · +1 $skill · Status $status · $reference';
  }

  @override
  String get wizQ2Family => '2. What family does your character belong to?';

  @override
  String familyStatsLine(String skills, int glory, int wealth) {
    return '+1 $skills · Glory $glory · Wealth $wealth koku';
  }

  @override
  String get familyRingIncrease => 'Family ring increase';

  @override
  String get wizQ1Region => '1. Where does your character come from?';

  @override
  String get regionLabel => 'Region';

  @override
  String get wizQ2Upbringing => '2. What was your character\'s upbringing?';

  @override
  String get upbringingLabel => 'Upbringing';

  @override
  String get upbringingRingIncrease => 'Upbringing ring increase';

  @override
  String upbringingSkillN(int n) {
    return 'Upbringing skill $n';
  }

  @override
  String get wizQ3Samurai =>
      '3. What is your school, and what roles does that school fall into?';

  @override
  String get wizQ3Ronin =>
      '3. What is your school, and what are its associated roles?';

  @override
  String get showSchoolsOutsideClan => 'Show schools outside my clan';

  @override
  String get schoolLabel => 'School';

  @override
  String schoolStatsLine(String roles, int honor, String reference) {
    return '$roles · Honor $honor · $reference';
  }

  @override
  String get kitsuneImpersonate => 'School to impersonate (outfit source)';

  @override
  String get additionalBurden => 'Additional burden';

  @override
  String chooseSchoolSkills(int size, int chosen) {
    return 'Choose $size school skills ($chosen chosen)';
  }

  @override
  String get schoolRingIncreases => 'School ring increases';

  @override
  String fixedRings(String rings) {
    return 'Fixed: +1 $rings';
  }

  @override
  String get ringOfYourChoice => 'Ring of your choice';

  @override
  String get wizQ4Samurai =>
      '4. How do you stand out within your school? (+1 ring)';

  @override
  String get wizQ4Ronin => '4. What gets you in and out of trouble? (+1 ring)';

  @override
  String get standoutRing => 'Standout ring';

  @override
  String get describeIt => 'Describe it';

  @override
  String startingTechniqueFixed(String name) {
    return 'Starting technique: $name';
  }

  @override
  String get chooseStartingTechnique => 'Choose a starting technique';

  @override
  String get startingOutfit => 'Starting outfit';

  @override
  String get chooseAnItem => 'Choose an item';

  @override
  String includedItems(String items) {
    return 'Included: $items';
  }

  @override
  String get wizQ5Samurai =>
      '5. Who is your lord, and what is your duty to them? (Giri)';

  @override
  String get wizQ5Ronin => '5. What is your past, and how does it affect you?';

  @override
  String get answerLabel => 'Answer';

  @override
  String get wizQ6Samurai =>
      '6. What do you long for, and how might this impede your duty? (Ninjō)';

  @override
  String get wizQ6Ronin =>
      '6. What do you long for, and how might your past impact your Ninjō?';

  @override
  String get wizQ7Samurai => '7. What is your relationship with your clan?';

  @override
  String get wizQ7Ronin => '7. What are you known for?';

  @override
  String get q7Positive => 'Positive (+5 Glory)';

  @override
  String get q7Negative => 'Negative (+1 rank in a skill you do not have)';

  @override
  String get wizQ8 => '8. What do you think of Bushidō?';

  @override
  String get q8Pos => 'Staunch orthodox belief (+10 Honor)';

  @override
  String get q8Mid => 'Pragmatic survivor (one item of rarity 5 or lower)';

  @override
  String get q8Neg => 'Diverges from common beliefs (+1 skill rank)';

  @override
  String get itemLabel => 'Item';

  @override
  String get wizQ9 =>
      '9. What is your greatest accomplishment so far? (Distinction)';

  @override
  String get distinctionLabel => 'Distinction';

  @override
  String get wizQ10 => '10. What holds your character back? (Adversity)';

  @override
  String get adversityLabel => 'Adversity';

  @override
  String get wizQ11 => '11. What activity makes you feel at peace? (Passion)';

  @override
  String get passionLabel => 'Passion';

  @override
  String get wizQ12 =>
      '12. What concern or fear keeps you up at night? (Anxiety)';

  @override
  String get anxietyLabel => 'Anxiety';

  @override
  String get wizQ13 =>
      '13. Who is the person you trust most, and what is the nature of the relationship?';

  @override
  String get q13GainAdvantage => 'Gain an advantage';

  @override
  String get q13GainDisadvantage => 'Gain a disadvantage and +1 skill rank';

  @override
  String get advantageLabel => 'Advantage';

  @override
  String get disadvantageLabel => 'Disadvantage';

  @override
  String get describeRelationship => 'Describe the relationship';

  @override
  String get wizQ14Samurai =>
      '14. What do people notice first upon encountering you?';

  @override
  String get wizQ14Ronin =>
      '14. What is your character\'s most prized possession?';

  @override
  String get possessionRarity5 => 'Possession (rarity 5 or lower)';

  @override
  String get wizQ15 => '15. How do you react to stressful situations?';

  @override
  String get wizQ16Samurai =>
      '16. What are your preexisting relationships with other clans, families, organizations, and traditions?';

  @override
  String get wizQ16Ronin =>
      '16. What are your relationships to your family, the clans, peasants, and others?';

  @override
  String get mementoRarity7 => 'Memento item (rarity 7 or lower)';

  @override
  String get describeThem => 'Describe them';

  @override
  String get wizQ17Parents =>
      '17. How would your parents describe you? (+1 skill rank)';

  @override
  String get wizQ17Raised => '18. Who raised you? (+1 skill rank)';

  @override
  String get wizQ17Bond => '17. With whom do you share a bond?';

  @override
  String get bondLabel => 'Bond';

  @override
  String get wizQ18Ancestry =>
      '18. What is your duty to your family, and who among your ancestors do you exemplify?';

  @override
  String get heritageTable => 'Heritage table';

  @override
  String ancestorN(int n) {
    return 'Ancestor $n';
  }

  @override
  String get rollTooltip => 'Roll (1d10)';

  @override
  String heritageHeader(String name) {
    return 'Heritage: $name';
  }

  @override
  String grantedLabel(String name) {
    return 'Granted: $name';
  }

  @override
  String get bonusSkill => 'Bonus skill';

  @override
  String get traitGained => 'Trait gained';

  @override
  String get heirloomCategory => 'Heirloom category';

  @override
  String get lostHeirloomCategory => 'Lost heirloom category';

  @override
  String get techniqueGroupLabel => 'Technique group';

  @override
  String get effectLabel => 'Effect';

  @override
  String get giftLabel => 'Gift';

  @override
  String get ringToRaise => 'Ring to raise';

  @override
  String get ringToLower => 'Ring to lower';

  @override
  String get qualityYourChoice => 'Quality (your choice)';

  @override
  String get qualityGmChoice => 'Quality (GM\'s choice)';

  @override
  String get wizQ19 => '19. What is your name?';

  @override
  String get personalNameLabel => 'Personal name';

  @override
  String get wizQ20 => '20. How should your character die?';

  @override
  String get answerOptional => 'Answer (optional)';

  @override
  String ringOverflowMsg(int n) {
    return 'A ring exceeds the creation cap of 3. Choose $n replacement ring(s):';
  }

  @override
  String skillOverflowMsg(int n) {
    return 'A skill exceeds the creation cap of 3. Choose $n replacement skill(s):';
  }

  @override
  String replacementRingN(int n) {
    return 'Replacement ring $n';
  }

  @override
  String replacementSkillN(int n) {
    return 'Replacement skill $n';
  }

  @override
  String get readyHeader => 'Ready';

  @override
  String get finishCreates =>
      'Finish creates the character and opens the editor.';

  @override
  String get ok => 'OK';

  @override
  String get tapToTypeValue => 'Tap to type a value';

  @override
  String get unlockIdentityTooltip => 'Unlock name, family, ninjō, and giri';

  @override
  String get lockIdentityTooltip => 'Lock name, family, ninjō, and giri';

  @override
  String get changePortraitTooltip =>
      'Tap to change portrait, long-press to remove';

  @override
  String get addPortraitTooltip => 'Tap to add a portrait';

  @override
  String get pdfFatigueStrifeConditions => 'Fatigue, Strife & Conditions';

  @override
  String get pdfWealthProgress => 'Wealth & Progress';

  @override
  String pdfWealthLine(
    int koku,
    int bu,
    int zeni,
    int spent,
    int total,
    int inRank,
  ) {
    return 'Wealth: $koku koku, $bu bu, $zeni zeni    ·    XP: $spent spent / $total total    ·    XP in rank: $inRank';
  }

  @override
  String pdfTitlePart(String title, int xp) {
    return '    ·    Title: $title ($xp XP)';
  }

  @override
  String get pdfTraitsHeader => 'Distinctions & Adversities';

  @override
  String get sheetStyleTitle => 'Character sheet style';

  @override
  String get sheetStyleSubtitle =>
      'Layout used when printing or exporting the PDF sheet.';

  @override
  String get sheetStyleMinimalist => 'Minimalist';

  @override
  String get sheetStyleStructured => 'Structured';

  @override
  String pdfPageOf(int page, int total) {
    return 'Page $page / $total';
  }

  @override
  String get pdfVoidPoints => 'Void Points';

  @override
  String get pdfStancesHeader => 'Conflict Quick Reference: Stances';

  @override
  String get colStance => 'Stance';

  @override
  String get colEffect => 'Effect';

  @override
  String get pdfStanceAir =>
      'Attack and Scheme action checks targeting you increase their TN by 1.';

  @override
  String get pdfStanceEarth =>
      'Opponents cannot spend Opportunity on Attack and Scheme action checks targeting you to inflict critical strikes or conditions.';

  @override
  String get pdfStanceFire =>
      'When you succeed on a check, gain one additional bonus success.';

  @override
  String get pdfStanceWater =>
      'Once per turn, you may perform one additional Move or Support action that does not require a check.';

  @override
  String get pdfStanceVoid =>
      'You do not receive strife from strife symbols on your checks.';

  @override
  String get pdfOtherCategory => 'Other';

  @override
  String get pdfXpTotalLabel => 'XP Total';

  @override
  String pdfTitleBox(String title, int xp) {
    return 'Title: $title ($xp XP)';
  }

  @override
  String get colAbility => 'Ability';

  @override
  String get ninjoHeader => 'Ninjō';

  @override
  String get giriHeader => 'Giri';

  @override
  String get customSchools => 'Custom schools';

  @override
  String get customSchoolsSubtitle =>
      'Build your own school with the Path of Waves rules (p. 76) and manage homebrew schools.';

  @override
  String get homebrewFolderIos =>
      'The paperblossoms folder is visible in the Files app (On My iPhone/iPad). Drop JSON files named like the bundled data there; they merge on launch.';

  @override
  String get homebrewFolderAndroid =>
      'Homebrew is managed in-app on Android; use the school builder and its import/export.';

  @override
  String get sbStep1 => 'Step 1: School Role';

  @override
  String get sbStep2 => 'Step 2: Affiliation & Summary';

  @override
  String get sbStep3 => 'Step 3: School Ability';

  @override
  String get sbStep4 => 'Step 4: Ring Increases';

  @override
  String get sbStep5 => 'Step 5: Starting Skills';

  @override
  String get sbStep6 => 'Step 6: Techniques';

  @override
  String get sbStep7 => 'Step 7: Curriculum & Mastery';

  @override
  String get sbStep8 => 'Step 8: Starting Outfit';

  @override
  String get sbStep9 => 'Step 9: Name & Save';

  @override
  String get sbSaveSchool => 'Save school';

  @override
  String get sbSaveAnyway => 'Save';

  @override
  String get sbUnnamedSchool => '(unnamed school)';

  @override
  String get sbDiscardTitle => 'Discard this school?';

  @override
  String get sbDiscardBody => 'Your answers so far will be lost.';

  @override
  String get sbErrChooseRole => 'Choose at least one role.';

  @override
  String get sbErrAbilityName => 'Name the school ability.';

  @override
  String get sbErrRings => 'Choose both ring increases.';

  @override
  String get sbErrNoSkills => 'Choose at least one skill.';

  @override
  String sbErrSkillPicks(int picks) {
    return 'The school must offer at least as many skills as the $picks a player picks.';
  }

  @override
  String sbWarnSkillCount(int count) {
    return 'The book\'s recipe for this role is $count skills (Table 2–7).';
  }

  @override
  String get sbErrDirectiveAlone =>
      'A “Rarity … or Lower” choice must be the only option in its row, or character creation would silently skip it.';

  @override
  String get sbAffiliationNone => 'None (unaffiliated)';

  @override
  String get sbAffiliationCustom => 'Custom…';

  @override
  String get sbErrCategory => 'Open at least one technique category.';

  @override
  String get sbErrChoiceSet =>
      'Every choice row needs options, and at least as many options as picks.';

  @override
  String sbErrCurriculumIncomplete(int rank) {
    return 'Fill every advance in ranks 1–5 (rank $rank has empty slots).';
  }

  @override
  String get sbErrMasteryName => 'Name the mastery ability.';

  @override
  String get sbErrName => 'Name the school.';

  @override
  String get sbOverrideBundledTitle => 'Override official school?';

  @override
  String sbOverrideBundledBody(String name) {
    return '“$name” matches an official school; your homebrew version will replace it until deleted.';
  }

  @override
  String get sbOverwriteHomebrewTitle => 'Overwrite homebrew school?';

  @override
  String sbOverwriteHomebrewBody(String name) {
    return 'A homebrew school named “$name” already exists.';
  }

  @override
  String get sbRolesQuestion => 'Which role or roles does the school embody?';

  @override
  String get sbRolesHelp =>
      'Choose one or two roles (up to three for a complex school). The primary role drives the suggested tables that prefill later steps.';

  @override
  String get sbWarnThreeRoles => 'The book recommends at most two roles.';

  @override
  String get sbRolesOrder => 'Role order';

  @override
  String get sbPrimaryRole => 'Primary role';

  @override
  String get sbMakePrimary => 'Make primary';

  @override
  String get sbAffiliationQuestion =>
      'Which clan or faction is the school associated with?';

  @override
  String get sbCustomAffiliationLabel => 'Custom affiliation';

  @override
  String get sbNoteRonin =>
      'A Rōnin school appears for rōnin and peasant characters in the New Character wizard.';

  @override
  String get sbNoteNoAffiliation =>
      'An unaffiliated school is only reachable via the “any school” checkbox in the New Character wizard.';

  @override
  String get sbNoteCustomAffiliation =>
      'A custom faction matches no clan or region, so the school is only reachable via the “any school” checkbox in the New Character wizard.';

  @override
  String get sbSummaryHeader => 'School summary';

  @override
  String get sbSummaryLabel => 'Summary (the book asks for 3–5 sentences)';

  @override
  String get sbSummaryShortLabel =>
      'One-line summary (shown under the school in dropdowns)';

  @override
  String get sbWarnNoSummary =>
      'No summary yet — the book asks for a 3–5 sentence selling point.';

  @override
  String get sbAbilityQuestion => 'What is the school ability?';

  @override
  String get sbAbilityHelp =>
      'The ability must scale with school rank. Start from a generic template (Table 2–4) or invent your own; the rules text is stored as your own description, like the descriptions editor.';

  @override
  String get sbAbilityTemplate => 'Start from a template (Table 2–4)';

  @override
  String sbSeeBook(String page) {
    return 'Template text from Path of Waves p. $page filled in below — edit freely.';
  }

  @override
  String get sbAbilityName => 'School ability name';

  @override
  String get sbAbilityText => 'School ability rules text';

  @override
  String get sbWarnNoAbilityText =>
      'No rules text entered; you can add it later in the descriptions editor.';

  @override
  String get sbShortDescLabel => 'Short description (one line)';

  @override
  String get sbRingsQuestion => 'Which two rings does the school increase?';

  @override
  String sbHintFirstRing(String role, String rings) {
    return '$role schools usually take their first increase in $rings (Table 2–5).';
  }

  @override
  String get sbHintShugenjaRing =>
      'Shugenja schools usually raise the element the school is attuned to (Table 2–5).';

  @override
  String get sbRing1 => 'First ring increase';

  @override
  String get sbRing2 => 'Second ring increase';

  @override
  String get sbWarnDoubledRing =>
      'Both increases on one ring is rare but legal (the Isawa Tensai schools do it).';

  @override
  String sbWarnRingsSuggestion(String role) {
    return 'This differs from the book\'s suggestion for a $role school. That\'s allowed — many schools break the mold.';
  }

  @override
  String get sbSecondRingHintsTitle =>
      'Second ring by what the school is known for (Table 2–6)';

  @override
  String get sbRingTraitAir => 'Precision, grace, or manners';

  @override
  String get sbRingTraitEarth => 'Patience, tradition, or resilience';

  @override
  String get sbRingTraitFire => 'Inventiveness, ferocity, or speed';

  @override
  String get sbRingTraitVoid => 'Philosophy, selflessness, or insight';

  @override
  String get sbRingTraitWater => 'Adaptability, flexibility, or awareness';

  @override
  String sbSkillsQuestion(int count) {
    return 'Choose the $count skills the school offers';
  }

  @override
  String sbSkillsProgress(int selected, int count, int picks) {
    return '$selected of $count selected — players will pick $picks of them at character creation (Table 2–7).';
  }

  @override
  String get sbAccessQuestion => 'Open technique access';

  @override
  String get sbAccessHelp =>
      'Most schools have Rituals plus two of Kata, Kihō, Invocations, and Shūji. Expand a category to grant only some of its subcategories instead (limited access).';

  @override
  String get sbWarnForbidden =>
      'Ninjutsu and mahō are forbidden arts — the book grants them only in unique cases.';

  @override
  String get sbWarnManyCategories =>
      'Typical schools open Rituals plus two other categories.';

  @override
  String get sbWarnShugenjaInvocations =>
      'Shugenja schools normally have open access to Invocations.';

  @override
  String get sbStartingTechniques => 'Starting techniques';

  @override
  String sbStartingTechniquesHelp(int count, String role) {
    return 'A $role school grants $count starting techniques (Table 2–8). Each row can offer a choice, like “1 of these 2 kata”.';
  }

  @override
  String get sbShowAllTechniques =>
      'Show all techniques (not just rank 1 within access)';

  @override
  String get sbAddRow => 'Add row';

  @override
  String get sbWarnCommune =>
      'Shugenja schools start with Commune with the Spirits (Table 2–8).';

  @override
  String sbWarnStartingTechRank(String name) {
    return '$name is above rank 1 or outside the school\'s open access — fine if intended (the book allows it).';
  }

  @override
  String get sbSlotSkillGroup => 'Skill group';

  @override
  String get sbSlotSkill => 'Skill';

  @override
  String get sbSlotTechniqueGroup => 'Technique group';

  @override
  String get sbSlotTechnique => 'Technique';

  @override
  String get sbChooseTechnique => 'Choose technique…';

  @override
  String sbCopyPrevRank(int rank) {
    return 'Copy from rank $rank';
  }

  @override
  String get sbClearRank => 'Clear rank';

  @override
  String get sbMaxTechRank => 'Max technique rank:';

  @override
  String get sbMaxTechRankDefault => 'Up to school rank';

  @override
  String get sbSpecialAccessChip => 'Special access';

  @override
  String get sbSpecialAccessWhy =>
      'Students may take this even though it is above the curriculum rank or outside the school\'s open access. Derived automatically.';

  @override
  String get sbWarnSkillInGroup =>
      'This skill is already covered by this rank\'s skill group — the book suggests picking skills from outside it.';

  @override
  String get sbWarnRankShape =>
      'This rank deviates from the book\'s shape (1 skill group, 3 skills, 1 technique group, 2 techniques). Allowed, but the book says to use it sparingly.';

  @override
  String get sbMastery => 'Mastery';

  @override
  String get sbMasteryQuestion => 'What is the mastery ability?';

  @override
  String get sbMasteryHelp =>
      'Rank 6 contains only the mastery ability — something powerful and awe-inspiring. Use a template (Table 2–10) or invent one; purely narrative abilities work best limited to once per session.';

  @override
  String get sbMasteryTemplate => 'Start from a template (Table 2–10)';

  @override
  String get sbMasteryName => 'Mastery ability name';

  @override
  String get sbMasteryText => 'Mastery ability rules text';

  @override
  String get sbOutfitQuestion => 'Starting outfit';

  @override
  String get sbOutfitHelp =>
      'Table 2–11 suggests an outfit for the primary role; it is prefilled here and freely editable. Rows like “One Weapon of Rarity 6 or Lower” become pickers at character creation.';

  @override
  String get sbWarnNoOutfit =>
      'No outfit rows — characters from this school will start with no equipment.';

  @override
  String get sbNameQuestion => 'Name the school';

  @override
  String get sbNameLabel => 'School name';

  @override
  String get sbHonorLabel =>
      'Starting honor (suggested for the role; the book doesn\'t chart honor)';

  @override
  String get sbRefBookLabel => 'Reference book';

  @override
  String get sbRefPageLabel => 'Reference page';

  @override
  String get sbReviewTitle => 'Review';

  @override
  String get sbReviewRoles => 'Roles';

  @override
  String get sbReviewRings => 'Rings';

  @override
  String get sbReviewSkills => 'Skills / picks';

  @override
  String get sbReviewAccess => 'Technique access';

  @override
  String get sbReviewCurriculum => 'Curriculum advances';

  @override
  String sbChooseOf(int size) {
    return 'Choose $size of:';
  }

  @override
  String get sbAddOption => 'Add option';

  @override
  String get sbRemoveRow => 'Remove row';

  @override
  String get sbBuildNew => 'Build a new school';

  @override
  String get sbBuildNewSubtitle =>
      'A nine-step wizard following Path of Waves pp. 76–84.';

  @override
  String get sbEmptyHint =>
      'No homebrew schools yet.\nBuild one, or drop a schools.json in the homebrew folder.';

  @override
  String sbSavedSnack(String name) {
    return 'Saved “$name” to homebrew/schools.json — it now appears in the New Character wizard.';
  }

  @override
  String sbDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get sbDeleteBody =>
      'Existing characters keep the school by name but lose its curriculum and abilities.';

  @override
  String get sbDeleteAlsoText =>
      'Also remove its rules text (summary, school ability, mastery ability)';

  @override
  String get sbDeleteAll => 'Remove all homebrew schools';

  @override
  String get sbDeleteAllBody =>
      'This deletes every school in homebrew/schools.json.';

  @override
  String get sbImportSchools => 'Import schools…';

  @override
  String get sbExportSchools => 'Export schools…';

  @override
  String sbImportedSchools(int count) {
    return '$count schools imported';
  }

  @override
  String sbExportedSchools(int count) {
    return '$count schools exported';
  }

  @override
  String get sbNoSchoolsToExport => 'No homebrew schools to export.';

  @override
  String get sbCouldNotReadSchoolsFile =>
      'That file could not be read as a schools JSON array.';
}
