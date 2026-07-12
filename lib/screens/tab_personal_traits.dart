import 'package:flutter/material.dart';

import '../character.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../theme.dart';
import 'add_trait_page.dart';

/// Tab 3: distinctions, adversities, passions, and anxieties held by the
/// character, grouped by category as in the original Personal Traits page.
class PersonalTraitsTab extends StatelessWidget {
  const PersonalTraitsTab({super.key});

  static const _categories = [
    'Distinctions',
    'Adversities',
    'Passions',
    'Anxieties',
  ];

  void _remove(String name) {
    character.advDisadv.remove(name);
    character.touch();
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, List<AdvDisadv>>{
      for (final category in _categories) category: [],
    };
    final unknown = <String>[];
    for (final name in character.advDisadv) {
      final entry = gameData.advDisadvByName(name);
      if (entry == null) {
        unknown.add(name);
      } else {
        (byCategory[entry.category] ??= []).add(entry);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in byCategory.keys) ...[
          SectionHeader(
            category,
            trailing: IconButton(
              tooltip: 'Add',
              icon: const Icon(Icons.add),
              onPressed: () => addTraitFlow(context, category: category),
            ),
          ),
          if (byCategory[category]!.isEmpty)
            const Text('—')
          else
            for (final entry in byCategory[category]!)
              Card(
                child: ListTile(
                  title: Text(entry.name),
                  subtitle: Text([
                    if (entry.ring.isNotEmpty) entry.ring,
                    if (entry.types.isNotEmpty) entry.types.join(', '),
                    if (gameData.shortDescFor(entry.name).isNotEmpty)
                      gameData.shortDescFor(entry.name),
                  ].join(' · ')),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _remove(entry.name),
                  ),
                ),
              ),
        ],
        if (unknown.isNotEmpty) ...[
          const SectionHeader('Unknown (custom or missing data)'),
          for (final name in unknown)
            Card(
              child: ListTile(
                title: Text(name),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _remove(name),
                ),
              ),
            ),
        ],
      ],
    );
  }
}
