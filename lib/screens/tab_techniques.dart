import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
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
        SectionHeader(context.l10n.techniquesSection),
        if (names.isEmpty) EmptyHint(context.l10n.noTechniquesYet),
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
        title: Text(trData(name)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tech != null)
              Text([
                trData(tech.category),
                if (tech.subcategory.isNotEmpty) trData(tech.subcategory),
                context.l10n.rankN(tech.rank),
                if (tech.reference.book.isNotEmpty) '${tech.reference}',
                if (tech.restriction.isNotEmpty)
                  context.l10n.restrictionLabel(tech.restriction),
              ].join(' · '))
            else
              Text(context.l10n.customOrUnknownTechnique),
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
