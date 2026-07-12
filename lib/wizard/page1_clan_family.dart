import 'package:flutter/material.dart';

import '../game_data.dart';
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
          label: 'Character type',
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
        if (wizard.isSamurai) ..._samuraiQuestions() else ..._roninQuestions(),
      ],
    );
  }

  List<Widget> _samuraiQuestions() {
    final clanData = gameData.clanByName(wizard.clan);
    final familyData = gameData.familyByName(wizard.clan, wizard.family);
    return [
      const QuestionHeader('1. What clan does your character belong to?'),
      WizDropdown(
        label: 'Clan',
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
        Text('+1 ${clanData.ringIncrease} · +1 ${clanData.skillIncrease} · '
            'Status ${clanData.status} · ${clanData.reference}'),
      const QuestionHeader('2. What family does your character belong to?'),
      WizDropdown(
        label: 'Family',
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
        Text('+1 ${familyData.skillIncrease.join(', +1 ')} · '
            'Glory ${familyData.glory} · Wealth ${familyData.wealth} koku'),
        WizDropdown(
          label: 'Family ring increase',
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

  List<Widget> _roninQuestions() {
    // Peasants use rōnin regions, like the original.
    final regionType = wizard.characterType == characterTypeGaijin
        ? characterTypeGaijin
        : characterTypeRonin;
    final upbringingData = gameData.upbringingByName(wizard.upbringing);
    List<String> expandAny(List<String> options, List<String> all) =>
        options.length == 1 && options.single == 'any' ? all : options;
    return [
      const QuestionHeader('1. Where does your character come from?'),
      WizDropdown(
        label: 'Region',
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
      const QuestionHeader('2. What was your character\'s upbringing?'),
      WizDropdown(
        label: 'Upbringing',
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
          label: 'Upbringing ring increase',
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
            label: 'Upbringing skill ${i + 1}',
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
