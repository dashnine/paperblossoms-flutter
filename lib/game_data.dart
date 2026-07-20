import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'game_data_models.dart';
import 'npc_models.dart';

/// Heroes of Rokugan campaign data (assets/data/hor/). Kept in its own
/// container, never merged into the stock lists, so no stock picker or
/// enumeration can surface an HoR entry while the mode is off.
class HorData {
  List<Title> titles = [];
  List<AdvDisadv> advantages = [];
  List<HeritageEntry> heritage = [];
  List<HorRoninBackground> roninBackgrounds = [];
  HorBans bans = const HorBans();

  // Campaign rōnin "clan" block (Twenty Questions, Question 1).
  String roninRingIncrease = '';
  String roninSkillIncrease = '';
  int roninStatus = 0;

  HorRoninBackground? backgroundByName(String name) {
    for (final b in roninBackgrounds) {
      if (b.name == name) return b;
    }
    return null;
  }
}

/// Chapter 8 GM data (assets/data/npc/): sample NPC stat blocks, templates,
/// and demeanors. Kept in its own container so no PC-facing picker or
/// enumeration ever surfaces an NPC entry. Custom (homebrew) NPCs are merged
/// into [samples] by the user data store.
class NpcData {
  List<Npc> samples = [];
  List<NpcTemplate> templates = [];
  List<Demeanor> demeanors = [];

  Npc? sampleByName(String name) {
    for (final n in samples) {
      if (n.name == name) return n;
    }
    return null;
  }

  NpcTemplate? templateByName(String name) {
    for (final t in templates) {
      if (t.name == name) return t;
    }
    return null;
  }

  Demeanor? demeanorByName(String name) {
    for (final d in demeanors) {
      if (d.name == name) return d;
    }
    return null;
  }
}

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
  HorData hor = HorData();
  NpcData npc = NpcData();

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

    await _loadHor();
    await _loadNpc();
    loaded = true;
  }

  /// Chapter 8 GM data must never break stock loading: any failure leaves an
  /// empty [NpcData] (the GM tools simply show nothing) with the stock lists
  /// untouched.
  Future<void> _loadNpc() async {
    final n = NpcData();
    try {
      n.samples = [
        for (final e in await _loadRaw('npc/npc_samples')) Npc.fromJson(e)
      ];
      n.templates = [
        for (final e in await _loadRaw('npc/npc_templates'))
          NpcTemplate.fromJson(e)
      ];
      n.demeanors = [
        for (final e in await _loadRaw('npc/npc_demeanors'))
          Demeanor.fromJson(e)
      ];
      npc = n;
    } catch (_) {
      npc = NpcData();
    }
  }

  /// Heroes of Rokugan data is additive-only and must never break stock
  /// loading: any failure leaves an empty [HorData] (the mode simply has
  /// nothing to offer) with the stock lists untouched.
  Future<void> _loadHor() async {
    final h = HorData();
    try {
      h.titles = [
        for (final e in await _loadRaw('hor/hor_titles')) Title.fromJson(e)
      ];
      h.advantages = [
        for (final category in await _loadRaw('hor/hor_advantages'))
          for (final e in category['entries'] ?? [])
            AdvDisadv.fromJson(e, category: category['name'] ?? '')
      ];
      h.heritage = [
        for (final e in await _loadRaw('hor/hor_heritage'))
          HeritageEntry.fromJson(e)
      ];
      final Map<String, dynamic> ronin = jsonDecode(
          await rootBundle.loadString('assets/data/hor/hor_ronin.json'));
      h.roninRingIncrease = ronin['clan']?['ring_increase'] ?? '';
      h.roninSkillIncrease = ronin['clan']?['skill_increase'] ?? '';
      h.roninStatus = ronin['clan']?['status'] ?? 0;
      h.roninBackgrounds = [
        for (final e in ronin['backgrounds'] ?? [])
          HorRoninBackground.fromJson(e)
      ];
      h.bans = HorBans.fromJson(jsonDecode(
          await rootBundle.loadString('assets/data/hor/hor_bans.json')));
      hor = h;
    } catch (_) {
      hor = HorData();
    }
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

  /// Item patterns (SL p.109) are granted/learned like techniques but live
  /// in their own table; display sites fall back to this after
  /// [techniqueByName] misses.
  ItemPattern? itemPatternByName(String name) =>
      _firstWhereOrNull(itemPatterns, (p) => p.name == name);

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

  // Stock entries win on any name collision; the HoR fall-throughs only
  // exist so a saved HoR character still renders with the mode off.
  AdvDisadv? advDisadvByName(String name) =>
      _firstWhereOrNull(advantagesDisadvantages, (a) => a.name == name) ??
      _firstWhereOrNull(hor.advantages, (a) => a.name == name);

  // ---- Rings ----

  Ring? ringByName(String name) =>
      _firstWhereOrNull(rings, (r) => r.name == name);

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
      _firstWhereOrNull(heritageEntries, (h) => h.result == result) ??
      _firstWhereOrNull(hor.heritage, (h) => h.result == result);

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
      _firstWhereOrNull(titles, (t) => t.name == name) ??
      _firstWhereOrNull(hor.titles, (t) => t.name == name);

  // ---- Heroes of Rokugan ----

  List<AdvDisadv> horAdvDisadvByCategory(String category) => [
        for (final a in hor.advantages)
          if (a.category == category) a
      ];

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
