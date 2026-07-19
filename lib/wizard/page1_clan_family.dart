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
          // HoR allows only Great Clan samurai and rōnin.
          options: wizard.horMode
              ? const [characterTypeSamurai, characterTypeRonin]
              : const [
                  characterTypeSamurai,
                  characterTypeRonin,
                  'Peasant',
                  characterTypeGaijin,
                ],
          onChanged: (value) {
            wizard.setCharacterType(value);
            onChanged();
          },
        ),
        if (wizard.isSamurai)
          ..._samuraiQuestions(context)
        else if (wizard.horMode)
          ..._horRoninQuestions(context)
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

  /// HoR rōnin: fixed clan block (+1 any ring, +1 Survival, Status 22) and
  /// a campaign background instead of region/upbringing.
  List<Widget> _horRoninQuestions(BuildContext context) {
    final l10n = context.l10n;
    final hor = gameData.hor;
    final background = hor.backgroundByName(wizard.horBackground);
    List<String> orAny(List<String> options, List<String> all) =>
        options.isEmpty ? all : options;
    return [
      QuestionHeader(l10n.wizQ1Clan),
      Text(l10n.horRoninStatsLine(
          trData(hor.roninSkillIncrease), hor.roninStatus)),
      WizDropdown(
        label: l10n.horRoninRingLabel,
        value: wizard.horRoninRing,
        options: gameData.ringNames(),
        onChanged: (value) {
          wizard.horRoninRing = value;
          onChanged();
        },
      ),
      QuestionHeader(l10n.wizQ2Family),
      WizDropdown(
        label: l10n.horBackgroundLabel,
        value: wizard.horBackground,
        options: [for (final b in hor.roninBackgrounds) b.name],
        onChanged: (value) {
          wizard.selectHorBackground(value);
          onChanged();
        },
      ),
      if (background != null) ...[
        Text(l10n.horBackgroundStatsLine(
            background.glory, '${background.startingWealth}')),
        WizDropdown(
          label: l10n.horBackgroundRingLabel,
          value: wizard.horBackgroundRing,
          options: orAny(background.ringOptions, gameData.ringNames()),
          onChanged: (value) {
            wizard.horBackgroundRing = value;
            onChanged();
          },
        ),
        // Bounded by the state list too: an injected state that predates
        // [selectHorBackground] must not index past what it allocated.
        for (var i = 0;
            i < background.skillChoices.length &&
                i < wizard.horBackgroundSkills.length;
            i++)
          WizDropdown(
            label: l10n.horBackgroundSkillN(i + 1),
            value: wizard.horBackgroundSkills[i],
            options: orAny(background.skillChoices[i], gameData.allSkills()),
            onChanged: (value) {
              wizard.horBackgroundSkills[i] = value;
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
