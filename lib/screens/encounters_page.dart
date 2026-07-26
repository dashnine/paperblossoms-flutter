import 'dart:convert';

import 'package:flutter/material.dart';

import '../encounter.dart';
import '../game_data.dart';
import '../helpers.dart';
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
  Future<void> _import() async {
    final text = await pickTextFile();
    if (text == null || !mounted) return;
    try {
      final count = await userDataStore.importEncounters(text);
      if (!mounted) return;
      setState(() {});
      showMessage(context, context.l10n.encImported(count));
    } on FormatException {
      if (!mounted) return;
      showMessage(context, context.l10n.encCouldNotRead);
    }
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final count = userDataStore.encounters.length;
    if (count == 0) {
      showMessage(context, l10n.encNoneToExport);
      return;
    }
    final bytes = utf8.encode(userDataStore.exportEncountersJson());
    final saved = await exportBytesToFile('encounters.json', bytes);
    if (!saved || !mounted) return;
    showMessage(context, l10n.encExported(count));
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
    final confirmed = await confirmDialog(
      context,
      title: l10n.npcDeleteTitle(encounter.name),
      body: l10n.encDeleteBody,
      confirmLabel: l10n.delete,
    );
    if (!confirmed) return;
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
