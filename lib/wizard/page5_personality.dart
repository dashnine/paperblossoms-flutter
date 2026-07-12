import 'package:flutter/material.dart';

import '../game_data.dart';
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
        QuestionHeader(samurai
            ? '14. What do people notice first upon encountering you?'
            : "14. What is your character's most prized possession?"),
        if (!samurai)
          WizDropdown(
            label: 'Possession (rarity 5 or lower)',
            value: wizard.q14Item,
            options: _itemsUnderRarity(5),
            onChanged: (value) {
              wizard.q14Item = value;
              widget.onChanged();
            },
          ),
        WizTextArea(
            label: 'Describe it',
            controller: _q14,
            onChanged: (value) => wizard.q14Text = value),
        const QuestionHeader('15. How do you react to stressful situations?'),
        WizTextArea(
            label: 'Answer',
            controller: _q15,
            onChanged: (value) => wizard.q15Text = value),
        QuestionHeader(samurai
            ? '16. What are your preexisting relationships with other '
                'clans, families, organizations, and traditions?'
            : '16. What are your relationships to your family, the clans, '
                'peasants, and others?'),
        WizDropdown(
          label: 'Memento item (rarity 7 or lower)',
          value: wizard.q16Item,
          options: _itemsUnderRarity(7),
          onChanged: (value) {
            wizard.q16Item = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: 'Describe them',
            controller: _q16,
            onChanged: (value) => wizard.q16Text = value),
      ],
    );
  }
}
