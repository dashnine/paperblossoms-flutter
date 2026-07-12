import 'package:flutter/material.dart';

import '../game_data.dart';
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
        '${entry.key} ${entry.value}'
    ].join(', ');
    final skillText = [
      for (final entry in skills.skills.entries)
        if (entry.value > 0) '${entry.key} ${entry.value}'
    ].join(', ');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const QuestionHeader('19. What is your name?'),
        TextFormField(
          initialValue: wizard.personalName,
          decoration: const InputDecoration(labelText: 'Personal name'),
          onChanged: (value) {
            wizard.personalName = value;
            onChanged();
          },
        ),
        const QuestionHeader('20. How should your character die?'),
        TextFormField(
          initialValue: wizard.q20Text,
          decoration: const InputDecoration(labelText: 'Answer (optional)'),
          onChanged: (value) => wizard.q20Text = value,
        ),
        const QuestionHeader('Rings'),
        Text(ringText),
        if (rings.overflow > 0) ...[
          Text(
            'A ring exceeds the creation cap of 3. Choose '
            '${rings.overflow} replacement ring(s):',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (var i = 0; i < 2; i++)
            if (i == 0 || wizard.replacementRings[0].isNotEmpty)
              WizDropdown(
                label: 'Replacement ring ${i + 1}',
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
        const QuestionHeader('Skills'),
        Text(skillText),
        if (skills.overflow > 0) ...[
          Text(
            'A skill exceeds the creation cap of 3. Choose '
            '${skills.overflow} replacement skill(s):',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (var i = 0; i < 3; i++)
            if (i == 0 || wizard.replacementSkills[i - 1].isNotEmpty)
              WizDropdown(
                label: 'Replacement skill ${i + 1}',
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
        const QuestionHeader('Techniques'),
        Text([
          for (final tech in wizard.techChoices)
            if (tech.isNotEmpty) tech
        ].join(', ')),
        const QuestionHeader('Ready'),
        const Text('Finish creates the character and opens the editor.'),
      ],
    );
  }
}
