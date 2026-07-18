import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../../rules_constants.dart';
import '../../screens/pickers.dart';
import '../wizard_widgets.dart';
import 'school_builder_data.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 7: the five curriculum ranks and the rank-6 mastery ability
/// (PoW pp. 81-83, Tables 2-9 and 2-10). Each rank defaults to the book's
/// recipe — 1 skill group, 3 skills, 1 technique group, 2 techniques — but
/// rows can be added or removed (the book allows deviation and 36 bundled
/// rank shapes use it).
class SbPage7Curriculum extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage7Curriculum({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  State<SbPage7Curriculum> createState() => _SbPage7CurriculumState();
}

class _SbPage7CurriculumState extends State<SbPage7Curriculum> {
  /// 1-5 = curriculum rank, 6 = mastery.
  int _segment = 1;

  SchoolBuilderState get state => widget.state;

  List<String> _groupCandidates() => [
    ...gameData.techniqueCategories().where((c) => c != categoryAstradhari),
    for (final sub in {
      for (final t in gameData.techniques)
        if (t.subcategory != t.category && t.category != categoryAstradhari)
          t.subcategory,
    })
      sub,
  ];

  Future<void> _pickTechnique(CurriculumSlot slot) async {
    final choice = await pick<String>(
      context,
      title: context.l10n.sbSlotTechnique,
      items: [for (final t in gameData.techniques) t.name],
      labelOf: (name) => name,
      subtitleOf: (name) {
        final tech = gameData.techniqueByName(name);
        return tech == null
            ? ''
            : '${trData(tech.subcategory)} · ${context.l10n.rankN(tech.rank)}';
      },
      descriptionOf: (name) => gameData.shortDescFor(name),
    );
    if (choice == null) return;
    slot.advance = choice;
    widget.onChanged();
  }

  void _copyFromPreviousRank(int rank) {
    state.curriculum[rank] = [
      for (final slot in state.curriculum[rank - 1]!)
        CurriculumSlot(
          slot.type,
          advance: slot.advance,
          minAllowableRank: slot.minAllowableRank,
          maxAllowableRank: slot.maxAllowableRank,
        ),
    ];
    widget.onChanged();
  }

  Widget _rankEditor(int rank) {
    final l10n = context.l10n;
    final slots = state.curriculum[rank]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            if (rank > 1)
              TextButton.icon(
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: Text(l10n.sbCopyPrevRank(rank - 1)),
                onPressed: () => _copyFromPreviousRank(rank),
              ),
            TextButton.icon(
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(l10n.sbClearRank),
              onPressed: () {
                state.curriculum[rank] = SchoolBuilderState.defaultRankSlots();
                widget.onChanged();
              },
            ),
          ],
        ),
        for (final slot in slots) _slotRow(rank, slots, slot),
        Wrap(
          children: [
            for (final (label, type) in [
              (l10n.sbSlotSkill, entryTypeSkill),
              (l10n.sbSlotSkillGroup, entryTypeSkillGroup),
              (l10n.sbSlotTechnique, entryTypeTechnique),
              (l10n.sbSlotTechniqueGroup, entryTypeTechniqueGroup),
            ])
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: Text(label),
                onPressed: () {
                  slots.add(CurriculumSlot(type));
                  widget.onChanged();
                },
              ),
          ],
        ),
        if (state.rankShapeDeviates(rank)) SoftWarning(l10n.sbWarnRankShape),
      ],
    );
  }

  Widget _slotRow(int rank, List<CurriculumSlot> slots, CurriculumSlot slot) {
    final l10n = context.l10n;
    final removable = slots.length > 1;
    void remove() {
      slots.remove(slot);
      widget.onChanged();
    }

    final special = state.slotNeedsSpecialAccess(slot, rank);
    final insideGroup =
        slot.type == entryTypeSkill &&
        state.skillsInsideRankGroup(rank).contains(slot.advance);
    Widget field;
    switch (slot.type) {
      case entryTypeSkillGroup:
        field = WizDropdown(
          label: l10n.sbSlotSkillGroup,
          value: slot.advance,
          options: [for (final g in gameData.skillGroups) g.name],
          onChanged: (value) {
            slot.advance = value;
            widget.onChanged();
          },
        );
      case entryTypeSkill:
        field = WizDropdown(
          label: l10n.sbSlotSkill,
          value: slot.advance,
          options: gameData.allSkills(),
          onChanged: (value) {
            slot.advance = value;
            widget.onChanged();
          },
        );
      case entryTypeTechniqueGroup:
        field = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WizDropdown(
              label: l10n.sbSlotTechniqueGroup,
              value: slot.advance,
              options: _groupCandidates(),
              onChanged: (value) {
                slot.advance = value;
                widget.onChanged();
              },
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.sbMaxTechRank,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: slot.maxAllowableRank,
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.sbMaxTechRankDefault),
                    ),
                    for (var r = 1; r <= 5; r++)
                      DropdownMenuItem(value: r, child: Text('$r')),
                    // Hand-edited JSON can hold a bound above 5; the value
                    // must appear among the items or the dropdown asserts.
                    if (slot.maxAllowableRank > 5)
                      DropdownMenuItem(
                        value: slot.maxAllowableRank,
                        child: Text('${slot.maxAllowableRank}'),
                      ),
                  ],
                  onChanged: (value) {
                    slot.maxAllowableRank = value ?? 0;
                    widget.onChanged();
                  },
                ),
              ],
            ),
          ],
        );
      default:
        field = Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: OutlinedButton(
            onPressed: () => _pickTechnique(slot),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                slot.advance.isEmpty
                    ? l10n.sbChooseTechnique
                    : trData(slot.advance),
              ),
            ),
          ),
        );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field,
              if (special)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Tooltip(
                    message: l10n.sbSpecialAccessWhy,
                    child: Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.lock_open, size: 16),
                      label: Text(l10n.sbSpecialAccessChip),
                    ),
                  ),
                ),
              if (insideGroup) SoftWarning(l10n.sbWarnSkillInGroup),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.sbRemoveRow,
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: removable ? remove : null,
        ),
      ],
    );
  }

  Widget _masteryEditor() =>
      _MasteryEditor(state: state, onChanged: widget.onChanged);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Scrolls horizontally so long locale labels ("Meisterschaft")
        // can't overflow a phone-width viewport.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (var rank = 1; rank <= 5; rank++)
                ButtonSegment(
                  value: rank,
                  label: Text('$rank'),
                  icon: state.rankComplete(rank)
                      ? const Icon(Icons.check, size: 14)
                      : null,
                ),
              ButtonSegment(
                value: 6,
                label: Text(l10n.sbMastery),
                icon: state.masteryName.isNotEmpty
                    ? const Icon(Icons.check, size: 14)
                    : null,
              ),
            ],
            selected: {_segment},
            onSelectionChanged: (selection) =>
                setState(() => _segment = selection.single),
          ),
        ),
        const SizedBox(height: 8),
        if (_segment <= 5) ...[
          QuestionHeader(l10n.rankN(_segment)),
          _rankEditor(_segment),
        ] else
          _masteryEditor(),
      ],
    );
  }
}

class _MasteryEditor extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const _MasteryEditor({required this.state, required this.onChanged});

  @override
  State<_MasteryEditor> createState() => _MasteryEditorState();
}

class _MasteryEditorState extends State<_MasteryEditor> {
  late final _name = TextEditingController(text: widget.state.masteryName);
  late final _text = TextEditingController(text: widget.state.masteryText);
  late final _short = TextEditingController(text: widget.state.masteryShort);
  AbilityTemplate? _template;

  @override
  void dispose() {
    _name.dispose();
    _text.dispose();
    _short.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final templates = [
      for (final t in masteryAbilityTemplates)
        if (t.roles.isEmpty || t.roles.any(state.roles.contains)) t,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionHeader(l10n.sbMasteryQuestion),
        Text(l10n.sbMasteryHelp, style: Theme.of(context).textTheme.bodySmall),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: DropdownButtonFormField<AbilityTemplate>(
            value: _template,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.sbMasteryTemplate,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final t in templates)
                DropdownMenuItem(
                  value: t,
                  child: Text(t.label, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (t) {
              setState(() => _template = t);
              if (t == null) return;
              _text.text = t.text;
              state.masteryText = t.text;
              widget.onChanged();
            },
          ),
        ),
        if (_template != null) SoftWarning(l10n.sbSeeBook(_template!.page)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.sbMasteryName,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              state.masteryName = value;
              widget.onChanged();
            },
          ),
        ),
        WizTextArea(
          label: l10n.sbMasteryText,
          controller: _text,
          minLines: 4,
          onChanged: (value) {
            state.masteryText = value;
            widget.onChanged();
          },
        ),
        WizTextArea(
          label: l10n.sbShortDescLabel,
          controller: _short,
          minLines: 1,
          onChanged: (value) {
            state.masteryShort = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
