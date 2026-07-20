import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../encounter.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../npc_math.dart';
import '../theme.dart';
import '../user_data_store.dart';
import 'encounter_editor_page.dart';

/// Saved encounters: named NPC rosters with their Chapter 8 challenge math.
class EncountersPage extends StatefulWidget {
  const EncountersPage({super.key});

  @override
  State<EncountersPage> createState() => _EncountersPageState();
}

class _EncountersPageState extends State<EncountersPage> {
  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      final count = await userDataStore.importEncounters(utf8.decode(bytes));
      if (!mounted) return;
      setState(() {});
      _showMessage(context.l10n.encImported(count));
    } on FormatException {
      if (!mounted) return;
      _showMessage(context.l10n.encCouldNotRead);
    }
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final count = userDataStore.encounters.length;
    if (count == 0) {
      _showMessage(l10n.encNoneToExport);
      return;
    }
    final bytes = utf8.encode(userDataStore.exportEncountersJson());
    if (!mounted) return;
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    final path = await FilePicker.platform.saveFile(
      fileName: 'encounters.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: isDesktop ? null : bytes,
    );
    if (path == null || !mounted) return;
    if (isDesktop) {
      await File(path).writeAsBytes(bytes);
      if (!mounted) return;
    }
    _showMessage(l10n.encExported(count));
  }

  Future<void> _open({Encounter? encounter}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EncounterEditorPage(encounter: encounter),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _delete(Encounter encounter) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.npcDeleteTitle(encounter.name)),
        content: Text(l10n.encDeleteBody),
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
    await userDataStore.deleteEncounter(encounter.name);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final encounters = List.of(userDataStore.encounters)
      ..sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.encountersTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => switch (value) {
              'import' => _import(),
              _ => _export(),
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'import', child: Text(l10n.encImport)),
              PopupMenuItem(value: 'export', child: Text(l10n.encExport)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(),
        icon: const Icon(Icons.add),
        label: Text(l10n.encNew),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (encounters.isEmpty)
            EmptyHint(l10n.encEmptyHint)
          else
            for (final encounter in encounters)
              Builder(builder: (context) {
                final roster = [
                  for (final e in encounter.entries)
                    if (gameData.npc.sampleByName(e.npc) != null)
                      (
                        npc: gameData.npc.sampleByName(e.npc)!,
                        count: e.count
                      )
                ];
                final rank = encounterRank(roster);
                final total = encounter.entries.fold(
                    0, (sum, e) => sum + e.count);
                return ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(encounter.name),
                  subtitle: Text(
                    '${l10n.encNpcCountLabel(total)} · '
                    '${l10n.npcCombatIntrigue(rank.combat, rank.intrigue)}',
                  ),
                  trailing: IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(encounter),
                  ),
                  onTap: () => _open(encounter: encounter),
                );
              }),
        ],
      ),
    );
  }
}
