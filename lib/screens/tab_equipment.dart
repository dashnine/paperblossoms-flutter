import 'package:flutter/material.dart';

import '../character.dart';
import '../game_data.dart';
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

  void _remove(BuildContext context, Item item) =>
      _removeGroup(context, [item]);

  /// Removes [items] (a weapon's grip rows, or a single item) together, with
  /// a single undo that restores them at their original positions.
  void _removeGroup(BuildContext context, List<Item> items) {
    final entries = <({int index, Item item})>[];
    for (final item in items) {
      final index = character.equipment.indexOf(item);
      if (index >= 0) entries.add((index: index, item: item));
    }
    if (entries.isEmpty) return;
    entries.sort((a, b) => a.index.compareTo(b.index));
    for (final entry in entries.reversed) {
      character.equipment.removeAt(entry.index);
    }
    character.touch();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed ${entries.first.item.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            for (final entry in entries) {
              character.equipment.insert(
                  entry.index.clamp(0, character.equipment.length),
                  entry.item);
            }
            character.touch();
          },
        ),
      ));
  }

  /// The description to display for [item]: a per-item override wins, then
  /// the user's full description, then the short one.
  String _descFor(Item item) {
    if (item.description.isNotEmpty) return item.description;
    final full = gameData.descriptionFor(item.name);
    return full.isNotEmpty ? full : gameData.shortDescFor(item.name);
  }

  Widget _buildWeapons(BuildContext context, List<Item> weapons) {
    if (weapons.isEmpty) {
      return const EmptyHint('No weapons yet — tap + to add.');
    }
    final groups = Item.gripGroups(weapons);
    // Cards below desktop width: the full stat table only fits expanded.
    if (!context.isExpanded) {
      return Column(
        children: [
          for (final group in groups)
            Card(
              child: ListTile(
                title: Text(group.first.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${group.first.category} · ${group.first.skill}'
                        '${group.first.qualities.isEmpty ? '' : ' · ${group.first.qualities.join(', ')}'}'),
                    for (final grip in group)
                      Text(
                          '${grip.grip}: Range ${grip.rangeMin}-${grip.rangeMax}'
                          ' · Dmg ${grip.damage} · Dls ${grip.deadliness}',
                          style: Theme.of(context).textTheme.bodySmall),
                    _description(context, group.first),
                  ],
                ),
                trailing: _removeGroupButton(context, group),
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
        for (final group in groups)
          for (var i = 0; i < group.length; i++)
            [
              i == 0 ? _nameCell(context, group.first) : const Text(''),
              Text(i == 0 ? group.first.category : ''),
              Text(i == 0 ? group.first.skill : ''),
              Text(group[i].grip),
              Text('${group[i].rangeMin}-${group[i].rangeMax}'),
              Text('${group[i].damage}'),
              Text('${group[i].deadliness}'),
              Text(i == 0 ? group.first.qualities.join(', ') : ''),
              i == 0
                  ? _removeGroupButton(context, group)
                  : const SizedBox.shrink(),
            ],
      ],
    );
  }

  /// The item's description, indented under its stat lines (empty when the
  /// item has none).
  Widget _description(BuildContext context, Item item) {
    final desc = _descFor(item);
    if (desc.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(desc),
    );
  }

  /// Name cell for wide tables: the item name with its short description
  /// beneath, and the full description on hover.
  Widget _nameCell(BuildContext context, Item item) {
    final short = gameData.shortDescFor(item.name);
    final full = _descFor(item);
    final cell = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name),
        if (short.isNotEmpty)
          SizedBox(
            width: 260,
            child: Text(short,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
    if (full.isEmpty || full == short) return cell;
    return Tooltip(
      message: full,
      waitDuration: const Duration(milliseconds: 500),
      child: cell,
    );
  }

  Widget _buildArmor(BuildContext context, List<Item> armorItems) {
    if (armorItems.isEmpty) {
      return const EmptyHint('No armor yet — tap + to add.');
    }
    if (!context.isExpanded) {
      return Column(
        children: [
          for (final item in armorItems)
            Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Physical ${item.physicalResistance} · '
                        'Supernatural ${item.supernaturalResistance}'
                        '${item.qualities.isEmpty ? '' : '\n${item.qualities.join(', ')}'}'),
                    _description(context, item),
                  ],
                ),
                trailing: _removeButton(context, item),
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
            _nameCell(context, item),
            Text('${item.physicalResistance}'),
            Text('${item.supernaturalResistance}'),
            Text(item.qualities.join(', ')),
            _removeButton(context, item),
          ],
      ],
    );
  }

  Widget _buildOther(BuildContext context, List<Item> items) {
    if (items.isEmpty) {
      return const EmptyHint('No personal effects yet — tap + to add.');
    }
    return Column(
      children: [
        for (final item in items)
          Card(
            child: ListTile(
              dense: true,
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  item.type == itemTypePersonalEffect
                      ? Text(
                          '${item.price} ${item.unit} · Rarity ${item.rarity}')
                      : Text(item.type),
                  _description(context, item),
                ],
              ),
              trailing: _removeButton(context, item),
            ),
          ),
      ],
    );
  }

  Widget _removeButton(BuildContext context, Item item) => IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _remove(context, item),
      );

  Widget _removeGroupButton(BuildContext context, List<Item> group) =>
      IconButton(
        tooltip: 'Remove',
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _removeGroup(context, group),
      );

  Widget _scrollableTable(
      {required List<String> columns, required List<List<Widget>> rows}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        // Name cells hold a second description line; let rows grow to fit.
        dataRowMaxHeight: double.infinity,
        columns: [for (final c in columns) DataColumn(label: Text(c))],
        rows: [
          for (final row in rows)
            DataRow(cells: [for (final cell in row) DataCell(cell)]),
        ],
      ),
    );
  }
}
