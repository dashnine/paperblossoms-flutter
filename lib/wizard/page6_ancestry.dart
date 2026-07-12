import 'dart:math';

import 'package:flutter/material.dart';

import '../game_data.dart';
import 'wizard_state.dart';
import 'wizard_widgets.dart';

/// Part 6: Ancestry and Family (Q17-18). Samurai roll or pick up to two
/// ancestors from a heritage table and keep one; non-samurai choose a bond.
class Page6Ancestry extends StatelessWidget {
  final WizardState wizard;
  final VoidCallback onChanged;

  const Page6Ancestry(
      {super.key, required this.wizard, required this.onChanged});

  static final _random = Random();

  List<String> _ancestorNames() => [
        for (final entry in gameData.heritagesBySource(wizard.heritageSource))
          entry.result
      ];

  void _roll(int which) {
    final roll = _random.nextInt(10) + 1;
    final entry = gameData.heritageByRoll(wizard.heritageSource, roll);
    if (entry == null) return;
    if (which == 1) {
      wizard.ancestor1 = entry.result;
    } else {
      wizard.ancestor2 = entry.result;
    }
    _clearEffects();
    onChanged();
  }

  void _clearEffects() {
    wizard
      ..q18OtherEffects = ''
      ..q18Secondary = ''
      ..q18Special1 = ''
      ..q18Special2 = '';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(wizard.isSamurai
            ? '17. How would your parents describe you? (+1 skill rank)'
            : '18. Who raised you? (+1 skill rank)'),
        WizDropdown(
          label: 'Skill',
          value: wizard.parentSkill,
          options: wizard.unheldSkillOptions(except: wizard.parentSkill),
          onChanged: (value) {
            wizard.parentSkill = value;
            onChanged();
          },
        ),
        _describeField(
            key: 'q17', initial: wizard.q17Text,
            onChanged: (value) => wizard.q17Text = value),
        if (wizard.isSamurai) ..._samuraiAncestry(context) else ..._roninBond(),
      ],
    );
  }

  Widget _describeField(
      {required String key,
      required String initial,
      required ValueChanged<String> onChanged}) {
    return TextFormField(
      key: ValueKey(key),
      initialValue: initial,
      decoration: const InputDecoration(labelText: 'Describe it'),
      onChanged: onChanged,
    );
  }

  List<Widget> _roninBond() {
    return [
      const QuestionHeader('17. With whom do you share a bond?'),
      WizDropdown(
        label: 'Bond',
        value: wizard.roninBond,
        options: [for (final bond in gameData.bonds) bond.name],
        onChanged: (value) {
          wizard.roninBond = value;
          onChanged();
        },
      ),
      _describeField(
          key: 'q17ronin',
          initial: wizard.q17RoninText,
          onChanged: (value) => wizard.q17RoninText = value),
    ];
  }

  List<Widget> _samuraiAncestry(BuildContext context) {
    final names = _ancestorNames();
    return [
      const QuestionHeader(
          '18. What is your duty to your family, and who among your '
          'ancestors do you exemplify?'),
      WizDropdown(
        label: 'Heritage table',
        value: wizard.heritageSource,
        options: heritageSources,
        onChanged: (value) {
          wizard
            ..heritageSource = value
            ..ancestor1 = ''
            ..ancestor2 = ''
            ..chosenAncestor = 0;
          _clearEffects();
          onChanged();
        },
      ),
      for (final which in [1, 2])
        Row(
          children: [
            Radio<int>(
              value: which,
              groupValue: wizard.chosenAncestor,
              onChanged: (value) {
                wizard.chosenAncestor = value ?? 0;
                _clearEffects();
                onChanged();
              },
            ),
            Expanded(
              child: WizDropdown(
                label: 'Ancestor $which',
                value: which == 1 ? wizard.ancestor1 : wizard.ancestor2,
                options: names,
                onChanged: (value) {
                  if (which == 1) {
                    wizard.ancestor1 = value;
                  } else {
                    wizard.ancestor2 = value;
                  }
                  if (wizard.chosenAncestor == which) _clearEffects();
                  onChanged();
                },
              ),
            ),
            IconButton(
              tooltip: 'Roll (1d10)',
              icon: const Icon(Icons.casino_outlined),
              onPressed: () => _roll(which),
            ),
            Text(_modifierLabel(
                which == 1 ? wizard.ancestor1 : wizard.ancestor2)),
          ],
        ),
      if (wizard.heritageEntry != null) ..._effectControls(context),
    ];
  }

  String _modifierLabel(String ancestor) {
    final entry = gameData.heritageByResult(ancestor);
    if (entry == null) return '';
    final parts = [
      if (entry.honor != 0) 'H:${entry.honor}',
      if (entry.glory != 0) 'G:${entry.glory}',
      if (entry.status != 0) 'S:${entry.status}',
    ];
    return parts.join(' ');
  }

  List<Widget> _effectControls(BuildContext context) {
    final entry = wizard.heritageEntry!;
    final kind = WizardState.effectKindOf(entry);
    final options = wizard.heritageEffectOptions();
    final auto = WizardState.autoGrantedTraits[entry.result];
    final widgets = <Widget>[
      QuestionHeader('Heritage: ${entry.result}'),
      if (entry.otherEffects.instructions.isNotEmpty)
        Text(entry.otherEffects.instructions),
      if (auto != null) Text('Granted: $auto'),
    ];

    void primaryDropdown(String label) {
      widgets.add(Row(
        children: [
          Expanded(
            child: WizDropdown(
              label: label,
              value: wizard.q18OtherEffects,
              options: options,
              onChanged: (value) {
                wizard
                  ..q18OtherEffects = value
                  ..q18Secondary = ''
                  ..q18Special1 = ''
                  ..q18Special2 = '';
                onChanged();
              },
            ),
          ),
          IconButton(
            tooltip: 'Roll (1d10)',
            icon: const Icon(Icons.casino_outlined),
            onPressed: () {
              final roll = _random.nextInt(10) + 1;
              for (final outcome in entry.otherEffects.outcomes) {
                if (roll >= outcome.rollMin && roll <= outcome.rollMax) {
                  wizard
                    ..q18OtherEffects = outcome.outcome
                    ..q18Secondary = ''
                    ..q18Special1 = ''
                    ..q18Special2 = '';
                  onChanged();
                  return;
                }
              }
            },
          ),
        ],
      ));
    }

    switch (kind) {
      case HeritageEffectKind.skill:
        primaryDropdown('Bonus skill');
      case HeritageEffectKind.trait:
        primaryDropdown('Trait gained');
      case HeritageEffectKind.startingItem:
      case HeritageEffectKind.lostHeirloom:
        primaryDropdown(kind == HeritageEffectKind.lostHeirloom
            ? 'Lost heirloom category'
            : 'Heirloom category');
        if (wizard.q18OtherEffects.isNotEmpty) {
          widgets.add(WizDropdown(
            label: 'Item',
            value: wizard.q18Secondary,
            options: _itemOptionsFor(wizard.q18OtherEffects),
            onChanged: (value) {
              wizard.q18Secondary = value;
              onChanged();
            },
          ));
          final qualityNames = [
            for (final quality in gameData.qualities) quality.name
          ];
          widgets.add(WizDropdown(
            label: 'Quality (your choice)',
            value: wizard.q18Special1,
            options: qualityNames,
            onChanged: (value) {
              wizard.q18Special1 = value;
              onChanged();
            },
          ));
          widgets.add(WizDropdown(
            label: "Quality (GM's choice)",
            value: wizard.q18Special2,
            options: qualityNames,
            onChanged: (value) {
              wizard.q18Special2 = value;
              onChanged();
            },
          ));
        }
      case HeritageEffectKind.technique:
        primaryDropdown('Technique group');
        if (wizard.q18OtherEffects.isNotEmpty) {
          widgets.add(WizDropdown(
            label: 'Technique',
            value: wizard.q18Secondary,
            options: _techniqueOptionsFor(wizard.q18OtherEffects),
            onChanged: (value) {
              wizard.q18Secondary = value;
              onChanged();
            },
          ));
        }
      case HeritageEffectKind.ringExchange:
        primaryDropdown('Effect');
        if (wizard.q18OtherEffects.isNotEmpty) {
          if (wizard.q18OtherEffects.endsWith(' Ring')) {
            // Spiritual Debt: raise the named ring, lower a chosen one.
            widgets.add(WizDropdown(
              label: 'Ring to lower',
              value: wizard.q18Special2,
              options: gameData.ringNames(),
              onChanged: (value) {
                wizard.q18Special2 = value;
                onChanged();
              },
            ));
          } else {
            widgets.add(WizDropdown(
              label: 'Ring to raise',
              value: wizard.q18Special1,
              options: gameData.ringNames(),
              onChanged: (value) {
                wizard.q18Special1 = value;
                onChanged();
              },
            ));
            widgets.add(WizDropdown(
              label: 'Ring to lower',
              value: wizard.q18Special2,
              options: gameData.ringNames(),
              onChanged: (value) {
                wizard.q18Special2 = value;
                onChanged();
              },
            ));
          }
        }
      case HeritageEffectKind.namedItem:
        primaryDropdown('Gift');
      case HeritageEffectKind.mixed:
        primaryDropdown('Effect');
        if (wizard.q18OtherEffects == 'Ring Exchange') {
          widgets.add(WizDropdown(
            label: 'Ring to raise',
            value: wizard.q18Special1,
            options: gameData.ringNames(),
            onChanged: (value) {
              wizard.q18Special1 = value;
              onChanged();
            },
          ));
          widgets.add(WizDropdown(
            label: 'Ring to lower',
            value: wizard.q18Special2,
            options: gameData.ringNames(),
            onChanged: (value) {
              wizard.q18Special2 = value;
              onChanged();
            },
          ));
        } else if (wizard.q18OtherEffects == 'Item (Rank 6 or Lower)') {
          widgets.add(WizDropdown(
            label: 'Item',
            value: wizard.q18Secondary,
            options: _itemOptionsFor('another item', maxRarity: 6),
            onChanged: (value) {
              wizard.q18Secondary = value;
              onChanged();
            },
          ));
        }
      case HeritageEffectKind.none:
        break;
    }
    return widgets;
  }

  List<String> _itemOptionsFor(String category, {int maxRarity = 7}) {
    switch (category.toLowerCase()) {
      case 'weapon':
        return [
          for (final weapon in gameData.weaponsUnderRarity(maxRarity))
            weapon.name
        ];
      case 'set of armor':
        return [
          for (final armor in gameData.armorUnderRarity(maxRarity)) armor.name
        ];
      default:
        return [
          for (final weapon in gameData.weaponsUnderRarity(maxRarity))
            weapon.name,
          for (final armor in gameData.armorUnderRarity(maxRarity))
            armor.name,
          for (final effect
              in gameData.personalEffectsUnderRarity(maxRarity))
            effect.name,
        ];
    }
  }

  List<String> _techniqueOptionsFor(String group) {
    if (group == 'Mahō or Ninjutsu') {
      return [
        for (final tech in gameData.techniquesByGroup('Mahō',
            minRank: 1, maxRank: 1))
          tech.name,
        for (final tech in gameData.techniquesByGroup('Ninjutsu',
            minRank: 1, maxRank: 1))
          tech.name,
      ];
    }
    return [
      for (final tech
          in gameData.techniquesByGroup(group, minRank: 1, maxRank: 1))
        tech.name
    ];
  }
}
