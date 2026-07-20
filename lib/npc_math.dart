/// Pure NPC math: derived-attribute formulas, template application, and the
/// Chapter 8 encounter-rank arithmetic (Core pp. 310-311). No Flutter imports
/// so everything here is trivially unit-testable.
library;

import 'npc_models.dart';

/// Derived attributes computed from rings with the PC formulas (Core p. 36),
/// halved for minions (the observed convention in the Ch8 sample minions).
/// Printed book values frequently diverge — the sidebar on p. 312 says NPC
/// values are set by design, not formula — so this is only used by the
/// editor's "auto" mode and as an advisory cross-check.
NpcDerived derivedFromRings(String type, Map<String, int> rings) {
  final air = rings['Air'] ?? 0;
  final earth = rings['Earth'] ?? 0;
  final fire = rings['Fire'] ?? 0;
  final water = rings['Water'] ?? 0;
  final mult = type == 'minion' ? 1 : 2;
  return NpcDerived(
    endurance: '${(earth + fire) * mult}',
    composure: '${(earth + water) * mult}',
    focus: '${fire + air}',
    vigilance: '${((air + water) + 1) ~/ 2}',
  );
}

/// Applies [template] to a copy of [npc] and returns it. All operations are
/// additive deltas, so stacking several templates is order-independent.
///
/// The book (Core p. 311) only specifies conflict-rank, ring, skill,
/// trait, technique, and demeanor changes; it says nothing about derived
/// attributes. We nudge them by the PC-formula delta of the +1 ring
/// (adversaries ×2, minions ×1, matching [derivedFromRings]) so a Warrior's
/// +1 Fire is felt in endurance — printed base values stay authoritative,
/// never recomputed wholesale. Non-numeric printed values ("∞") are left
/// untouched.
Npc applyTemplate(
  Npc npc,
  NpcTemplate template, {
  String? demeanor,
  List<String>? techniques,
  List<NpcTrait> advantages = const [],
  List<NpcTrait> disadvantages = const [],
}) {
  final out = npc.clone();
  out.crCombat += template.crCombat;
  out.crIntrigue += template.crIntrigue;

  final oldRings = Map<String, int>.from(out.rings);
  if (template.ring.isNotEmpty) {
    out.rings[template.ring] = (out.rings[template.ring] ?? 0) + 1;
  }
  _applyDerivedDelta(out, oldRings);

  for (final e in template.skillGroups.entries) {
    out.skillGroups[e.key] = (out.skillGroups[e.key] ?? 0) + e.value;
  }

  out.demeanor = demeanor ?? template.defaultDemeanor;
  for (final t in techniques ?? template.defaultTechniques) {
    if (!out.techniques.contains(t)) out.techniques.add(t);
  }
  for (final a in advantages) {
    if (!out.advantages.any((x) => x.name == a.name)) out.advantages.add(a);
  }
  for (final d in disadvantages) {
    if (!out.disadvantages.any((x) => x.name == d.name)) {
      out.disadvantages.add(d);
    }
  }

  out.appliedTemplates = [...npc.appliedTemplates, template.name];
  if (out.base.isEmpty) out.base = npc.name;
  return out;
}

void _applyDerivedDelta(Npc npc, Map<String, int> oldRings) {
  final mult = npc.isMinion ? 1 : 2;
  int d(String ring) => (npc.rings[ring] ?? 0) - (oldRings[ring] ?? 0);
  void bump(String current, int delta, void Function(String) set) {
    final v = int.tryParse(current);
    if (v != null && delta != 0) set('${v + delta}');
  }

  bump(npc.derived.endurance, (d('Earth') + d('Fire')) * mult,
      (v) => npc.derived.endurance = v);
  bump(npc.derived.composure, (d('Earth') + d('Water')) * mult,
      (v) => npc.derived.composure = v);
  bump(npc.derived.focus, d('Fire') + d('Air'), (v) => npc.derived.focus = v);
  int vig(Map<String, int> r) => ((r['Air'] ?? 0) + (r['Water'] ?? 0) + 1) ~/ 2;
  bump(npc.derived.vigilance, vig(npc.rings) - vig(oldRings),
      (v) => npc.derived.vigilance = v);
}

/// Sum of combat and intrigue conflict ranks over a roster (Core p. 310:
/// the Encounter Rank is the sum of the relevant conflict ranks of all NPCs
/// opposing the PCs).
({int combat, int intrigue}) encounterRank(
    Iterable<({Npc npc, int count})> roster) {
  var combat = 0, intrigue = 0;
  for (final e in roster) {
    combat += e.npc.crCombat * e.count;
    intrigue += e.npc.crIntrigue * e.count;
  }
  return (combat: combat, intrigue: intrigue);
}

/// Group-rank thresholds for an encounter rank (Core p. 310): a party whose
/// summed school ranks are near [rank] is evenly matched; 1.5–2× has a
/// significant edge; 0.5× or below is significantly outmatched.
({int even, int easy, int hard}) groupRankThresholds(int rank) => (
      even: rank,
      easy: (rank * 3 + 1) ~/ 2,
      hard: rank ~/ 2,
    );
