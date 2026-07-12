import 'package:flutter/material.dart';

import '../game_data.dart';
import '../item.dart';
import '../rules_constants.dart';
import '../theme.dart';
import 'pickers.dart';

/// Adds equipment (port of AddItemDialog): pick a base weapon/armor/personal
/// effect, then edit any field before adding — customized gear is stored
/// denormalized on the character. Weapons add one item per grip, as in the
/// original. Pops with a `List<Item>`, or null.
class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  String _type = itemTypeWeapon;
  List<Item> _drafts = [];
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _rarityController = TextEditingController();
  final _qualitiesController = TextEditingController();
  String _unit = 'zeni';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _rarityController.dispose();
    _qualitiesController.dispose();
    super.dispose();
  }

  void _seedControllers() {
    final first = _drafts.first;
    _nameController.text = first.name;
    _priceController.text = '${first.price}';
    _rarityController.text = '${first.rarity}';
    _qualitiesController.text = first.qualities.join(', ');
    _unit = first.unit;
  }

  Future<void> _pickBase() async {
    switch (_type) {
      case itemTypeWeapon:
        final weapon = await pick(
          context,
          title: 'Choose Weapon',
          items: gameData.weapons,
          labelOf: (w) => w.name,
          subtitleOf: (w) =>
              '${w.category} · ${w.skill} · Dmg ${w.damage} · Dls '
              '${w.deadliness}',
          descriptionOf: (w) => gameData.shortDescFor(w.name),
        );
        if (weapon == null) return;
        _drafts = [
          for (final grip in weapon.grips) Item.fromWeapon(weapon, grip)
        ];
      case itemTypeArmor:
        final armor = await pick(
          context,
          title: 'Choose Armor',
          items: gameData.armor,
          labelOf: (a) => a.name,
          subtitleOf: (a) => a.qualities.join(', '),
          descriptionOf: (a) => gameData.shortDescFor(a.name),
        );
        if (armor == null) return;
        _drafts = [Item.fromArmor(armor)];
      default:
        final effect = await pick(
          context,
          title: 'Choose Personal Effect',
          items: gameData.personalEffects,
          labelOf: (e) => e.name,
          subtitleOf: (e) => '${e.price.value} ${e.price.unit}',
          descriptionOf: (e) => gameData.shortDescFor(e.name),
        );
        if (effect == null) return;
        _drafts = [Item.fromPersonalEffect(effect)];
    }
    _seedControllers();
    setState(() {});
  }

  void _startBlank() {
    _drafts = [
      Item(
          type: _type,
          name: '',
          grip: _type == itemTypeWeapon ? '1-hand' : '')
    ];
    _seedControllers();
    setState(() {});
  }

  void _submit() {
    final qualities = [
      for (final quality in _qualitiesController.text.split(','))
        if (quality.trim().isNotEmpty) quality.trim()
    ];
    for (final draft in _drafts) {
      draft.name = _nameController.text.trim();
      draft.price = int.tryParse(_priceController.text) ?? draft.price;
      draft.rarity = int.tryParse(_rarityController.text) ?? draft.rarity;
      draft.unit = _unit;
      draft.qualities = qualities;
    }
    Navigator.pop(context, _drafts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: itemTypeWeapon, label: Text('Weapon')),
              ButtonSegment(value: itemTypeArmor, label: Text('Armor')),
              ButtonSegment(
                  value: itemTypePersonalEffect,
                  label: Text('Personal Effect')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() {
              _type = selection.single;
              _drafts = [];
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonal(
                onPressed: _pickBase,
                child: Text(_drafts.isEmpty
                    ? 'Choose from book…'
                    : 'Change base item…'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _startBlank,
                child: const Text('Custom item'),
              ),
            ],
          ),
          if (_drafts.isNotEmpty) ...[
            const SectionHeader('Details'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (_) => setState(() {}),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _unit,
                  items: const [
                    DropdownMenuItem(value: 'koku', child: Text('koku')),
                    DropdownMenuItem(value: 'bu', child: Text('bu')),
                    DropdownMenuItem(value: 'zeni', child: Text('zeni')),
                  ],
                  onChanged: (value) =>
                      setState(() => _unit = value ?? _unit),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rarityController,
                    decoration: const InputDecoration(labelText: 'Rarity'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            TextField(
              controller: _qualitiesController,
              decoration: const InputDecoration(
                  labelText: 'Qualities (comma-separated)'),
            ),
            if (_type == itemTypeWeapon)
              for (final draft in _drafts) _GripEditor(draft: draft),
            if (_type == itemTypeArmor)
              for (final draft in _drafts) _ArmorEditor(draft: draft),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  _nameController.text.trim().isEmpty ? null : _submit,
              child: Text(_drafts.length > 1
                  ? 'Add (${_drafts.length} grips)'
                  : 'Add Item'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GripEditor extends StatelessWidget {
  final Item draft;

  const _GripEditor({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grip: ${draft.grip}',
                style: Theme.of(context).textTheme.titleSmall),
            Row(
              children: [
                _numField(context, 'Min range', draft.rangeMin,
                    (v) => draft.rangeMin = v),
                _numField(context, 'Max range', draft.rangeMax,
                    (v) => draft.rangeMax = v),
                _numField(
                    context, 'Damage', draft.damage, (v) => draft.damage = v),
                _numField(context, 'Deadliness', draft.deadliness,
                    (v) => draft.deadliness = v),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArmorEditor extends StatelessWidget {
  final Item draft;

  const _ArmorEditor({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _numField(context, 'Physical', draft.physicalResistance,
                (v) => draft.physicalResistance = v),
            _numField(context, 'Supernatural', draft.supernaturalResistance,
                (v) => draft.supernaturalResistance = v),
          ],
        ),
      ),
    );
  }
}

Widget _numField(BuildContext context, String label, int initial,
    ValueChanged<int> onChanged) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextFormField(
        initialValue: '$initial',
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onChanged: (value) => onChanged(int.tryParse(value) ?? initial),
      ),
    ),
  );
}
