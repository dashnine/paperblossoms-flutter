import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 2: Role and School (Q3-4): school choice drives skill picks, ring
/// increases, starting technique choices, and the starting outfit.
class Page2School extends StatelessWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page2School(
      {super.key, required this.wizard, required this.onChanged});

  void _selectSchool(String name) {
    final school = gameData.schoolByName(name);
    wizard
      ..school = name
      // HoR: +1 in every listed starting skill, no picking.
      ..schoolSkills = wizard.horMode
          ? [...school?.startingSkills.options ?? <String>[]]
          : []
      ..kitsuneSchool = ''
      ..schoolOtherChoice = '';
    // One slot per school ring increase; fixed rings are pre-filled.
    wizard.ringChoices = [
      for (final ring in school?.ringIncrease ?? <String>[])
        ring == 'any' ? '' : ring
    ];
    // One slot per starting technique pick.
    wizard.techChoices = [
      for (final set in school?.startingTechniques ?? <ChoiceSet>[])
        for (var i = 0; i < set.size; i++)
          set.options.length == 1 ? set.options.single : ''
    ];
    _resizeOutfitSlots(school);
    onChanged();
  }

  /// Outfit: multi-option sets get one slot per pick; single-option special
  /// directives spawn special-choice slots.
  void _resizeOutfitSlots(School? outfitSource) {
    final equipSlots = <String>[];
    var specialSlots = 0;
    for (final set in outfitSource?.startingOutfit ?? <ChoiceSet>[]) {
      if (set.options.length > 1) {
        for (var i = 0; i < set.size; i++) {
          equipSlots.add('');
        }
      } else if (set.options.length == 1 &&
          WizardState.equipmentSpecialOptions(set.options.single) != null) {
        specialSlots +=
            WizardState.equipmentSpecialCount(set.options.single);
      }
    }
    wizard.equipChoices = equipSlots;
    wizard.equipSpecialChoices = List.filled(specialSlots, '',
        growable: true);
  }

  @override
  Widget build(BuildContext context) {
    final school = gameData.schoolByName(wizard.school);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(wizard.isSamurai
            ? context.l10n.wizQ3Samurai
            : context.l10n.wizQ3Ronin),
        // HoR bans cross-clan schools outright.
        if (!wizard.horMode)
          CheckboxListTile(
            dense: true,
            title: Text(context.l10n.showSchoolsOutsideClan),
            value: wizard.unrestrictedSchool,
            onChanged: (value) {
              wizard.unrestrictedSchool = value ?? false;
              onChanged();
            },
          ),
        WizDropdown(
          label: context.l10n.schoolLabel,
          value: wizard.school,
          options: wizard.schoolOptions(),
          onChanged: _selectSchool,
        ),
        if (school != null) ...[
          Text(context.l10n.schoolStatsLine(school.role.map(trData).join(', '),
              school.honor, '${school.reference}')),
          ..._schoolDetail(context, school),
        ],
      ],
    );
  }

  List<Widget> _schoolDetail(BuildContext context, School school) {
    final widgets = <Widget>[];

    // Special-case schools, as in the original.
    if (school.name == 'Kitsune Impersonator Tradition') {
      widgets.add(WizDropdown(
        label: context.l10n.kitsuneImpersonate,
        value: wizard.kitsuneSchool,
        options: [
          for (final s in gameData.schools)
            if (s.name != school.name) s.name
        ],
        onChanged: (value) {
          wizard.kitsuneSchool = value;
          _resizeOutfitSlots(gameData.schoolByName(value) ?? school);
          onChanged();
        },
      ));
    }
    if (school.name == "Mazoku's Enforcer Tradition") {
      widgets.add(WizDropdown(
        label: context.l10n.additionalBurden,
        value: wizard.schoolOtherChoice,
        options: const ['Haunting', 'Omen of Bad Luck'],
        onChanged: (value) {
          wizard.schoolOtherChoice = value;
          onChanged();
        },
      ));
    }

    // Skills. HoR grants every listed skill; the book has the player choose
    // all but two.
    if (wizard.horMode) {
      widgets.add(QuestionHeader(context.l10n.horAllSchoolSkills));
      widgets.add(Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final skill in school.startingSkills.options)
            Chip(label: Text(trData(skill))),
        ],
      ));
    } else {
      widgets.add(QuestionHeader(context.l10n.chooseSchoolSkills(
          school.startingSkills.size, wizard.schoolSkills.length)));
      widgets.add(Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final skill in school.startingSkills.options)
            FilterChip(
              label: Text(trData(skill)),
              selected: wizard.schoolSkills.contains(skill),
              onSelected: (selected) {
                if (selected &&
                    wizard.schoolSkills.length <
                        school.startingSkills.size) {
                  wizard.schoolSkills.add(skill);
                } else if (!selected) {
                  wizard.schoolSkills.remove(skill);
                }
                onChanged();
              },
            ),
        ],
      ));
    }

    // Rings.
    final anyRingIndexes = [
      for (var i = 0; i < school.ringIncrease.length; i++)
        if (school.ringIncrease[i] == 'any') i
    ];
    if (school.ringIncrease.isNotEmpty) {
      widgets.add(QuestionHeader(context.l10n.schoolRingIncreases));
      final fixed = [
        for (final ring in school.ringIncrease)
          if (ring != 'any') ring
      ];
      if (fixed.isNotEmpty) {
        widgets.add(
            Text(context.l10n.fixedRings(fixed.map(trData).join(', +1 '))));
      }
      for (final index in anyRingIndexes) {
        widgets.add(WizDropdown(
          label: context.l10n.ringOfYourChoice,
          value: wizard.ringChoices[index],
          options: gameData.ringNames(),
          onChanged: (value) {
            wizard.ringChoices[index] = value;
            onChanged();
          },
        ));
      }
    }

    // Q4 standout ring (samurai only in the original's phrasing, but the
    // control applies to all types).
    widgets.add(QuestionHeader(wizard.isSamurai
        ? context.l10n.wizQ4Samurai
        : context.l10n.wizQ4Ronin));
    widgets.add(WizDropdown(
      label: context.l10n.standoutRing,
      value: wizard.schoolSpecialRing,
      options: gameData.ringNames(),
      onChanged: (value) {
        wizard.schoolSpecialRing = value;
        onChanged();
      },
    ));
    widgets.add(TextFormField(
      initialValue: wizard.q4Text,
      decoration: InputDecoration(labelText: context.l10n.describeIt),
      onChanged: (value) => wizard.q4Text = value,
    ));

    // Techniques.
    var techSlot = 0;
    for (final set in school.startingTechniques) {
      for (var i = 0; i < set.size; i++) {
        final slot = techSlot++;
        if (set.options.length == 1) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(context.l10n
                .startingTechniqueFixed(trData(set.options.single))),
          ));
          continue;
        }
        widgets.add(WizDropdown(
          label: context.l10n.chooseStartingTechnique,
          value: wizard.techChoices[slot],
          options: wizard.expandTechniqueOptions(set),
          onChanged: (value) {
            wizard.techChoices[slot] = value;
            onChanged();
          },
        ));
      }
    }

    // Outfit.
    widgets.add(QuestionHeader(context.l10n.startingOutfit));
    final outfitSource = school.name == 'Kitsune Impersonator Tradition' &&
            wizard.kitsuneSchool.isNotEmpty
        ? gameData.schoolByName(wizard.kitsuneSchool) ?? school
        : school;
    final fixedItems = <String>[];
    var equipSlot = 0;
    final specialDirectives = <String>[];
    for (final set in outfitSource.startingOutfit) {
      if (set.options.length > 1) {
        for (var i = 0; i < set.size; i++) {
          final slot = equipSlot++;
          if (slot >= wizard.equipChoices.length) continue;
          widgets.add(WizDropdown(
            label: context.l10n.chooseAnItem,
            value: wizard.equipChoices[slot],
            options: set.options,
            onChanged: (value) {
              wizard.equipChoices[slot] = value;
              onChanged();
            },
          ));
        }
      } else if (set.options.length == 1) {
        final only = set.options.single;
        if (WizardState.equipmentSpecialOptions(only) != null) {
          specialDirectives.add(only);
        } else if (only.isNotEmpty) {
          fixedItems.add(only);
        }
      }
    }
    if (fixedItems.isNotEmpty) {
      widgets.add(Text(
          context.l10n.includedItems(fixedItems.map(trData).join(', '))));
    }
    var specialSlot = 0;
    for (final directive in specialDirectives) {
      final options = WizardState.equipmentSpecialOptions(directive)!;
      for (var i = 0;
          i < WizardState.equipmentSpecialCount(directive);
          i++) {
        final slot = specialSlot++;
        if (slot >= wizard.equipSpecialChoices.length) continue;
        widgets.add(WizDropdown(
          label: directive,
          value: wizard.equipSpecialChoices[slot],
          options: options,
          onChanged: (value) {
            wizard.equipSpecialChoices[slot] = value;
            onChanged();
          },
        ));
      }
    }
    return widgets;
  }
}
