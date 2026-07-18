import 'dart:async';

import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../../layout.dart';
import '../../user_data_store.dart';
import '../wizard_state.dart';
import 'sb_page1_roles.dart';
import 'sb_page2_affiliation.dart';
import 'sb_page3_ability.dart';
import 'sb_page4_rings.dart';
import 'sb_page5_skills.dart';
import 'sb_page6_techniques.dart';
import 'sb_page7_curriculum.dart';
import 'sb_page8_outfit.dart';
import 'sb_page9_final.dart';
import 'school_builder_state.dart';

/// The PoW "Building a School" wizard shell (pp. 76-84): nine steps with
/// validation gates and a school-so-far side panel, following
/// [NewCharacterWizard]. Hard errors block Next; the book's "should" rules
/// render as inline soft warnings on the pages instead.
class SchoolBuilderWizard extends StatefulWidget {
  /// Injectable for tests and edit mode; blank for a new school.
  final SchoolBuilderState? initialState;

  /// Set in edit mode: the school being edited, so renaming replaces it.
  final String? originalName;

  /// Starting page index; preview/tests only (production starts at 0).
  final int initialPage;

  const SchoolBuilderWizard({
    super.key,
    this.initialState,
    this.originalName,
    this.initialPage = 0,
  });

  @override
  State<SchoolBuilderWizard> createState() => _SchoolBuilderWizardState();
}

class _SchoolBuilderWizardState extends State<SchoolBuilderWizard> {
  late final SchoolBuilderState state =
      widget.initialState ?? SchoolBuilderState();
  late int _page = widget.initialPage;

  List<String> _titles(AppLocalizations l10n) => [
    l10n.sbStep1,
    l10n.sbStep2,
    l10n.sbStep3,
    l10n.sbStep4,
    l10n.sbStep5,
    l10n.sbStep6,
    l10n.sbStep7,
    l10n.sbStep8,
    l10n.sbStep9,
  ];

  String? _validate(int page) {
    final l10n = context.l10n;
    switch (page) {
      case 0:
        if (state.roles.isEmpty) return l10n.sbErrChooseRole;
        return null;
      case 2:
        if (state.abilityName.trim().isEmpty) return l10n.sbErrAbilityName;
        return null;
      case 3:
        if (state.ringIncrease.any((ring) => ring.isEmpty)) {
          return l10n.sbErrRings;
        }
        return null;
      case 4:
        // The role's Table 2-7 count is a soft suggestion (page 5 warns);
        // the hard rules are only what the data model demands.
        if (state.startingSkills.isEmpty) return l10n.sbErrNoSkills;
        if (state.skillPicks > state.startingSkills.length) {
          return l10n.sbErrSkillPicks(state.skillPicks);
        }
        return null;
      case 5:
        if (state.techniquesAvailable.isEmpty) return l10n.sbErrCategory;
        if (state.startingTechniques.any(
          (set) =>
              set.options.isEmpty ||
              set.size < 1 ||
              set.size > set.options.length,
        )) {
          return l10n.sbErrChoiceSet;
        }
        return null;
      case 6:
        for (var rank = 1; rank <= 5; rank++) {
          if (!state.rankComplete(rank)) {
            return l10n.sbErrCurriculumIncomplete(rank);
          }
        }
        if (state.masteryName.trim().isEmpty) return l10n.sbErrMasteryName;
        return null;
      case 7:
        if (state.startingOutfit.any(
          (set) =>
              set.options.isEmpty ||
              set.size < 1 ||
              set.size > set.options.length,
        )) {
          return l10n.sbErrChoiceSet;
        }
        // The character wizard only spawns a picker for a rarity directive
        // when it is a row's sole option; picked from a mixed row it would
        // silently produce no item (page2_school._resizeOutfitSlots).
        if (state.startingOutfit.any(
          (set) =>
              set.options.length > 1 &&
              set.options.any(
                (o) => WizardState.equipmentSpecialOptions(o) != null,
              ),
        )) {
          return l10n.sbErrDirectiveAlone;
        }
        return null;
      case 8:
        if (state.name.trim().isEmpty) return l10n.sbErrName;
        return null;
      default:
        return null;
    }
  }

  /// True when [name] belongs to a bundled school (i.e. not a homebrew
  /// one); saving would override the official entry.
  bool _isBundledName(String name) =>
      gameData.schoolByName(name) != null &&
      !userDataStore.homebrewSchools.any((s) => s.name == name);

  Future<bool> _confirm(String title, String body) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.sbSaveAnyway),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  /// Updates one description in memory unless doing so would wipe text a
  /// *different* school still resolves by this name — ability names come
  /// from shared templates, so clearing is only safe when this school owns
  /// the name outright.
  void _updateOwnedDescription(String name, String desc, String short) {
    if (desc.isEmpty &&
        short.isEmpty &&
        gameData.schools.any(
          (s) =>
              s.name != state.name &&
              (s.name == name ||
                  s.schoolAbility == name ||
                  s.masteryAbility == name),
        )) {
      return;
    }
    userDataStore.updateDescription(name, desc, short);
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    final name = state.name.trim();
    state.name = name;
    // Trim the ability names too: the school record and the description
    // entry must key on the same string or the text becomes unreachable.
    state.abilityName = state.abilityName.trim();
    state.masteryName = state.masteryName.trim();
    if (name != widget.originalName) {
      if (_isBundledName(name)) {
        if (!await _confirm(
          l10n.sbOverrideBundledTitle,
          l10n.sbOverrideBundledBody(name),
        )) {
          return;
        }
      } else if (gameData.schoolByName(name) != null) {
        if (!await _confirm(
          l10n.sbOverwriteHomebrewTitle,
          l10n.sbOverwriteHomebrewBody(name),
        )) {
          return;
        }
      }
    }
    if (!mounted) return;
    // Memory is updated synchronously here and persisted in the background,
    // like the character wizard's finish (a rare I/O failure is recoverable
    // via re-save; the manager page reads from memory).
    final persistSchool = userDataStore.saveHomebrewSchool(
      state.toSchool(),
      replacingName: widget.originalName,
    );
    userDataStore.updateDescription(
      name,
      state.summary.trim(),
      state.summaryShort.trim(),
    );
    _updateOwnedDescription(
      state.abilityName,
      state.abilityText.trim(),
      state.abilityShort.trim(),
    );
    _updateOwnedDescription(
      state.masteryName,
      state.masteryText.trim(),
      state.masteryShort.trim(),
    );
    final persistText = userDataStore.saveDescriptions();
    if (widget.originalName != null && widget.originalName != name) {
      // Renaming may leave a bundled school the old name had overridden
      // missing from memory; only a full reload resurrects it. Chained
      // after both writes so the reload reads the fresh files.
      unawaited(
        Future.wait([
          persistSchool,
          persistText,
        ]).then((_) => userDataStore.reloadAll()),
      );
    } else {
      unawaited(persistSchool);
      unawaited(persistText);
    }
    Navigator.pop(context, name);
  }

  Future<void> _next() async {
    final error = _validate(_page);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (_page < 8) {
      setState(() => _page++);
      return;
    }
    await _finish();
  }

  bool get _hasProgress => _page > 0 || state.roles.isNotEmpty;

  Future<void> _confirmDiscard() async {
    final colors = Theme.of(context).colorScheme;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.sbDiscardTitle),
        content: Text(context.l10n.sbDiscardBody),
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
    final l10n = context.l10n;
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.name.isEmpty ? l10n.sbUnnamedSchool : state.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          row(l10n.sbReviewRoles, state.roles.map(trData).join(', ')),
          if (state.clan.isNotEmpty) row(l10n.clanLabel, trData(state.clan)),
          row(
            l10n.sbReviewRings,
            [
              for (final r in state.ringIncrease)
                if (r.isNotEmpty) trData(r),
            ].join(', '),
          ),
          row(
            l10n.sbReviewSkills,
            '${state.startingSkills.length} / ${state.skillPicks}',
          ),
          const SizedBox(height: 12),
          Text(
            l10n.sbReviewCurriculum,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          for (var rank = 1; rank <= 5; rank++)
            row(
              l10n.rankN(rank),
              '${state.filledSlots(rank)}/${state.curriculum[rank]!.length}',
            ),
          row(l10n.sbMastery, state.masteryName.isEmpty ? '—' : '✓'),
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
      SbPage1Roles(state: state, onChanged: refresh),
      SbPage2Affiliation(state: state, onChanged: refresh),
      SbPage3Ability(state: state, onChanged: refresh),
      SbPage4Rings(state: state, onChanged: refresh),
      SbPage5Skills(state: state, onChanged: refresh),
      SbPage6Techniques(state: state, onChanged: refresh),
      SbPage7Curriculum(state: state, onChanged: refresh),
      SbPage8Outfit(state: state, onChanged: refresh),
      SbPage9Final(state: state, onChanged: refresh),
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
          child: LinearProgressIndicator(value: (_page + 1) / 9),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Flexible so long locale strings ("Schritt 7 von 9") shrink
              // instead of overflowing a phone-width bar.
              Expanded(
                child: Text(
                  context.l10n.wizStepOf(_page + 1, 9),
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
                  _page == 8 ? context.l10n.sbSaveSchool : context.l10n.next,
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
