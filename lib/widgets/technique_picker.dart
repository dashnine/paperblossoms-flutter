import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';

/// Searchable technique chooser dialog. [categories] restricts the pool
/// (e.g. a Chapter 8 template's "Kata, Shūji"); empty means every
/// technique. Returns the chosen canonical English name, or null.
Future<String?> showTechniquePicker(
  BuildContext context, {
  List<String> categories = const [],
  Set<String> exclude = const {},
}) {
  final options = [
    for (final t in gameData.techniques)
      if ((categories.isEmpty || categories.contains(t.category)) &&
          !exclude.contains(t.name))
        t
  ];
  return showDialog<String>(
    context: context,
    builder: (context) => _TechniquePickerDialog(options: options),
  );
}

class _TechniquePickerDialog extends StatefulWidget {
  final List<Technique> options;

  const _TechniquePickerDialog({required this.options});

  @override
  State<_TechniquePickerDialog> createState() => _TechniquePickerDialogState();
}

class _TechniquePickerDialogState extends State<_TechniquePickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.toLowerCase();
    final filtered = [
      for (final t in widget.options)
        if (q.isEmpty ||
            t.name.toLowerCase().contains(q) ||
            trData(t.name).toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            trData(t.category).toLowerCase().contains(q))
          t
    ];
    return AlertDialog(
      title: Text(l10n.npcAddTechnique),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final t = filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(trData(t.name)),
                    subtitle: Text(
                      [
                        '${trData(t.category)} ${t.rank}',
                        if ('${t.reference}'.isNotEmpty) '${t.reference}',
                      ].join(' · '),
                    ),
                    onTap: () => Navigator.pop(context, t.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
