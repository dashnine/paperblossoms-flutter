// Canonical rule strings used as logic keys. These must match the bundled
// game data exactly (including diacritics); game_data_validation_test.dart
// asserts each exists in the loaded data.

// Rings.
const ringAir = 'Air';
const ringEarth = 'Earth';
const ringFire = 'Fire';
const ringWater = 'Water';
const ringVoid = 'Void';

// Advance types (first column of the original pipe-delimited advance rows).
const advanceTypeSkill = 'Skill';
const advanceTypeRing = 'Ring';
const advanceTypeTechnique = 'Technique';

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

// Curriculum XP needed to advance out of each school rank (core book p.98).
const rankXpThresholds = [20, 24, 32, 44, 60];

// Character types chosen on wizard page 1.
const characterTypeSamurai = 'Samurai';
const characterTypeRonin = 'Rōnin';
const characterTypeGaijin = 'Gaijin';

// Item types.
const itemTypeWeapon = 'Weapon';
const itemTypeArmor = 'Armor';
const itemTypePersonalEffect = 'Personal Effect';
