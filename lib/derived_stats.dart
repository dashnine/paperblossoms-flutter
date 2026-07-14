// Pure rules functions over (Character, GameData), ported from the original
// app: mainwindow.cpp populateUI()/recalcTitle(), tabs/advancementpage.cpp
// recalcRank()/isInCurriculum()/isInTitle(), and dialog/addadvancedialog.cpp.
// Kept UI-free so they are unit-testable against the Qt app's numbers.

import 'character.dart';
import 'game_data.dart';
import 'game_data_models.dart';
import 'rules_constants.dart';

class RankResult {
  final int rank;
  final int curriculumXP; // XP accumulated within the current rank

  const RankResult(this.rank, this.curriculumXP);
}

class TitleResult {
  final String currentTitle; // '' when no title is in progress
  final int titleXP;

  const TitleResult(this.currentTitle, this.titleXP);
}

/// Effective skill ranks: creation-time base + one per skill advance.
Map<String, int> effectiveSkillRanks(Character c) {
  final ranks = {for (final skill in gameData.allSkills()) skill: 0};
  ranks.addAll(c.baseSkills);
  for (final advance in c.advanceStack) {
    if (advance.isSkill) {
      ranks[advance.name] = (ranks[advance.name] ?? 0) + 1;
    }
  }
  return ranks;
}

/// Effective ring ranks: creation-time base + one per ring advance.
Map<String, int> effectiveRingRanks(Character c) {
  final ranks = {for (final ring in gameData.ringNames()) ring: 0};
  ranks.addAll(c.baseRings);
  for (final advance in c.advanceStack) {
    if (advance.isRing) {
      ranks[advance.name] = (ranks[advance.name] ?? 0) + 1;
    }
  }
  return ranks;
}

int endurance(Map<String, int> rings) =>
    ((rings[ringEarth] ?? 0) + (rings[ringFire] ?? 0)) * 2;

int composure(Map<String, int> rings) =>
    ((rings[ringEarth] ?? 0) + (rings[ringWater] ?? 0)) * 2;

int focus(Map<String, int> rings) =>
    (rings[ringFire] ?? 0) + (rings[ringAir] ?? 0);

int vigilance(Map<String, int> rings) =>
    (((rings[ringWater] ?? 0) + (rings[ringAir] ?? 0)) / 2.0).round();

/// Core p.268: after suffering fatigue, a character whose fatigue exceeds
/// their endurance suffers the Incapacitated condition; it is removed when
/// fatigue drops back to endurance or lower.
bool isIncapacitated(Character c, Map<String, int> rings) =>
    c.fatigue > endurance(rings);

/// Core p.272: a character whose strife exceeds their composure is
/// Compromised; the condition is removed when strife is reduced to their
/// composure or lower (e.g. by unmasking).
bool isCompromised(Character c, Map<String, int> rings) =>
    c.strife > composure(rings);

// ---- Critical strikes (core p.270, Table 6-6) ----

/// Conditions a player tracks by hand (core p.271-273). Compromised and
/// Incapacitated are excluded: they are derived from strife/fatigue above.
/// Dying takes a round count; the Wounded pair takes the affected ring.
const trackableConditions = [
  'Afflicted',
  'Bleeding',
  'Burning',
  'Dazed',
  'Disoriented',
  'Dying',
  'Enraged',
  'Exhausted',
  'Immobilized',
  'Intoxicated',
  'Lightly Wounded',
  'Prone',
  'Severely Wounded',
  'Silenced',
  'Unconscious',
];

const conditionBleeding = 'Bleeding';
const conditionDying = 'Dying';
const conditionLightlyWounded = 'Lightly Wounded';
const conditionSeverelyWounded = 'Severely Wounded';

/// One-line paraphrased effect per condition (core p.271-273), keyed by the
/// base name without the ring/rounds qualifier.
const conditionSummaries = {
  'Afflicted': 'Haunted by a malevolent spirit: vigilance counts as 1, the '
      'GM may corrupt one kept die, and being Compromised triggers worse.',
  'Bleeding': 'Suffer unreducible damage equal to strife symbols on kept '
      'dice; removed by a TN 2 Medicine (Earth) Support action.',
  'Burning': 'After each action, suffer 3 strife and 3 unreducible damage '
      '(crit severity 5); smothered with TN 2 Fitness (Water).',
  'Dazed': '+2 TN on Attack and Scheme checks; ends after a turn without '
      'either action.',
  'Disoriented': '+2 TN on Movement and Support checks; ends after a turn '
      'without either action.',
  'Dying': 'Perish once the allotted rounds pass unless removed by a TN 4 '
      'Medicine (Air) Support action.',
  'Enraged': 'Critical strikes by and against the character gain +2 '
      'severity; TN 3 Meditation (Void) or scene end removes.',
  'Exhausted': 'No end-of-scene fatigue/strife recovery; removed by six or '
      'more hours of sleep.',
  'Immobilized': 'No Movement actions or stance changes; ends after a turn '
      'without a Movement action.',
  'Intoxicated': 'All strife suffered and removed is doubled; sober up at '
      'scene end with TN 3 Fitness (Water).',
  'Lightly Wounded': '+1 TN on checks with the affected ring; wounded '
      'lightly again on that ring becomes Severely Wounded.',
  'Prone': 'Move at most 1 range band; harder to hit at range; may stand '
      'after a turn without a Movement action.',
  'Severely Wounded': '+3 TN on checks with the affected ring; wounded '
      'again on that ring inflicts a severity-8 Permanent Injury.',
  'Silenced': '+3 TN on Scheme checks and checks to activate invocations, '
      'mahō, and shūji.',
  'Unconscious': 'Cannot act or defend; critical strikes suffered gain +10 '
      'severity; spend 1 Void point to awaken.',
};

/// Core p.270: on a successful TN 1 Fitness check the victim reduces the
/// severity by 1 plus bonus successes, to a minimum of 0.
int mitigatedSeverity(int severity, bool checkSucceeded, int bonusSuccesses) =>
    checkSucceeded ? (severity - 1 - bonusSuccesses).clamp(0, severity) : severity;

/// One row of Table 6-6: Results of Critical Strikes by Severity.
class CritBand {
  final String name;
  final String effect; // the row's mechanical effect, summarized

  /// '' | Lightly Wounded | Severely Wounded, suffered for the resist ring.
  final String woundCondition;
  final bool bleeding; // Bleeding inflicted outright
  final bool bleedingIfRazorEdged; // Bleeding only from Razor-Edged attacks
  final bool scar; // choose a scar adversity for the resist ring
  final int dyingRounds; // 0 when the row does not inflict Dying
  final bool fatal;

  const CritBand({
    required this.name,
    required this.effect,
    this.woundCondition = '',
    this.bleeding = false,
    this.bleedingIfRazorEdged = false,
    this.scar = false,
    this.dyingRounds = 0,
    this.fatal = false,
  });
}

/// Table 6-6 row for a final (post-mitigation) severity.
CritBand critBand(int severity) {
  if (severity <= 2) {
    return const CritBand(
      name: 'Close Call',
      effect: 'No blood drawn. If the character is wearing armor, '
          'the armor gains the Damaged quality.',
    );
  }
  if (severity <= 4) {
    return const CritBand(
      name: 'Flesh Wound',
      effect: 'Lightly Wounded for the ring used to resist; '
          'Bleeding as well if the attack was Razor-Edged.',
      woundCondition: conditionLightlyWounded,
      bleedingIfRazorEdged: true,
    );
  }
  if (severity <= 6) {
    return const CritBand(
      name: 'Debilitating Gash',
      effect: 'Severely Wounded for the ring used to resist; '
          'Bleeding as well if the attack was Razor-Edged.',
      woundCondition: conditionSeverelyWounded,
      bleedingIfRazorEdged: true,
    );
  }
  if (severity <= 8) {
    return const CritBand(
      name: 'Permanent Injury',
      effect: 'Bleeding, then choose one scar for the ring used to resist: '
          'Air (Maimed Visage or Nerve Damage), Earth (Damaged Organ or '
          'Fractured Spine), Fire (Lost Fingers or Maimed Arm), '
          'Water (Lost Eye or Lost Foot), Void (Lost Memories).',
      bleeding: true,
      scar: true,
    );
  }
  if (severity <= 11) {
    return const CritBand(
      name: 'Maiming Blow',
      effect: 'Bleeding, then choose one scar for the ring used to resist: '
          'Air (Deafness or Muteness), Earth (Damaged Heart or Damaged '
          'Organ), Fire (Lost Arm or Lost Hand), Water (Blindness or '
          'Lost Leg), Void (Cognitive Lapses).',
      bleeding: true,
      scar: true,
    );
  }
  if (severity <= 13) {
    return const CritBand(
      name: 'Agonizing Death',
      effect: 'Severely Wounded for the ring used to resist, '
          'plus Bleeding and Dying (3 rounds).',
      woundCondition: conditionSeverelyWounded,
      bleeding: true,
      dyingRounds: 3,
    );
  }
  if (severity <= 15) {
    return const CritBand(
      name: 'Swift Death',
      effect: 'Severely Wounded for the ring used to resist, '
          'plus Bleeding and Dying (1 round).',
      woundCondition: conditionSeverelyWounded,
      bleeding: true,
      dyingRounds: 1,
    );
  }
  return const CritBand(
    name: 'Instant Death',
    effect: 'The character dies immediately.',
    fatal: true,
  );
}

/// Adds a resolved condition string to [c] without notifying, applying the
/// wounded-escalation rule (core p.273): suffering Lightly Wounded again for
/// the same ring upgrades it to Severely Wounded, and a wound never
/// downgrades one already Severely Wounded (the book's follow-on severity-8
/// critical strike in that case is left to the table). Exact duplicates of
/// other conditions are dropped. Returns true if anything changed.
bool addCondition(Character c, String condition) {
  if (condition.startsWith(conditionLightlyWounded)) {
    final severe = condition.replaceFirst(
        conditionLightlyWounded, conditionSeverelyWounded);
    if (c.conditions.contains(severe)) return false;
    if (c.conditions.remove(condition)) {
      c.conditions.add(severe);
      return true;
    }
  }
  if (c.conditions.contains(condition)) return false;
  c.conditions.add(condition);
  return true;
}

/// The condition strings a Table 6-6 row adds to the character, with the
/// resist ring and Dying rounds resolved into the stored display form.
List<String> critConditions(CritBand band, String resistRing,
    {required bool razorEdged}) {
  return [
    if (band.woundCondition.isNotEmpty)
      '${band.woundCondition} ($resistRing)',
    if (band.bleeding || (band.bleedingIfRazorEdged && razorEdged))
      conditionBleeding,
    if (band.dyingRounds == 1) '$conditionDying (1 round)',
    if (band.dyingRounds > 1) '$conditionDying (${band.dyingRounds} rounds)',
  ];
}

int xpSpent(Character c) =>
    c.advanceStack.fold(0, (sum, advance) => sum + advance.cost);

/// All technique names the character knows: creation-time techniques plus
/// purchased technique advances, in that order.
List<String> knownTechniques(Character c) => [
      ...c.techniques,
      for (final advance in c.advanceStack)
        if (advance.isTechnique) advance.name,
    ];

// ---- XP costs (addadvancedialog.cpp on_advchooser_combobox_...) ----

int skillAdvanceCost(int currentRank) => (currentRank + 1) * 2;

int ringAdvanceCost(int currentRank) => (currentRank + 1) * 3;

int halfCost(int cost) => (cost / 2.0).round();

// ---- Curriculum / title membership ----

/// Whether an advance of [advType] (Skill/Technique) named [value] is in the
/// school curriculum at [curriculumRank]. Port of MainWindow::isInCurriculum:
/// group entries expand, technique groups bounded by allowable_rank
/// (defaulting to 1..[curriculumRank]). Note the entry `type` label decides
/// the namespace exactly as in the original — mislabeled upstream entries
/// (e.g. a technique typed "skill") never match there either.
bool isInCurriculum(
    String value, String advType, String school, int curriculumRank) {
  final curriculum = gameData.schoolByName(school)?.curriculum ?? [];
  final skills = <String>{};
  final techniques = <String>{};
  for (final entry in curriculum) {
    if (entry.rank != curriculumRank) continue;
    final minRank = entry.minAllowableRank > 0 ? entry.minAllowableRank : 1;
    final maxRank =
        entry.maxAllowableRank > 0 ? entry.maxAllowableRank : curriculumRank;
    switch (entry.type) {
      case entryTypeSkillGroup:
        skills.addAll(gameData.skillsByGroup(entry.advance));
      case entryTypeSkill:
        skills.add(entry.advance);
      case entryTypeTechnique:
        techniques.add(entry.advance);
      case entryTypeTechniqueGroup:
        techniques.addAll([
          for (final t in gameData.techniquesByGroup(entry.advance,
              minRank: minRank, maxRank: maxRank))
            t.name
        ]);
    }
  }
  if (advType == advanceTypeSkill) return skills.contains(value);
  if (advType == advanceTypeTechnique) return techniques.contains(value);
  return false;
}

/// Whether an advance is in [title]'s advancement track. Port of
/// MainWindow::isInTitle; technique groups are bounded by the row's own rank.
bool isInTitle(String value, String advType, String title) {
  final advancements = gameData.titleByName(title)?.advancements ?? [];
  final skills = <String>{};
  final techniques = <String>{};
  final rings = <String>{};
  for (final entry in advancements) {
    final maxRank = entry.rank;
    switch (entry.type) {
      case entryTypeSkillGroup:
        skills.addAll(gameData.skillsByGroup(entry.name));
      case entryTypeSkill:
        skills.add(entry.name);
      case entryTypeTechnique:
        techniques.add(entry.name);
      case entryTypeTechniqueGroup:
        techniques.addAll([
          for (final t in gameData.techniquesByGroup(entry.name,
              minRank: 1, maxRank: maxRank > 0 ? maxRank : 5))
            t.name
        ]);
      case entryTypeRing:
        rings.add(entry.name);
    }
  }
  if (advType == advanceTypeSkill) return skills.contains(value);
  if (advType == advanceTypeTechnique) return techniques.contains(value);
  if (advType == advanceTypeRing) return rings.contains(value);
  return false;
}

/// School rank and XP within it. Port of MainWindow::recalcRank: walk the
/// advance stack in purchase order; Curriculum-track advances earn full cost
/// when in-curriculum at the rank in effect at that point of the walk, else
/// half (rounded); rank-up thresholds per the core book chart, resetting the
/// in-rank XP each rank-up.
RankResult recalcRank(Character c) {
  var curricXP = 0;
  var rank = 1;
  for (final advance in c.advanceStack) {
    if (advance.onCurriculumTrack) {
      if (isInCurriculum(advance.name, advance.type, c.school, rank)) {
        curricXP += advance.cost;
      } else {
        curricXP += halfCost(advance.cost);
      }
    }
    if (rank <= rankXpThresholds.length &&
        curricXP >= rankXpThresholds[rank - 1]) {
      rank++;
      curricXP = 0;
    }
  }
  return RankResult(rank, curricXP);
}

/// The title currently in progress and XP toward it. Port of
/// MainWindow::recalcTitle: titles complete strictly in the order taken;
/// Title-track advances earn full cost when in the current title's track,
/// else half.
TitleResult recalcTitle(Character c) {
  if (c.titles.isEmpty) return const TitleResult('', 0);
  final xpToComplete = [
    for (final title in c.titles)
      gameData.titleByName(title)?.xpToCompletion ?? 0
  ];
  var titleXP = 0;
  var titleIndex = 0;
  var currentTitle = c.titles.first;
  for (final advance in c.advanceStack) {
    if (advance.onTitleTrack) {
      if (isInTitle(advance.name, advance.type, currentTitle)) {
        titleXP += advance.cost;
      } else {
        titleXP += halfCost(advance.cost);
      }
    }
    if (titleIndex + 1 > xpToComplete.length) continue;
    if (titleXP >= xpToComplete[titleIndex]) {
      titleIndex++;
      titleXP = 0;
      currentTitle =
          titleIndex < c.titles.length ? c.titles[titleIndex] : '';
    }
  }
  return TitleResult(currentTitle, titleXP);
}

/// Ability names in effect: school ability, mastery ability above rank 5,
/// abilities of completed titles, and bond abilities.
List<String> abilities(Character c, int rank, String currentTitle) {
  final school = gameData.schoolByName(c.school);
  return [
    if (school != null && school.schoolAbility.isNotEmpty)
      school.schoolAbility,
    if (school != null && rank > 5 && school.masteryAbility.isNotEmpty)
      school.masteryAbility,
    for (final title in c.titles)
      if (title != currentTitle &&
          (gameData.titleByName(title)?.titleAbility ?? '').isNotEmpty)
        gameData.titleByName(title)!.titleAbility,
    for (final bond in c.bonds)
      if ((gameData.bondByName(bond.name)?.ability ?? '').isNotEmpty)
        gameData.bondByName(bond.name)!.ability,
  ];
}

// ---- Advance legality (addadvancedialog.cpp) ----

/// Skills purchasable as advances: everything below effective rank 5.
List<String> purchasableSkills(Character c) {
  final ranks = effectiveSkillRanks(c);
  return [
    for (final skill in gameData.allSkills())
      if ((ranks[skill] ?? 0) < 5) skill
  ];
}

/// Rings purchasable as advances. The cap is min(5, lowest non-Void ring +
/// Void ring) applied per ring.
List<String> purchasableRings(Character c) {
  final ranks = effectiveRingRanks(c);
  var lowest = 99;
  for (final ring in gameData.ringNames()) {
    if (ring != ringVoid && (ranks[ring] ?? 0) < lowest) {
      lowest = ranks[ring] ?? 0;
    }
  }
  final cap = lowest + (ranks[ringVoid] ?? 0);
  return [
    for (final ring in gameData.ringNames())
      if ((ranks[ring] ?? 0) < cap && (ranks[ring] ?? 0) < 5) ring
  ];
}

/// Whether [techniqueName] is already learned (creation techniques or a
/// previous technique advance); the Summoning Mantra placeholder is
/// repeatable.
bool alreadyLearned(Character c, String techniqueName) {
  if (c.techniques.contains(techniqueName)) return true;
  if (techniqueName == repeatableTechnique) return false;
  for (final advance in c.advanceStack) {
    if (advance.isTechnique && advance.name == techniqueName) return true;
  }
  return false;
}

/// Techniques legally purchasable right now. Port of
/// AddAdvanceDialog::populateTechModel: rank-gated school categories,
/// universally available categories, the Astradhari title gate, special-access
/// curriculum rows of the current rank (name matches bypass the rank bounds),
/// and special-access rows of the most recent title's track.
List<Technique> legalTechniques(Character c, {bool removeRestrictions = false}) {
  final rank = recalcRank(c).rank;
  final school = gameData.schoolByName(c.school);
  final schoolTech = school?.techniquesAvailable ?? [];
  final curriculum = school?.curriculum ?? [];
  final titleTrack = c.titles.isEmpty
      ? const <TitleAdvancement>[]
      : gameData.titleByName(c.titles.last)?.advancements ??
          const <TitleAdvancement>[];

  final result = <Technique>[];
  for (final tech in gameData.techniques) {
    if (removeRestrictions) {
      result.add(tech);
      continue;
    }
    if (rank >= tech.rank) {
      if (schoolTech.contains(tech.category) ||
          schoolTech.contains(tech.subcategory) ||
          universalTechniqueCategories.contains(tech.category) ||
          (tech.category == categoryAstradhari &&
              c.titles.contains(titleAstradhari))) {
        result.add(tech);
        continue;
      }
    }
    var added = false;
    for (final entry in curriculum) {
      if (entry.rank != rank || !entry.specialAccess) continue;
      final minRank = entry.minAllowableRank > 0 ? entry.minAllowableRank : 1;
      final maxRank =
          entry.maxAllowableRank > 0 ? entry.maxAllowableRank : rank;
      if (tech.rank >= minRank && tech.rank <= maxRank) {
        if (entry.advance == tech.category ||
            entry.advance == tech.subcategory) {
          result.add(tech);
          added = true;
          break;
        }
      }
      if (entry.advance == tech.name) {
        // A name match bypasses the rank bounds.
        result.add(tech);
        added = true;
        break;
      }
    }
    if (added) continue;
    for (final entry in titleTrack) {
      if (!entry.specialAccess) continue;
      if (entry.rank > 0 && tech.rank > entry.rank) continue;
      if (entry.name == tech.category ||
          entry.name == tech.subcategory ||
          entry.name == tech.name) {
        result.add(tech);
        break;
      }
    }
  }
  return result;
}
