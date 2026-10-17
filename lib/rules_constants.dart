// Canonical rule strings used as logic keys. These must match the bundled
// game data exactly (including diacritics); game_data_validation_test.dart
// asserts each exists in the loaded data.

// Rings.
const ringAir = 'Air';
const ringEarth = 'Earth';
const ringFire = 'Fire';
const ringWater = 'Water';
const ringVoid = 'Void';
// Hero's Death (Legacies of War p. 8) takes its ring from the chosen tenet;
// the data carries this placeholder, the custom builder offers it too.
const ringVarious = 'Various';

// Advance types (first column of the original pipe-delimited advance rows).
const advanceTypeSkill = 'Skill';
const advanceTypeRing = 'Ring';
const advanceTypeTechnique = 'Technique';
// An XP-priced advantage (Student of Akodo, BotL p. 9) recorded when the
// trait is added in play, on the Curriculum or Title track the player picks;
// no curriculum lists it, so the rank/title math gives it half credit.
const advanceTypeAdvantage = 'Advantage';

// Advance tracks. Anything else in the track slot is a free-advance reason.
const trackCurriculum = 'Curriculum';
const trackTitle = 'Title';

// Curriculum/title advancement entry types (game data `type` fields).
const entryTypeSkill = 'skill';
const entryTypeSkillGroup = 'skill_group';
const entryTypeTechnique = 'technique';
const entryTypeTechniqueGroup = 'technique_group';
const entryTypeRing = 'ring';

// Technique categories every character may always learn from.
const universalTechniqueCategories = {
  'Mahō',
  'Item Patterns',
  'Signature Scrolls',
};

// The Astradhari title grants access to this category.
const categoryAstradhari = 'Astradhari Techniques';
const titleAstradhari = 'Astradhari';

// The only technique that may be purchased more than once.
const repeatableTechnique = 'Summoning Mantra: [Implement Name]';

// Titles that grant an advantage/disadvantage when taken.
const titleTheDamned = 'The Damned';
const titleTheDamnedGrant = 'Ferocity';
const titleMoonCultist = 'Moon Cultist';
const titleMoonCultistGrant = 'Dark Secret';
const titleGrants = {
  titleTheDamned: titleTheDamnedGrant,
  titleMoonCultist: titleMoonCultistGrant,
  'Covert Agent': 'Dark Secret',
  'Dreaded Enforcer': 'Whispers of Cruelty',
};

// School ability granting bonus curriculum skill picks equal to school rank
// (Worldly Rōnin Path, core p.87). The rank-6 cap on those skills comes from
// its mastery ability, A Bottomless Ocean.
const schoolAbilityWaves = 'School of Waves';

// Curriculum XP needed to advance out of each school rank (core book p.98).
const rankXpThresholds = [20, 24, 32, 44, 60];

// Character types chosen on wizard page 1.
const characterTypeSamurai = 'Samurai';
const characterTypeRonin = 'Rōnin';
const characterTypeGaijin = 'Gaijin';

// Advantage/disadvantage category and the type tag marking the permanent
// injuries a critical strike assigns (core p.270, Table 6-6, severity 7-11).
const categoryAdversities = 'Adversities';
const typeScar = 'Scar';

// Legacies (Legacies of War pp. 5-12): a fifth advantage category, taken in
// place of the Q18 heritage roll and never offered as a Q9/Q13 pick.
const categoryLegacies = 'Legacies';
// Reference stamped on custom Legacy templates (the custom-template rules).
const customLegacyRefBook = 'LoW';
const customLegacyRefPage = '12';

// Backwards compatibility for upstream names corrected here
// (docs/UPSTREAM_NOTES.md #82). Applied on parse so homebrew files, a
// re-synced upstream copy, and saved characters keep resolving.
const bookCodeAliases = {'Legacies of War': 'LoW'};
const familyRenames = {'Foreheshu': 'Fureheshu'};

// Item types.
const itemTypeWeapon = 'Weapon';
const itemTypeArmor = 'Armor';
const itemTypePersonalEffect = 'Personal Effect';
