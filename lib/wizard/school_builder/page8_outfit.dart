import 'package:flutter/material.dart';

import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../wizard_state.dart';
import '../wizard_widgets.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 8: the starting outfit (PoW p. 84, Table 2-11), prefilled from the
/// primary role's suggested outfit and freely editable.
class SbPage8Outfit extends StatelessWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage8Outfit({
    super.key,
    required this.state,
    required this.onChanged,
  });

  /// Known item names plus the rarity directives the character wizard turns
  /// into pickers, matching the bundled outfit vocabulary.
  List<String> _candidates() => [
    'Traveling Pack',
    'One Weapon of Rarity 5 or Lower',
    'One Weapon of Rarity 6 or Lower',
    'One Weapon of Rarity 7 or Lower',
    'One Item of Rarity 3 or Lower',
    'One Item of Rarity 4 or Lower',
    'One Item of Rarity 5 or Lower',
    'One Item of Rarity 6 or Lower',
    for (final w in gameData.weapons) w.name,
    for (final a in gameData.armor) a.name,
    for (final p in gameData.personalEffects) p.name,
  ];

  String _subtitle(String name) {
    final type = gameData.itemTypeOf(name);
    return type.isEmpty ? '' : type;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbOutfitQuestion),
        Text(l10n.sbOutfitHelp, style: Theme.of(context).textTheme.bodySmall),
        if (state.startingOutfit.isEmpty) SoftWarning(l10n.sbWarnNoOutfit),
        for (final set in state.startingOutfit) ...[
          ChoiceSetEditor(
            set: set,
            candidates: _candidates(),
            pickerTitle: l10n.sbOutfitQuestion,
            subtitleOf: _subtitle,
            onChanged: () {
              state.outfitTouched = true;
              onChanged();
            },
            onRemoveRow: () {
              state.startingOutfit.remove(set);
              state.outfitTouched = true;
              onChanged();
            },
          ),
          // The character wizard only turns a rarity directive into a
          // picker when it stands alone in its row; mixed in with items it
          // would silently produce nothing (also a hard rule on Next).
          if (set.options.length > 1 &&
              set.options.any(
                (o) => WizardState.equipmentSpecialOptions(o) != null,
              ))
            SoftWarning(l10n.sbErrDirectiveAlone),
        ],
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.sbAddRow),
          onPressed: () {
            state.startingOutfit.add(EditableChoiceSet());
            state.outfitTouched = true;
            onChanged();
          },
        ),
      ],
    );
  }
}
