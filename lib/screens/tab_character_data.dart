import 'package:flutter/material.dart';

import '../character.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../layout.dart';
import '../theme.dart';
import '../widgets/identity_lock_button.dart';
import '../widgets/int_spinner.dart';
import '../widgets/portrait_picker.dart';
import '../widgets/ring_viewer.dart';
import 'critical_strike_dialog.dart';
import 'pickers.dart';

/// Tab 1: identity, portrait, rings, derived attributes, social standing,
/// wealth, skills, and abilities (mainwindow.ui Character Data page).
class CharacterDataTab extends StatefulWidget {
  const CharacterDataTab({super.key});

  @override
  State<CharacterDataTab> createState() => _CharacterDataTabState();
}

class _CharacterDataTabState extends State<CharacterDataTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _familyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: character.name);
    _familyController = TextEditingController(text: character.family);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _familyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final identity = _buildIdentity(context);
    final ringsPanel = _buildRingsPanel(context);
    final skills = _buildSkillsPanel(context);

    if (context.isExpanded) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: identity),
            const SizedBox(width: 24),
            Expanded(child: ringsPanel),
            const SizedBox(width: 24),
            Expanded(child: skills),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [identity, ringsPanel, skills],
    );
  }

  Widget _buildIdentity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PortraitPicker(size: 120),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    enabled: !character.identityLocked,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) {
                      character.name = value;
                      character.touch();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _familyController,
                    enabled: !character.identityLocked,
                    decoration: const InputDecoration(labelText: 'Family'),
                    onChanged: (value) {
                      character.family = value;
                      character.touch();
                    },
                  ),
                ],
              ),
            ),
            const IdentityLockButton(),
          ],
        ),
        const SizedBox(height: 8),
        Text('${character.clan.isEmpty ? 'No clan' : character.clan} · '
            '${character.school.isEmpty ? 'No school' : character.school}'),
        const SectionHeader('Social Standing'),
        Wrap(
          spacing: 12,
          children: [
            IntSpinner(
                label: 'Honor',
                value: character.honor,
                max: 100,
                onChanged: (v) {
                  character.honor = v;
                  character.touch();
                }),
            IntSpinner(
                label: 'Glory',
                value: character.glory,
                max: 100,
                onChanged: (v) {
                  character.glory = v;
                  character.touch();
                }),
            IntSpinner(
                label: 'Status',
                value: character.status,
                max: 100,
                onChanged: (v) {
                  character.status = v;
                  character.touch();
                }),
          ],
        ),
        const SectionHeader('Wealth'),
        Wrap(
          spacing: 12,
          children: [
            IntSpinner(
                label: 'Koku',
                value: character.koku,
                onChanged: (v) {
                  character.koku = v;
                  character.touch();
                }),
            IntSpinner(
                label: 'Bu',
                value: character.bu,
                onChanged: (v) {
                  character.bu = v;
                  character.touch();
                }),
            IntSpinner(
                label: 'Zeni',
                value: character.zeni,
                onChanged: (v) {
                  character.zeni = v;
                  character.touch();
                }),
          ],
        ),
        const SectionHeader('Abilities'),
        ..._buildAbilities(context),
      ],
    );
  }

  List<Widget> _buildAbilities(BuildContext context) {
    final rank = recalcRank(character).rank;
    final currentTitle = recalcTitle(character).currentTitle;
    final abilityList = abilities(character, rank, currentTitle);
    if (abilityList.isEmpty) return [const EmptyHint('No abilities yet.')];
    return [
      for (final ability in abilityList)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            gameData.shortDescFor(ability).isEmpty
                ? ability
                : '$ability — ${gameData.shortDescFor(ability)}',
          ),
        ),
    ];
  }

  Widget _buildRingsPanel(BuildContext context) {
    final rings = effectiveRingRanks(character);
    final rank = recalcRank(character);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Rings'),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
          child: RingViewer(rings: rings),
        ),
        const SectionHeader('Derived Attributes'),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            StatTile(label: 'Endurance', value: '${endurance(rings)}'),
            StatTile(label: 'Composure', value: '${composure(rings)}'),
            StatTile(label: 'Focus', value: '${focus(rings)}'),
            StatTile(label: 'Vigilance', value: '${vigilance(rings)}'),
            StatTile(label: 'School Rank', value: '${rank.rank}'),
          ],
        ),
        const SectionHeader('Fatigue & Strife'),
        Wrap(
          spacing: 24,
          runSpacing: 8,
          children: [
            // Each track pairs its spinner with its own clear button so the
            // shortcut sits under the number it resets.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntSpinner(
                    label: 'Fatigue / ${endurance(rings)}',
                    value: character.fatigue,
                    onChanged: (v) {
                      character.fatigue = v;
                      character.touch();
                    }),
                Tooltip(
                  message: 'Clear all fatigue',
                  child: TextButton(
                    onPressed: character.fatigue > 0
                        ? () {
                            character.fatigue = 0;
                            character.touch();
                          }
                        : null,
                    child: const Text('Recover'),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntSpinner(
                    label: 'Strife / ${composure(rings)}',
                    value: character.strife,
                    onChanged: (v) {
                      character.strife = v;
                      character.touch();
                    }),
                Tooltip(
                  message: 'Clear all strife',
                  child: TextButton(
                    onPressed: character.strife > 0
                        ? () {
                            character.strife = 0;
                            character.touch();
                          }
                        : null,
                    child: const Text('Unmask'),
                  ),
                ),
              ],
            ),
          ],
        ),
        SectionHeader(
          'Conditions',
          trailing: IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add condition',
            onPressed: () => _addCondition(context),
          ),
        ),
        if (character.conditions.isEmpty &&
            !isIncapacitated(character, rings) &&
            !isCompromised(character, rings))
          const EmptyHint('No conditions.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Derived from fatigue/strife, so no delete affordance: they
              // clear themselves when the tracks drop back under the limit.
              if (isIncapacitated(character, rings))
                _derivedChip(context, 'Incapacitated',
                    'Fatigue exceeds endurance: no actions requiring checks '
                    'and no defending against damage.'),
              if (isCompromised(character, rings))
                _derivedChip(context, 'Compromised',
                    'Strife exceeds composure: cannot keep dice showing '
                    'strife; vigilance counts as 1.'),
              for (final condition in character.conditions)
                Tooltip(
                  message:
                      conditionSummaries[condition.split(' (').first] ?? '',
                  child: InputChip(
                    label: Text(condition),
                    onDeleted: () {
                      character.conditions.remove(condition);
                      character.touch();
                    },
                  ),
                ),
            ],
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.bolt),
            label: const Text('Critical strike…'),
            onPressed: () => criticalStrikeFlow(context),
          ),
        ),
      ],
    );
  }

  Widget _derivedChip(BuildContext context, String label, String rule) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: rule,
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(color: colors.onErrorContainer),
        backgroundColor: colors.errorContainer,
        side: BorderSide(color: colors.error),
      ),
    );
  }

  Future<void> _addCondition(BuildContext context) async {
    final options = <String>[
      for (final condition in trackableConditions)
        if (condition == conditionDying) ...[
          '$conditionDying (1 round)',
          for (var rounds = 2; rounds <= 5; rounds++)
            '$conditionDying ($rounds rounds)',
        ] else if (condition == conditionLightlyWounded ||
            condition == conditionSeverelyWounded) ...[
          for (final ring in gameData.ringNames()) '$condition ($ring)',
        ] else
          condition
    ]..removeWhere(character.conditions.contains);
    final choice = await pick<String>(
      context,
      title: 'Add condition',
      items: options,
      labelOf: (condition) => condition,
      descriptionOf: (condition) =>
          conditionSummaries[condition.split(' (').first] ?? '',
    );
    if (choice == null) return;
    if (addCondition(character, choice)) character.touch();
  }

  Widget _buildSkillsPanel(BuildContext context) {
    final ranks = effectiveSkillRanks(character);
    final groups = gameData.skillGroups;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Skills'),
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(group.name,
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final skill in group.skills)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: _skillRow(skill, ranks[skill] ?? 0, colors),
            ),
        ],
      ],
    );
  }

  /// Trained skills pop in the primary color; rank-0 rows recede so the
  /// column can be scanned for what the character can actually do.
  Widget _skillRow(String skill, int rank, ColorScheme colors) {
    final trained = rank > 0;
    return Row(
      children: [
        Expanded(
          child: Text(skill,
              style: trained ? null : TextStyle(color: colors.outline)),
        ),
        Text('$rank',
            style: TextStyle(
              fontWeight: trained ? FontWeight.bold : FontWeight.normal,
              color: trained ? colors.primary : colors.outline,
            )),
      ],
    );
  }
}
