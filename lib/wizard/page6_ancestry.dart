import 'dart:math';

import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../l10n/l10n.dart';
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
            ? context.l10n.wizQ17Parents
            : context.l10n.wizQ17Raised),
        WizDropdown(
          label: context.l10n.advTypeSkill,
          value: wizard.parentSkill,
          options: wizard.unheldSkillOptions(except: wizard.parentSkill),
          onChanged: (value) {
            wizard.parentSkill = value;
            onChanged();
          },
        ),
        _describeField(
            context: context,
            key: 'q17', initial: wizard.q17Text,
            onChanged: (value) => wizard.q17Text = value),
        if (wizard.horMode)
          ..._horAncestry(context)
        else if (wizard.isSamurai)
          ..._samuraiAncestry(context)
        else
          ..._roninBond(context),
      ],
    );
  }

  Widget _describeField(
      {required BuildContext context,
      required String key,
      required String initial,
      required ValueChanged<String> onChanged}) {
    return TextFormField(
      key: ValueKey(key),
      initialValue: initial,
      decoration: InputDecoration(labelText: context.l10n.describeIt),
      onChanged: onChanged,
    );
  }

  List<Widget> _roninBond(BuildContext context) {
    return [
      QuestionHeader(context.l10n.wizQ17Bond),
      WizDropdown(
        label: context.l10n.bondLabel,
        value: wizard.roninBond,
        options: [for (final bond in gameData.bonds) bond.name],
        onChanged: (value) {
          wizard.roninBond = value;
          onChanged();
        },
      ),
      _describeField(
          context: context,
          key: 'q17ronin',
          initial: wizard.q17RoninText,
          onChanged: (value) => wizard.q17RoninText = value),
    ];
  }

  /// HoR (samurai and rōnin alike): one result chosen from the campaign
  /// heritage table — no source picker, no dice, no second ancestor.
  List<Widget> _horAncestry(BuildContext context) {
    return [
      QuestionHeader(context.l10n.wizQ18Ancestry),
      WizDropdown(
        label: context.l10n.horHeritageLabel,
        value: wizard.ancestor1,
        options: [for (final entry in gameData.hor.heritage) entry.result],
        onChanged: (value) {
          wizard
            ..ancestor1 = value
            ..chosenAncestor = 1;
          _clearEffects();
          onChanged();
        },
      ),
      if (wizard.heritageEntry != null) ...[
        Text(_modifierText(wizard.heritageEntry!)),
        ..._effectControls(context),
      ],
    ];
  }

  /// Starting-outfit item names already locked in on page 2, for the Battle
  /// of One Thousand Years heritage (one outfit item gains qualities).
  List<String> _horOutfitItemNames() {
    final school = gameData.schoolByName(wizard.school);
    final names = <String>{};
    for (final set in school?.startingOutfit ?? const []) {
      if (set.options.length == 1) {
        final only = set.options.single as String;
        if (only.isEmpty ||
            WizardState.equipmentSpecialOptions(only) != null ||
            only == 'Yumi and quiver of arrows with three special arrows') {
          continue;
        }
        names.add(only);
      }
    }
    names.addAll(
        [for (final choice in wizard.equipChoices) if (choice.isNotEmpty) choice]);
    names.addAll([
      for (final choice in wizard.equipSpecialChoices)
        if (choice.isNotEmpty) choice
    ]);
    return names.toList();
  }

  List<Widget> _samuraiAncestry(BuildContext context) {
    final names = _ancestorNames();
    return [
      QuestionHeader(context.l10n.wizQ18Ancestry),
      WizDropdown(
        label: context.l10n.heritageTable,
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
                label: context.l10n.ancestorN(which),
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
              tooltip: context.l10n.rollTooltip,
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
    return entry == null ? '' : _modifierText(entry);
  }

  String _modifierText(HeritageEntry entry) {
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
      QuestionHeader(context.l10n.heritageHeader(trData(entry.result))),
      if (entry.otherEffects.instructions.isNotEmpty)
        Text(trData(entry.otherEffects.instructions)),
      if (auto != null) Text(context.l10n.grantedLabel(trData(auto))),
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
            tooltip: context.l10n.rollTooltip,
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

    // HoR-only effect types with no stock kind: Wealth is informational
    // (instructions already shown); Outfit Item picks one page-2 item.
    // horMode-gated so homebrew heritage data reusing the type string
    // cannot surface this UI in the stock flow.
    if (wizard.horMode && entry.otherEffects.type == 'Outfit Item') {
      widgets.add(WizDropdown(
        label: context.l10n.itemLabel,
        value: wizard.q18Secondary,
        options: _horOutfitItemNames(),
        onChanged: (value) {
          wizard.q18Secondary = value;
          onChanged();
        },
      ));
      return widgets;
    }

    switch (kind) {
      case HeritageEffectKind.skill:
        primaryDropdown(context.l10n.bonusSkill);
      case HeritageEffectKind.trait:
        primaryDropdown(context.l10n.traitGained);
      case HeritageEffectKind.startingItem:
      case HeritageEffectKind.lostHeirloom:
        primaryDropdown(kind == HeritageEffectKind.lostHeirloom
            ? context.l10n.lostHeirloomCategory
            : context.l10n.heirloomCategory);
        if (wizard.q18OtherEffects.isNotEmpty) {
          widgets.add(WizDropdown(
            label: context.l10n.itemLabel,
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
            label: context.l10n.qualityYourChoice,
            value: wizard.q18Special1,
            options: qualityNames,
            onChanged: (value) {
              wizard.q18Special1 = value;
              onChanged();
            },
          ));
          widgets.add(WizDropdown(
            label: context.l10n.qualityGmChoice,
            value: wizard.q18Special2,
            options: qualityNames,
            onChanged: (value) {
              wizard.q18Special2 = value;
              onChanged();
            },
          ));
        }
      case HeritageEffectKind.technique:
        primaryDropdown(context.l10n.techniqueGroupLabel);
        if (wizard.q18OtherEffects.isNotEmpty) {
          widgets.add(WizDropdown(
            label: context.l10n.advTypeTechnique,
            value: wizard.q18Secondary,
            options: _techniqueOptionsFor(wizard.q18OtherEffects),
            onChanged: (value) {
              wizard.q18Secondary = value;
              onChanged();
            },
          ));
        }
      case HeritageEffectKind.ringExchange:
        primaryDropdown(context.l10n.effectLabel);
        if (wizard.q18OtherEffects.isNotEmpty) {
          if (wizard.q18OtherEffects.endsWith(' Ring')) {
            // Spiritual Debt: raise the named ring, lower a chosen one.
            widgets.add(WizDropdown(
              label: context.l10n.ringToLower,
              value: wizard.q18Special2,
              options: gameData.ringNames(),
              onChanged: (value) {
                wizard.q18Special2 = value;
                onChanged();
              },
            ));
          } else {
            widgets.add(WizDropdown(
              label: context.l10n.ringToRaise,
              value: wizard.q18Special1,
              options: gameData.ringNames(),
              onChanged: (value) {
                wizard.q18Special1 = value;
                onChanged();
              },
            ));
            widgets.add(WizDropdown(
              label: context.l10n.ringToLower,
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
        primaryDropdown(context.l10n.giftLabel);
      case HeritageEffectKind.mixed:
        primaryDropdown(context.l10n.effectLabel);
        if (wizard.q18OtherEffects == 'Ring Exchange') {
          widgets.add(WizDropdown(
            label: context.l10n.ringToRaise,
            value: wizard.q18Special1,
            options: gameData.ringNames(),
            onChanged: (value) {
              wizard.q18Special1 = value;
              onChanged();
            },
          ));
          widgets.add(WizDropdown(
            label: context.l10n.ringToLower,
            value: wizard.q18Special2,
            options: gameData.ringNames(),
            onChanged: (value) {
              wizard.q18Special2 = value;
              onChanged();
            },
          ));
        } else if (wizard.q18OtherEffects == 'Item (Rank 6 or Lower)') {
          widgets.add(WizDropdown(
            label: context.l10n.itemLabel,
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
