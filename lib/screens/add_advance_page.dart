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

/// Purchase an advance (port of AddAdvanceDialog): pick Skill/Ring/Technique,
/// a legal option, and a track; XP cost is computed live with the half-cost
/// checkbox and free-advance reason. Pops with the [Advance], or null.
class AddAdvancePage extends StatefulWidget {
  /// Optional preselection, e.g. tapping a curriculum entry.
  final String? initialType;
  final String? initialOption;

  /// Optional group pre-filter, e.g. tapping a curriculum skill_group or
  /// technique_group entry ('Martial skills', 'Close Combat Kata', ...).
  final String? initialGroup;

  /// Optional track preset ([trackCurriculum]/[trackTitle]), e.g. tapping a
  /// title advancement row.
  final String? initialTrack;

  const AddAdvancePage(
      {super.key,
      this.initialType,
      this.initialOption,
      this.initialGroup,
      this.initialTrack});

  @override
  State<AddAdvancePage> createState() => _AddAdvancePageState();
}

class _AddAdvancePageState extends State<AddAdvancePage> {
  String _type = advanceTypeSkill;
  String? _selection;
  String _track = trackCurriculum;
  bool _halfXp = false;
  bool _removeRestrictions = false;
  String _groupFilter = '';
  final _reasonController = TextEditingController();
  final _searchController = TextEditingController();
  final _techListController = ScrollController();
  final _selectedTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? advanceTypeSkill;
    _selection = widget.initialOption;
    _groupFilter = widget.initialGroup ?? '';
    _track = widget.initialTrack ?? trackCurriculum;
    if (_type == advanceTypeTechnique && widget.initialOption != null) {
      final tech = gameDataTechnique(widget.initialOption!);
      if (tech != null) {
        if (_groupFilter.isEmpty) _groupFilter = tech.category;
        // Pre-fill the filter so the tapped technique isn't lost in the
        // list; clearing it re-reveals the selection by scrolling.
        _searchController.text = widget.initialOption!;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _revealSelectedTechnique());
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _searchController.dispose();
    _techListController.dispose();
    super.dispose();
  }

  /// Scroll the preselected technique into view. The list builds tiles
  /// lazily, so the keyed tile may not exist yet; jump to a proportional
  /// estimate and retry — the estimate converges as tiles get real extents.
  void _revealSelectedTechnique([int attempts = 8]) {
    final keyContext = _selectedTileKey.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(keyContext, alignment: 0.3);
      return;
    }
    if (attempts == 0 || !mounted || !_techListController.hasClients) return;
    final options = _techniqueOptions();
    final index = options.indexWhere((t) => t.name == _selection);
    if (index < 0) return;
    final position = _techListController.position;
    final estimate = (position.maxScrollExtent + position.viewportDimension) *
            index /
            options.length -
        position.viewportDimension / 2;
    _techListController
        .jumpTo(estimate.clamp(0.0, position.maxScrollExtent));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _revealSelectedTechnique(attempts - 1));
  }

  Technique? gameDataTechnique(String name) =>
      legalTechniques(character, removeRestrictions: true)
          .where((t) => t.name == name)
          .firstOrNull;

  List<String> _options() {
    switch (_type) {
      case advanceTypeSkill:
        final skills = purchasableSkills(character);
        if (_groupFilter.isEmpty) return skills;
        final inGroup = gameData.skillsByGroup(_groupFilter);
        return [for (final skill in skills) if (inGroup.contains(skill)) skill];
      case advanceTypeRing:
        return purchasableRings(character);
      default:
        return [];
    }
  }

  List<Technique> _legalTechniques() =>
      legalTechniques(character, removeRestrictions: _removeRestrictions);

  /// Case- and diacritic-insensitive, so typing "kiho" finds "Kihō".
  String _fold(String s) => dataL10n.sortKey(s);

  List<Technique> _techniqueOptions() {
    final query = _fold(_searchController.text.trim());
    return [
      for (final tech in _legalTechniques())
        if ((_groupFilter.isEmpty ||
                tech.category == _groupFilter ||
                tech.subcategory == _groupFilter) &&
            (query.isEmpty ||
                _fold(tech.name).contains(query) ||
                _fold(trData(tech.name)).contains(query)))
          tech
    ];
  }

  /// Categories with their subcategories indented beneath them; curriculum
  /// technique groups name either level ('Kata', 'Close Combat Kata').
  List<DropdownMenuEntry<String>> _techniqueGroupEntries() {
    final entries = <DropdownMenuEntry<String>>[
      DropdownMenuEntry(value: '', label: context.l10n.allGroups),
    ];
    final seen = <String>{};
    for (final tech in _legalTechniques()) {
      if (seen.add(tech.category)) {
        entries.add(DropdownMenuEntry(
            value: tech.category, label: trData(tech.category)));
      }
      if (tech.subcategory.isNotEmpty &&
          tech.subcategory != tech.category &&
          seen.add(tech.subcategory)) {
        entries.add(DropdownMenuEntry(
          value: tech.subcategory,
          label: trData(tech.subcategory),
          labelWidget: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(trData(tech.subcategory)),
          ),
        ));
      }
    }
    // Keep a preset curriculum group selectable even when no technique is
    // currently legal in it (e.g. all its ranks are above the character's).
    if (_groupFilter.isNotEmpty && !seen.contains(_groupFilter)) {
      entries.add(
          DropdownMenuEntry(value: _groupFilter, label: trData(_groupFilter)));
    }
    return entries;
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
    if (_selection == null) return context.l10n.chooseAnAdvance;
    if (_type == advanceTypeTechnique &&
        alreadyLearned(character, _selection!)) {
      return context.l10n.alreadyLearnedError(trData(_selection!));
    }
    return null;
  }

  /// Localized display label for an advance-type constant (the constants
  /// themselves are canonical English and appear in saves).
  String _typeLabel(String type) => switch (type) {
        advanceTypeSkill => context.l10n.advTypeSkill,
        advanceTypeRing => context.l10n.advTypeRing,
        _ => context.l10n.advTypeTechnique,
      };

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
    // Fixed menus would clip on sub-360px phones; the page itself is capped
    // so a desktop window doesn't stretch radios and buttons edge to edge.
    final menuWidth =
        (MediaQuery.sizeOf(context).width - 32).clamp(160.0, 320.0);
    // Let the technique list use tall windows instead of a fixed 320px.
    final listMaxHeight =
        (MediaQuery.sizeOf(context).height * 0.5).clamp(320.0, 720.0);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addAdvanceTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                  value: advanceTypeSkill,
                  label: Text(context.l10n.advTypeSkill)),
              ButtonSegment(
                  value: advanceTypeRing, label: Text(context.l10n.advTypeRing)),
              ButtonSegment(
                  value: advanceTypeTechnique,
                  label: Text(context.l10n.advTypeTechnique)),
            ],
            selected: {_type},
            onSelectionChanged: (selection) => setState(() {
              _type = selection.single;
              _selection = null;
              _groupFilter = '';
              _searchController.clear();
            }),
          ),
          if (_type != advanceTypeTechnique) ...[
            SectionHeader(context.l10n.advanceSection),
            if (_type == advanceTypeSkill) ...[
              DropdownMenu<String>(
                width: menuWidth,
                initialSelection: _groupFilter,
                label: Text(context.l10n.groupLabel),
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: '', label: context.l10n.allGroups),
                  for (final group in gameData.skillGroups)
                    DropdownMenuEntry(
                        value: group.name, label: trData(group.name)),
                ],
                onSelected: (value) => setState(() {
                  _groupFilter = value ?? '';
                  if (!_options().contains(_selection)) _selection = null;
                }),
              ),
              const SizedBox(height: 8),
            ],
            DropdownMenu<String>(
              key: ValueKey('$_type:$_groupFilter'),
              width: menuWidth,
              initialSelection: _selection,
              label: Text(_typeLabel(_type)),
              enableFilter: true,
              requestFocusOnTap: true,
              dropdownMenuEntries: [
                for (final option in _options())
                  DropdownMenuEntry(value: option, label: trData(option)),
              ],
              onSelected: (value) => setState(() => _selection = value),
            ),
          ] else ...[
            SectionHeader(context.l10n.advTypeTechnique),
            DropdownMenu<String>(
              width: menuWidth,
              initialSelection: _groupFilter,
              label: Text(context.l10n.groupLabel),
              dropdownMenuEntries: _techniqueGroupEntries(),
              onSelected: (value) => setState(() {
                _groupFilter = value ?? '';
                if (!_techniqueOptions().any((t) => t.name == _selection)) {
                  _selection = null;
                }
              }),
            ),
            if (_groupFilter == 'Mahō')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(context.l10n.mahoWarning,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              // A physical keyboard is a safe assumption outside compact;
              // on phones autofocus would pop the on-screen keyboard.
              autofocus: !context.isCompact,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: context.l10n.typeToFilter,
                isDense: true,
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: context.l10n.clearFilter,
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(_searchController.clear);
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _revealSelectedTechnique());
                        },
                      ),
              ),
              onChanged: (_) => setState(() {}),
              // Enter picks the technique once the filter narrows to one.
              onSubmitted: (_) {
                final options = _techniqueOptions();
                if (options.length == 1) {
                  setState(() => _selection = options.single.name);
                }
              },
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: Card(
                child: ListView(
                  controller: _techListController,
                  children: [
                    for (final tech in _techniqueOptions())
                      RadioListTile<String>(
                        key: tech.name == _selection
                            ? _selectedTileKey
                            : null,
                        dense: true,
                        value: tech.name,
                        groupValue: _selection,
                        title: Text(trData(tech.name)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.techSubtitle(
                                trData(tech.subcategory), tech.rank, tech.xp)),
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
            CheckboxListTile(
              dense: true,
              value: _removeRestrictions,
              title: Text(context.l10n.ignoreRestrictions),
              onChanged: (value) =>
                  setState(() => _removeRestrictions = value ?? false),
            ),
          ],
          SectionHeader(context.l10n.trackSection),
          for (final (value, label) in [
            (trackCurriculum, context.l10n.trackCurriculumLabel),
            (trackTitle, context.l10n.trackTitleLabel),
            ('Free', context.l10n.trackFreeLabel),
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
                  InputDecoration(labelText: context.l10n.reasonOptional),
            ),
          CheckboxListTile(
            dense: true,
            value: _halfXp,
            title: Text(context.l10n.halfXpLabel),
            onChanged: (value) => setState(() => _halfXp = value ?? false),
          ),
          const SizedBox(height: 8),
          if (error != null)
            Text(error,
                style: TextStyle(color: Theme.of(context).colorScheme.error))
          else if (!_isFree && cost != null)
            Text(context.l10n.costXp(cost),
                style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: error == null ? _submit : null,
            child: Text(context.l10n.addAdvanceTitle),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
