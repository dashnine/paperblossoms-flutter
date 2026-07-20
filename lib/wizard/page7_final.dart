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
    // Cap 2 can overflow past the stock three replacement slots. The extra
    // slots are computed locally and only materialized in state when a pick
    // is made (setReplacementSkill) — build must not mutate the wizard.
    var skillSlots = wizard.replacementSkills.length;
    var ringSlots = wizard.replacementRings.length;
    if (wizard.horMode) {
      final filled =
          wizard.replacementSkills.where((s) => s.isNotEmpty).length;
      final needed = filled + skills.overflow;
      if (needed > skillSlots) skillSlots = needed;
      final ringsFilled =
          wizard.replacementRings.where((r) => r.isNotEmpty).length;
      final ringsNeeded = ringsFilled + rings.overflow;
      if (ringsNeeded > ringSlots) ringSlots = ringsNeeded;
    }
    String slotValue(int i) =>
        i < wizard.replacementSkills.length ? wizard.replacementSkills[i] : '';
    String ringSlotValue(int i) =>
        i < wizard.replacementRings.length ? wizard.replacementRings[i] : '';
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
        // HoR Q19: the name question also grants one extra technique.
        if (wizard.horMode)
          WizDropdown(
            label: context.l10n.horQ19TechniqueLabel,
            value: wizard.horQ19Technique,
            options: wizard.horQ19Options(),
            onChanged: (value) {
              wizard.horQ19Technique = value;
              onChanged();
            },
          ),
        QuestionHeader(context.l10n.wizQ20),
        TextFormField(
          initialValue: wizard.q20Text,
          decoration: InputDecoration(labelText: context.l10n.answerOptional),
          onChanged: (value) => wizard.q20Text = value,
        ),
        if (wizard.horMode && wizard.horCampaignTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(context.l10n.horCampaignTitleLine(
                wizard.horCampaignTitle,
                gameData.titleByName(wizard.horCampaignTitle)?.stipendKoku ??
                    0)),
          ),
        QuestionHeader(context.l10n.ringsSection),
        Text(ringText),
        if (rings.overflow > 0) ...[
          Text(
            context.l10n.ringOverflowMsg(rings.overflow),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          for (var i = 0; i < ringSlots; i++)
            if (i == 0 || ringSlotValue(i - 1).isNotEmpty)
              WizDropdown(
                label: context.l10n.replacementRingN(i + 1),
                value: ringSlotValue(i),
                options: [
                  for (final entry in rings.rings.entries)
                    if (entry.value < 3) entry.key
                ],
                onChanged: (value) {
                  wizard.setReplacementRing(i, value);
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
          for (var i = 0; i < skillSlots; i++)
            if (i == 0 || slotValue(i - 1).isNotEmpty)
              WizDropdown(
                label: context.l10n.replacementSkillN(i + 1),
                value: slotValue(i),
                options: [
                  for (final skill in gameData.allSkills())
                    if ((skills.skills[skill] ?? 0) < wizard.skillCap(skill))
                      skill
                ],
                onChanged: (value) {
                  wizard.setReplacementSkill(i, value);
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
