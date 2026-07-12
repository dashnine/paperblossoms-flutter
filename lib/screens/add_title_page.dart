import 'package:flutter/material.dart' hide Title;

import '../character.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../rules_constants.dart';
import 'pickers.dart';

/// Picks a new title for the character and applies the side effects the
/// original app special-cased (The Damned grants Ferocity, Moon Cultist
/// grants Dark Secret). Returns true if a title was added.
Future<bool> addTitleFlow(BuildContext context) async {
  final options = [
    for (final title in gameData.titles)
      if (!character.titles.contains(title.name)) title
  ];
  final choice = await pick<Title>(
    context,
    title: 'Add Title',
    items: options,
    labelOf: (title) => title.name,
    subtitleOf: (title) => '${title.xpToCompletion} XP'
        '${title.titleAbility.isEmpty ? '' : ' · ${title.titleAbility}'}',
    descriptionOf: (title) => gameData.shortDescFor(title.titleAbility),
  );
  if (choice == null) return false;
  character.titles.add(choice.name);
  if (choice.name == titleTheDamned) {
    if (!character.advDisadv.contains(titleTheDamnedGrant)) {
      character.advDisadv.add(titleTheDamnedGrant);
    }
  } else if (choice.name == titleMoonCultist) {
    character.advDisadv.add(titleMoonCultistGrant);
  }
  character.touch();
  return true;
}
