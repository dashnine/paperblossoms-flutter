import 'dart:async';

import 'package:flutter/material.dart';

import '../character_store.dart';
import '../game_data.dart';
import '../layout.dart';
import '../screens/character_editor.dart';
import 'page1_clan_family.dart';
import 'page2_school.dart';
import 'page3_honor_glory.dart';
import 'page4_strengths.dart';
import 'page5_personality.dart';
import 'page6_ancestry.dart';
import 'page7_final.dart';
import 'wizard_state.dart';

/// The Twenty Questions wizard shell: seven pages with validation gates and
/// a live rings/skills summary (side panel on wide layouts).
class NewCharacterWizard extends StatefulWidget {
  /// Injectable for tests; production always starts blank.
  final WizardState? initialState;

  const NewCharacterWizard({super.key, this.initialState});

  @override
  State<NewCharacterWizard> createState() => _NewCharacterWizardState();
}

class _NewCharacterWizardState extends State<NewCharacterWizard> {
  late final WizardState wizard = widget.initialState ?? WizardState();
  int _page = 0;

  static const _titles = [
    'Part 1: Clan and Family',
    'Part 2: Role and School',
    'Part 3: Honor and Glory',
    'Part 4: Strengths and Weaknesses',
    'Part 5: Personality and Behavior',
    'Part 6: Ancestry and Family',
    'Part 7: Death',
  ];

  /// Per-page validation, ported from each page's validatePage().
  String? _validate(int page) {
    switch (page) {
      case 0:
        if (wizard.isSamurai) {
          if (wizard.clan.isEmpty ||
              wizard.family.isEmpty ||
              wizard.familyRing.isEmpty) {
            return 'Please answer all questions to advance.';
          }
        } else {
          if (wizard.region.isEmpty ||
              wizard.upbringing.isEmpty ||
              wizard.upbringingRing.isEmpty) {
            return 'Please answer all questions to advance.';
          }
          final sets =
              gameData.upbringingByName(wizard.upbringing)?.skillIncreases ??
                  [];
          for (var i = 0; i < sets.length; i++) {
            if (wizard.upbringingSkills[i].isEmpty) {
              return 'Please answer all questions to advance.';
            }
          }
        }
        return null;
      case 1:
        final school = gameData.schoolByName(wizard.school);
        if (school == null) return 'Choose a school.';
        if (wizard.schoolSkills.length < school.startingSkills.size) {
          return 'Insufficient skills selected.';
        }
        if (wizard.ringChoices.any((ring) => ring.isEmpty)) {
          return 'Choose your school ring increases.';
        }
        if (wizard.schoolSpecialRing.isEmpty) {
          return 'Choose your standout ring.';
        }
        if (wizard.techChoices.any((tech) => tech.isEmpty)) {
          return 'Choose your starting techniques.';
        }
        return null;
      case 2:
        if (wizard.q7Positive == null) {
          return 'Choose an option for Question 7.';
        }
        if (wizard.q7Positive == false && wizard.q7Skill.isEmpty) {
          return 'Choose a skill for Question 7.';
        }
        if (wizard.q8Choice.isEmpty) {
          return 'Choose an option for Question 8.';
        }
        if (wizard.q8Choice == 'neg' && wizard.q8Skill.isEmpty) {
          return 'Choose a skill for Question 8.';
        }
        if (wizard.q8Choice == 'mid' && wizard.q8Item.isEmpty) {
          return 'Choose an item for Question 8.';
        }
        return null;
      case 3:
        // Qt only checked Q13 here, but its combo boxes could never be
        // blank (they defaulted to their first entry); require an explicit
        // choice instead.
        if (wizard.distinction.isEmpty ||
            wizard.adversity.isEmpty ||
            wizard.passion.isEmpty ||
            wizard.anxiety.isEmpty) {
          return 'Please answer all questions to advance.';
        }
        if (wizard.q13PickedAdvantage == null) {
          return 'Choose an option for Question 13.';
        }
        if (wizard.q13PickedAdvantage == true &&
            wizard.q13Advantage.isEmpty) {
          return 'Choose an advantage for Question 13.';
        }
        if (wizard.q13PickedAdvantage == false &&
            (wizard.q13Disadvantage.isEmpty || wizard.q13Skill.isEmpty)) {
          return 'Choose a disadvantage and skill for Question 13.';
        }
        return null;
      case 4:
        if (wizard.q16Item.isEmpty) {
          return 'Choose a memento item for Question 16.';
        }
        return null;
      case 5:
        return null;
      case 6:
        if (wizard.calcRings().overflow > 0) {
          return 'Please select replacement ring(s).';
        }
        if (wizard.calcSkills().overflow > 0) {
          return 'Please select replacement skill(s).';
        }
        return null;
      default:
        return null;
    }
  }

  Future<void> _next() async {
    final error = _validate(_page);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_page < 6) {
      setState(() => _page++);
      return;
    }
    // Finish: assemble, open the editor in place of the wizard, and save in
    // the background (the editor's Save button covers any rare I/O failure).
    wizard.assemble();
    unawaited(characterStore.save());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CharacterEditor()),
    );
  }

  Widget _summaryPanel() {
    final rings = wizard.rawRings();
    final skills = wizard.rawSkills();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rings', style: Theme.of(context).textTheme.titleSmall),
          for (final entry in rings.entries)
            Text('  ${entry.key}: ${entry.value}'),
          const SizedBox(height: 12),
          Text('Skills', style: Theme.of(context).textTheme.titleSmall),
          if (skills.isEmpty) const Text('  —'),
          for (final entry in skills.entries)
            Text('  ${entry.key}: ${entry.value}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void refresh() => setState(() {});
    final pages = [
      Page1ClanFamily(wizard: wizard, onChanged: refresh),
      Page2School(wizard: wizard, onChanged: refresh),
      Page3HonorGlory(wizard: wizard, onChanged: refresh),
      Page4Strengths(wizard: wizard, onChanged: refresh),
      Page5Personality(wizard: wizard, onChanged: refresh),
      Page6Ancestry(wizard: wizard, onChanged: refresh),
      Page7Final(wizard: wizard, onChanged: refresh),
    ];
    final content = pages[_page];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_page])),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text('Step ${_page + 1} of 7'),
              const Spacer(),
              if (_page > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _page--),
                  child: const Text('Back'),
                ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _next,
                child: Text(_page == 6 ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ),
      body: context.isExpanded
          ? Row(
              children: [
                Expanded(flex: 3, child: content),
                const VerticalDivider(width: 1),
                SizedBox(width: 260, child: _summaryPanel()),
              ],
            )
          : content,
    );
  }
}
