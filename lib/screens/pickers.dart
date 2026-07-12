import 'package:flutter/material.dart';

/// Searchable list page; pops with the tapped item. Used by the add-title,
/// add-bond, add-trait, and add-item flows.
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
    final query = _query.toLowerCase();
    final matches = [
      for (final item in widget.items)
        if (widget.labelOf(item).toLowerCase().contains(query) ||
            (widget.subtitleOf?.call(item).toLowerCase().contains(query) ??
                false) ||
            (widget.descriptionOf
                    ?.call(item)
                    .toLowerCase()
                    .contains(query) ??
                false))
          item
    ];
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search…',
                isDense: true,
                border: OutlineInputBorder(),
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
                  title: Text(widget.labelOf(item)),
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
