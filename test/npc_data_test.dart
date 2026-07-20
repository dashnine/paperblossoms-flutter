import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';

/// Validates the bundled Chapter 8 GM data (assets/data/npc/): counts,
/// cross-references, and structural invariants. Derived attributes are
/// deliberately NOT checked against the PC formulas — the sidebar on Core
/// p. 312 says NPC values are set by design, and nearly every sample
/// diverges; the transcription was verified against two independent PDF
/// extractions instead.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  test('bundled counts: 31 samples, 7 templates, 19 demeanors', () {
    expect(gameData.npc.samples.length, 31);
    expect(gameData.npc.templates.length, 7);
    expect(gameData.npc.demeanors.length, 19);
  });

  test('sample names are unique and types valid', () {
    final names = [for (final n in gameData.npc.samples) n.name];
    expect(names.toSet().length, names.length);
    for (final n in gameData.npc.samples) {
      expect(['minion', 'adversary'], contains(n.type), reason: n.name);
    }
  });

  test('every sample field is well-formed', () {
    for (final n in gameData.npc.samples) {
      expect(n.name, isNotEmpty);
      expect(n.blurb, isNotEmpty, reason: n.name);
      expect(n.crCombat, greaterThanOrEqualTo(0), reason: n.name);
      expect(n.crIntrigue, greaterThanOrEqualTo(0), reason: n.name);
      expect(n.rings.keys.toSet(),
          {'Air', 'Earth', 'Fire', 'Water', 'Void'},
          reason: n.name);
      expect(n.skillGroups.keys.toSet(),
          {'Artisan', 'Martial', 'Scholar', 'Social', 'Trade'},
          reason: n.name);
      for (final value in [
        n.derived.endurance,
        n.derived.composure,
        n.derived.focus,
        n.derived.vigilance,
      ]) {
        // Numeric, or the book's literal ∞ (undead composure).
        expect(value == '∞' || int.tryParse(value) != null, isTrue,
            reason: '${n.name}: derived "$value"');
      }
      for (final trait in [...n.advantages, ...n.disadvantages]) {
        expect(trait.name, isNotEmpty, reason: n.name);
        expect(['Air', 'Earth', 'Fire', 'Water', 'Void'],
            contains(trait.ring),
            reason: '${n.name}: ${trait.name}');
        expect(trait.groups, isNotEmpty,
            reason: '${n.name}: ${trait.name}');
        expect(trait.types, isNotEmpty,
            reason: '${n.name}: ${trait.name}');
      }
      for (final a in n.abilities) {
        expect(a.name, isNotEmpty, reason: n.name);
        expect(a.text, isNotEmpty, reason: '${n.name}: ${a.name}');
        expect(a.reference.book, 'Core', reason: '${n.name}: ${a.name}');
      }
      expect(n.reference.book, 'Core', reason: n.name);
      final page = int.parse(n.reference.page);
      expect(page, inInclusiveRange(312, 327), reason: n.name);
    }
  });

  test('every sample demeanor resolves', () {
    for (final n in gameData.npc.samples) {
      expect(gameData.npc.demeanorByName(n.demeanor), isNotNull,
          reason: '${n.name}: demeanor "${n.demeanor}"');
    }
  });

  test('demeanors have modifiers; the five generic ones have unmasking', () {
    for (final d in gameData.npc.demeanors) {
      expect(d.modifiers, isNotEmpty, reason: d.name);
      for (final ring in d.modifiers.keys) {
        expect(['Air', 'Earth', 'Fire', 'Water', 'Void'], contains(ring),
            reason: d.name);
      }
    }
    for (final name in [
      'Ambitious',
      'Assertive',
      'Detached',
      'Gruff',
      'Shrewd'
    ]) {
      final d = gameData.npc.demeanorByName(name);
      expect(d, isNotNull, reason: name);
      expect(d!.unmasking, isNotEmpty, reason: name);
      expect(d.reference.page, '310', reason: name);
    }
  });

  test('templates: default techniques exist, belong to listed categories,'
      ' and fit under max', () {
    for (final t in gameData.npc.templates) {
      expect(t.reference.page, '311', reason: t.name);
      expect(t.defaultTechniques.length, lessThanOrEqualTo(t.techniqueMax),
          reason: t.name);
      for (final name in t.defaultTechniques) {
        final technique = gameData.techniqueByName(name);
        expect(technique, isNotNull, reason: '${t.name}: $name');
        expect(t.techniqueCategories, contains(technique!.category),
            reason: '${t.name}: $name is ${technique.category}');
      }
      expect(t.demeanorOptions, contains(t.defaultDemeanor), reason: t.name);
      expect(gameData.npc.demeanorByName(t.defaultDemeanor), isNotNull,
          reason: t.name);
      for (final trait in [
        ...t.suggestedAdvantages,
        ...t.suggestedDisadvantages
      ]) {
        expect(trait.name, isNotEmpty, reason: t.name);
        expect(trait.groups, isNotEmpty, reason: '${t.name}: ${trait.name}');
      }
      expect(t.ring, isNotEmpty, reason: t.name);
      expect(t.crCombat + t.crIntrigue, greaterThan(0), reason: t.name);
    }
  });

  test('NPC data never leaks into PC-facing lists', () {
    final sampleNames = {for (final n in gameData.npc.samples) n.name};
    for (final t in gameData.techniques) {
      expect(sampleNames, isNot(contains(t.name)));
    }
    for (final a in gameData.advantagesDisadvantages) {
      // Chapter 8 trait names are specialized and stay out of the PC list.
      expect(sampleNames, isNot(contains(a.name)));
    }
  });
}
