import 'package:flutter/material.dart';

import '../game_data.dart';

/// Labeled dropdown over strings; the wizard's workhorse control.
///
/// Options that have a user-entered short description (techniques, traits,
/// items, ...) show it under their name in the menu, and the selected
/// option's description appears as helper text under the field.
class WizDropdown extends StatelessWidget {
  final String label;
  final String value; // '' = nothing selected
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const WizDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = {...options};
    final effective = value.isEmpty || !items.contains(value) ? null : value;
    final descriptions = {
      for (final option in items) option: gameData.shortDescFor(option)
    };
    final hasDescriptions = descriptions.values.any((d) => d.isNotEmpty);
    final selectedDesc =
        effective == null ? '' : descriptions[effective] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        // The form field keeps its own selection state; key it by the
        // effective value so a selection that disappears from [options]
        // resets the field instead of tripping the framework's "exactly one
        // item with value" assertion.
        key: ValueKey('$label:$effective'),
        value: effective,
        isExpanded: true,
        // null lets rows grow to fit a description line.
        itemHeight: hasDescriptions ? null : kMinInteractiveDimension,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          helperText: selectedDesc.isEmpty ? null : selectedDesc,
          helperMaxLines: 2,
        ),
        // The closed field shows only the name; descriptions live in the
        // menu rows and the helper text.
        selectedItemBuilder: hasDescriptions
            ? (context) => [
                  for (final option in items)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(option, overflow: TextOverflow.ellipsis),
                    ),
                ]
            : null,
        items: [
          for (final option in items)
            DropdownMenuItem(
              value: option,
              child: descriptions[option]!.isEmpty
                  ? Text(option)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option),
                          Text(
                            descriptions[option]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
            ),
        ],
        onChanged: enabled ? (v) => onChanged(v ?? '') : null,
      ),
    );
  }
}

/// Multiline free-text answer.
class WizTextArea extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int minLines;

  const WizTextArea({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.minLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 3,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

/// Bold question header, matching the original's numbered group boxes.
class QuestionHeader extends StatelessWidget {
  final String text;

  const QuestionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
