import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import '../widgets/int_spinner.dart';
import 'add_bond_page.dart';

/// Tab 4: bonds with rank adjustment (Bonds page, a v3 feature of the
/// original app).
class BondsTab extends StatelessWidget {
  const BondsTab({super.key});

  void _removeBond(BuildContext context, CharacterBond bond) {
    final index = character.bonds.indexOf(bond);
    if (index < 0) return;
    character.bonds.removeAt(index);
    character.touch();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.l10n.removedName(trData(bond.name))),
        action: SnackBarAction(
          label: context.l10n.undo,
          onPressed: () {
            character.bonds
                .insert(index.clamp(0, character.bonds.length), bond);
            character.touch();
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionHeader(
          context.l10n.bondsSection,
          trailing: IconButton(
            tooltip: context.l10n.addBond,
            icon: const Icon(Icons.add),
            onPressed: () => addBondFlow(context),
          ),
        ),
        if (character.bonds.isEmpty) EmptyHint(context.l10n.noBondsYet),
        for (final bond in character.bonds)
          Card(
            child: ListTile(
              title: Text(trData(bond.name)),
              subtitle: Text([
                trData(gameData.bondByName(bond.name)?.ability ?? ''),
                gameData.shortDescFor(bond.name),
              ].where((s) => s.isNotEmpty).join(' · ')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IntSpinner(
                    label: context.l10n.rankLabel,
                    value: bond.rank,
                    min: 1,
                    max: 5,
                    onChanged: (value) {
                      bond.rank = value;
                      character.touch();
                    },
                  ),
                  IconButton(
                    tooltip: context.l10n.remove,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeBond(context, bond),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
