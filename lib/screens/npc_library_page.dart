import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../npc_models.dart';
import '../theme.dart';
import '../user_data_store.dart';
import 'npc_detail_page.dart';
import 'npc_quick_build_page.dart';

/// The GM's NPC library: the 31 bundled Chapter 8 sample stat blocks plus
/// custom NPCs, searchable and filterable. Also serves as a picker for the
/// encounter editor ([pickerMode] pops the chosen NPC's name).
class NpcLibraryPage extends StatefulWidget {
  final bool pickerMode;

  const NpcLibraryPage({super.key, this.pickerMode = false});

  @override
  State<NpcLibraryPage> createState() => _NpcLibraryPageState();
}

class _NpcLibraryPageState extends State<NpcLibraryPage> {
  String _query = '';
  String _filter = 'all';

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Npc> _filtered() {
    final q = _query.toLowerCase();
    return [
      for (final n in gameData.npc.samples)
        if (switch (_filter) {
              'minions' => n.isMinion,
              'adversaries' => !n.isMinion,
              'custom' => n.custom,
              _ => true,
            } &&
            (q.isEmpty ||
                n.name.toLowerCase().contains(q) ||
                trData(n.name).toLowerCase().contains(q) ||
                n.blurb.toLowerCase().contains(q)))
          n
    ]..sort((a, b) => trData(a.name).compareTo(trData(b.name)));
  }

  Future<void> _delete(Npc npc) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.npcDeleteTitle(npc.name)),
        content: Text(l10n.npcDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await userDataStore.deleteCustomNpc(npc.name);
    if (mounted) setState(() {});
  }

  Future<void> _deleteAll() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.npcDeleteAll),
        content: Text(l10n.npcDeleteAllBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await userDataStore.deleteAllCustomNpcs();
    if (mounted) setState(() {});
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null || !mounted) return;
    try {
      final count = await userDataStore.importCustomNpcs(utf8.decode(bytes));
      if (!mounted) return;
      setState(() {});
      _showMessage(context.l10n.npcImported(count));
    } on FormatException {
      if (!mounted) return;
      _showMessage(context.l10n.npcCouldNotRead);
    }
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final count = userDataStore.customNpcs.length;
    if (count == 0) {
      _showMessage(l10n.npcNoneToExport);
      return;
    }
    final bytes = utf8.encode(userDataStore.exportCustomNpcsJson());
    if (!mounted) return;
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final path = await FilePicker.platform.saveFile(
      fileName: 'npcs.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: isDesktop ? null : bytes,
    );
    if (path == null || !mounted) return;
    if (isDesktop) {
      await File(path).writeAsBytes(bytes);
      if (!mounted) return;
    }
    _showMessage(l10n.npcExported(count));
  }

  Future<void> _openQuickBuild({Npc? base}) async {
    final l10n = context.l10n;
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => NpcQuickBuildPage(base: base),
      ),
    );
    if (!mounted) return;
    setState(() {});
    if (saved != null) _showMessage(l10n.npcSavedSnack(saved));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final npcs = _filtered();
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.pickerMode ? l10n.npcPickTitle : l10n.npcLibraryTitle),
        actions: [
          if (!widget.pickerMode)
            PopupMenuButton<String>(
              onSelected: (value) => switch (value) {
                'import' => _import(),
                'export' => _export(),
                _ => _deleteAll(),
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'import', child: Text(l10n.npcImport)),
                PopupMenuItem(value: 'export', child: Text(l10n.npcExport)),
                PopupMenuItem(
                  value: 'deleteAll',
                  enabled: userDataStore.customNpcs.isNotEmpty,
                  child: Text(l10n.npcDeleteAll),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: widget.pickerMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openQuickBuild(),
              icon: const Icon(Icons.bolt),
              label: Text(l10n.npcQuickBuild),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.searchHint,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (value, label) in [
                    ('all', l10n.npcFilterAll),
                    ('minions', l10n.npcFilterMinions),
                    ('adversaries', l10n.npcFilterAdversaries),
                    ('custom', l10n.npcFilterCustom),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: _filter == value,
                        onSelected: (_) => setState(() => _filter = value),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: npcs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: EmptyHint(l10n.npcEmptyHint),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: npcs.length,
                    itemBuilder: (context, index) {
                      final npc = npcs[index];
                      return ListTile(
                        leading: Icon(npc.custom
                            ? Icons.person_outline
                            : npc.isMinion
                                ? Icons.group_outlined
                                : Icons.person_pin_outlined),
                        title: Text(trData(npc.name)),
                        subtitle: Text(
                          [
                            npc.isMinion
                                ? l10n.npcTypeMinion
                                : l10n.npcTypeAdversary,
                            l10n.npcCombatIntrigue(
                                npc.crCombat, npc.crIntrigue),
                            if ('${npc.reference}'.isNotEmpty)
                              '${npc.reference}',
                          ].join(' · '),
                        ),
                        trailing: npc.custom && !widget.pickerMode
                            ? IconButton(
                                tooltip: l10n.delete,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(npc),
                              )
                            : null,
                        onTap: () async {
                          if (widget.pickerMode) {
                            Navigator.pop(context, npc.name);
                            return;
                          }
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NpcDetailPage(npc: npc),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
