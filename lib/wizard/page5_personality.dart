import 'package:flutter/material.dart';

import '../game_data.dart';
import '../l10n/l10n.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 5: Personality and Behavior (Q14-16).
class Page5Personality extends StatefulWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page5Personality(
      {super.key, required this.wizard, required this.onChanged});

  @override
  State<Page5Personality> createState() => _Page5PersonalityState();
}

class _Page5PersonalityState extends State<Page5Personality> {
  late final TextEditingController _q14;
  late final TextEditingController _q15;
  late final TextEditingController _q16;

  WizardState get wizard => widget.wizard;

  @override
  void initState() {
    super.initState();
    _q14 = TextEditingController(text: wizard.q14Text);
    _q15 = TextEditingController(text: wizard.q15Text);
    _q16 = TextEditingController(text: wizard.q16Text);
  }

  @override
  void dispose() {
    _q14.dispose();
    _q15.dispose();
    _q16.dispose();
    super.dispose();
  }

  List<String> _itemsUnderRarity(int rarity) => [
        for (final weapon in gameData.weaponsUnderRarity(rarity)) weapon.name,
        for (final armor in gameData.armorUnderRarity(rarity)) armor.name,
        for (final effect in gameData.personalEffectsUnderRarity(rarity))
          effect.name,
      ];

  @override
  Widget build(BuildContext context) {
    final samurai = wizard.isSamurai;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(
            samurai ? context.l10n.wizQ14Samurai : context.l10n.wizQ14Ronin),
        if (!samurai)
          WizDropdown(
            label: context.l10n.possessionRarity5,
            value: wizard.q14Item,
            options: _itemsUnderRarity(5),
            onChanged: (value) {
              wizard.q14Item = value;
              widget.onChanged();
            },
          ),
        WizTextArea(
            label: context.l10n.describeIt,
            controller: _q14,
            onChanged: (value) => wizard.q14Text = value),
        QuestionHeader(context.l10n.wizQ15),
        WizTextArea(
            label: context.l10n.answerLabel,
            controller: _q15,
            onChanged: (value) => wizard.q15Text = value),
        QuestionHeader(
            samurai ? context.l10n.wizQ16Samurai : context.l10n.wizQ16Ronin),
        WizDropdown(
          label: context.l10n.mementoRarity7,
          value: wizard.q16Item,
          options: _itemsUnderRarity(7),
          onChanged: (value) {
            wizard.q16Item = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: context.l10n.describeThem,
            controller: _q16,
            onChanged: (value) => wizard.q16Text = value),
      ],
    );
  }
}
