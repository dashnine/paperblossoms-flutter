import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'advance.dart';
import 'item.dart';

const saveFileVersion = 1;

class CharacterBond {
  String name;
  int rank;

  CharacterBond({required this.name, this.rank = 1});

  CharacterBond.fromJson(Map<String, dynamic> json)
      : name = json['name'] ?? '',
        rank = json['rank'] ?? 1;

  Map<String, dynamic> toJson() => {'name': name, 'rank': rank};
}

/// The character currently being edited. A single global instance ([character])
/// is shared by every screen; mutations go through [touch] (or the helpers
/// that call it) so listening widgets rebuild.
///
/// Effective skill/ring ranks, school rank, title progress, and abilities are
/// intentionally NOT stored — they are derived from [baseSkills]/[baseRings] +
/// [advanceStack] by derived_stats.dart, exactly like the original app's
/// populateUI().
class Character extends ChangeNotifier {
  static final Character _instance = Character._internal();
  factory Character() => _instance;
  Character._internal();

  String uuid = const Uuid().v4();
  String name = '';
  String clan = '';
  String family = '';
  String school = '';
  String ninjo = '';
  String giri = '';
  String heritage = '';
  String notes = '';
  List<String> titles = [];

  /// Skills the player has designated as bonus curriculum skills via the
  /// Worldly Rōnin Path's School of Waves ability (core p.87). Stored as
  /// canonical English skill names. Inert unless the school's ability is
  /// [schoolAbilityWaves]; the allowed count equals the current school rank.
  List<String> bonusCurriculumSkills = [];
  List<String> techniques = [];
  List<String> advDisadv = [];
  Map<String, int> baseSkills = {};
  Map<String, int> baseRings = {};
  int honor = 0;
  int glory = 0;
  int status = 0;
  int koku = 0;
  int bu = 0;
  int zeni = 0;
  int totalXP = 0;
  int fatigue = 0;
  int strife = 0;

  /// Active conditions (core rulebook ch.6), stored as display strings with
  /// their qualifier resolved, e.g. 'Bleeding', 'Lightly Wounded (Fire)',
  /// 'Dying (3 rounds)'. Compromised and Incapacitated are NOT stored — they
  /// are derived from strife/composure and fatigue/endurance.
  List<String> conditions = [];
  List<Advance> advanceStack = [];
  List<Item> equipment = [];
  List<CharacterBond> bonds = [];
  String portraitB64 = '';

  /// Built under Heroes of Rokugan campaign rules. Serialized only when
  /// true so stock save files stay byte-identical.
  bool hor = false;

  /// When true, the rarely-changing identity fields (name, family, ninjō,
  /// giri) are read-only in the editor so they can't be edited accidentally.
  bool identityLocked = false;

  /// True when there are mutations not yet persisted by the store. Not
  /// serialized; drives the editor's save badge and close guard.
  bool dirty = false;

  /// Decoded portrait bytes, or null when no portrait is set or the stored
  /// base64 is corrupt (e.g. a truncated or hand-edited save file).
  Uint8List? get portraitBytes {
    if (portraitB64.isEmpty) return null;
    try {
      return base64Decode(portraitB64);
    } on FormatException {
      return null;
    }
  }

  /// Notify listeners after any direct field mutation.
  void touch() {
    dirty = true;
    notifyListeners();
  }

  /// Called by the store once the character is on disk.
  void markSaved() {
    dirty = false;
    notifyListeners();
  }

  void clear() {
    uuid = const Uuid().v4();
    name = '';
    clan = '';
    family = '';
    school = '';
    ninjo = '';
    giri = '';
    heritage = '';
    notes = '';
    titles = [];
    bonusCurriculumSkills = [];
    techniques = [];
    advDisadv = [];
    baseSkills = {};
    baseRings = {};
    honor = 0;
    glory = 0;
    status = 0;
    koku = 0;
    bu = 0;
    zeni = 0;
    totalXP = 0;
    fatigue = 0;
    strife = 0;
    conditions = [];
    advanceStack = [];
    equipment = [];
    bonds = [];
    portraitB64 = '';
    hor = false;
    identityLocked = false;
    dirty = false;
    notifyListeners();
  }

  void loadFromJson(Map<String, dynamic> json) {
    // saveVersion gates future format migrations; version 1 needs none.
    uuid = json['uuid'] ?? const Uuid().v4();
    name = json['name'] ?? '';
    clan = json['clan'] ?? '';
    family = json['family'] ?? '';
    school = json['school'] ?? '';
    ninjo = json['ninjo'] ?? '';
    giri = json['giri'] ?? '';
    heritage = json['heritage'] ?? '';
    notes = json['notes'] ?? '';
    titles = List<String>.from(json['titles'] ?? []);
    bonusCurriculumSkills =
        List<String>.from(json['bonus_curriculum_skills'] ?? []);
    techniques = List<String>.from(json['techniques'] ?? []);
    advDisadv = List<String>.from(json['adv_disadv'] ?? []);
    baseSkills = Map<String, int>.from(json['base_skills'] ?? {});
    baseRings = Map<String, int>.from(json['base_rings'] ?? {});
    honor = json['honor'] ?? 0;
    glory = json['glory'] ?? 0;
    status = json['status'] ?? 0;
    koku = json['koku'] ?? 0;
    bu = json['bu'] ?? 0;
    zeni = json['zeni'] ?? 0;
    totalXP = json['total_xp'] ?? 0;
    fatigue = json['fatigue'] ?? 0;
    strife = json['strife'] ?? 0;
    conditions = List<String>.from(json['conditions'] ?? []);
    advanceStack = [
      for (final a in json['advance_stack'] ?? []) Advance.fromJson(a)
    ];
    equipment = [for (final e in json['equipment'] ?? []) Item.fromJson(e)];
    bonds = [for (final b in json['bonds'] ?? []) CharacterBond.fromJson(b)];
    portraitB64 = json['portrait'] ?? '';
    hor = json['hor'] ?? false;
    // A freshly loaded character always starts locked so its identity fields
    // can't be edited by accident; the user unlocks per-session via
    // IdentityLockButton. The persisted `identity_locked` is intentionally
    // ignored here — loading is treated the same as finishing chargen.
    identityLocked = true;
    dirty = false;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'save_version': saveFileVersion,
        'uuid': uuid,
        'name': name,
        'clan': clan,
        'family': family,
        'school': school,
        'ninjo': ninjo,
        'giri': giri,
        'heritage': heritage,
        'notes': notes,
        'titles': titles,
        'techniques': techniques,
        'adv_disadv': advDisadv,
        'base_skills': baseSkills,
        'base_rings': baseRings,
        'honor': honor,
        'glory': glory,
        'status': status,
        'koku': koku,
        'bu': bu,
        'zeni': zeni,
        'total_xp': totalXP,
        'fatigue': fatigue,
        'strife': strife,
        'conditions': conditions,
        'advance_stack': [for (final a in advanceStack) a.toJson()],
        'equipment': [for (final e in equipment) e.toJson()],
        'bonds': [for (final b in bonds) b.toJson()],
        'portrait': portraitB64,
        // Omitted when empty so stock (non-Waves) saves stay byte-identical.
        if (bonusCurriculumSkills.isNotEmpty)
          'bonus_curriculum_skills': bonusCurriculumSkills,
        if (hor) 'hor': true,
        'identity_locked': identityLocked,
      };
}

final character = Character();
