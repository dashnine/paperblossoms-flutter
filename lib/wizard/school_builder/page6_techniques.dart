import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_data.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 6: open technique access and starting techniques (PoW p. 80,
/// Table 2-8).
class SbPage6Techniques extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage6Techniques({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  State<SbPage6Techniques> createState() => _SbPage6TechniquesState();
}

class _SbPage6TechniquesState extends State<SbPage6Techniques> {
  bool _showAllTechniques = false;

  SchoolBuilderState get state => widget.state;

  /// Categories offered as open access: the common five plus the two
  /// forbidden arts, each with its subcategories for limited access.
  Map<String, List<String>> _accessTree() {
    final categories = [
      ritualsCategory,
      ...commonTechniqueCategories,
      ...warnTechniqueCategories,
    ];
    return {
      for (final category in categories)
        category: {
          // Several categories carry a single nameless subcategory in the
          // data (Mahō, Ninjutsu, ...); those offer no limited access.
          for (final t in gameData.techniques)
            if (t.category == category &&
                t.subcategory != category &&
                t.subcategory.isNotEmpty)
              t.subcategory,
        }.toList(),
    };
  }

  void _toggleAccess(String group, bool nowSelected) {
    if (nowSelected) {
      state.techniquesAvailable.add(group);
    } else {
      state.techniquesAvailable.remove(group);
    }
    state.accessTouched = true;
    widget.onChanged();
  }

  List<String> _candidates() => [
    for (final t in gameData.techniques)
      if (_showAllTechniques ||
          (t.rank == 1 &&
              (state.techniquesAvailable.contains(t.category) ||
                  state.techniquesAvailable.contains(t.subcategory))))
        t.name,
  ];

  String _subtitle(String name) {
    final tech = gameData.techniqueByName(name);
    if (tech == null) return '';
    return '${trData(tech.subcategory)} · '
        '${context.l10n.rankN(tech.rank)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final forbidden = warnTechniqueCategories.any(
      state.techniquesAvailable.contains,
    );
    final shugenja = state.primaryRole == 'Shugenja';
    final missingInvocations =
        shugenja && !state.techniquesAvailable.contains('Invocations');
    final missingCommune =
        shugenja &&
        !state.startingTechniques.any(
          (set) => set.options.contains(communeWithSpirits),
        );
    final oversized = state.techniquesAvailable.length > 3;
    final oddPicks = <String>{
      for (final set in state.startingTechniques)
        for (final name in set.options)
          if (state.techniqueNeedsSpecialAccess(name, 1)) name,
    };
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbAccessQuestion),
        Text(l10n.sbAccessHelp, style: Theme.of(context).textTheme.bodySmall),
        for (final entry in _accessTree().entries)
          _CategoryTile(
            category: entry.key,
            subcategories: entry.value,
            selected: state.techniquesAvailable,
            onToggle: _toggleAccess,
          ),
        if (forbidden) SoftWarning(l10n.sbWarnForbidden),
        if (oversized) SoftWarning(l10n.sbWarnManyCategories),
        if (missingInvocations) SoftWarning(l10n.sbWarnShugenjaInvocations),
        QuestionHeader(l10n.sbStartingTechniques),
        Text(
          l10n.sbStartingTechniquesHelp(
            state.defaults?.startingTechniqueSlots ??
                state.startingTechniques.length,
            trData(state.primaryRole),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SwitchListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.sbShowAllTechniques),
          value: _showAllTechniques,
          onChanged: (value) => setState(() => _showAllTechniques = value),
        ),
        for (final set in state.startingTechniques)
          ChoiceSetEditor(
            set: set,
            candidates: _candidates(),
            pickerTitle: l10n.sbStartingTechniques,
            subtitleOf: _subtitle,
            onChanged: () {
              state.startingTechniquesTouched = true;
              widget.onChanged();
            },
            onRemoveRow: state.startingTechniques.length > 1
                ? () {
                    state.startingTechniques.remove(set);
                    state.startingTechniquesTouched = true;
                    widget.onChanged();
                  }
                : null,
          ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.sbAddRow),
          onPressed: () {
            state.startingTechniques.add(EditableChoiceSet());
            state.startingTechniquesTouched = true;
            widget.onChanged();
          },
        ),
        if (missingCommune) SoftWarning(l10n.sbWarnCommune),
        for (final name in oddPicks)
          SoftWarning(l10n.sbWarnStartingTechRank(trData(name))),
      ],
    );
  }
}

/// One open-access category checkbox with an expandable subcategory list
/// for the book's "limited category access" refinement.
class _CategoryTile extends StatelessWidget {
  final String category;
  final List<String> subcategories;
  final List<String> selected;
  final void Function(String, bool) onToggle;

  const _CategoryTile({
    required this.category,
    required this.subcategories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final categoryOn = selected.contains(category);
    // No subcategories → plain checkbox row, no expansion chevron.
    if (subcategories.isEmpty) {
      return CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(trData(category)),
        value: categoryOn,
        onChanged: (value) => onToggle(category, value ?? false),
      );
    }
    final chosenSubs = subcategories.where(selected.contains).toList();
    return ExpansionTile(
      dense: true,
      tilePadding: EdgeInsets.zero,
      leading: Checkbox(
        value: categoryOn,
        onChanged: (value) => onToggle(category, value ?? false),
      ),
      title: Text(trData(category)),
      subtitle: chosenSubs.isEmpty
          ? null
          : Text(chosenSubs.map(trData).join(', ')),
      children: [
        for (final sub in subcategories)
          CheckboxListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 40),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(trData(sub)),
            value: selected.contains(sub),
            // A subcategory grant is redundant while the category is open.
            onChanged: categoryOn
                ? null
                : (value) => onToggle(sub, value ?? false),
          ),
      ],
    );
  }
}
