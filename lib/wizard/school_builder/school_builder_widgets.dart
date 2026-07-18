import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../../screens/pickers.dart';
import 'school_builder_state.dart';

/// Amber inline banner for the book's "should" rules: advisory, never
/// blocking (PoW explicitly allows deviating from its tables).
class SoftWarning extends StatelessWidget {
  final String text;

  const SoftWarning(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Colors.amber.harmonizeWith(theme),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Color {
  /// Amber reads on both themes; darken slightly for light backgrounds.
  Color harmonizeWith(ThemeData theme) =>
      theme.brightness == Brightness.light ? Colors.amber.shade800 : this;
}

/// Filter chips grouped under muted group headers; selection capped at
/// [maxSelected] when set.
class WizMultiSelectChips extends StatelessWidget {
  final Map<String, List<String>> groups;
  final Set<String> selected;
  final void Function(String option, bool nowSelected) onToggle;
  final int? maxSelected;

  const WizMultiSelectChips({
    super.key,
    required this.groups,
    required this.selected,
    required this.onToggle,
    this.maxSelected,
  });

  @override
  Widget build(BuildContext context) {
    final full = maxSelected != null && selected.length >= maxSelected!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              trData(entry.key),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: -6,
            children: [
              for (final option in entry.value)
                FilterChip(
                  label: Text(trData(option)),
                  selected: selected.contains(option),
                  onSelected: full && !selected.contains(option)
                      ? null
                      : (value) => onToggle(option, value),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Editor for one "choose [size] of [options]" row: a pick-count stepper,
/// deletable chips for the options, and an add button backed by the
/// searchable [PickerPage].
class ChoiceSetEditor extends StatelessWidget {
  final EditableChoiceSet set;

  /// Candidates offered by the add picker (already-chosen entries are
  /// filtered out here).
  final List<String> candidates;
  final String pickerTitle;
  final String Function(String)? subtitleOf;
  final VoidCallback onChanged;
  final VoidCallback? onRemoveRow;

  const ChoiceSetEditor({
    super.key,
    required this.set,
    required this.candidates,
    required this.pickerTitle,
    required this.onChanged,
    this.subtitleOf,
    this.onRemoveRow,
  });

  Future<void> _add(BuildContext context) async {
    final choice = await pick<String>(
      context,
      title: pickerTitle,
      items: [
        for (final c in candidates)
          if (!set.options.contains(c)) c,
      ],
      labelOf: (name) => name,
      subtitleOf: subtitleOf,
      descriptionOf: (name) => gameData.shortDescFor(name),
    );
    if (choice == null) return;
    set.options.add(choice);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.sbChooseOf(set.size)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  onPressed: set.size > 1
                      ? () {
                          set.size--;
                          onChanged();
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  onPressed: set.size < set.options.length
                      ? () {
                          set.size++;
                          onChanged();
                        }
                      : null,
                ),
                const Spacer(),
                if (onRemoveRow != null)
                  IconButton(
                    tooltip: l10n.sbRemoveRow,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onRemoveRow,
                  ),
              ],
            ),
            Wrap(
              spacing: 6,
              runSpacing: -6,
              children: [
                for (final option in set.options)
                  InputChip(
                    label: Text(trData(option)),
                    onDeleted: () {
                      set.options.remove(option);
                      if (set.size > set.options.length && set.size > 1) {
                        set.size = set.options.length;
                      }
                      onChanged();
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.sbAddOption),
                  onPressed: () => _add(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
