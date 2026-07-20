import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../generate_pdf_npc.dart';
import '../l10n/l10n.dart';
import '../encounter.dart';
import '../npc_models.dart';
import '../theme.dart';
import '../user_data_store.dart';
import '../widgets/ring_viewer.dart';
import 'encounter_editor_page.dart';
import 'npc_edit_page.dart';
import 'npc_quick_build_page.dart';

/// Read-only rendered stat block for one NPC, mirroring the book's profile
/// layout. Bundled ability text renders in full; template-added PC
/// techniques show imported descriptions when available.
class NpcDetailPage extends StatefulWidget {
  final Npc npc;

  const NpcDetailPage({super.key, required this.npc});

  @override
  State<NpcDetailPage> createState() => _NpcDetailPageState();
}

class _NpcDetailPageState extends State<NpcDetailPage> {
  late Npc _npc = widget.npc;

  Future<void> _edit() async {
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => NpcEditPage(
          npc: _npc,
          replacingName: _npc.custom ? _npc.name : null,
        ),
      ),
    );
    if (!mounted || saved == null) return;
    setState(() {
      _npc = gameData.npc.sampleByName(saved) ?? _npc;
    });
  }

  Future<void> _useAsBase() async {
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => NpcQuickBuildPage(base: _npc),
      ),
    );
    if (!mounted || saved == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.npcSavedSnack(saved))),
    );
  }

  Future<void> _addToEncounter() async {
    final l10n = context.l10n;
    // No saved encounters: open a fresh editor seeded with this NPC.
    if (userDataStore.encounters.isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EncounterEditorPage(
            encounter: Encounter(
              entries: [EncounterEntry(npc: _npc.name)],
            ),
          ),
        ),
      );
      return;
    }
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.npcAddToEncounter),
        children: [
          for (final encounter in userDataStore.encounters)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, encounter.name),
              child: Text(encounter.name),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: Row(
              children: [
                const Icon(Icons.add, size: 18),
                const SizedBox(width: 8),
                Text(l10n.encNew),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    if (picked.isEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EncounterEditorPage(
            encounter: Encounter(
              entries: [EncounterEntry(npc: _npc.name)],
            ),
          ),
        ),
      );
      return;
    }
    final encounter =
        userDataStore.encounters.where((e) => e.name == picked).first;
    final existing =
        encounter.entries.where((e) => e.npc == _npc.name).firstOrNull;
    if (existing != null) {
      existing.count++;
    } else {
      encounter.entries.add(EncounterEntry(npc: _npc.name));
    }
    // Memory-first store contract: merge now, disk write in the background.
    unawaited(userDataStore.saveEncounters());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.npcSavedSnack(picked))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final npc = _npc;
    final demeanor = gameData.npc.demeanorByName(npc.demeanor);
    return Scaffold(
      appBar: AppBar(
        title: Text(trData(npc.name)),
        actions: [
          IconButton(
            tooltip: l10n.npcPrintSheet,
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              final strings = context.l10n;
              Printing.layoutPdf(
                name: npc.name,
                // The print dialog re-invokes onLayout on paper/orientation
                // changes, so the preview stays live.
                onLayout: (format) => buildNpcPdf(
                  npc,
                  strings: strings,
                  pageFormat: format,
                ),
              );
            },
          ),
          IconButton(
            tooltip: l10n.npcUseAsBase,
            icon: const Icon(Icons.bolt),
            onPressed: _useAsBase,
          ),
          IconButton(
            tooltip: npc.custom ? l10n.npcEditAction : l10n.npcDuplicateEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
          IconButton(
            tooltip: l10n.npcAddToEncounter,
            icon: const Icon(Icons.flag_outlined),
            onPressed: _addToEncounter,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  npc.isMinion ? l10n.npcTypeMinion : l10n.npcTypeAdversary,
                ),
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n.npcConflictRank}: '
                  '${l10n.npcCombatIntrigue(npc.crCombat, npc.crIntrigue)}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          if (npc.blurb.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                trData(npc.blurb),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 148, child: RingViewer(rings: npc.rings)),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    StatTile(
                        label: l10n.endurance, value: npc.derived.endurance),
                    StatTile(
                        label: l10n.composure, value: npc.derived.composure),
                    StatTile(label: l10n.focusStat, value: npc.derived.focus),
                    StatTile(
                        label: l10n.vigilance, value: npc.derived.vigilance),
                    if (npc.social != null) ...[
                      StatTile(
                          label: l10n.honor, value: '${npc.social!.honor}'),
                      StatTile(
                          label: l10n.glory, value: '${npc.social!.glory}'),
                      StatTile(
                          label: l10n.statusLabel, value: '${npc.social!.status}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (npc.demeanor.isNotEmpty) ...[
            SectionHeader(l10n.npcDemeanorLabel),
            Text(trData(npc.demeanor), style: theme.textTheme.bodyLarge),
          ],
          if (demeanor != null)
            // The modifiers shift the TN of Social checks made against the
            // NPC with these rings — they are not ring adjustments.
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l10n.npcDemeanorTnMods(demeanor.modifierLine(trData))),
            ),
          if (demeanor != null && demeanor.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(trData(demeanor.description)),
            ),
          if (demeanor != null && demeanor.unmasking.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.npcUnmasking(trData(demeanor.unmasking)),
                style: theme.textTheme.bodySmall,
              ),
            ),
          SectionHeader(l10n.npcSkillGroupsLabel),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in npc.skillGroups.entries)
                Chip(
                  label: Text('${trData(e.key)} ${e.value}'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (npc.advantages.isNotEmpty) ...[
            SectionHeader(l10n.npcAdvantagesLabel),
            for (final a in npc.advantages) _TraitLine(trait: a),
          ],
          if (npc.disadvantages.isNotEmpty) ...[
            SectionHeader(l10n.npcDisadvantagesLabel),
            for (final d in npc.disadvantages) _TraitLine(trait: d),
          ],
          SectionHeader(l10n.npcWeaponsGear),
          for (final w in npc.weapons)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${trData(w.name)}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: [
                        '${l10n.colRange} ${w.range}',
                        '${l10n.damageLabel} ${w.damage}',
                        '${l10n.deadlinessLabel} ${w.deadliness}',
                        for (final q in w.qualities) trData(q),
                      ].join(', '),
                    ),
                  ],
                ),
              ),
            ),
          if (npc.gearEquipped.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${l10n.npcGearEquipped}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                        text: npc.gearEquipped.map(trData).join(', ')),
                  ],
                ),
              ),
            ),
          if (npc.gearOther.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l10n.npcGearOther}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: npc.gearOther.map(trData).join(', ')),
                ],
              ),
            ),
          if (npc.abilities.isNotEmpty) ...[
            SectionHeader(l10n.abilitiesSection),
            for (final a in npc.abilities)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trData(a.name),
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(trData(a.text)),
                    if ('${a.reference}'.isNotEmpty)
                      Text(
                        '${a.reference}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                  ],
                ),
              ),
          ],
          if (npc.techniques.isNotEmpty) ...[
            SectionHeader(l10n.npcTechniquesLabel),
            for (final name in npc.techniques) _TechniqueLine(name: name),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.npcTechniqueImportHint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
          if (npc.isMinion) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.npcMinionRules,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
          if ('${npc.reference}'.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '${npc.reference}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
        ],
      ),
    );
  }
}

class _TraitLine extends StatelessWidget {
  final NpcTrait trait;

  const _TraitLine({required this.trait});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${trData(trait.name)} (${trData(trait.ring)}): ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text:
                  '${trait.groups.map(trData).join(', ')}; '
                  '${trait.types.map(trData).join(', ')}',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechniqueLine extends StatelessWidget {
  final String name;

  const _TechniqueLine({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final technique = gameData.techniqueByName(name);
    final pattern =
        technique == null ? gameData.itemPatternByName(name) : null;
    final desc = gameData.descriptionFor(name);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              trData(name),
              if (technique != null)
                '${trData(technique.category)} ${technique.rank}',
              if (technique != null && '${technique.reference}'.isNotEmpty)
                '${technique.reference}',
              if (pattern != null) trData('Item Patterns'),
              if (pattern != null && '${pattern.reference}'.isNotEmpty)
                '${pattern.reference}',
            ].join(' · '),
            style: theme.textTheme.titleSmall,
          ),
          if (desc.isNotEmpty) Text(desc),
        ],
      ),
    );
  }
}
