import 'package:flutter/material.dart';

import '../character.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../game_data_models.dart';
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
      title: '${band.name}: choose a scar (${result.resistRing})',
      items: scars,
      labelOf: (entry) => entry.name,
      subtitleOf: (entry) => [
        entry.ring,
        if (entry.types.isNotEmpty) entry.types.join(', '),
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
        content: Text('Severity ${result.finalSeverity}: ${band.name} — '
            '${band.effect}')));
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
      title: const Text('Critical strike'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntSpinner(
                label: 'Severity (deadliness of the source)',
                value: _severity,
                onChanged: (v) => setState(() => _severity = v),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Attack was Razor-Edged'),
                value: _razorEdged,
                onChanged: (v) => setState(() => _razorEdged = v ?? false),
              ),
              DropdownButtonFormField<String>(
                value: _resistRing,
                decoration: const InputDecoration(
                  labelText: 'Ring used to resist',
                  helperText: 'Stance ring in a conflict, any in a narrative',
                ),
                items: [
                  for (final ring in gameData.ringNames())
                    DropdownMenuItem(value: ring, child: Text(ring)),
                ],
                onChanged: (v) =>
                    setState(() => _resistRing = v ?? _resistRing),
              ),
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('TN 1 Fitness check succeeded'),
                subtitle: const Text('Roll your own dice; enter the result'),
                value: _checkSucceeded,
                onChanged: (v) =>
                    setState(() => _checkSucceeded = v ?? false),
              ),
              if (_checkSucceeded)
                IntSpinner(
                  label: 'Bonus successes (severity −1 each, on top of −1)',
                  value: _bonusSuccesses,
                  onChanged: (v) => setState(() => _bonusSuccesses = v),
                ),
              const Divider(),
              Text('Final severity $finalSeverity — ${band.name}',
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(band.effect, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
              context,
              CritStrikeResult(
                finalSeverity: finalSeverity,
                resistRing: _resistRing,
                razorEdged: _razorEdged,
              )),
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
