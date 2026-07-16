import 'package:flutter/material.dart' hide Title;

import '../character.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import 'pickers.dart';

/// Picks a new title for the character and applies the disadvantage grants
/// some titles list as immediate effects (see titleGrants). Returns true if
/// a title was added.
Future<bool> addTitleFlow(BuildContext context) async {
  final options = [
    for (final title in gameData.titles)
      if (!character.titles.contains(title.name)) title
  ];
  final choice = await pick<Title>(
    context,
    title: context.l10n.addTitleTitle,
    items: options,
    labelOf: (title) => title.name,
    subtitleOf: (title) => context.l10n.xpAmount(title.xpToCompletion) +
        (title.titleAbility.isEmpty ? '' : ' · ${trData(title.titleAbility)}'),
    descriptionOf: (title) => gameData.shortDescFor(title.titleAbility),
  );
  if (choice == null) return false;
  character.titles.add(choice.name);
  final grant = titleGrants[choice.name];
  if (grant != null && !character.advDisadv.contains(grant)) {
    character.advDisadv.add(grant);
  }
  character.touch();
  return true;
}
