import 'package:flutter/material.dart';

import '../character.dart';
import '../derived_stats.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import '../widgets/int_spinner.dart';
import 'pickers.dart';

/// What the player chose in the dialog; the Table 6-6 row follows from
/// [finalSeverity] via critBand().
class CritStrikeResult {
  final int finalSeverity;
  final String resistRing;
  final bool razorEdged;

  const CritStrikeResult({
    required this.finalSeverity,
    required this.resistRing,
    required this.razorEdged,
  });
}

/// Walks a suffered critical strike per core p.270: severity in, real-dice
/// Fitness check result in, Table 6-6 row out, then applies the row —
/// conditions onto the tracker and (for severity 7-11) a scar adversity
/// chosen from the game data onto the trait list.
Future<void> criticalStrikeFlow(BuildContext context) async {
  final result = await showDialog<CritStrikeResult>(
    context: context,
    builder: (context) => const _CritStrikeDialog(),
  );
  if (result == null) return;

  final band = critBand(result.finalSeverity);
  var changed = false;
  for (final condition in critConditions(band, result.resistRing,
      razorEdged: result.razorEdged)) {
    changed = addCondition(character, condition) || changed;
  }

  if (band.scar && context.mounted) {
    // The book restricts the choice to the resist ring's scars, so those
    // sort first; the rest stay available for table variance.
    final scars = [
      for (final entry in gameData.advantagesDisadvantages)
        if (entry.category == categoryAdversities &&
            entry.types.contains(typeScar) &&
            !character.advDisadv.contains(entry.name))
          entry
    ]..sort((a, b) {
        final aRing = a.ring == result.resistRing ? 0 : 1;
        final bRing = b.ring == result.resistRing ? 0 : 1;
        return aRing != bRing ? aRing - bRing : a.name.compareTo(b.name);
      });
    final choice = await pick<AdvDisadv>(
      context,
      title: context.l10n
          .chooseScarTitle(trData(band.name), trData(result.resistRing)),
      items: scars,
      labelOf: (entry) => entry.name,
      subtitleOf: (entry) => [
        trData(entry.ring),
        if (entry.types.isNotEmpty) entry.types.map(trData).join(', '),
      ].join(' · '),
      descriptionOf: (entry) => gameData.shortDescFor(entry.name),
    );
    if (choice != null) {
      character.advDisadv.add(choice.name);
      changed = true;
    }
  }

  if (changed) character.touch();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.severityResult(
            result.finalSeverity, trData(band.name), trData(band.effect)))));
  }
}

class _CritStrikeDialog extends StatefulWidget {
  const _CritStrikeDialog();

  @override
  State<_CritStrikeDialog> createState() => _CritStrikeDialogState();
}

class _CritStrikeDialogState extends State<_CritStrikeDialog> {
  int _severity = 0;
  bool _razorEdged = false;
  String _resistRing = gameData.ringNames().first;
  bool _checkSucceeded = false;
  int _bonusSuccesses = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalSeverity =
        mitigatedSeverity(_severity, _checkSucceeded, _bonusSuccesses);
    final band = critBand(finalSeverity);
    return AlertDialog(
      title: Text(context.l10n.criticalStrikeTitle),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntSpinner(
                label: context.l10n.severityLabel,
                value: _severity,
                onChanged: (v) => setState(() => _severity = v),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.razorEdgedLabel),
                value: _razorEdged,
                onChanged: (v) => setState(() => _razorEdged = v ?? false),
              ),
              DropdownButtonFormField<String>(
                value: _resistRing,
                decoration: InputDecoration(
                  labelText: context.l10n.ringUsedToResist,
                  helperText: context.l10n.ringResistHelper,
                ),
                items: [
                  for (final ring in gameData.ringNames())
                    DropdownMenuItem(value: ring, child: Text(trData(ring))),
                ],
                onChanged: (v) =>
                    setState(() => _resistRing = v ?? _resistRing),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.tnFitnessCheck),
                subtitle: Text(context.l10n.rollOwnDice),
                value: _checkSucceeded,
                onChanged: (v) =>
                    setState(() => _checkSucceeded = v ?? false),
              ),
              if (_checkSucceeded)
                IntSpinner(
                  label: context.l10n.bonusSuccessesLabel,
                  value: _bonusSuccesses,
                  onChanged: (v) => setState(() => _bonusSuccesses = v),
                ),
              const Divider(),
              Text(
                  context.l10n
                      .finalSeverityLine(finalSeverity, trData(band.name)),
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(trData(band.effect), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
              context,
              CritStrikeResult(
                finalSeverity: finalSeverity,
                resistRing: _resistRing,
                razorEdged: _razorEdged,
              )),
          child: Text(context.l10n.apply),
        ),
      ],
    );
  }
}
