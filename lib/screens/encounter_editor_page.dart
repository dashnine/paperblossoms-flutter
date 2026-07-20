import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data_l10n.dart';
import '../encounter.dart';
import '../game_data.dart';
import '../generate_pdf_npc.dart';
import '../l10n/l10n.dart';
import '../npc_math.dart';
import '../theme.dart';
import '../user_data_store.dart';
import '../widgets/int_spinner.dart';
import 'npc_detail_page.dart';
import 'npc_library_page.dart';

/// Roster editor for one encounter: NPCs × counts, live combat/intrigue
/// Encounter Ranks, and the Core p. 310 party group-rank thresholds.
class EncounterEditorPage extends StatefulWidget {
  final Encounter? encounter;

  const EncounterEditorPage({super.key, this.encounter});

  @override
  State<EncounterEditorPage> createState() => _EncounterEditorPageState();
}

class _EncounterEditorPageState extends State<EncounterEditorPage> {
  late final Encounter _encounter =
      widget.encounter?.clone() ?? Encounter();
  late final TextEditingController _name =
      TextEditingController(text: _encounter.name);
  late final TextEditingController _notes =
      TextEditingController(text: _encounter.notes);

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addNpc() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const NpcLibraryPage(pickerMode: true),
      ),
    );
    if (name == null || !mounted) return;
    setState(() {
      final existing =
          _encounter.entries.where((e) => e.npc == name).firstOrNull;
      if (existing != null) {
        existing.count++;
      } else {
        _encounter.entries.add(EncounterEntry(npc: name));
      }
    });
  }

  void _save() {
    _encounter.name = _name.text.trim();
    _encounter.notes = _notes.text.trim();
    if (_encounter.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.nameRequiredSnack)),
      );
      return;
    }
    // Memory-first store contract: merge now, disk write in the background.
    unawaited(userDataStore.saveEncounter(
      _encounter,
      replacingName: widget.encounter?.name,
    ));
    Navigator.pop(context, _encounter.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final roster = [
      for (final e in _encounter.entries)
        if (gameData.npc.sampleByName(e.npc) != null)
          (npc: gameData.npc.sampleByName(e.npc)!, count: e.count)
    ];
    final rank = encounterRank(roster);
    final combat = groupRankThresholds(rank.combat);
    final intrigue = groupRankThresholds(rank.intrigue);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.encounter == null
            ? l10n.encNew
            : widget.encounter!.name),
        actions: [
          IconButton(
            tooltip: l10n.encPrint,
            icon: const Icon(Icons.print_outlined),
            onPressed: roster.isEmpty
                ? null
                : () {
                    final strings = context.l10n;
                    final encounter = _encounter.clone()
                      ..name = _name.text.trim()
                      ..notes = _notes.text.trim();
                    Printing.layoutPdf(
                      name: encounter.name.isEmpty
                          ? l10n.encountersTitle
                          : encounter.name,
                      onLayout: (format) => buildEncounterPdf(
                        encounter,
                        roster,
                        strings: strings,
                        pageFormat: format,
                      ),
                    );
                  },
          ),
          IconButton(
            tooltip: l10n.save,
            icon: const Icon(Icons.save_outlined),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SectionHeader(l10n.npcLibraryTitle),
          for (final (index, entry) in _encounter.entries.indexed)
            Builder(builder: (context) {
              final npc = gameData.npc.sampleByName(entry.npc);
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  npc == null ? l10n.encMissing(entry.npc) : trData(entry.npc),
                  style: npc == null
                      ? TextStyle(color: theme.colorScheme.error)
                      : null,
                ),
                subtitle: npc == null
                    ? null
                    : Text(l10n.npcCombatIntrigue(
                        npc.crCombat, npc.crIntrigue)),
                onTap: npc == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NpcDetailPage(npc: npc),
                          ),
                        ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IntSpinner(
                      label: '',
                      value: entry.count,
                      min: 1,
                      max: 99,
                      onChanged: (v) => setState(() => entry.count = v),
                    ),
                    IconButton(
                      tooltip: l10n.delete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(
                          () => _encounter.entries.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.encAddNpc),
            onPressed: _addNpc,
          ),
          SectionHeader(l10n.encThresholdsTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.encCombatRank(rank.combat),
                      style: theme.textTheme.titleSmall),
                  Text('  ${l10n.encEven(combat.even)}'),
                  Text('  ${l10n.encEasy(combat.easy)}'),
                  Text('  ${l10n.encHard(combat.hard)}'),
                  const SizedBox(height: 8),
                  Text(l10n.encIntrigueRank(rank.intrigue),
                      style: theme.textTheme.titleSmall),
                  Text('  ${l10n.encEven(intrigue.even)}'),
                  Text('  ${l10n.encEasy(intrigue.easy)}'),
                  Text('  ${l10n.encHard(intrigue.hard)}'),
                  const SizedBox(height: 8),
                  Text(
                    l10n.encGroupRankHint,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(l10n.notesSection),
          TextField(
            controller: _notes,
            maxLines: 4,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
