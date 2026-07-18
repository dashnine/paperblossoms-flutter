import 'package:flutter_test/flutter_test.dart';
import 'package:paperblossoms/game_data.dart';
import 'package:paperblossoms/wizard/school_builder/school_builder_data.dart';
import 'package:paperblossoms/wizard/wizard_state.dart';

// Every canonical name in the school-builder tables must exist in the loaded
// game data (diacritics and bracketed skill names included), or the wizard
// would emit schools the engine cannot resolve.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await gameData.load();
  });

  test('every role has defaults and appears in the bundled data', () {
    final dataRoles = {for (final s in gameData.schools) ...s.role};
    for (final role in schoolBuilderRoles) {
      expect(roleDefaults, contains(role));
      expect(dataRoles, contains(role));
    }
    expect(roleDefaults.keys.toSet(), schoolBuilderRoles.toSet());
  });

  test('suggested rings resolve', () {
    final rings = gameData.ringNames().toSet();
    roleDefaults.forEach((role, defaults) {
      for (final ring in defaults.suggestedRings) {
        expect(rings, contains(ring), reason: role);
      }
    });
  });

  test('common skills resolve and cover the pick counts', () {
    final skills = gameData.allSkills().toSet();
    roleDefaults.forEach((role, defaults) {
      for (final skill in defaults.commonSkills) {
        expect(skills, contains(skill), reason: role);
      }
      expect(defaults.commonSkills.length,
          greaterThanOrEqualTo(defaults.skillCount),
          reason: role);
      expect(defaults.skillChoose, lessThanOrEqualTo(defaults.skillCount),
          reason: role);
    });
  });

  test('technique categories resolve', () {
    final categories = gameData.techniqueCategories().toSet();
    expect(categories, contains(ritualsCategory));
    for (final cat in [
      ...commonTechniqueCategories,
      ...warnTechniqueCategories
    ]) {
      expect(categories, contains(cat));
    }
    roleDefaults.forEach((role, defaults) {
      for (final cat in defaults.suggestedTechCategories) {
        expect(categories, contains(cat), reason: role);
      }
    });
    expect(gameData.techniqueByName(communeWithSpirits), isNotNull);
  });

  test('suggested outfits resolve to items or wizard directives', () {
    roleDefaults.forEach((role, defaults) {
      for (final row in defaults.suggestedOutfit) {
        expect(row.size, lessThanOrEqualTo(row.options.length), reason: role);
        for (final entry in row.options) {
          // 'Traveling Pack' is the same freebie every bundled outfit uses:
          // no item entry exists, so assembly makes a bare personal effect.
          expect(
              gameData.itemTypeOf(entry).isNotEmpty ||
                  WizardState.equipmentSpecialOptions(entry) != null ||
                  entry == 'Traveling Pack',
              isTrue,
              reason: '$role outfit entry "$entry" is neither an item nor a '
                  'directive the wizard resolves');
        }
      }
    });
  });

  test('rarity-directive outfit entries used by bundled schools resolve', () {
    // The character wizard turns these directive strings into item pickers;
    // a directive without a handler silently becomes a bare personal effect
    // named after the directive.
    final directives = {
      for (final s in gameData.schools)
        for (final set in s.startingOutfit)
          for (final o in set.options)
            if (o.contains('Rarity') && o.contains('or Lower')) o
    };
    for (final directive in directives) {
      expect(WizardState.equipmentSpecialOptions(directive), isNotNull,
          reason: '"$directive" has no equipmentSpecialOptions case');
    }
  });

  test('extra affiliations match bundled school clans', () {
    final schoolClans = {for (final s in gameData.schools) s.clan};
    for (final affiliation in extraAffiliations) {
      expect(schoolClans, contains(affiliation));
    }
  });

  test('ability templates are role-gated to real roles and carry text', () {
    for (final t in [...schoolAbilityTemplates, ...masteryAbilityTemplates]) {
      for (final role in t.roles) {
        expect(schoolBuilderRoles, contains(role), reason: t.label);
      }
      expect(t.label, isNotEmpty);
      expect(t.page, isNotEmpty);
      expect(t.text, isNotEmpty, reason: t.label);
    }
    expect(schoolAbilityTemplates, hasLength(9)); // Table 2-4
    expect(masteryAbilityTemplates, hasLength(11)); // Table 2-10
  });

  test('suggested honor values sit in the bundled range', () {
    roleDefaults.forEach((role, defaults) {
      expect(defaults.suggestedHonor, inInclusiveRange(18, 55), reason: role);
    });
  });
}
