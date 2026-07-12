import 'package:flutter/material.dart';

import '../character.dart';
import '../item.dart';
import '../layout.dart';
import '../rules_constants.dart';
import '../theme.dart';
import 'add_item_page.dart';

/// Tab 6: weapons, armor, and personal effects. Wide layouts get real data
/// tables; compact layouts get cards.
class EquipmentTab extends StatelessWidget {
  const EquipmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final weapons =
        character.equipment.where((item) => item.isWeapon).toList();
    final armor = character.equipment.where((item) => item.isArmor).toList();
    final other = character.equipment
        .where((item) => !item.isWeapon && !item.isArmor)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          'Weapons',
          trailing: _addButton(context),
        ),
        _buildWeapons(context, weapons),
        const SectionHeader('Armor'),
        _buildArmor(context, armor),
        const SectionHeader('Personal Effects'),
        _buildOther(context, other),
      ],
    );
  }

  Widget _addButton(BuildContext context) => IconButton(
        tooltip: 'Add item',
        icon: const Icon(Icons.add),
        onPressed: () async {
          final items = await Navigator.push<List<Item>>(
            context,
            MaterialPageRoute(builder: (context) => const AddItemPage()),
          );
          if (items == null || items.isEmpty) return;
          character.equipment.addAll(items);
          character.touch();
        },
      );

  void _remove(Item item) {
    character.equipment.remove(item);
    character.touch();
  }

  Widget _buildWeapons(BuildContext context, List<Item> weapons) {
    if (weapons.isEmpty) return const Text('—');
    if (context.isCompact) {
      return Column(
        children: [
          for (final weapon in weapons)
            Card(
              child: ListTile(
                title: Text('${weapon.name} (${weapon.grip})'),
                subtitle: Text(
                    '${weapon.category} · ${weapon.skill} · Range '
                    '${weapon.rangeMin}-${weapon.rangeMax} · Dmg '
                    '${weapon.damage} · Dls ${weapon.deadliness}'
                    '${weapon.qualities.isEmpty ? '' : '\n${weapon.qualities.join(', ')}'}'),
                trailing: _removeButton(weapon),
              ),
            ),
        ],
      );
    }
    return _scrollableTable(
      columns: const [
        'Name', 'Category', 'Skill', 'Grip', 'Range', 'Dmg', 'Dls',
        'Qualities', ''
      ],
      rows: [
        for (final weapon in weapons)
          [
            Text(weapon.name),
            Text(weapon.category),
            Text(weapon.skill),
            Text(weapon.grip),
            Text('${weapon.rangeMin}-${weapon.rangeMax}'),
            Text('${weapon.damage}'),
            Text('${weapon.deadliness}'),
            Text(weapon.qualities.join(', ')),
            _removeButton(weapon),
          ],
      ],
    );
  }

  Widget _buildArmor(BuildContext context, List<Item> armorItems) {
    if (armorItems.isEmpty) return const Text('—');
    if (context.isCompact) {
      return Column(
        children: [
          for (final item in armorItems)
            Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Physical ${item.physicalResistance} · '
                    'Supernatural ${item.supernaturalResistance}'
                    '${item.qualities.isEmpty ? '' : '\n${item.qualities.join(', ')}'}'),
                trailing: _removeButton(item),
              ),
            ),
        ],
      );
    }
    return _scrollableTable(
      columns: const ['Name', 'Physical', 'Supernatural', 'Qualities', ''],
      rows: [
        for (final item in armorItems)
          [
            Text(item.name),
            Text('${item.physicalResistance}'),
            Text('${item.supernaturalResistance}'),
            Text(item.qualities.join(', ')),
            _removeButton(item),
          ],
      ],
    );
  }

  Widget _buildOther(BuildContext context, List<Item> items) {
    if (items.isEmpty) return const Text('—');
    return Column(
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: item.type == itemTypePersonalEffect
                  ? Text('${item.price} ${item.unit} · Rarity ${item.rarity}')
                  : Text(item.type),
              trailing: _removeButton(item),
            ),
          ),
      ],
    );
  }

  Widget _removeButton(Item item) => IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _remove(item),
      );

  Widget _scrollableTable(
      {required List<String> columns, required List<List<Widget>> rows}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [for (final c in columns) DataColumn(label: Text(c))],
        rows: [
          for (final row in rows)
            DataRow(cells: [for (final cell in row) DataCell(cell)]),
        ],
      ),
    );
  }
}
