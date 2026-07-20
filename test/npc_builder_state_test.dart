import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/npc_builder_state.dart';
import 'package:paperblossoms/npc_math.dart';
import 'package:paperblossoms/npc_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  NpcTemplate template(String name) => gameData.npc.templateByName(name)!;
  Npc sample(String name) => gameData.npc.sampleByName(name)!;

  group('applyTemplate', () {
    test('Goblin Chieftain (Core p. 311 sidebar): goblin + Warrior', () {
      final goblin = sample('Shadowlands Goblin');
      final out = applyTemplate(
        goblin,
        template('Warrior'),
        techniques: ['Striking as Fire', 'Tactical Assessment'],
      );
      expect(out.crCombat, goblin.crCombat + 2);
      expect(out.crIntrigue, goblin.crIntrigue + 1);
      expect(out.rings['Fire'], goblin.rings['Fire']! + 1);
      expect(out.skillGroups['Martial'], goblin.skillGroups['Martial']! + 2);
      expect(out.skillGroups['Social'], goblin.skillGroups['Social']! + 2);
      expect(out.demeanor, 'Assertive');
      expect(out.techniques, ['Striking as Fire', 'Tactical Assessment']);
      expect(out.base, 'Shadowlands Goblin');
      expect(out.appliedTemplates, ['Warrior']);
      // Minion derived delta: +1 Fire → endurance +1, focus +1.
      expect(out.derived.endurance,
          '${goblin.derived.enduranceValue! + 1}');
      expect(out.derived.focus,
          '${int.parse(goblin.derived.focus) + 1}');
      // The original is untouched.
      expect(goblin.appliedTemplates, isEmpty);
      expect(sample('Shadowlands Goblin').crCombat, 1);
    });

    test('adversary derived deltas apply ×2 and skip non-numeric values',
        () {
      final bushi = sample('Loyal Bushi');
      final out = applyTemplate(bushi, template('Warrior'));
      // +1 Fire, adversary: endurance +2, composure unchanged, focus +1.
      expect(out.derived.endurance,
          '${bushi.derived.enduranceValue! + 2}');
      expect(out.derived.composure, bushi.derived.composure);
      expect(out.derived.focus, '${int.parse(bushi.derived.focus) + 1}');

      final skeleton = sample('Bushi Skeleton'); // composure ∞
      final outSkeleton = applyTemplate(skeleton, template('Sage'));
      expect(outSkeleton.derived.composure, '∞');
      // Sage: +1 Earth → minion endurance +1.
      expect(outSkeleton.derived.endurance,
          '${skeleton.derived.enduranceValue! + 1}');
    });

    test('suggested traits merge without duplicates', () {
      final t = template('Warrior');
      final out = applyTemplate(
        sample('Loyal Bushi'),
        t,
        advantages: t.suggestedAdvantages.take(2).toList(),
        disadvantages: t.suggestedDisadvantages.take(1).toList(),
      );
      expect(
          out.advantages.map((a) => a.name),
          containsAll(
              [for (final a in t.suggestedAdvantages.take(2)) a.name]));
      expect(out.disadvantages.map((d) => d.name),
          contains(t.suggestedDisadvantages.first.name));
    });
  });

  group('NpcBuilderState', () {
    test('happy path: base + template with defaults', () {
      final state = NpcBuilderState()..base = sample('Loyal Bushi');
      state.toggleTemplate(template('Investigator'));
      expect(state.autoName(), 'Investigator Loyal Bushi');

      final result = state.result(gameData.npc.templates)!;
      expect(result.name, 'Investigator Loyal Bushi');
      expect(result.crCombat, 4 + 2);
      expect(result.crIntrigue, 2 + 2);
      expect(result.rings['Air'], 2 + 1);
      expect(result.techniques,
          ['Iaijutsu Cut: Crossing Blade', 'Battle in the Mind']);
      expect(result.demeanor, 'Gruff');
      expect(result.custom, isTrue);
    });

    test('stacking two templates sums deltas; toggle off restores', () {
      final state = NpcBuilderState()..base = sample('Humble Peasant');
      state.toggleTemplate(template('Artist'));
      state.toggleTemplate(template('Socialite'));
      var result = state.result(gameData.npc.templates)!;
      expect(result.crIntrigue, 1 + 2 + 2);
      expect(result.skillGroups['Social'], 1 + 2 + 2);
      expect(result.appliedTemplates, ['Artist', 'Socialite']);

      state.toggleTemplate(template('Socialite'));
      result = state.result(gameData.npc.templates)!;
      expect(result.crIntrigue, 1 + 2);
      expect(result.appliedTemplates, ['Artist']);

      state.toggleTemplate(template('Artist'));
      result = state.result(gameData.npc.templates)!;
      expect(result.crIntrigue, 1);
      expect(result.rings, sample('Humble Peasant').rings);
    });

    test('name and type overrides win', () {
      final state = NpcBuilderState()..base = sample('Shadowlands Goblin');
      state.toggleTemplate(template('Warrior'));
      state.name = 'Goblin Chieftain';
      state.typeOverride = 'adversary';
      final result = state.result(gameData.npc.templates)!;
      expect(result.name, 'Goblin Chieftain');
      expect(result.type, 'adversary');
    });

    test('no base means no result', () {
      expect(NpcBuilderState().result(gameData.npc.templates), isNull);
    });

    test('extra techniques add without a template; one removal hits every '
        'source at once', () {
      final base = sample('Loyal Bushi').clone()
        ..techniques = ['Striking as Earth'];
      final state = NpcBuilderState()..base = base;
      state.extraTechniques.add('Striking as Fire');
      var result = state.result(gameData.npc.templates)!;
      expect(result.techniques, ['Striking as Earth', 'Striking as Fire']);

      // 'Striking as Fire' is now both an extra pick and a Warrior default;
      // one removal call clears both sources.
      state.toggleTemplate(template('Warrior'));
      state.removeTechnique('Striking as Fire');
      state.removeTechnique('Striking as Earth'); // base-carried
      result = state.result(gameData.npc.templates)!;
      expect(result.techniques, ['Tactical Assessment']);
      expect(state.extraTechniques, isEmpty);
      expect(state.selected['Warrior']!.techniques, ['Tactical Assessment']);

      // Re-adding a removed base technique resurrects it.
      state.removedTechniques.remove('Striking as Earth');
      state.extraTechniques.add('Striking as Earth');
      result = state.result(gameData.npc.templates)!;
      expect(result.techniques,
          containsAll(['Tactical Assessment', 'Striking as Earth']));
    });

    test('re-selecting a template resurrects its removed defaults', () {
      final state = NpcBuilderState()..base = sample('Loyal Bushi');
      state.toggleTemplate(template('Warrior'));
      state.removeTechnique('Striking as Fire');
      state.toggleTemplate(template('Warrior')); // off
      state.toggleTemplate(template('Warrior')); // on: fresh defaults again
      final result = state.result(gameData.npc.templates)!;
      expect(result.techniques, contains('Striking as Fire'));
    });

    test('swapping the base clears removals aimed at the old base', () {
      final first = sample('Loyal Bushi').clone()
        ..techniques = ['Striking as Water'];
      final state = NpcBuilderState()..base = first;
      state.removeTechnique('Striking as Water');
      expect(state.result(gameData.npc.templates)!.techniques, isEmpty);

      final second = sample('Shadowlands Goblin').clone()
        ..techniques = ['Striking as Water'];
      state.setBase(second);
      expect(state.result(gameData.npc.templates)!.techniques,
          ['Striking as Water']);
    });
  });

  group('encounter math (Core p. 310)', () {
    test('encounterRank sums conflict ranks times counts', () {
      final rank = encounterRank([
        (npc: sample('Desperate Bandit'), count: 4), // 1/1 each
        (npc: sample('Experienced Bandit'), count: 1), // 3/2
      ]);
      expect(rank.combat, 4 * 1 + 3);
      expect(rank.intrigue, 4 * 1 + 2);
    });

    test('groupRankThresholds: even / 1.5× easy / 0.5× hard', () {
      final t = groupRankThresholds(7);
      expect(t.even, 7);
      expect(t.easy, 11); // ceil(7 * 1.5)
      expect(t.hard, 3); // floor(7 * 0.5)
    });
  });

  test('derivedFromRings halves for minions', () {
    final rings = {'Air': 2, 'Earth': 3, 'Fire': 2, 'Water': 3, 'Void': 1};
    final adversary = derivedFromRings('adversary', rings);
    expect(adversary.endurance, '10');
    expect(adversary.composure, '12');
    expect(adversary.focus, '4');
    expect(adversary.vigilance, '3');
    final minion = derivedFromRings('minion', rings);
    expect(minion.endurance, '5');
    expect(minion.composure, '6');
  });
}
