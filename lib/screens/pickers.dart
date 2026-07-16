import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../l10n/l10n.dart';

/// Searchable list page; pops with the tapped item. Used by the add-title,
/// add-bond, add-trait, and add-item flows.
///
/// Labels render through the data-translation overlay ([trData]); the popped
/// item is the object itself, so canonical English names are never affected.
/// Search matches both the displayed (possibly translated) label and the
/// English original, case- and diacritic-insensitively.
class PickerPage<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;

  /// Optional user-entered short description, shown as an extra muted line.
  final String Function(T)? descriptionOf;

  const PickerPage({
    super.key,
    required this.title,
    required this.items,
    required this.labelOf,
    this.subtitleOf,
    this.descriptionOf,
  });

  @override
  State<PickerPage<T>> createState() => _PickerPageState<T>();
}

class _PickerPageState<T> extends State<PickerPage<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = dataL10n.sortKey(_query);
    bool matchesQuery(T item) {
      if (query.isEmpty) return true;
      final english = widget.labelOf(item);
      return dataL10n.sortKey(english).contains(query) ||
          dataL10n.sortKey(dataL10n.trCondition(english)).contains(query) ||
          dataL10n
              .sortKey(widget.subtitleOf?.call(item) ?? '')
              .contains(query) ||
          dataL10n
              .sortKey(widget.descriptionOf?.call(item) ?? '')
              .contains(query);
    }

    final matches = [
      for (final item in widget.items)
        if (matchesQuery(item)) item
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: context.l10n.searchHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final item = matches[index];
                final subtitle = widget.subtitleOf?.call(item) ?? '';
                final description = widget.descriptionOf?.call(item) ?? '';
                return ListTile(
                  title: Text(dataL10n.trCondition(widget.labelOf(item))),
                  subtitle: subtitle.isEmpty && description.isEmpty
                      ? null
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subtitle.isNotEmpty) Text(subtitle),
                            if (description.isNotEmpty)
                              Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pushes a [PickerPage] and returns the selection (null if dismissed).
Future<T?> pick<T>(
  BuildContext context, {
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  String Function(T)? subtitleOf,
  String Function(T)? descriptionOf,
}) {
  return Navigator.push<T>(
    context,
    MaterialPageRoute(
      builder: (context) => PickerPage<T>(
        title: title,
        items: items,
        labelOf: labelOf,
        subtitleOf: subtitleOf,
        descriptionOf: descriptionOf,
      ),
    ),
  );
}
