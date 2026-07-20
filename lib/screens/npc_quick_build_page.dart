import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../generate_pdf_npc.dart';
import '../l10n/l10n.dart';
import '../npc_builder_state.dart';
import '../npc_models.dart';
import '../theme.dart';
import '../user_data_store.dart';
import '../widgets/technique_picker.dart';
import 'npc_library_page.dart';

/// The fast path: pick a base sample, tap Chapter 8 templates onto it, save.
/// A single scrollable page — the happy path is three taps. Every template
/// pick starts from its book defaults and stays one tap away from change.
class NpcQuickBuildPage extends StatefulWidget {
  final Npc? base;

  const NpcQuickBuildPage({super.key, this.base});

  @override
  State<NpcQuickBuildPage> createState() => _NpcQuickBuildPageState();
}

class _NpcQuickBuildPageState extends State<NpcQuickBuildPage> {
  final NpcBuilderState _state = NpcBuilderState();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _state.base = widget.base;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBase() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const NpcLibraryPage(pickerMode: true),
      ),
    );
    if (name == null || !mounted) return;
    setState(() => _state.setBase(gameData.npc.sampleByName(name)));
  }

  Future<void> _addTechnique(
      NpcTemplate template, TemplateChoices choices) async {
    final picked = await showTechniquePicker(
      context,
      categories: template.techniqueCategories,
      exclude: choices.techniques.toSet(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _state.removedTechniques.remove(picked);
      choices.techniques.add(picked);
    });
  }

  Future<void> _save({bool print = false}) async {
    final npc = _state.result(gameData.npc.templates);
    if (npc == null || npc.name.isEmpty) return;
    // Memory-first store contract: the merge happens synchronously, the
    // disk write finishes in the background (see saveHomebrewSchool).
    unawaited(userDataStore.saveCustomNpc(npc));
    if (!mounted) return;
    if (print) {
      final strings = context.l10n;
      await Printing.layoutPdf(
        name: npc.name,
        onLayout: (format) =>
            buildNpcPdf(npc, strings: strings, pageFormat: format),
      );
      if (!mounted) return;
    }
    Navigator.pop(context, npc.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = _state.result(gameData.npc.templates);
    final autoName = _state.autoName();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.npcQuickBuildTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(l10n.npcBaseLabel),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_search_outlined),
            title: Text(
              _state.base == null
                  ? l10n.npcChooseBase
                  : trData(_state.base!.name),
            ),
            subtitle: _state.base == null
                ? null
                : Text(l10n.npcCombatIntrigue(
                    _state.base!.crCombat, _state.base!.crIntrigue)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickBase,
          ),
          SectionHeader(l10n.npcTemplatesLabel),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final template in gameData.npc.templates)
                FilterChip(
                  label: Text(trData(template.name)),
                  selected: _state.isSelected(template.name),
                  onSelected: _state.hasBase
                      ? (_) => setState(() => _state.toggleTemplate(template))
                      : null,
                ),
            ],
          ),
          for (final template in gameData.npc.templates)
            if (_state.isSelected(template.name))
              _templateCard(template, _state.selected[template.name]!),
          if (_state.hasBase) ...[
            SectionHeader(l10n.npcTechniquesLabel),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final name in result?.techniques ?? const <String>[])
                  InputChip(
                    label: Text(trData(name)),
                    visualDensity: VisualDensity.compact,
                    onDeleted: () =>
                        setState(() => _state.removeTechnique(name)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.npcAddTechnique),
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    final picked = await showTechniquePicker(
                      context,
                      exclude: result?.techniques.toSet() ?? const {},
                    );
                    if (picked == null || !mounted) return;
                    setState(() {
                      _state.removedTechniques.remove(picked);
                      _state.extraTechniques.add(picked);
                    });
                  },
                ),
              ],
            ),
          ],
          SectionHeader(l10n.nameLabel),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: autoName,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _state.name = value),
          ),
          if (_state.hasBase) ...[
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: 'minion', label: Text(l10n.npcTypeMinion)),
                ButtonSegment(
                    value: 'adversary', label: Text(l10n.npcTypeAdversary)),
              ],
              selected: {
                _state.typeOverride.isEmpty
                    ? _state.base!.type
                    : _state.typeOverride
              },
              onSelectionChanged: (selection) =>
                  setState(() => _state.typeOverride = selection.first),
            ),
          ],
          if (result != null) ...[
            SectionHeader(l10n.npcResultLabel),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.name} — '
                      '${result.isMinion ? l10n.npcTypeMinion : l10n.npcTypeAdversary}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.npcCombatIntrigue(
                        result.crCombat, result.crIntrigue)),
                    Text(
                      [
                        for (final e in result.rings.entries)
                          '${trData(e.key)} ${e.value}'
                      ].join(' · '),
                    ),
                    Text(
                      '${l10n.endurance} ${result.derived.endurance} · '
                      '${l10n.composure} ${result.derived.composure} · '
                      '${l10n.focusStat} ${result.derived.focus} · '
                      '${l10n.vigilance} ${result.derived.vigilance}',
                    ),
                    if (result.demeanor.isNotEmpty)
                      Text('${l10n.npcDemeanorLabel}: '
                          '${trData(result.demeanor)}'),
                    if (result.techniques.isNotEmpty)
                      Text('${l10n.npcTechniquesLabel}: '
                          '${result.techniques.map(trData).join(', ')}'),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: result == null ? null : () => _save(),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      result == null ? null : () => _save(print: true),
                  icon: const Icon(Icons.print_outlined),
                  label: Text(l10n.npcSaveAndPrint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _templateCard(NpcTemplate template, TemplateChoices choices) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trData(template.name), style: theme.textTheme.titleSmall),
            Text(
              [
                if (template.crCombat != 0)
                  '${l10n.npcCombatRank} +${template.crCombat}',
                if (template.crIntrigue != 0)
                  '${l10n.npcIntrigueRank} +${template.crIntrigue}',
                if (template.ring.isNotEmpty) '+1 ${trData(template.ring)}',
                for (final e in template.skillGroups.entries)
                  '${trData(e.key)} +${e.value}',
              ].join(' · '),
              style: theme.textTheme.bodySmall,
            ),
            if (template.techniqueCategories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final name in choices.techniques)
                    InputChip(
                      label: Text(trData(name)),
                      visualDensity: VisualDensity.compact,
                      onDeleted: () =>
                          setState(() => choices.techniques.remove(name)),
                    ),
                  if (choices.techniques.length < template.techniqueMax)
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l10n.npcAddTechnique),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _addTechnique(template, choices),
                    ),
                ],
              ),
            ],
            if (template.demeanorOptions.length > 1) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in template.demeanorOptions)
                    ChoiceChip(
                      label: Text(trData(option)),
                      visualDensity: VisualDensity.compact,
                      selected: choices.demeanor == option,
                      onSelected: (_) =>
                          setState(() => choices.demeanor = option),
                    ),
                ],
              ),
            ],
            if (template.suggestedAdvantages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.npcSuggestedAdv, style: theme.textTheme.labelMedium),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final a in template.suggestedAdvantages)
                    FilterChip(
                      label: Text('${trData(a.name)} (${trData(a.ring)})'),
                      visualDensity: VisualDensity.compact,
                      selected: choices.advantages.contains(a.name),
                      onSelected: (selected) => setState(() {
                        if (selected && choices.advantages.length < 2) {
                          choices.advantages.add(a.name);
                        } else {
                          choices.advantages.remove(a.name);
                        }
                      }),
                    ),
                ],
              ),
            ],
            if (template.suggestedDisadvantages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(l10n.npcSuggestedDisadv,
                  style: theme.textTheme.labelMedium),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final d in template.suggestedDisadvantages)
                    FilterChip(
                      label: Text('${trData(d.name)} (${trData(d.ring)})'),
                      visualDensity: VisualDensity.compact,
                      selected: choices.disadvantages.contains(d.name),
                      onSelected: (selected) => setState(() {
                        if (selected && choices.disadvantages.length < 2) {
                          choices.disadvantages.add(d.name);
                        } else {
                          choices.disadvantages.remove(d.name);
                        }
                      }),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
