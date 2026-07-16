import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 1: Clan and Family (Q1-2) — or region/upbringing for non-samurai.
class Page1ClanFamily extends StatelessWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page1ClanFamily(
      {super.key, required this.wizard, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WizDropdown(
          label: context.l10n.characterTypeLabel,
          value: wizard.characterType,
          options: const [
            characterTypeSamurai,
            characterTypeRonin,
            'Peasant',
            characterTypeGaijin,
          ],
          onChanged: (value) {
            wizard
              ..characterType = value
              ..clan = ''
              ..family = ''
              ..familyRing = ''
              ..region = ''
              ..upbringing = ''
              ..upbringingRing = ''
              ..upbringingSkills = ['', '', '']
              ..school = ''
              ..schoolSkills = [];
            onChanged();
          },
        ),
        if (wizard.isSamurai)
          ..._samuraiQuestions(context)
        else
          ..._roninQuestions(context),
      ],
    );
  }

  List<Widget> _samuraiQuestions(BuildContext context) {
    final clanData = gameData.clanByName(wizard.clan);
    final familyData = gameData.familyByName(wizard.clan, wizard.family);
    return [
      QuestionHeader(context.l10n.wizQ1Clan),
      WizDropdown(
        label: context.l10n.clanLabel,
        value: wizard.clan,
        options: [for (final clan in gameData.clans) clan.name],
        onChanged: (value) {
          wizard
            ..clan = value
            ..family = ''
            ..familyRing = ''
            ..school = ''
            ..schoolSkills = [];
          onChanged();
        },
      ),
      if (clanData != null)
        Text(context.l10n.clanStatsLine(
            trData(clanData.ringIncrease),
            trData(clanData.skillIncrease),
            clanData.status,
            '${clanData.reference}')),
      QuestionHeader(context.l10n.wizQ2Family),
      WizDropdown(
        label: context.l10n.familyLabel,
        value: wizard.family,
        options: [
          for (final family in gameData.familiesOf(wizard.clan)) family.name
        ],
        onChanged: (value) {
          wizard
            ..family = value
            ..familyRing = '';
          onChanged();
        },
      ),
      if (familyData != null) ...[
        Text(context.l10n.familyStatsLine(
            familyData.skillIncrease.map(trData).join(', +1 '),
            familyData.glory,
            familyData.wealth)),
        WizDropdown(
          label: context.l10n.familyRingIncrease,
          value: wizard.familyRing,
          options: familyData.ringIncrease,
          onChanged: (value) {
            wizard.familyRing = value;
            onChanged();
          },
        ),
      ],
    ];
  }

  List<Widget> _roninQuestions(BuildContext context) {
    // Peasants use rōnin regions, like the original.
    final regionType = wizard.characterType == characterTypeGaijin
        ? characterTypeGaijin
        : characterTypeRonin;
    final upbringingData = gameData.upbringingByName(wizard.upbringing);
    List<String> expandAny(List<String> options, List<String> all) =>
        options.length == 1 && options.single == 'any' ? all : options;
    return [
      QuestionHeader(context.l10n.wizQ1Region),
      WizDropdown(
        label: context.l10n.regionLabel,
        value: wizard.region,
        options: [
          for (final region in gameData.regionsByType(regionType)) region.name
        ],
        onChanged: (value) {
          wizard
            ..region = value
            ..school = ''
            ..schoolSkills = [];
          onChanged();
        },
      ),
      QuestionHeader(context.l10n.wizQ2Upbringing),
      WizDropdown(
        label: context.l10n.upbringingLabel,
        value: wizard.upbringing,
        options: [for (final u in gameData.upbringings) u.name],
        onChanged: (value) {
          wizard
            ..upbringing = value
            ..upbringingRing = ''
            ..upbringingSkills = ['', '', ''];
          onChanged();
        },
      ),
      if (upbringingData != null) ...[
        WizDropdown(
          label: context.l10n.upbringingRingIncrease,
          value: wizard.upbringingRing,
          options: expandAny(
              upbringingData.ringIncrease.options, gameData.ringNames()),
          onChanged: (value) {
            wizard.upbringingRing = value;
            onChanged();
          },
        ),
        for (var i = 0; i < upbringingData.skillIncreases.length; i++)
          WizDropdown(
            label: context.l10n.upbringingSkillN(i + 1),
            value: wizard.upbringingSkills[i],
            options: expandAny(upbringingData.skillIncreases[i].options,
                gameData.allSkills()),
            onChanged: (value) {
              wizard.upbringingSkills[i] = value;
              onChanged();
            },
          ),
      ],
    ];
  }
}
