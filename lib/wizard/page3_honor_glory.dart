import 'package:flutter/material.dart';

import '../game_data.dart';
import '../l10n/l10n.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 3: Honor and Glory (Q5-8).
class Page3HonorGlory extends StatefulWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page3HonorGlory(
      {super.key, required this.wizard, required this.onChanged});

  @override
  State<Page3HonorGlory> createState() => _Page3HonorGloryState();
}

class _Page3HonorGloryState extends State<Page3HonorGlory> {
  late final TextEditingController _q5;
  late final TextEditingController _q6;
  late final TextEditingController _q7;
  late final TextEditingController _q8;

  WizardState get wizard => widget.wizard;

  /// HoR Q7 options, preferring skills not already increased by an earlier
  /// question (the campaign allows repeats only when every option is held).
  List<String> _horQ7Options() {
    final base =
        wizard.horQ7SkillOptions(positive: wizard.q7Positive == true);
    final unheld =
        wizard.unheldSkillOptions(except: wizard.q7Skill).toSet();
    final fresh = [
      for (final skill in base)
        if (unheld.contains(skill)) skill
    ];
    return fresh.isEmpty ? base : fresh;
  }

  @override
  void initState() {
    super.initState();
    _q5 = TextEditingController(text: wizard.q5Text);
    _q6 = TextEditingController(text: wizard.q6Text);
    _q7 = TextEditingController(text: wizard.q7Text);
    _q8 = TextEditingController(text: wizard.q8Text);
  }

  @override
  void dispose() {
    _q5.dispose();
    _q6.dispose();
    _q7.dispose();
    _q8.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final samurai = wizard.isSamurai;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(
            samurai ? context.l10n.wizQ5Samurai : context.l10n.wizQ5Ronin),
        if (wizard.horMode) ...[
          // All PCs serve their clan champion or one of the five Regent
          // services; rōnin must serve a Regent.
          WizDropdown(
            label: context.l10n.horServiceLabel,
            value: wizard.horService,
            options: [
              for (final service in horServiceTitles.keys)
                if (samurai || service != 'Clan Champion') service
            ],
            onChanged: (value) {
              wizard.horService = value;
              widget.onChanged();
            },
          ),
          WizDropdown(
            label: context.l10n.horRelatedSkill,
            value: wizard.horQ5Skill,
            options: gameData.allSkills(),
            onChanged: (value) {
              wizard.horQ5Skill = value;
              // Q6 must differ from Q5; a pick that now collides would
              // render blank while silently failing validation.
              if (wizard.horQ6Skill == value) wizard.horQ6Skill = '';
              widget.onChanged();
            },
          ),
        ],
        WizTextArea(
            label: context.l10n.answerLabel,
            controller: _q5,
            onChanged: (value) => wizard.q5Text = value),
        QuestionHeader(
            samurai ? context.l10n.wizQ6Samurai : context.l10n.wizQ6Ronin),
        if (wizard.horMode)
          WizDropdown(
            label: context.l10n.horRelatedSkill,
            value: wizard.horQ6Skill,
            options: [
              for (final skill in gameData.allSkills())
                if (skill != wizard.horQ5Skill) skill
            ],
            onChanged: (value) {
              wizard.horQ6Skill = value;
              widget.onChanged();
            },
          ),
        WizTextArea(
            label: context.l10n.answerLabel,
            controller: _q6,
            onChanged: (value) => wizard.q6Text = value),
        QuestionHeader(
            samurai ? context.l10n.wizQ7Samurai : context.l10n.wizQ7Ronin),
        RadioListTile<bool>(
          dense: true,
          value: true,
          groupValue: wizard.q7Positive,
          title: Text(wizard.horMode
              ? context.l10n.horQ7Positive
              : context.l10n.q7Positive),
          onChanged: (value) {
            wizard
              ..q7Positive = true
              ..q7Skill = '';
            widget.onChanged();
          },
        ),
        RadioListTile<bool>(
          dense: true,
          value: false,
          groupValue: wizard.q7Positive,
          title: Text(wizard.horMode
              ? context.l10n.horQ7Negative
              : context.l10n.q7Negative),
          onChanged: (value) {
            wizard.q7Positive = false;
            if (wizard.horMode) wizard.q7Skill = '';
            widget.onChanged();
          },
        ),
        if (wizard.horMode
            ? wizard.q7Positive != null
            : wizard.q7Positive == false)
          WizDropdown(
            label: context.l10n.advTypeSkill,
            value: wizard.q7Skill,
            options: wizard.horMode
                ? _horQ7Options()
                : wizard.unheldSkillOptions(except: wizard.q7Skill),
            onChanged: (value) {
              wizard.q7Skill = value;
              widget.onChanged();
            },
          ),
        WizTextArea(
            label: context.l10n.describeIt,
            controller: _q7,
            onChanged: (value) => wizard.q7Text = value),
        QuestionHeader(context.l10n.wizQ8),
        RadioListTile<String>(
          dense: true,
          value: 'pos',
          groupValue: wizard.q8Choice,
          title: Text(
              wizard.horMode ? context.l10n.horQ8Pos : context.l10n.q8Pos),
          onChanged: (value) {
            wizard
              ..q8Choice = 'pos'
              ..q8Skill = ''
              ..q8Item = '';
            widget.onChanged();
          },
        ),
        if (!samurai && !wizard.horMode)
          RadioListTile<String>(
            dense: true,
            value: 'mid',
            groupValue: wizard.q8Choice,
            title: Text(context.l10n.q8Mid),
            onChanged: (value) {
              wizard
                ..q8Choice = 'mid'
                ..q8Skill = '';
              widget.onChanged();
            },
          ),
        RadioListTile<String>(
          dense: true,
          value: 'neg',
          groupValue: wizard.q8Choice,
          title: Text(
              wizard.horMode ? context.l10n.horQ8Neg : context.l10n.q8Neg),
          onChanged: (value) {
            wizard
              ..q8Choice = 'neg'
              ..q8Skill = ''
              ..q8Item = '';
            widget.onChanged();
          },
        ),
        if (wizard.q8Choice == 'neg' ||
            (wizard.horMode && wizard.q8Choice == 'pos'))
          WizDropdown(
            label: context.l10n.advTypeSkill,
            value: wizard.q8Skill,
            options: wizard.horMode && wizard.q8Choice == 'pos'
                ? horQ8PosSkills
                : question8Skills,
            onChanged: (value) {
              wizard.q8Skill = value;
              widget.onChanged();
            },
          ),
        if (wizard.q8Choice == 'mid')
          WizDropdown(
            label: context.l10n.itemLabel,
            value: wizard.q8Item,
            options: [
              for (final weapon in gameData.weaponsUnderRarity(5))
                weapon.name,
              for (final armor in gameData.armorUnderRarity(5)) armor.name,
              for (final effect in gameData.personalEffectsUnderRarity(5))
                effect.name,
            ],
            onChanged: (value) {
              wizard.q8Item = value;
              widget.onChanged();
            },
          ),
        WizTextArea(
            label: context.l10n.describeIt,
            controller: _q8,
            onChanged: (value) => wizard.q8Text = value),
      ],
    );
  }
}
