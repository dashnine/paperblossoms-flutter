import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import '../theme.dart';
import 'add_trait_page.dart';
import 'custom_legacy_page.dart';

/// Tab 3: distinctions, adversities, passions, anxieties, and Legacies held
/// by the character, grouped by category as in the original Personal Traits
/// page (Legacies are the fifth category, Legacies of War p. 5).
class PersonalTraitsTab extends StatelessWidget {
  const PersonalTraitsTab({super.key});

  static const _categories = [
    'Distinctions',
    'Adversities',
    'Passions',
    'Anxieties',
    'Legacies',
  ];

  // A priced trait's XP advance goes with it (see Character.removeTrait).
  void _remove(String name) => character.removeTrait(name);

  /// Builds a custom Legacy template (Legacies of War p. 12) and takes it.
  Future<void> _createCustomLegacy(BuildContext context) async {
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CustomLegacyPage()),
    );
    final entry = saved == null ? null : gameData.advDisadvByName(saved);
    if (entry != null) character.addTrait(entry);
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
            trData(category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category == categoryLegacies)
                  IconButton(
                    tooltip: context.l10n.createCustomLegacy,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    onPressed: () => _createCustomLegacy(context),
                  ),
                IconButton(
                  tooltip: context.l10n.add,
                  icon: const Icon(Icons.add),
                  onPressed: () => addTraitFlow(context, category: category),
                ),
              ],
            ),
          ),
          if (byCategory[category]!.isEmpty)
            const Text('—')
          else
            for (final entry in byCategory[category]!)
              Card(
                child: ListTile(
                  title: Text(trData(entry.name)),
                  subtitle: Text([
                    if (entry.ring.isNotEmpty) trData(entry.ring),
                    if (entry.types.isNotEmpty)
                      entry.types.map(trData).join(', '),
                    if (entry.xp > 0) context.l10n.costXp(entry.xp),
                    if (gameData.shortDescFor(entry.name).isNotEmpty)
                      gameData.shortDescFor(entry.name),
                  ].join(' · ')),
                  trailing: IconButton(
                    tooltip: context.l10n.remove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _remove(entry.name),
                  ),
                ),
              ),
        ],
        if (unknown.isNotEmpty) ...[
          SectionHeader(context.l10n.unknownCustomSection),
          for (final name in unknown)
            Card(
              child: ListTile(
                title: Text(name),
                trailing: IconButton(
                  tooltip: context.l10n.remove,
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
