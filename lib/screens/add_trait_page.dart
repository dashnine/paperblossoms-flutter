import 'package:flutter/material.dart';

import '../character.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import 'pickers.dart';

/// Picks a distinction/adversity/passion/anxiety (port of AddDisadvDialog),
/// optionally pre-filtered to one category. Returns true if one was added.
Future<bool> addTraitFlow(BuildContext context, {String? category}) async {
  final options = [
    for (final entry in gameData.advantagesDisadvantages)
      if ((category == null || entry.category == category) &&
          !character.advDisadv.contains(entry.name))
        entry
  ];
  final choice = await pick<AdvDisadv>(
    context,
    title: category == null ? 'Add Trait' : 'Add ${category.toLowerCase()}',
    items: options,
    labelOf: (entry) => entry.name,
    subtitleOf: (entry) => [
      if (category == null) entry.category,
      if (entry.ring.isNotEmpty) entry.ring,
      if (entry.types.isNotEmpty) entry.types.join(', '),
    ].join(' · '),
    descriptionOf: (entry) => gameData.shortDescFor(entry.name),
  );
  if (choice == null) return false;
  character.advDisadv.add(choice.name);
  character.touch();
  return true;
}
