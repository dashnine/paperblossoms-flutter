import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import '../widgets/picker_page.dart';

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
    title: category == null
        ? context.l10n.addTrait
        : context.l10n.addCategoryLower(trData(category).toLowerCase()),
    items: options,
    labelOf: (entry) => entry.name,
    subtitleOf: (entry) => [
      if (category == null) trData(entry.category),
      if (entry.ring.isNotEmpty) trData(entry.ring),
      if (entry.types.isNotEmpty) entry.types.map(trData).join(', '),
      if (entry.xp > 0) context.l10n.costXp(entry.xp),
    ].join(' · '),
    descriptionOf: (entry) => gameData.shortDescFor(entry.name),
  );
  if (choice == null) return false;
  var track = trackCurriculum;
  if (choice.xp > 0) {
    // BotL p. 9 sells Student of Akodo for 3 XP: confirm the cost and pick
    // the track its advance counts toward (half credit, Character.addTrait).
    if (!context.mounted) return false;
    final picked = await _pickTrack(context, choice);
    if (picked == null) return false;
    track = picked;
  }
  character.addTrait(choice, track: track);
  return true;
}

/// Confirms an XP-priced trait and picks the track its advance lands on;
/// null = cancelled. The Title option appears only while a title is held.
Future<String?> _pickTrack(BuildContext context, AdvDisadv entry) {
  final l10n = context.l10n;
  var track = trackCurriculum;
  return showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(trData(entry.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pricedTraitBody(entry.xp)),
            for (final (value, label) in [
              (trackCurriculum, l10n.trackCurriculumLabel),
              if (character.titles.isNotEmpty)
                (trackTitle, l10n.trackTitleLabel),
            ])
              RadioListTile<String>(
                value: value,
                groupValue: track,
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                onChanged: (selected) =>
                    setDialogState(() => track = selected ?? track),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, track),
            child: Text(l10n.add),
          ),
        ],
      ),
    ),
  );
}
