import 'dart:async';

import 'package:flutter/material.dart';

import '../character_store.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../layout.dart';
import '../screens/character_editor.dart';
import '../theme.dart';
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

  List<String> _titles(AppLocalizations l10n) => [
    l10n.wizPart1,
    l10n.wizPart2,
    l10n.wizPart3,
    l10n.wizPart4,
    l10n.wizPart5,
    l10n.wizPart6,
    l10n.wizPart7,
  ];

  /// Per-page validation, ported from each page's validatePage().
  String? _validate(int page) {
    final l10n = context.l10n;
    switch (page) {
      case 0:
        if (wizard.isSamurai) {
          if (wizard.clan.isEmpty) return l10n.wizErrChooseClan;
          if (wizard.family.isEmpty) return l10n.wizErrChooseFamily;
          if (wizard.familyRing.isEmpty) {
            return l10n.wizErrChooseFamilyRing;
          }
        } else {
          if (wizard.region.isEmpty) return l10n.wizErrChooseRegion;
          if (wizard.upbringing.isEmpty) {
            return l10n.wizErrChooseUpbringing;
          }
          if (wizard.upbringingRing.isEmpty) {
            return l10n.wizErrChooseUpbringingRing;
          }
          final sets =
              gameData.upbringingByName(wizard.upbringing)?.skillIncreases ??
              [];
          for (var i = 0; i < sets.length; i++) {
            if (wizard.upbringingSkills[i].isEmpty) {
              return l10n.wizErrChooseUpbringingSkill(i + 1);
            }
          }
        }
        return null;
      case 1:
        final school = gameData.schoolByName(wizard.school);
        if (school == null) return l10n.wizErrChooseSchool;
        if (wizard.schoolSkills.length < school.startingSkills.size) {
          return l10n.wizErrInsufficientSkills;
        }
        if (wizard.ringChoices.any((ring) => ring.isEmpty)) {
          return l10n.wizErrSchoolRings;
        }
        if (wizard.schoolSpecialRing.isEmpty) {
          return l10n.wizErrStandoutRing;
        }
        if (wizard.techChoices.any((tech) => tech.isEmpty)) {
          return l10n.wizErrStartingTechniques;
        }
        return null;
      case 2:
        if (wizard.q7Positive == null) {
          return l10n.wizErrQ7Option;
        }
        if (wizard.q7Positive == false && wizard.q7Skill.isEmpty) {
          return l10n.wizErrQ7Skill;
        }
        if (wizard.q8Choice.isEmpty) {
          return l10n.wizErrQ8Option;
        }
        if (wizard.q8Choice == 'neg' && wizard.q8Skill.isEmpty) {
          return l10n.wizErrQ8Skill;
        }
        if (wizard.q8Choice == 'mid' && wizard.q8Item.isEmpty) {
          return l10n.wizErrQ8Item;
        }
        return null;
      case 3:
        // Qt only checked Q13 here, but its combo boxes could never be
        // blank (they defaulted to their first entry); require an explicit
        // choice instead.
        if (wizard.distinction.isEmpty) {
          return l10n.wizErrDistinction;
        }
        if (wizard.adversity.isEmpty) {
          return l10n.wizErrAdversity;
        }
        if (wizard.passion.isEmpty) return l10n.wizErrPassion;
        if (wizard.anxiety.isEmpty) return l10n.wizErrAnxiety;
        if (wizard.q13PickedAdvantage == null) {
          return l10n.wizErrQ13Option;
        }
        if (wizard.q13PickedAdvantage == true && wizard.q13Advantage.isEmpty) {
          return l10n.wizErrQ13Advantage;
        }
        if (wizard.q13PickedAdvantage == false &&
            (wizard.q13Disadvantage.isEmpty || wizard.q13Skill.isEmpty)) {
          return l10n.wizErrQ13DisadvSkill;
        }
        return null;
      case 4:
        if (wizard.q16Item.isEmpty) {
          return l10n.wizErrQ16Item;
        }
        return null;
      case 5:
        return null;
      case 6:
        if (wizard.calcRings().overflow > 0) {
          return l10n.wizErrReplacementRings;
        }
        if (wizard.calcSkills().overflow > 0) {
          return l10n.wizErrReplacementSkills;
        }
        return null;
      default:
        return null;
    }
  }

  Future<void> _next() async {
    final error = _validate(_page);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
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

  /// True once the user has answered anything; a blank wizard pops freely.
  bool get _hasProgress =>
      _page > 0 ||
      wizard.clan.isNotEmpty ||
      wizard.family.isNotEmpty ||
      wizard.region.isNotEmpty ||
      wizard.upbringing.isNotEmpty;

  Future<void> _confirmDiscard() async {
    final colors = Theme.of(context).colorScheme;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.wizDiscardTitle),
        content: Text(context.l10n.wizDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.keepEditing),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.discard),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.pop(context);
  }

  Widget _summaryPanel() {
    final rings = wizard.rawRings();
    final skills = wizard.rawSkills();
    Widget row(String name, int value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.ringsSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (final entry in rings.entries)
            row(trData(entry.key), entry.value),
          const SizedBox(height: 12),
          Text(
            context.l10n.skillsSection,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (skills.isEmpty) EmptyHint(context.l10n.wizNoSkillsYet),
          for (final entry in skills.entries)
            row(trData(entry.key), entry.value),
        ],
      ),
    );
  }

  void _showSummarySheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(child: _summaryPanel()),
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

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text(_titles(context.l10n)[_page]),
        actions: [
          if (!context.isExpanded)
            IconButton(
              tooltip: context.l10n.wizSummaryTooltip,
              icon: const Icon(Icons.donut_small_outlined),
              onPressed: _showSummarySheet,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_page + 1) / 7),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Flexible so long locale strings ("Schritt 7 von 7") shrink
              // instead of overflowing a phone-width bar.
              Expanded(
                child: Text(
                  context.l10n.wizStepOf(_page + 1, 7),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_page > 0)
                OutlinedButton(
                  onPressed: () => setState(() => _page--),
                  child: Text(context.l10n.back),
                ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _next,
                child: Text(
                  _page == 6 ? context.l10n.finish : context.l10n.next,
                ),
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

    return PopScope(
      canPop: !_hasProgress,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmDiscard();
      },
      child: scaffold,
    );
  }
}
