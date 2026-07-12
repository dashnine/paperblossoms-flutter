import 'package:flutter/material.dart';

import '../advance.dart';
import '../character.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../game_data_models.dart';
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
      {String? initialType, String? initialOption}) async {
    final advance = await Navigator.push<Advance>(
      context,
      MaterialPageRoute(
          builder: (context) => AddAdvancePage(
              initialType: initialType, initialOption: initialOption)),
    );
    if (advance == null) return;
    character.advanceStack.add(advance);
    character.touch();
  }

  /// Tapping a curriculum entry preselects it in the advance page (the
  /// original app's table double-click shortcut).
  void _buyCurriculumEntry(BuildContext context, CurriculumEntry entry) {
    switch (entry.type) {
      case entryTypeSkill:
        _addAdvance(context,
            initialType: advanceTypeSkill, initialOption: entry.advance);
      case entryTypeSkillGroup:
        _addAdvance(context, initialType: advanceTypeSkill);
      case entryTypeTechnique:
        _addAdvance(context,
            initialType: advanceTypeTechnique, initialOption: entry.advance);
      case entryTypeTechniqueGroup:
        _addAdvance(context, initialType: advanceTypeTechnique);
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
            StatTile(label: 'School Rank', value: '${rank.rank}'),
            StatTile(
                label: 'XP in Rank',
                value: threshold == null
                    ? '${rank.curriculumXP}'
                    : '${rank.curriculumXP} / $threshold'),
            StatTile(label: 'XP Spent', value: '${xpSpent(character)}'),
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
                ? 'No title in progress'
                : 'Current title: ${title.currentTitle} — ${title.titleXP} / '
                    '${gameData.titleByName(title.currentTitle)?.xpToCompletion ?? 0} XP',
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Curriculum — ${school?.name ?? 'no school'}',
          trailing: IconButton(
            tooltip: 'Add advance',
            icon: const Icon(Icons.add),
            onPressed: () => _addAdvance(context),
          ),
        ),
        if (school == null)
          const EmptyHint('No school chosen, so there is no curriculum.')
        else
          for (final entry in school.curriculum)
            ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: CircleAvatar(
                radius: 12,
                backgroundColor: entry.rank == currentRank
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                child: Text('${entry.rank}',
                    style: TextStyle(
                      fontSize: 12,
                      color: entry.rank == currentRank
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    )),
              ),
              title: Text(entry.advance),
              subtitle: Text([
                entry.type.replaceAll('_', ' '),
                if (entry.specialAccess) 'special access',
                if (entry.minAllowableRank > 0 || entry.maxAllowableRank > 0)
                  'ranks ${entry.minAllowableRank}-${entry.maxAllowableRank}',
              ].join(' · ')),
              trailing: Tooltip(
                message: 'Buy this advance',
                child: Icon(Icons.add_circle_outline,
                    color: theme.colorScheme.primary),
              ),
              onTap: () => _buyCurriculumEntry(context, entry),
            ),
      ],
    );
  }

  Widget _buildTitles(BuildContext context, String currentTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Titles',
          trailing: IconButton(
            tooltip: currentTitle.isEmpty
                ? 'Add title'
                : 'Finish the current title first',
            icon: const Icon(Icons.add),
            // Like the original, adding is blocked while a title is open.
            onPressed:
                currentTitle.isEmpty ? () => addTitleFlow(context) : null,
          ),
        ),
        if (character.titles.isEmpty)
          const EmptyHint('No titles yet — tap + to add.'),
        for (final title in character.titles)
          ExpansionTile(
            dense: true,
            title: Text(title),
            subtitle: Text(title == currentTitle
                ? 'In progress'
                : 'Completed — ${gameData.titleByName(title)?.titleAbility ?? ''}'),
            children: [
              for (final advancement
                  in gameData.titleByName(title)?.advancements ?? [])
                ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(advancement.name),
                  subtitle: Text([
                    advancement.type.replaceAll('_', ' '),
                    if (advancement.specialAccess) 'special access',
                    if (advancement.rank > 0) 'max rank ${advancement.rank}',
                  ].join(' · ')),
                ),
            ],
          ),
      ],
    );
  }

  void _removeAdvance(BuildContext context, int index) {
    final advance = character.advanceStack.removeAt(index);
    character.touch();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed ${advance.name}'),
        action: SnackBarAction(
          label: 'Undo',
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
        const SectionHeader('Advances Taken'),
        if (character.advanceStack.isEmpty)
          const EmptyHint(
              'No advances purchased yet — tap + or a curriculum entry.'),
        for (var i = character.advanceStack.length - 1; i >= 0; i--)
          ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(character.advanceStack[i].name),
            subtitle: Text('${character.advanceStack[i].type} · '
                '${character.advanceStack[i].track} · '
                '${character.advanceStack[i].cost} XP'),
            trailing: IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeAdvance(context, i),
            ),
          ),
      ],
    );
  }
}
