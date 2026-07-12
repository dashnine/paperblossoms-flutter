import 'package:flutter/material.dart';

import '../character.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../theme.dart';

/// Tab 5: every technique the character knows (creation techniques plus
/// purchased advances), with details and user-entered descriptions.
class TechniquesTab extends StatelessWidget {
  const TechniquesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final names = knownTechniques(character);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Techniques'),
        if (names.isEmpty) const Text('No techniques known.'),
        for (final name in names) _TechniqueCard(name: name),
      ],
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final String name;

  const _TechniqueCard({required this.name});

  @override
  Widget build(BuildContext context) {
    final tech = gameData.techniqueByName(name);
    final description = gameData.descriptionFor(name);
    final shortDesc = gameData.shortDescFor(name);
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tech != null)
              Text([
                tech.category,
                if (tech.subcategory.isNotEmpty) tech.subcategory,
                'Rank ${tech.rank}',
                if (tech.reference.book.isNotEmpty) '${tech.reference}',
                if (tech.restriction.isNotEmpty)
                  'Restriction: ${tech.restriction}',
              ].join(' · '))
            else
              const Text('Custom or unknown technique'),
            if (shortDesc.isNotEmpty) Text(shortDesc),
            if (description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(description),
              ),
          ],
        ),
      ),
    );
  }
}
