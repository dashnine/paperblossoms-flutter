import 'package:flutter/material.dart';

import '../advance.dart';
import '../character.dart';
import '../derived_stats.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../rules_constants.dart';
import '../theme.dart';

/// Purchase an advance (port of AddAdvanceDialog): pick Skill/Ring/Technique,
/// a legal option, and a track; XP cost is computed live with the half-cost
/// checkbox and free-advance reason. Pops with the [Advance], or null.
class AddAdvancePage extends StatefulWidget {
  /// Optional preselection, e.g. tapping a curriculum entry.
  final String? initialType;
  final String? initialOption;

  const AddAdvancePage({super.key, this.initialType, this.initialOption});

  @override
  State<AddAdvancePage> createState() => _AddAdvancePageState();
}

class _AddAdvancePageState extends State<AddAdvancePage> {
  String _type = advanceTypeSkill;
  String? _selection;
  String _track = trackCurriculum;
  bool _halfXp = false;
  bool _removeRestrictions = false;
  String _categoryFilter = '';
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? advanceTypeSkill;
    _selection = widget.initialOption;
    if (_type == advanceTypeTechnique && widget.initialOption != null) {
      final tech = gameDataTechnique(widget.initialOption!);
      if (tech != null) _categoryFilter = tech.category;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Technique? gameDataTechnique(String name) =>
      legalTechniques(character, removeRestrictions: true)
          .where((t) => t.name == name)
          .firstOrNull;

  List<String> _options() {
    switch (_type) {
      case advanceTypeSkill:
        return purchasableSkills(character);
      case advanceTypeRing:
        return purchasableRings(character);
      default:
        return [];
    }
  }

  List<Technique> _techniqueOptions() {
    final legal =
        legalTechniques(character, removeRestrictions: _removeRestrictions);
    return [
      for (final tech in legal)
        if (_categoryFilter.isEmpty || tech.category == _categoryFilter) tech
    ];
  }

  int? _cost() {
    if (_selection == null) return null;
    int base;
    switch (_type) {
      case advanceTypeSkill:
        base = skillAdvanceCost(
            effectiveSkillRanks(character)[_selection] ?? 0);
      case advanceTypeRing:
        base =
            ringAdvanceCost(effectiveRingRanks(character)[_selection] ?? 0);
      default:
        final tech = gameDataTechnique(_selection!);
        if (tech == null) return null;
        base = tech.xp;
    }
    return _halfXp ? halfCost(base) : base;
  }

  bool get _isFree => !_isCurriculum && !_isTitle;
  bool get _isCurriculum => _track == trackCurriculum;
  bool get _isTitle => _track == trackTitle;

  String? _validationError() {
    if (_selection == null) return 'Choose an advance.';
    if (_type == advanceTypeTechnique &&
        alreadyLearned(character, _selection!)) {
      return "'$_selection' is already learned.";
    }
    return null;
  }

  void _submit() {
    final cost = _isFree ? 0 : (_cost() ?? 0);
    final track = _isFree
        ? _reasonController.text
            .replaceAll('|', '')
            .replaceAll(trackTitle, '')
            .replaceAll(trackCurriculum, '')
        : _track;
    Navigator.pop(
        context,
        Advance(
            type: _type,
            name: _selection!,
            track: track.isEmpty ? 'Free' : track,
            cost: cost));
  }

  @override
  Widget build(BuildContext context) {
    final error = _validationError();
    final cost = _cost();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Advance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: advanceTypeSkill, label: Text('Skill')),
              ButtonSegment(value: advanceTypeRing, label: Text('Ring')),
              ButtonSegment(
                  value: advanceTypeTechnique, label: Text('Technique')),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() {
              _type = selection.single;
              _selection = null;
              _categoryFilter = '';
            }),
          ),
          if (_type != advanceTypeTechnique) ...[
            const SectionHeader('Advance'),
            DropdownMenu<String>(
              key: ValueKey(_type),
              width: 320,
              initialSelection: _selection,
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (final option in _options())
                  DropdownMenuEntry(value: option, label: option),
              ],
              onSelected: (value) => setState(() => _selection = value),
            ),
          ] else ...[
            SectionHeader(
              'Technique',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Ignore restrictions'),
                  Checkbox(
                    value: _removeRestrictions,
                    onChanged: (value) => setState(
                        () => _removeRestrictions = value ?? false),
                  ),
                ],
              ),
            ),
            DropdownMenu<String>(
              width: 320,
              initialSelection: _categoryFilter,
              label: const Text('Category'),
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: '', label: 'All categories'),
                for (final category in {
                  for (final t in _techniqueOptions()) t.category
                })
                  DropdownMenuEntry(value: category, label: category),
              ],
              onSelected: (value) =>
                  setState(() => _categoryFilter = value ?? ''),
            ),
            if (_categoryFilter == 'Mahō')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                    'Mahō is forbidden. Learning it has consequences.',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Card(
                child: ListView(
                  children: [
                    for (final tech in _techniqueOptions())
                      RadioListTile<String>(
                        dense: true,
                        value: tech.name,
                        groupValue: _selection,
                        title: Text(tech.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${tech.subcategory} · Rank ${tech.rank} · '
                                '${tech.xp} XP'),
                            if (gameData
                                .shortDescFor(tech.name)
                                .isNotEmpty)
                              Text(
                                gameData.shortDescFor(tech.name),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        onChanged: (value) =>
                            setState(() => _selection = value),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SectionHeader('Track'),
          for (final (value, label) in [
            (trackCurriculum, 'Curriculum'),
            (trackTitle, 'Title'),
            ('Free', 'Free (no XP cost)'),
          ])
            RadioListTile<String>(
              value: value,
              groupValue: _track,
              dense: true,
              title: Text(label),
              onChanged: (selected) =>
                  setState(() => _track = selected ?? _track),
            ),
          if (_isFree)
            TextField(
              controller: _reasonController,
              decoration:
                  const InputDecoration(labelText: 'Reason (optional)'),
            ),
          CheckboxListTile(
            dense: true,
            value: _halfXp,
            title: const Text('Half XP (school/title discount)'),
            onChanged: (value) => setState(() => _halfXp = value ?? false),
          ),
          const SizedBox(height: 8),
          if (error != null)
            Text(error,
                style: TextStyle(color: Theme.of(context).colorScheme.error))
          else if (!_isFree && cost != null)
            Text('Cost: $cost XP',
                style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: error == null ? _submit : null,
            child: const Text('Add Advance'),
          ),
        ],
      ),
    );
  }
}
