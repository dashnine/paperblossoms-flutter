import 'package:flutter/material.dart';

import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 5: the skills the school offers, of which players pick a few at
/// character creation (PoW p. 79, Table 2-7).
class SbPage5Skills extends StatelessWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage5Skills({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = state.defaults?.skillCount ?? state.startingSkills.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbSkillsQuestion(target)),
        Text(
          l10n.sbSkillsProgress(
            state.startingSkills.length,
            target,
            state.skillPicks,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        // Table 2-7's count is a suggestion — bundled schools deviate, so
        // editing them must stay possible. Deviation warns, never blocks.
        if (state.startingSkills.isNotEmpty &&
            state.startingSkills.length != target)
          SoftWarning(l10n.sbWarnSkillCount(target)),
        WizMultiSelectChips(
          groups: {
            for (final group in gameData.skillGroups) group.name: group.skills,
          },
          selected: state.startingSkills.toSet(),
          onToggle: (skill, nowSelected) {
            if (nowSelected) {
              state.startingSkills.add(skill);
            } else {
              state.startingSkills.remove(skill);
            }
            state.skillsTouched = true;
            onChanged();
          },
        ),
      ],
    );
  }
}
