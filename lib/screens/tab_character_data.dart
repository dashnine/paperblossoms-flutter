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
      ],
    );
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
