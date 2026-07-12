import 'package:flutter/material.dart';

import '../game_data.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 4: Strengths and Weaknesses (Q9-13).
class Page4Strengths extends StatefulWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page4Strengths(
      {super.key, required this.wizard, required this.onChanged});

  @override
  State<Page4Strengths> createState() => _Page4StrengthsState();
}

class _Page4StrengthsState extends State<Page4Strengths> {
  final _controllers = <String, TextEditingController>{};

  WizardState get wizard => widget.wizard;

  TextEditingController _controller(String key, String initial) =>
      _controllers.putIfAbsent(
          key, () => TextEditingController(text: initial));

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> names(String category) => [
          for (final entry in gameData.advDisadvByCategory(category))
            entry.name
        ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const QuestionHeader(
            '9. What is your greatest accomplishment so far? (Distinction)'),
        WizDropdown(
          label: 'Distinction',
          value: wizard.distinction,
          options: names('Distinctions'),
          onChanged: (value) {
            wizard.distinction = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: 'Describe it',
            controller: _controller('q9', wizard.q9Text),
            onChanged: (value) => wizard.q9Text = value),
        const QuestionHeader(
            "10. What holds your character back? (Adversity)"),
        WizDropdown(
          label: 'Adversity',
          value: wizard.adversity,
          options: names('Adversities'),
          onChanged: (value) {
            wizard.adversity = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: 'Describe it',
            controller: _controller('q10', wizard.q10Text),
            onChanged: (value) => wizard.q10Text = value),
        const QuestionHeader('11. What activity makes you feel at peace? '
            '(Passion)'),
        WizDropdown(
          label: 'Passion',
          value: wizard.passion,
          options: names('Passions'),
          onChanged: (value) {
            wizard.passion = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: 'Describe it',
            controller: _controller('q11', wizard.q11Text),
            onChanged: (value) => wizard.q11Text = value),
        const QuestionHeader('12. What concern or fear keeps you up at '
            'night? (Anxiety)'),
        WizDropdown(
          label: 'Anxiety',
          value: wizard.anxiety,
          options: names('Anxieties'),
          onChanged: (value) {
            wizard.anxiety = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
            label: 'Describe it',
            controller: _controller('q12', wizard.q12Text),
            onChanged: (value) => wizard.q12Text = value),
        const QuestionHeader('13. Who is the person you trust most, and '
            'what is the nature of the relationship?'),
        RadioListTile<bool>(
          dense: true,
          value: true,
          groupValue: wizard.q13PickedAdvantage,
          title: const Text('Gain an advantage'),
          onChanged: (value) {
            wizard
              ..q13PickedAdvantage = true
              ..q13Skill = ''
              ..q13Disadvantage = '';
            widget.onChanged();
          },
        ),
        RadioListTile<bool>(
          dense: true,
          value: false,
          groupValue: wizard.q13PickedAdvantage,
          title: const Text('Gain a disadvantage and +1 skill rank'),
          onChanged: (value) {
            wizard
              ..q13PickedAdvantage = false
              ..q13Advantage = '';
            widget.onChanged();
          },
        ),
        if (wizard.q13PickedAdvantage == true)
          WizDropdown(
            label: 'Advantage',
            value: wizard.q13Advantage,
            options: [
              ...names('Distinctions'),
              ...names('Passions'),
            ],
            onChanged: (value) {
              wizard.q13Advantage = value;
              widget.onChanged();
            },
          ),
        if (wizard.q13PickedAdvantage == false) ...[
          WizDropdown(
            label: 'Disadvantage',
            value: wizard.q13Disadvantage,
            options: [
              ...names('Adversities'),
              ...names('Anxieties'),
            ],
            onChanged: (value) {
              wizard.q13Disadvantage = value;
              widget.onChanged();
            },
          ),
          WizDropdown(
            label: 'Skill',
            value: wizard.q13Skill,
            options: gameData.allSkills(),
            onChanged: (value) {
              wizard.q13Skill = value;
              widget.onChanged();
            },
          ),
        ],
        WizTextArea(
            label: 'Describe the relationship',
            controller: _controller('q13', wizard.q13Text),
            onChanged: (value) => wizard.q13Text = value),
      ],
    );
  }
}
