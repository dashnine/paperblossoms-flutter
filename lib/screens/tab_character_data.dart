import 'package:flutter/material.dart';

import '../character.dart';
import '../data_l10n.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
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
                    decoration:
                        InputDecoration(labelText: context.l10n.nameLabel),
                    onChanged: (value) {
                      character.name = value;
                      character.touch();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _familyController,
                    enabled: !character.identityLocked,
                    decoration:
                        InputDecoration(labelText: context.l10n.familyLabel),
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
        Text(
            '${character.clan.isEmpty ? context.l10n.noClan : trData(character.clan)} · '
            '${character.school.isEmpty ? context.l10n.noSchool : trData(character.school)}'),
        SectionHeader(context.l10n.socialStandingSection),
        Wrap(
          spacing: 12,
          children: [
            IntSpinner(
                label: context.l10n.honor,
                value: character.honor,
                max: 100,
                onChanged: (v) {
                  character.honor = v;
                  character.touch();
                }),
            IntSpinner(
                label: context.l10n.glory,
                value: character.glory,
                max: 100,
                onChanged: (v) {
                  character.glory = v;
                  character.touch();
                }),
            IntSpinner(
                label: context.l10n.statusLabel,
                value: character.status,
                max: 100,
                onChanged: (v) {
                  character.status = v;
                  character.touch();
                }),
          ],
        ),
        SectionHeader(context.l10n.wealthSection),
        Wrap(
          spacing: 12,
          children: [
            IntSpinner(
                label: context.l10n.koku,
                value: character.koku,
                onChanged: (v) {
                  character.koku = v;
                  character.touch();
                }),
            IntSpinner(
                label: context.l10n.bu,
                value: character.bu,
                onChanged: (v) {
                  character.bu = v;
                  character.touch();
                }),
            IntSpinner(
                label: context.l10n.zeni,
                value: character.zeni,
                onChanged: (v) {
                  character.zeni = v;
                  character.touch();
                }),
          ],
        ),
        SectionHeader(context.l10n.abilitiesSection),
        ..._buildAbilities(context),
      ],
    );
  }

  List<Widget> _buildAbilities(BuildContext context) {
    final rank = recalcRank(character).rank;
    final currentTitle = recalcTitle(character).currentTitle;
    final abilityList = abilities(character, rank, currentTitle);
    if (abilityList.isEmpty) {
      return [EmptyHint(context.l10n.noAbilitiesYet)];
    }
    return [
      for (final ability in abilityList)
        _AbilityTile(name: ability, reference: _abilityReference(ability)),
    ];
  }

  /// The book/page of whichever school, title, or bond granted [ability].
  Reference? _abilityReference(String ability) {
    final school = gameData.schoolByName(character.school);
    if (school != null &&
        (ability == school.schoolAbility ||
            ability == school.masteryAbility)) {
      return school.reference;
    }
    for (final name in character.titles) {
      final title = gameData.titleByName(name);
      if (title?.titleAbility == ability) return title!.reference;
    }
    for (final bond in character.bonds) {
      final entry = gameData.bondByName(bond.name);
      if (entry?.ability == ability) return entry!.reference;
    }
    return null;
  }

  Widget _buildRingsPanel(BuildContext context) {
    final rings = effectiveRingRanks(character);
    final rank = recalcRank(character);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(context.l10n.ringsSection),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
          child: RingViewer(rings: rings),
        ),
        SectionHeader(context.l10n.derivedAttributesSection),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            StatTile(
                label: context.l10n.endurance, value: '${endurance(rings)}'),
            StatTile(
                label: context.l10n.composure, value: '${composure(rings)}'),
            StatTile(label: context.l10n.focusStat, value: '${focus(rings)}'),
            StatTile(
                label: context.l10n.vigilance, value: '${vigilance(rings)}'),
            StatTile(label: context.l10n.schoolRank, value: '${rank.rank}'),
          ],
        ),
        SectionHeader(context.l10n.fatigueStrifeSection),
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
                    label: context.l10n.fatigueOf(endurance(rings)),
                    value: character.fatigue,
                    onChanged: (v) {
                      character.fatigue = v;
                      character.touch();
                    }),
                Tooltip(
                  message: context.l10n.clearAllFatigue,
                  child: TextButton(
                    onPressed: character.fatigue > 0
                        ? () {
                            character.fatigue = 0;
                            character.touch();
                          }
                        : null,
                    child: Text(context.l10n.recover),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IntSpinner(
                    label: context.l10n.strifeOf(composure(rings)),
                    value: character.strife,
                    onChanged: (v) {
                      character.strife = v;
                      character.touch();
                    }),
                Tooltip(
                  message: context.l10n.clearAllStrife,
                  child: TextButton(
                    onPressed: character.strife > 0
                        ? () {
                            character.strife = 0;
                            character.touch();
                          }
                        : null,
                    child: Text(context.l10n.unmask),
                  ),
                ),
              ],
            ),
          ],
        ),
        SectionHeader(
          context.l10n.conditionsSection,
          trailing: IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.addCondition,
            onPressed: () => _addCondition(context),
          ),
        ),
        if (character.conditions.isEmpty &&
            !isIncapacitated(character, rings) &&
            !isCompromised(character, rings))
          EmptyHint(context.l10n.noConditions)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Derived from fatigue/strife, so no delete affordance: they
              // clear themselves when the tracks drop back under the limit.
              if (isIncapacitated(character, rings))
                _derivedChip(context, trData('Incapacitated'),
                    context.l10n.incapacitatedRule),
              if (isCompromised(character, rings))
                _derivedChip(context, trData('Compromised'),
                    context.l10n.compromisedRule),
              for (final condition in character.conditions)
                Tooltip(
                  message: trData(
                      conditionSummaries[condition.split(' (').first] ?? ''),
                  child: InputChip(
                    label: Text(dataL10n.trCondition(condition)),
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
            label: Text(context.l10n.criticalStrike),
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
      title: context.l10n.addCondition,
      items: options,
      labelOf: (condition) => condition,
      descriptionOf: (condition) =>
          trData(conditionSummaries[condition.split(' (').first] ?? ''),
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
        SectionHeader(context.l10n.skillsSection),
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(trData(group.name),
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
          child: Text(trData(skill),
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

/// One ability row: the familiar "name — short description" line, expanding
/// to the book/page reference and the full rules text when either exists.
class _AbilityTile extends StatelessWidget {
  final String name;
  final Reference? reference;

  const _AbilityTile({required this.name, this.reference});

  /// Bond abilities are described under their bond's name (the rules text is
  /// folded into the bond description), so lookups fall back to that entry.
  String _descName() {
    if (gameData.descriptionFor(name).isNotEmpty ||
        gameData.shortDescFor(name).isNotEmpty) {
      return name;
    }
    for (final bond in gameData.bonds) {
      if (bond.ability == name) return bond.name;
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final descName = _descName();
    final shortDesc = gameData.shortDescFor(descName);
    final headline =
        shortDesc.isEmpty ? trData(name) : '${trData(name)} — $shortDesc';
    final refText = reference?.toString() ?? '';
    final longDesc = gameData.descriptionFor(descName);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    if (refText.isEmpty && longDesc.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(headline),
      );
    }
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      shape: const Border(),
      collapsedShape: const Border(),
      dense: true,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      title: Text(headline, style: bodyStyle),
      children: [
        if (refText.isNotEmpty)
          Text(refText,
              style: bodyStyle?.copyWith(
                  color: Theme.of(context).colorScheme.outline)),
        if (longDesc.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: refText.isEmpty ? 0 : 4),
            child: Text(longDesc),
          ),
      ],
    );
  }
}
