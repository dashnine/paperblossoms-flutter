import 'package:flutter/material.dart';

import '../advance.dart';
import '../character.dart';
import '../data_l10n.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
import '../layout.dart';
import '../rules_constants.dart';
import '../theme.dart';
import 'add_advance_page.dart';
import 'add_title_page.dart';

/// Tab 7: rank/title status, the school curriculum, title tracks, and the
/// advance stack (Advancement page of the original app).
class AdvancementTab extends StatelessWidget {
  const AdvancementTab({super.key});

  Future<void> _addAdvance(BuildContext context,
      {String? initialType,
      String? initialOption,
      String? initialGroup,
      String? initialTrack}) async {
    final rankBefore = recalcRank(character).rank;
    final advance = await Navigator.push<Advance>(
      context,
      MaterialPageRoute(
          builder: (context) => AddAdvancePage(
              initialType: initialType,
              initialOption: initialOption,
              initialGroup: initialGroup,
              initialTrack: initialTrack)),
    );
    if (advance == null) return;
    character.advanceStack.add(advance);
    character.touch();
    if (!context.mounted) return;
    final rankAfter = recalcRank(character).rank;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(rankAfter > rankBefore
            ? context.l10n.addedAdvanceRankUp(trData(advance.name), rankAfter)
            : context.l10n.addedAdvance(
                trData(advance.name), advance.cost, trData(advance.track))),
      ));
  }

  /// Tapping a curriculum entry preselects it in the advance page (the
  /// original app's table double-click shortcut).
  void _buyCurriculumEntry(BuildContext context, CurriculumEntry entry) {
    switch (entry.type) {
      case entryTypeSkill:
        _addAdvance(context,
            initialType: advanceTypeSkill, initialOption: entry.advance);
      case entryTypeSkillGroup:
        _addAdvance(context,
            initialType: advanceTypeSkill, initialGroup: entry.advance);
      case entryTypeTechnique:
        _addAdvance(context,
            initialType: advanceTypeTechnique, initialOption: entry.advance);
      case entryTypeTechniqueGroup:
        _addAdvance(context,
            initialType: advanceTypeTechnique, initialGroup: entry.advance);
    }
  }

  /// Tapping an advancement row of the in-progress title buys it on the
  /// Title track, mirroring the curriculum shortcut.
  void _buyTitleEntry(BuildContext context, TitleAdvancement entry) {
    switch (entry.type) {
      case entryTypeSkill:
        _addAdvance(context,
            initialType: advanceTypeSkill,
            initialOption: entry.name,
            initialTrack: trackTitle);
      case entryTypeSkillGroup:
        _addAdvance(context,
            initialType: advanceTypeSkill,
            initialGroup: entry.name,
            initialTrack: trackTitle);
      case entryTypeTechnique:
        _addAdvance(context,
            initialType: advanceTypeTechnique,
            initialOption: entry.name,
            initialTrack: trackTitle);
      case entryTypeTechniqueGroup:
        _addAdvance(context,
            initialType: advanceTypeTechnique,
            initialGroup: entry.name,
            initialTrack: trackTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = recalcRank(character);
    final title = recalcTitle(character);
    final status = _buildStatus(context, rank, title);
    final curriculum = _buildCurriculum(context, rank.rank);
    final titles = _buildTitles(context, title.currentTitle);
    final stack = _buildAdvanceStack(context);

    if (context.isExpanded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            status,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: curriculum),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [titles, stack],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [status, curriculum, titles, stack],
    );
  }

  Widget _buildStatus(
      BuildContext context, RankResult rank, TitleResult title) {
    final theme = Theme.of(context);
    // Progress to the next school rank per the core-book thresholds; null
    // once past the charted ranks.
    final threshold = rank.rank <= rankXpThresholds.length
        ? rankXpThresholds[rank.rank - 1]
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatTile(label: context.l10n.schoolRank, value: '${rank.rank}'),
            StatTile(
                label: context.l10n.xpInRank,
                value: threshold == null
                    ? '${rank.curriculumXP}'
                    : '${rank.curriculumXP} / $threshold'),
            StatTile(
                label: context.l10n.xpSpentLabel,
                value: '${xpSpent(character)}'),
          ],
        ),
        if (threshold != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  minHeight: 6,
                  value: (rank.curriculumXP / threshold).clamp(0.0, 1.0)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            title.currentTitle.isEmpty
                ? context.l10n.noTitleInProgress
                : context.l10n.currentTitleLine(
                    trData(title.currentTitle),
                    title.titleXP,
                    gameData.titleByName(title.currentTitle)?.xpToCompletion ??
                        0),
            style: theme.textTheme.titleSmall?.copyWith(
              color: title.currentTitle.isEmpty
                  ? theme.colorScheme.outline
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurriculum(BuildContext context, int currentRank) {
    final school = gameData.schoolByName(character.school);
    final skillRanks = effectiveSkillRanks(character);
    final theme = Theme.of(context);
    final byRank = <int, List<CurriculumEntry>>{};
    for (final entry in school?.curriculum ?? const <CurriculumEntry>[]) {
      byRank.putIfAbsent(entry.rank, () => []).add(entry);
    }
    final ranks = byRank.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          context.l10n.curriculumSection(
              school == null ? context.l10n.noSchoolFallback : trData(school.name)),
          trailing: IconButton(
            tooltip: context.l10n.addAdvance,
            icon: const Icon(Icons.add),
            onPressed: () => _addAdvance(context),
          ),
        ),
        if (school == null)
          EmptyHint(context.l10n.noSchoolNoCurriculum)
        else
          // One collapsible section per rank so the common case — buying
          // within the current rank — doesn't require scrolling past the
          // whole chart.
          for (final rank in ranks)
            ExpansionTile(
              // Keyed on the current rank too: ranking up (or down) remints
              // the keys, so expansion resets to just-the-current-rank open.
              key: PageStorageKey('curriculum-rank-$rank@$currentRank'),
              dense: true,
              initiallyExpanded: rank == currentRank,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: rank == currentRank
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                child: Text('$rank',
                    style: TextStyle(
                      fontSize: 12,
                      color: rank == currentRank
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    )),
              ),
              title: Text(context.l10n.rankN(rank)),
              subtitle: rank == currentRank
                  ? Text(context.l10n.currentLabel)
                  : null,
              children: [
                for (final entry in byRank[rank]!)
                  _curriculumTile(context, entry, skillRanks),
              ],
            ),
      ],
    );
  }

  Widget _curriculumTile(BuildContext context, CurriculumEntry entry,
      Map<String, int> skillRanks) {
    final theme = Theme.of(context);
    final skillRank =
        entry.type == entryTypeSkill ? (skillRanks[entry.advance] ?? 0) : 0;
    // "Done" entries: a learned technique, or a skill at the rank-5 cap.
    // Group entries are open-ended and never marked.
    final done = switch (entry.type) {
      entryTypeTechnique => alreadyLearned(character, entry.advance),
      entryTypeSkill => skillRank >= 5,
      _ => false,
    };
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      enabled: !done,
      title: Text(trData(entry.advance)),
      subtitle: Text([
        trData(entry.type.replaceAll('_', ' ')),
        if (skillRank > 0) context.l10n.skillRankLabel(skillRank),
        if (entry.specialAccess) context.l10n.specialAccess,
        if (entry.minAllowableRank > 0 || entry.maxAllowableRank > 0)
          context.l10n
              .ranksRange(entry.minAllowableRank, entry.maxAllowableRank),
      ].join(' · ')),
      trailing: done
          ? Tooltip(
              message: entry.type == entryTypeSkill
                  ? context.l10n.atRank5
                  : context.l10n.alreadyLearnedLabel,
              child:
                  Icon(Icons.check_circle, color: theme.colorScheme.outline),
            )
          : Tooltip(
              message: context.l10n.buyThisAdvance,
              child: Icon(Icons.add_circle_outline,
                  color: theme.colorScheme.primary),
            ),
      onTap: done ? null : () => _buyCurriculumEntry(context, entry),
    );
  }

  Widget _buildTitles(BuildContext context, String currentTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          context.l10n.titlesSection,
          trailing: IconButton(
            tooltip: currentTitle.isEmpty
                ? context.l10n.addTitle
                : context.l10n.finishCurrentTitleFirst,
            icon: const Icon(Icons.add),
            // Like the original, adding is blocked while a title is open.
            onPressed:
                currentTitle.isEmpty ? () => addTitleFlow(context) : null,
          ),
        ),
        if (character.titles.isEmpty) EmptyHint(context.l10n.noTitlesYet),
        for (final title in character.titles)
          ExpansionTile(
            dense: true,
            title: Text(trData(title)),
            subtitle: Text(title == currentTitle
                ? context.l10n.inProgressLabel
                : context.l10n.completedWithAbility(
                    trData(gameData.titleByName(title)?.titleAbility ?? ''))),
            children: [
              for (final advancement
                  in gameData.titleByName(title)?.advancements ??
                      const <TitleAdvancement>[])
                _titleAdvancementTile(
                    context, advancement, title == currentTitle),
            ],
          ),
      ],
    );
  }

  /// A row of a title's advancement track. Rows of the in-progress title
  /// buy on tap; completed titles and learned techniques stay inert.
  Widget _titleAdvancementTile(
      BuildContext context, TitleAdvancement entry, bool inProgress) {
    final theme = Theme.of(context);
    final learned = entry.type == entryTypeTechnique &&
        alreadyLearned(character, entry.name);
    final buyable = inProgress && !learned;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      enabled: !learned,
      title: Text(trData(entry.name)),
      subtitle: Text([
        trData(entry.type.replaceAll('_', ' ')),
        if (entry.specialAccess) context.l10n.specialAccess,
        if (entry.rank > 0) context.l10n.maxRankLabel(entry.rank),
      ].join(' · ')),
      trailing: learned
          ? Tooltip(
              message: context.l10n.alreadyLearnedLabel,
              child:
                  Icon(Icons.check_circle, color: theme.colorScheme.outline),
            )
          : buyable
              ? Tooltip(
                  message: context.l10n.buyThisAdvance,
                  child: Icon(Icons.add_circle_outline,
                      color: theme.colorScheme.primary),
                )
              : null,
      onTap: buyable ? () => _buyTitleEntry(context, entry) : null,
    );
  }

  void _removeAdvance(BuildContext context, int index) {
    final advance = character.advanceStack.removeAt(index);
    character.touch();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(context.l10n.removedName(trData(advance.name))),
        action: SnackBarAction(
          label: context.l10n.undo,
          onPressed: () {
            character.advanceStack
                .insert(index.clamp(0, character.advanceStack.length), advance);
            character.touch();
          },
        ),
      ));
  }

  Widget _buildAdvanceStack(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.advancesTakenSection),
        if (character.advanceStack.isEmpty)
          EmptyHint(context.l10n.noAdvancesYet),
        for (var i = character.advanceStack.length - 1; i >= 0; i--)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(trData(character.advanceStack[i].name)),
            subtitle: Text(context.l10n.advanceSubtitle(
                trData(character.advanceStack[i].type),
                trData(character.advanceStack[i].track),
                character.advanceStack[i].cost)),
            trailing: IconButton(
              tooltip: context.l10n.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeAdvance(context, i),
            ),
          ),
      ],
    );
  }
}
