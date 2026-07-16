import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import 'pickers.dart';

/// Picks a bond (port of AddBondDialog). Returns true if one was added.
Future<bool> addBondFlow(BuildContext context) async {
  final held = {for (final bond in character.bonds) bond.name};
  final options = [
    for (final bond in gameData.bonds)
      if (!held.contains(bond.name)) bond
  ];
  final choice = await pick<Bond>(
    context,
    title: context.l10n.addBondTitle,
    items: options,
    labelOf: (bond) => bond.name,
    subtitleOf: (bond) => trData(bond.ability),
    descriptionOf: (bond) => gameData.shortDescFor(bond.name),
  );
  if (choice == null) return false;
  character.bonds.add(CharacterBond(name: choice.name));
  character.touch();
  return true;
}
