import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../user_data_store.dart';

/// Editor for user-entered rules descriptions (port of
/// EditUserDescriptionsDialog): the bundled data ships no rules text, so
/// owners of the books record their own here. Descriptions appear on the
/// technique/trait cards and the PDF sheet.
class DescriptionsEditor extends StatefulWidget {
  const DescriptionsEditor({super.key});

  @override
  State<DescriptionsEditor> createState() => _DescriptionsEditorState();
}

class _DescriptionsEditorState extends State<DescriptionsEditor> {
  String _query = '';
  bool _onlyDescribed = false;

  Future<void> _edit(String name) async {
    final descController =
        TextEditingController(text: gameData.descriptionFor(name));
    final shortController =
        TextEditingController(text: gameData.shortDescFor(name));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shortController,
                decoration: InputDecoration(
                    labelText: context.l10n.shortDescriptionLabel),
              ),
              TextField(
                controller: descController,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                    labelText: context.l10n.fullDescriptionLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
    if (saved == true) {
      await userDataStore.setDescription(
          name, descController.text.trim(), shortController.text.trim());
      setState(() {});
    }
    descController.dispose();
    shortController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = dataL10n.sortKey(_query);
    final names = [
      for (final name in gameData.describableNames())
        if ((dataL10n.sortKey(name).contains(query) ||
                dataL10n.sortKey(trData(name)).contains(query)) &&
            (!_onlyDescribed || gameData.descriptionFor(name).isNotEmpty ||
                gameData.shortDescFor(name).isNotEmpty))
          name
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.rulesDescriptionsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: context.l10n.searchHint,
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(context.l10n.withText),
                  selected: _onlyDescribed,
                  onSelected: (value) =>
                      setState(() => _onlyDescribed = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) {
                final name = names[index];
                final short = gameData.shortDescFor(name);
                final hasText =
                    short.isNotEmpty || gameData.descriptionFor(name).isNotEmpty;
                return ListTile(
                  dense: true,
                  title: Text(trData(name)),
                  subtitle: short.isEmpty ? null : Text(short),
                  trailing: hasText
                      ? const Icon(Icons.notes_outlined)
                      : null,
                  onTap: () => _edit(name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
