import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../helpers.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../user_data_store.dart';
import 'custom_legacy_page.dart';

/// Management surface for custom Legacy templates (Legacies of War p. 12):
/// create, edit, delete. Backed by homebrew/legacies.json (hand-authored
/// entries appear and are editable too). Same shape as the homebrew schools
/// page, minus import/export: the file is plain JSON in the homebrew folder.
class CustomLegaciesPage extends StatefulWidget {
  const CustomLegaciesPage({super.key});

  @override
  State<CustomLegaciesPage> createState() => _CustomLegaciesPageState();
}

class _CustomLegaciesPageState extends State<CustomLegaciesPage> {
  List<AdvDisadv> _legacies = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() => _legacies = List.of(userDataStore.customLegacies));
  }

  Future<void> _open({AdvDisadv? legacy}) async {
    final l10n = context.l10n;
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomLegacyPage(initial: legacy),
      ),
    );
    if (!mounted) return;
    _refresh();
    if (saved != null) showMessage(context, l10n.customLegacySaved(saved));
  }

  Future<void> _delete(AdvDisadv legacy) async {
    final l10n = context.l10n;
    final alsoText = await confirmWithCheckbox(
      context,
      title: l10n.sbDeleteTitle(legacy.name),
      body: l10n.customLegacyDeleteBody,
      checkboxLabel: l10n.customLegacyDeleteAlsoText,
      confirmLabel: l10n.delete,
    );
    if (alsoText == null) return;
    await userDataStore.deleteCustomLegacy(legacy.name);
    // Delete (and reload) first, THEN clear rules text, and only when the
    // name no longer resolves: a hand-authored entry may have shadowed a
    // bundled Legacy, which the reload has just resurrected.
    if (alsoText && gameData.advDisadvByName(legacy.name) == null) {
      userDataStore.updateDescription(legacy.name, '', '');
      await userDataStore.saveDescriptions();
    }
    if (!mounted) return;
    _refresh();
  }

  Future<void> _deleteAll() async {
    final l10n = context.l10n;
    final confirmed = await confirmDialog(
      context,
      title: l10n.customLegacyDeleteAll,
      body: l10n.customLegacyDeleteAllBody,
      confirmLabel: l10n.delete,
    );
    if (!confirmed) return;
    await userDataStore.deleteAllCustomLegacies();
    if (!mounted) return;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customLegacies),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _deleteAll(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deleteAll',
                enabled: _legacies.isNotEmpty,
                child: Text(l10n.customLegacyDeleteAll),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.createCustomLegacy),
            subtitle: Text(l10n.customLegaciesSubtitle),
            onTap: () => _open(),
          ),
          const Divider(),
          if (_legacies.isEmpty)
            EmptyHint(l10n.customLegacyEmptyHint)
          else
            for (final legacy in _legacies)
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(trData(legacy.name)),
                subtitle: Text(
                  [
                    if (legacy.ring.isNotEmpty) trData(legacy.ring),
                    if (legacy.types.isNotEmpty)
                      legacy.types.map(trData).join(', '),
                    if ('${legacy.reference}'.isNotEmpty) '${legacy.reference}',
                  ].join(' · '),
                ),
                trailing: IconButton(
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(legacy),
                ),
                onTap: () => _open(legacy: legacy),
              ),
        ],
      ),
    );
  }
}
