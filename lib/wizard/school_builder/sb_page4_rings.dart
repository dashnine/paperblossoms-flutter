import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Step 4: the two +1 ring increases (PoW p. 79, Tables 2-5 and 2-6).
class SbPage4Rings extends StatelessWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage4Rings({super.key, required this.state, required this.onChanged});

  String _traitHint(AppLocalizations l10n, String ring) => switch (ring) {
    'Air' => l10n.sbRingTraitAir,
    'Earth' => l10n.sbRingTraitEarth,
    'Fire' => l10n.sbRingTraitFire,
    'Void' => l10n.sbRingTraitVoid,
    _ => l10n.sbRingTraitWater,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final suggested = state.defaults?.suggestedRings ?? const [];
    final doubled =
        state.ringIncrease[0].isNotEmpty &&
        state.ringIncrease[0] == state.ringIncrease[1];
    final offSuggestion =
        suggested.isNotEmpty &&
        state.ringIncrease[0].isNotEmpty &&
        !suggested.contains(state.ringIncrease[0]);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbRingsQuestion),
        if (state.primaryRole == 'Shugenja')
          Text(
            l10n.sbHintShugenjaRing,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else if (suggested.isNotEmpty)
          Text(
            l10n.sbHintFirstRing(
              trData(state.primaryRole),
              suggested.map(trData).join(' / '),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        WizDropdown(
          label: l10n.sbRing1,
          value: state.ringIncrease[0],
          options: gameData.ringNames(),
          onChanged: (value) {
            state
              ..ringIncrease[0] = value
              ..ringsTouched = true;
            onChanged();
          },
        ),
        WizDropdown(
          label: l10n.sbRing2,
          value: state.ringIncrease[1],
          options: gameData.ringNames(),
          onChanged: (value) {
            state
              ..ringIncrease[1] = value
              ..ringsTouched = true;
            onChanged();
          },
        ),
        if (doubled) SoftWarning(l10n.sbWarnDoubledRing),
        if (offSuggestion)
          SoftWarning(l10n.sbWarnRingsSuggestion(trData(state.primaryRole))),
        QuestionHeader(l10n.sbSecondRingHintsTitle),
        for (final ring in gameData.ringNames())
          ListTile(
            dense: true,
            leading: Text(
              trData(ring),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            title: Text(_traitHint(l10n, ring)),
          ),
      ],
    );
  }
}
