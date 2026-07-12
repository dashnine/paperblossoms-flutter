import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'game_data_models.dart';

/// Read-only game reference data loaded from the bundled JSON assets, with
/// user homebrew entries merged over the top (the in-memory equivalent of the
/// original app's base_/user_ table UNION views).
class GameData {
  static final GameData _instance = GameData._internal();
  factory GameData() => _instance;
  GameData._internal();

  bool loaded = false;

  List<Clan> clans = [];
  List<School> schools = [];
  List<SkillGroup> skillGroups = [];
  List<Ring> rings = [];
  List<Technique> techniques = [];
  List<AdvDisadv> advantagesDisadvantages = [];
  List<Bond> bonds = [];
  List<Weapon> weapons = [];
  List<Armor> armor = [];
  List<PersonalEffect> personalEffects = [];
  List<Quality> qualities = [];
  List<ItemPattern> itemPatterns = [];
  List<HeritageEntry> heritageEntries = [];
  List<Region> regions = [];
  List<Upbringing> upbringings = [];
  List<Title> titles = [];
  List<Question8Option> question8Options = [];
  List<Description> descriptions = [];

  Future<void> load() async {
    clans = await _loadList('clans', Clan.fromJson);
    skillGroups = await _loadList('skill_groups', SkillGroup.fromJson);
    rings = await _loadList('rings', Ring.fromJson);
    schools = await _loadList('schools', School.fromJson);
    bonds = await _loadList('bonds', Bond.fromJson);
    armor = await _loadList('armor', Armor.fromJson);
    personalEffects =
        await _loadList('personal_effects', PersonalEffect.fromJson);
    qualities = await _loadList('qualities', Quality.fromJson);
    itemPatterns = await _loadList('item_patterns', ItemPattern.fromJson);
    heritageEntries =
        await _loadList('samurai_heritage', HeritageEntry.fromJson);
    regions = await _loadList('regions', Region.fromJson);
    upbringings = await _loadList('upbringings', Upbringing.fromJson);
    titles = await _loadList('titles', Title.fromJson);
    question8Options =
        await _loadList('question_8', Question8Option.fromJson);

    techniques = [
      for (final category in await _loadRaw('techniques'))
        for (final subcategory in category['subcategories'] ?? [])
          for (final t in subcategory['techniques'] ?? [])
            Technique.fromJson(t,
                category: category['name'] ?? '',
                subcategory: subcategory['name'] ?? '')
    ];
    advantagesDisadvantages = [
      for (final category in await _loadRaw('advantages_disadvantages'))
        for (final e in category['entries'] ?? [])
          AdvDisadv.fromJson(e, category: category['name'] ?? '')
    ];
    weapons = [
      for (final category in await _loadRaw('weapons'))
        for (final e in category['entries'] ?? [])
          Weapon.fromJson(e, category: category['name'] ?? '')
    ];

    loaded = true;
  }

  Future<List<dynamic>> _loadRaw(String asset) async =>
      jsonDecode(await rootBundle.loadString('assets/data/$asset.json'));

  Future<List<T>> _loadList<T>(
      String asset, T Function(Map<String, dynamic>) fromJson) async {
    return [for (final e in await _loadRaw(asset)) fromJson(e)];
  }

  // ---- Clans and families ----

  Clan? clanByName(String name) =>
      _firstWhereOrNull(clans, (c) => c.name == name);

  List<Family> familiesOf(String clan) => clanByName(clan)?.families ?? [];

  Family? familyByName(String clan, String name) =>
      _firstWhereOrNull(familiesOf(clan), (f) => f.name == name);

  // ---- Schools ----

  School? schoolByName(String name) =>
      _firstWhereOrNull(schools, (s) => s.name == name);

  /// Schools offered by [clan], or all schools when [allClans] is set.
  List<School> schoolsOf(String clan, {bool allClans = false}) =>
      allClans ? schools : [for (final s in schools) if (s.clan == clan) s];

  // ---- Skills ----

  List<String> allSkills() =>
      [for (final g in skillGroups) ...g.skills]..sort();

  List<String> skillsByGroup(String group) =>
      _firstWhereOrNull(skillGroups, (g) => g.name == group)?.skills ?? [];

  String groupOfSkill(String skill) => _firstWhereOrNull(
          skillGroups, (g) => g.skills.contains(skill))?.name ??
      '';

  // ---- Rings ----

  List<String> ringNames() => [for (final r in rings) r.name];

  // ---- Techniques ----

  Technique? techniqueByName(String name) =>
      _firstWhereOrNull(techniques, (t) => t.name == name);

  /// Techniques in a category or subcategory whose rank falls in
  /// [minRank]..[maxRank] (inclusive).
  List<Technique> techniquesByGroup(String group,
          {int minRank = 1, int maxRank = 5}) =>
      [
        for (final t in techniques)
          if ((t.category == group || t.subcategory == group) &&
              t.rank >= minRank &&
              t.rank <= maxRank)
            t
      ];

  List<String> techniqueCategories() =>
      {for (final t in techniques) t.category}.toList();

  // ---- Advantages / disadvantages ----

  List<AdvDisadv> advDisadvByCategory(String category) => [
        for (final a in advantagesDisadvantages)
          if (a.category == category) a
      ];

  AdvDisadv? advDisadvByName(String name) =>
      _firstWhereOrNull(advantagesDisadvantages, (a) => a.name == name);

  // ---- Bonds ----

  Bond? bondByName(String name) =>
      _firstWhereOrNull(bonds, (b) => b.name == name);

  // ---- Heritage ----

  List<HeritageEntry> heritagesBySource(String source) => [
        for (final h in heritageEntries)
          if (h.source == source) h
      ];

  HeritageEntry? heritageByRoll(String source, int roll) => _firstWhereOrNull(
      heritagesBySource(source), (h) => roll >= h.rollMin && roll <= h.rollMax);

  HeritageEntry? heritageByResult(String result) =>
      _firstWhereOrNull(heritageEntries, (h) => h.result == result);

  // ---- Inventory ----

  Weapon? weaponByName(String name) =>
      _firstWhereOrNull(weapons, (w) => w.name == name);

  Armor? armorByName(String name) =>
      _firstWhereOrNull(armor, (a) => a.name == name);

  PersonalEffect? personalEffectByName(String name) =>
      _firstWhereOrNull(personalEffects, (p) => p.name == name);

  List<String> weaponCategories() =>
      {for (final w in weapons) w.category}.toList();

  /// The item type of [name]: 'Weapon', 'Armor', 'Personal Effect', or ''.
  String itemTypeOf(String name) {
    if (weaponByName(name) != null) return 'Weapon';
    if (armorByName(name) != null) return 'Armor';
    if (personalEffectByName(name) != null) return 'Personal Effect';
    return '';
  }

  List<Weapon> weaponsUnderRarity(int rarity, {String? category}) => [
        for (final w in weapons)
          if (w.rarity <= rarity && (category == null || w.category == category))
            w
      ];

  List<Armor> armorUnderRarity(int rarity) =>
      [for (final a in armor) if (a.rarity <= rarity) a];

  List<PersonalEffect> personalEffectsUnderRarity(int rarity) =>
      [for (final p in personalEffects) if (p.rarity <= rarity) p];

  // ---- Regions and upbringings ----

  List<Region> regionsByType(String type) =>
      [for (final r in regions) if (r.type == type) r];

  Region? regionByName(String name) =>
      _firstWhereOrNull(regions, (r) => r.name == name);

  Upbringing? upbringingByName(String name) =>
      _firstWhereOrNull(upbringings, (u) => u.name == name);

  // ---- Titles ----

  Title? titleByName(String name) =>
      _firstWhereOrNull(titles, (t) => t.name == name);

  // ---- Descriptions (user-entered only; base data ships none) ----

  String descriptionFor(String name) =>
      _firstWhereOrNull(descriptions, (d) => d.name == name)?.description ??
      '';

  String shortDescFor(String name) =>
      _firstWhereOrNull(descriptions, (d) => d.name == name)?.shortDesc ?? '';

  /// Every name a user may attach a description to (techniques, abilities,
  /// advantages, items, ...), for the descriptions editor.
  List<String> describableNames() => {
        for (final t in techniques) t.name,
        for (final a in advantagesDisadvantages) a.name,
        for (final b in bonds) b.name,
        for (final w in weapons) w.name,
        for (final a in armor) a.name,
        for (final p in personalEffects) p.name,
        for (final q in qualities) q.name,
        for (final t in titles) t.titleAbility,
        for (final s in schools) ...[s.schoolAbility, s.masteryAbility],
      }.toList()
        ..sort();

  static T? _firstWhereOrNull<T>(List<T> list, bool Function(T) test) {
    for (final e in list) {
      if (test(e)) return e;
    }
    return null;
  }
}

final gameData = GameData();
