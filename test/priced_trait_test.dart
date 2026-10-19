import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/derived_stats.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/rules_constants.dart';

/// Student of Akodo (BotL p. 9) is the one XP-priced advantage: taking it in
/// play records an Advantage advance on the chosen track, where it earns
/// half credit like any purchase outside the curriculum.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  setUp(() => character.clear());

  test('adding Student of Akodo records a 3 XP advance on the chosen track',
      () {
    final before = xpSpent(character);
    character.addTrait(gameData.advDisadvByName('Student of Akodo')!,
        track: trackTitle);
    expect(character.advDisadv, contains('Student of Akodo'));
    final advance = character.advanceStack.single;
    expect(advance.isAdvantage, isTrue);
    expect(advance.name, 'Student of Akodo');
    expect(advance.track, trackTitle);
    expect(advance.cost, 3);
    expect(xpSpent(character), before + 3);
  });

  test('defaults to the curriculum track and earns half credit toward rank',
      () {
    character.school = 'Hida Defender School';
    final before = recalcRank(character);
    character.addTrait(gameData.advDisadvByName('Student of Akodo')!);
    final after = recalcRank(character);
    expect(character.advanceStack.single.track, trackCurriculum);
    expect(after.rank, before.rank);
    expect(after.curriculumXP, before.curriculumXP + halfCost(3));
    expect(knownTechniques(character), isNot(contains('Student of Akodo')));
  });

  test('on the title track it earns half credit toward the title', () {
    character.titles = ['Deathseeker'];
    final before = recalcTitle(character);
    character.addTrait(gameData.advDisadvByName('Student of Akodo')!,
        track: trackTitle);
    final after = recalcTitle(character);
    expect(after.currentTitle, 'Deathseeker');
    expect(after.titleXP, before.titleXP + halfCost(3));
  });

  test('a Lion takes Student of Akodo for free; anyone else pays', () {
    final student = gameData.advDisadvByName('Student of Akodo')!;
    character.clan = 'Lion';
    expect(character.priceFor(student), 0);
    character.addTrait(student);
    expect(character.advDisadv, ['Student of Akodo']);
    expect(character.advanceStack, isEmpty);

    character.clear();
    character.clan = 'Crab';
    expect(character.priceFor(student), 3);
    character.addTrait(student);
    expect(character.advanceStack.single.cost, 3);
  });

  test('a free trait records no advance, and re-adding is a no-op', () {
    final trait = gameData.advDisadvByName('Large Stature')!;
    character.addTrait(trait);
    character.addTrait(trait);
    expect(character.advDisadv, ['Large Stature']);
    expect(character.advanceStack, isEmpty);
  });

  test('removing the trait removes its advance and nothing else', () {
    character.advanceStack.add(Advance(
        type: advanceTypeSkill,
        name: 'Command',
        track: trackCurriculum,
        cost: 4));
    character.addTrait(gameData.advDisadvByName('Student of Akodo')!);
    character.removeTrait('Student of Akodo');
    expect(character.advDisadv, isNot(contains('Student of Akodo')));
    expect(character.advanceStack.map((a) => a.name), ['Command']);
  });
}
