import 'package:flutter/material.dart';

import '../game_data.dart';
import '../game_data_models.dart';
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
      ..schoolSkills = []
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
            ? '3. What is your school, and what roles does that school '
                'fall into?'
            : '3. What is your school, and what are its associated roles?'),
        CheckboxListTile(
          dense: true,
          title: const Text('Show schools outside my clan'),
          value: wizard.unrestrictedSchool,
          onChanged: (value) {
            wizard.unrestrictedSchool = value ?? false;
            onChanged();
          },
        ),
        WizDropdown(
          label: 'School',
          value: wizard.school,
          options: wizard.schoolOptions(),
          onChanged: _selectSchool,
        ),
        if (school != null) ...[
          Text('${school.role.join(', ')} · Honor ${school.honor} · '
              '${school.reference}'),
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
        label: 'School to impersonate (outfit source)',
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
        label: 'Additional burden',
        value: wizard.schoolOtherChoice,
        options: const ['Haunting', 'Omen of Bad Luck'],
        onChanged: (value) {
          wizard.schoolOtherChoice = value;
          onChanged();
        },
      ));
    }

    // Skills.
    widgets.add(QuestionHeader(
        'Choose ${school.startingSkills.size} school skills '
        '(${wizard.schoolSkills.length} chosen)'));
    widgets.add(Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final skill in school.startingSkills.options)
          FilterChip(
            label: Text(skill),
            selected: wizard.schoolSkills.contains(skill),
            onSelected: (selected) {
              if (selected &&
                  wizard.schoolSkills.length < school.startingSkills.size) {
                wizard.schoolSkills.add(skill);
              } else if (!selected) {
                wizard.schoolSkills.remove(skill);
              }
              onChanged();
            },
          ),
      ],
    ));

    // Rings.
    final anyRingIndexes = [
      for (var i = 0; i < school.ringIncrease.length; i++)
        if (school.ringIncrease[i] == 'any') i
    ];
    if (school.ringIncrease.isNotEmpty) {
      widgets.add(const QuestionHeader('School ring increases'));
      final fixed = [
        for (final ring in school.ringIncrease)
          if (ring != 'any') ring
      ];
      if (fixed.isNotEmpty) widgets.add(Text('Fixed: +1 ${fixed.join(', +1 ')}'));
      for (final index in anyRingIndexes) {
        widgets.add(WizDropdown(
          label: 'Ring of your choice',
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
        ? '4. How do you stand out within your school? (+1 ring)'
        : '4. What gets you in and out of trouble? (+1 ring)'));
    widgets.add(WizDropdown(
      label: 'Standout ring',
      value: wizard.schoolSpecialRing,
      options: gameData.ringNames(),
      onChanged: (value) {
        wizard.schoolSpecialRing = value;
        onChanged();
      },
    ));
    widgets.add(TextFormField(
      initialValue: wizard.q4Text,
      decoration: const InputDecoration(labelText: 'Describe it'),
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
            child: Text('Starting technique: ${set.options.single}'),
          ));
          continue;
        }
        widgets.add(WizDropdown(
          label: 'Choose a starting technique',
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
    widgets.add(const QuestionHeader('Starting outfit'));
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
            label: 'Choose an item',
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
      widgets.add(Text('Included: ${fixedItems.join(', ')}'));
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
