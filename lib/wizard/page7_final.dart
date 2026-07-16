import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 7: Death (Q19-20) and final assembly: name, the running totals, and
/// replacement pickers when a ring or skill exceeds the creation cap of 3.
class Page7Final extends StatelessWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page7Final(
      {super.key, required this.wizard, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final rings = wizard.calcRings();
    final skills = wizard.calcSkills();
    final ringText = [
      for (final entry in rings.rings.entries)
        '${trData(entry.key)} ${entry.value}'
    ].join(', ');
    final skillText = [
      for (final entry in skills.skills.entries)
        if (entry.value > 0) '${trData(entry.key)} ${entry.value}'
    ].join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(context.l10n.wizQ19),
        TextFormField(
          initialValue: wizard.personalName,
          decoration:
              InputDecoration(labelText: context.l10n.personalNameLabel),
          onChanged: (value) {
            wizard.personalName = value;
            onChanged();
          },
        ),
        QuestionHeader(context.l10n.wizQ20),
        TextFormField(
          initialValue: wizard.q20Text,
          decoration: InputDecoration(labelText: context.l10n.answerOptional),
          onChanged: (value) => wizard.q20Text = value,
        ),
        QuestionHeader(context.l10n.ringsSection),
        Text(ringText),
        if (rings.overflow > 0) ...[
          Text(
            context.l10n.ringOverflowMsg(rings.overflow),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (var i = 0; i < 2; i++)
            if (i == 0 || wizard.replacementRings[0].isNotEmpty)
              WizDropdown(
                label: context.l10n.replacementRingN(i + 1),
                value: wizard.replacementRings[i],
                options: [
                  for (final entry in rings.rings.entries)
                    if (entry.value < 3) entry.key
                ],
                onChanged: (value) {
                  wizard.replacementRings[i] = value;
                  onChanged();
                },
              ),
        ],
        QuestionHeader(context.l10n.skillsSection),
        Text(skillText),
        if (skills.overflow > 0) ...[
          Text(
            context.l10n.skillOverflowMsg(skills.overflow),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (var i = 0; i < 3; i++)
            if (i == 0 || wizard.replacementSkills[i - 1].isNotEmpty)
              WizDropdown(
                label: context.l10n.replacementSkillN(i + 1),
                value: wizard.replacementSkills[i],
                options: [
                  for (final skill in gameData.allSkills())
                    if ((skills.skills[skill] ?? 0) < 3) skill
                ],
                onChanged: (value) {
                  wizard.replacementSkills[i] = value;
                  onChanged();
                },
              ),
        ],
        QuestionHeader(context.l10n.techniquesSection),
        Text([
          for (final tech in wizard.techChoices)
            if (tech.isNotEmpty) trData(tech)
        ].join(', ')),
        QuestionHeader(context.l10n.readyHeader),
        Text(context.l10n.finishCreates),
      ],
    );
  }
}
