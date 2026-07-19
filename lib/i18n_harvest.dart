import 'derived_stats.dart';
import 'game_data.dart';
import 'rules_constants.dart';
import 'wizard/wizard_state.dart';

/// The canonical set of game-data display strings a locale overlay may
/// translate. This is the single authority both for the CI sync guard
/// (overlay keys must be a subset) and for the import tooling's coverage
/// report — anything shown through trData/trCondition should trace back to
/// an entry here.
///
/// Requires [gameData] to be loaded.
Set<String> translatableDataStrings() {
  final out = <String>{};
  void add(String? s) {
    if (s != null && s.trim().isNotEmpty) out.add(s.trim());
  }

  void addAll(Iterable<String> list) => list.forEach(add);

  for (final clan in gameData.clans) {
    add(clan.name);
    add(clan.ringIncrease);
    add(clan.skillIncrease);
    for (final family in clan.families) {
      add(family.name);
      addAll(family.ringIncrease);
      addAll(family.skillIncrease);
    }
  }
  for (final school in gameData.schools) {
    add(school.name);
    addAll(school.role);
    add(school.schoolAbility);
    add(school.masteryAbility);
    addAll(school.techniquesAvailable);
    addAll(school.advDisadv);
    addAll(school.startingSkills.options);
    for (final set in school.startingTechniques) {
      addAll(set.options);
    }
    for (final set in school.startingOutfit) {
      addAll(set.options);
    }
    for (final entry in school.curriculum) {
      add(entry.advance);
    }
  }
  for (final group in gameData.skillGroups) {
    add(group.name);
    addAll(group.skills);
  }
  for (final ring in gameData.rings) {
    add(ring.name);
    add(ring.outstandingQuality);
  }
  for (final tech in gameData.techniques) {
    add(tech.name);
    add(tech.category);
    add(tech.subcategory);
    add(tech.restriction);
  }
  for (final entry in gameData.advantagesDisadvantages) {
    add(entry.name);
    add(entry.category);
    add(entry.ring);
    addAll(entry.types);
  }
  for (final bond in gameData.bonds) {
    add(bond.name);
    add(bond.ability);
  }
  for (final weapon in gameData.weapons) {
    add(weapon.name);
    add(weapon.category);
    add(weapon.skill);
    addAll(weapon.qualities);
    for (final grip in weapon.grips) {
      add(grip.name);
    }
  }
  for (final armor in gameData.armor) {
    add(armor.name);
    addAll(armor.qualities);
  }
  for (final effect in gameData.personalEffects) {
    add(effect.name);
  }
  for (final quality in gameData.qualities) {
    add(quality.name);
  }
  for (final pattern in gameData.itemPatterns) {
    add(pattern.name);
  }
  for (final heritage in gameData.heritageEntries) {
    add(heritage.result);
    add(heritage.otherEffects.instructions);
    for (final outcome in heritage.otherEffects.outcomes) {
      add(outcome.outcome);
    }
  }
  for (final region in gameData.regions) {
    add(region.name);
  }
  for (final upbringing in gameData.upbringings) {
    add(upbringing.name);
    addAll(upbringing.ringIncrease.options);
    for (final set in upbringing.skillIncreases) {
      addAll(set.options);
    }
  }
  for (final title in gameData.titles) {
    add(title.name);
    add(title.titleAbility);
    for (final advancement in title.advancements) {
      add(advancement.name);
    }
  }

  // App-side display strings that behave like data: conditions and their
  // qualifiers, Table 6-6 bands, derived states, heritage tables, character
  // types, and the type/track vocabulary shown on advances.
  addAll(trackableConditions);
  addAll(conditionSummaries.values);
  add('Incapacitated');
  add('Compromised');
  for (var rounds = 1; rounds <= 5; rounds++) {
    add(rounds == 1 ? '$rounds round' : '$rounds rounds');
  }
  // Representative severities cover every distinct Table 6-6 band.
  for (final severity in [0, 3, 5, 7, 9, 12, 20]) {
    add(critBand(severity).name);
    add(critBand(severity).effect);
  }
  addAll(heritageSources);
  for (final trait in WizardState.autoGrantedTraits.values) {
    add(trait);
  }
  addAll(universalTechniqueCategories);
  addAll([characterTypeSamurai, characterTypeRonin, 'Peasant',
      characterTypeGaijin]);
  addAll(['skill', 'skill group', 'technique', 'technique group']);
  addAll([trackCurriculum, trackTitle, 'Free']);
  addAll([advanceTypeSkill, advanceTypeRing, advanceTypeTechnique]);
  addAll([itemTypeWeapon, itemTypeArmor, itemTypePersonalEffect]);

  out.remove('any');
  return out;
}
