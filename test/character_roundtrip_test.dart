import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/advance.dart';
import 'package:paperblossoms/character.dart';
import 'package:paperblossoms/item.dart';
import 'package:paperblossoms/rules_constants.dart';

void main() {
  test('character JSON roundtrips through save format', () {
    character.clear();
    character.name = 'Tetsu';
    character.clan = 'Crab';
    character.family = 'Hida';
    character.school = 'Hida Defender School';
    character.ninjo = 'Protect the weak';
    character.giri = 'Guard the Wall';
    character.heritage = 'Glorious Sacrifice';
    character.notes = 'Some notes';
    character.titles = ['Deathseeker'];
    character.techniques = ['Striking as Earth'];
    character.advDisadv = ['Blunt'];
    character.baseSkills = {'Command': 1, 'Fitness': 2};
    character.baseRings = {ringAir: 1, ringEarth: 3};
    character.honor = 40;
    character.glory = 44;
    character.status = 30;
    character.koku = 3;
    character.bu = 1;
    character.zeni = 5;
    character.totalXP = 10;
    character.fatigue = 5;
    character.strife = 3;
    character.conditions = ['Bleeding', 'Lightly Wounded (Fire)'];
    character.advanceStack = [
      Advance(
          type: advanceTypeSkill,
          name: 'Command',
          track: trackCurriculum,
          cost: 4),
      Advance(
          type: advanceTypeTechnique,
          name: 'Striking as Water',
          track: 'GM award',
          cost: 0),
    ];
    character.equipment = [
      Item(
          type: itemTypeWeapon,
          name: 'Katana',
          category: 'Swords',
          skill: 'Melee',
          grip: '1-hand',
          rangeMin: 1,
          rangeMax: 1,
          damage: 4,
          deadliness: 5,
          qualities: ['Ceremonial', 'Razor-Edged'],
          price: 15,
          unit: 'koku',
          rarity: 7),
    ];
    character.bonds = [CharacterBond(name: 'Companion', rank: 2)];
    character.portraitB64 = 'aGVsbG8=';
    character.identityLocked = true;

    final json = jsonEncode(character.toJson());
    final saved = character.toJson();
    character.clear();
    character.loadFromJson(jsonDecode(json));

    expect(character.toJson(), saved);
    expect(character.name, 'Tetsu');
    expect(character.identityLocked, isTrue);
    expect(character.advanceStack[1].track, 'GM award');
    expect(character.advanceStack[1].isFree, isTrue);
    expect(character.equipment.single.qualities, ['Ceremonial', 'Razor-Edged']);
    expect(character.bonds.single.rank, 2);
    expect(character.fatigue, 5);
    expect(character.strife, 3);
    expect(character.conditions, ['Bleeding', 'Lightly Wounded (Fire)']);
  });

  test('portraitBytes decodes valid data and nulls out corrupt data', () {
    character.clear();
    expect(character.portraitBytes, isNull);
    character.portraitB64 = 'aGVsbG8=';
    expect(character.portraitBytes, [104, 101, 108, 108, 111]);
    character.portraitB64 = 'not valid base64!!';
    expect(character.portraitBytes, isNull);
  });

  test('missing fields fall back to defaults', () {
    character.loadFromJson({'name': 'Lonely'});
    expect(character.name, 'Lonely');
    expect(character.advanceStack, isEmpty);
    expect(character.baseRings, isEmpty);
    expect(character.honor, 0);
    expect(character.fatigue, 0);
    expect(character.strife, 0);
    expect(character.conditions, isEmpty);
    expect(character.uuid, isNotEmpty);
    // Loading always locks identity, regardless of the saved/absent flag.
    expect(character.identityLocked, isTrue);
  });
}
