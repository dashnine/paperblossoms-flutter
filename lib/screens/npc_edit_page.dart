import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../npc_math.dart';
import '../npc_models.dart';
import '../rules_constants.dart';
import '../theme.dart';
import '../user_data_store.dart';
import '../widgets/int_spinner.dart';
import '../widgets/technique_picker.dart';

/// Full field-level NPC editor — the secondary path behind the quick
/// builder. Editing a bundled sample saves a custom copy; [replacingName]
/// makes a rename replace the original custom entry.
class NpcEditPage extends StatefulWidget {
  final Npc? npc;
  final String? replacingName;

  const NpcEditPage({super.key, this.npc, this.replacingName});

  @override
  State<NpcEditPage> createState() => _NpcEditPageState();
}

class _NpcEditPageState extends State<NpcEditPage> {
  late final Npc _npc = widget.npc?.clone() ?? Npc();
  bool _autoDerived = false;
  late final TextEditingController _name =
      TextEditingController(text: _npc.name);
  late final TextEditingController _blurb =
      TextEditingController(text: _npc.blurb);
  late final TextEditingController _gearEquipped =
      TextEditingController(text: _npc.gearEquipped.join('\n'));
  late final TextEditingController _gearOther =
      TextEditingController(text: _npc.gearOther.join('\n'));

  @override
  void dispose() {
    _name.dispose();
    _blurb.dispose();
    _gearEquipped.dispose();
    _gearOther.dispose();
    super.dispose();
  }

  void _recomputeDerived() {
    if (!_autoDerived) return;
    _npc.derived = derivedFromRings(_npc.type, _npc.rings);
  }

  Future<void> _save() async {
    _npc.name = _name.text.trim();
    _npc.blurb = _blurb.text.trim();
    _npc.gearEquipped = [
      for (final line in _gearEquipped.text.split('\n'))
        if (line.trim().isNotEmpty) line.trim()
    ];
    _npc.gearOther = [
      for (final line in _gearOther.text.split('\n'))
        if (line.trim().isNotEmpty) line.trim()
    ];
    if (_npc.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.nameRequiredSnack)),
      );
      return;
    }
    // Memory-first store contract: merge now, disk write in the background.
    unawaited(userDataStore.saveCustomNpc(
      _npc,
      replacingName: widget.replacingName,
    ));
    Navigator.pop(context, _npc.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.npc == null ? l10n.npcNewTitle : l10n.npcEditTitle),
        actions: [
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
          const SizedBox(height: 12),
          TextField(
            controller: _blurb,
            decoration: InputDecoration(
              labelText: l10n.npcBlurbLabel,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'minion', label: Text(l10n.npcTypeMinion)),
              ButtonSegment(
                  value: 'adversary', label: Text(l10n.npcTypeAdversary)),
            ],
            selected: {_npc.type},
            onSelectionChanged: (selection) => setState(() {
              _npc.type = selection.first;
              _recomputeDerived();
            }),
          ),
          SectionHeader(l10n.npcConflictRank),
          Wrap(
            spacing: 16,
            children: [
              IntSpinner(
                label: l10n.npcCombatRank,
                value: _npc.crCombat,
                min: 0,
                max: 99,
                onChanged: (v) => setState(() => _npc.crCombat = v),
              ),
              IntSpinner(
                label: l10n.npcIntrigueRank,
                value: _npc.crIntrigue,
                min: 0,
                max: 99,
                onChanged: (v) => setState(() => _npc.crIntrigue = v),
              ),
            ],
          ),
          SectionHeader(l10n.ringsSection),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final ring in const [
                ringAir,
                ringEarth,
                ringFire,
                ringWater,
                ringVoid
              ])
                IntSpinner(
                  label: trData(ring),
                  value: _npc.rings[ring] ?? 0,
                  min: 0,
                  max: 9,
                  onChanged: (v) => setState(() {
                    _npc.rings[ring] = v;
                    _recomputeDerived();
                  }),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.npcAutoDerived),
            value: _autoDerived,
            onChanged: (v) => setState(() {
              _autoDerived = v;
              _recomputeDerived();
            }),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _derivedField(l10n.endurance, _npc.derived.endurance,
                  (v) => _npc.derived.endurance = v),
              _derivedField(l10n.composure, _npc.derived.composure,
                  (v) => _npc.derived.composure = v),
              _derivedField(l10n.focusStat, _npc.derived.focus,
                  (v) => _npc.derived.focus = v),
              _derivedField(l10n.vigilance, _npc.derived.vigilance,
                  (v) => _npc.derived.vigilance = v),
            ],
          ),
          SectionHeader('${l10n.honor} · ${l10n.glory} · ${l10n.statusLabel}'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${l10n.honor} / ${l10n.glory} / ${l10n.statusLabel}'),
            value: _npc.social != null,
            onChanged: (v) =>
                setState(() => _npc.social = v ? NpcSocial() : null),
          ),
          if (_npc.social != null)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                IntSpinner(
                  label: l10n.honor,
                  value: _npc.social!.honor,
                  max: 100,
                  onChanged: (v) => setState(() => _npc.social!.honor = v),
                ),
                IntSpinner(
                  label: l10n.glory,
                  value: _npc.social!.glory,
                  max: 100,
                  onChanged: (v) => setState(() => _npc.social!.glory = v),
                ),
                IntSpinner(
                  label: l10n.statusLabel,
                  value: _npc.social!.status,
                  max: 100,
                  onChanged: (v) => setState(() => _npc.social!.status = v),
                ),
              ],
            ),
          SectionHeader(l10n.npcDemeanorLabel),
          DropdownButtonFormField<String>(
            value: gameData.npc.demeanorByName(_npc.demeanor) == null
                ? ''
                : _npc.demeanor,
            items: [
              DropdownMenuItem(value: '', child: Text(l10n.npcDemeanorNone)),
              for (final d in gameData.npc.demeanors)
                DropdownMenuItem(
                  value: d.name,
                  child: Text(
                    '${trData(d.name)} — '
                    '${l10n.npcDemeanorTnMods(d.modifierLine(trData))}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _npc.demeanor = v ?? ''),
          ),
          SectionHeader(l10n.npcSkillGroupsLabel),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final group in const [
                'Artisan',
                'Martial',
                'Scholar',
                'Social',
                'Trade'
              ])
                IntSpinner(
                  label: trData(group),
                  value: _npc.skillGroups[group] ?? 0,
                  min: 0,
                  max: 9,
                  onChanged: (v) =>
                      setState(() => _npc.skillGroups[group] = v),
                ),
            ],
          ),
          SectionHeader(l10n.npcAdvantagesLabel),
          _traitList(_npc.advantages, l10n.npcAddAdvantage),
          SectionHeader(l10n.npcDisadvantagesLabel),
          _traitList(_npc.disadvantages, l10n.npcAddDisadvantage),
          SectionHeader(l10n.npcWeaponsGear),
          for (final (index, w) in _npc.weapons.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(trData(w.name)),
              subtitle: Text(
                '${l10n.colRange} ${w.range} · ${l10n.damageLabel} '
                '${w.damage} · ${l10n.deadlinessLabel} ${w.deadliness}'
                '${w.qualities.isEmpty ? '' : ' · ${w.qualities.join(', ')}'}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    setState(() => _npc.weapons.removeAt(index)),
              ),
              onTap: () => _editWeapon(index),
            ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.npcAddWeapon),
            onPressed: () => _editWeapon(null),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _gearEquipped,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.npcGearEquippedLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gearOther,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.npcGearOtherLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          SectionHeader(l10n.abilitiesSection),
          for (final (index, a) in _npc.abilities.indexed)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(trData(a.name)),
              subtitle: Text(
                a.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    setState(() => _npc.abilities.removeAt(index)),
              ),
              onTap: () => _editAbility(index),
            ),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.npcAddAbility),
            onPressed: () => _editAbility(null),
          ),
          SectionHeader(l10n.npcTechniquesLabel),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final name in _npc.techniques)
                InputChip(
                  label: Text(trData(name)),
                  onDeleted: () =>
                      setState(() => _npc.techniques.remove(name)),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(l10n.npcAddTechnique),
                onPressed: () async {
                  final picked = await showTechniquePicker(
                    context,
                    exclude: _npc.techniques.toSet(),
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _npc.techniques.add(picked));
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
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

  Widget _derivedField(
      String label, String value, void Function(String) onChanged) {
    return SizedBox(
      width: 110,
      child: TextFormField(
        key: ValueKey('$label:$value'),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (v) => onChanged(v.trim()),
      ),
    );
  }

  Widget _traitList(List<NpcTrait> traits, String addLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, t) in traits.indexed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${trData(t.name)} (${trData(t.ring)})'),
            subtitle: Text(t.tagLine),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => traits.removeAt(index)),
            ),
            onTap: () => _editTrait(traits, index),
          ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(addLabel),
          onPressed: () => _editTrait(traits, null),
        ),
      ],
    );
  }

  Future<void> _editTrait(List<NpcTrait> traits, int? index) async {
    final l10n = context.l10n;
    final trait = index == null ? NpcTrait() : traits[index];
    final name = TextEditingController(text: trait.name);
    final groups = TextEditingController(text: trait.groups.join(', '));
    final types = TextEditingController(text: trait.types.join(', '));
    var ring = trait.ring.isEmpty ? ringAir : trait.ring;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? l10n.npcAddAdvantage : trait.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: l10n.nameLabel),
              ),
              DropdownButtonFormField<String>(
                value: ring,
                decoration: InputDecoration(labelText: l10n.npcRingLabel),
                items: [
                  for (final r in const [
                    ringAir,
                    ringEarth,
                    ringFire,
                    ringWater,
                    ringVoid
                  ])
                    DropdownMenuItem(value: r, child: Text(trData(r))),
                ],
                onChanged: (v) => setDialogState(() => ring = v ?? ring),
              ),
              TextField(
                controller: groups,
                decoration: InputDecoration(labelText: l10n.npcGroupsLabel),
              ),
              TextField(
                controller: types,
                decoration: InputDecoration(labelText: l10n.npcTypesLabel),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
    final nameText = name.text.trim();
    final groupsText = groups.text;
    final typesText = types.text;
    name.dispose();
    groups.dispose();
    types.dispose();
    if (saved != true || !mounted) return;
    List<String> split(String s) => [
          for (final part in s.split(','))
            if (part.trim().isNotEmpty) part.trim()
        ];
    setState(() {
      trait
        ..name = nameText
        ..ring = ring
        ..groups = split(groupsText)
        ..types = split(typesText);
      if (index == null && trait.name.isNotEmpty) traits.add(trait);
    });
  }

  Future<void> _editWeapon(int? index) async {
    final l10n = context.l10n;
    final weapon = index == null ? NpcWeaponLine() : _npc.weapons[index];
    final name = TextEditingController(text: weapon.name);
    final range = TextEditingController(text: weapon.range);
    final damage = TextEditingController(text: weapon.damage);
    final deadliness = TextEditingController(text: weapon.deadliness);
    final qualities =
        TextEditingController(text: weapon.qualities.join(', '));
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? l10n.npcAddWeapon : weapon.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l10n.nameLabel),
            ),
            TextField(
              controller: range,
              decoration: InputDecoration(labelText: l10n.colRange),
            ),
            TextField(
              controller: damage,
              decoration: InputDecoration(labelText: l10n.damageLabel),
            ),
            TextField(
              controller: deadliness,
              decoration: InputDecoration(labelText: l10n.deadlinessLabel),
            ),
            TextField(
              controller: qualities,
              decoration:
                  InputDecoration(labelText: l10n.qualitiesCommaSeparated),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final nameText = name.text.trim();
    final rangeText = range.text.trim();
    final damageText = damage.text.trim();
    final deadlinessText = deadliness.text.trim();
    final qualitiesText = qualities.text;
    name.dispose();
    range.dispose();
    damage.dispose();
    deadliness.dispose();
    qualities.dispose();
    if (saved != true || !mounted) return;
    setState(() {
      weapon
        ..name = nameText
        ..range = rangeText
        ..damage = damageText
        ..deadliness = deadlinessText
        ..qualities = [
          for (final part in qualitiesText.split(','))
            if (part.trim().isNotEmpty) part.trim()
        ];
      if (index == null && weapon.name.isNotEmpty) _npc.weapons.add(weapon);
    });
  }

  Future<void> _editAbility(int? index) async {
    final l10n = context.l10n;
    final ability = index == null ? NpcAbility() : _npc.abilities[index];
    final name = TextEditingController(text: ability.name);
    final text = TextEditingController(text: ability.text);
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? l10n.npcAddAbility : ability.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: l10n.nameLabel),
            ),
            TextField(
              controller: text,
              maxLines: 6,
              decoration:
                  InputDecoration(labelText: l10n.npcAbilityTextLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    final nameText = name.text.trim();
    final bodyText = text.text.trim();
    name.dispose();
    text.dispose();
    if (saved != true || !mounted) return;
    setState(() {
      ability
        ..name = nameText
        ..text = bodyText;
      if (index == null && ability.name.isNotEmpty) {
        _npc.abilities.add(ability);
      }
    });
  }
}
