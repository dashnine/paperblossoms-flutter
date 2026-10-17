import 'dart:async';

import 'package:flutter/material.dart';

import '../data_l10n.dart';
import '../game_data.dart';
import '../game_data_models.dart';
import '../helpers.dart';
import '../l10n/l10n.dart';
import '../rules_constants.dart';
import '../user_data_store.dart';

/// Builds or edits a custom Legacy template (Legacies of War pp. 6 and 12):
/// a Legacies-category advantage saved memory-first to homebrew/legacies.json
/// plus its rules text in the descriptions store. Pops with the saved name.
///
/// Renaming moves the rules text to the new name; a character already holding
/// the old name keeps it as an unknown trait (the same limitation as renaming
/// a homebrew school).
class CustomLegacyPage extends StatefulWidget {
  /// The entry being edited, or null to create a new one.
  final AdvDisadv? initial;

  const CustomLegacyPage({super.key, this.initial});

  @override
  State<CustomLegacyPage> createState() => _CustomLegacyPageState();
}

/// The three rules-text sections of a Legacy, stored as one description.
class LegacyText {
  final String requirement;
  final String charge;
  final String effects;

  const LegacyText(this.requirement, this.charge, this.effects);

  /// Parses text in the layout [compose] writes. Labels are honoured only
  /// in their canonical order, each searched after the previous one, so a
  /// "Charge:" line quoted inside Effects stays in Effects. Text in any
  /// other layout (an imported book description, say) lands in [effects].
  static LegacyText parse(String text) {
    final requirement = _label(text, 'Requirement', 0);
    final charge = _label(text, 'Charge', requirement?.end ?? 0);
    final effects =
        _label(text, 'Effects', charge?.end ?? requirement?.end ?? 0);
    if (requirement == null && charge == null && effects == null) {
      return LegacyText('', '', text.trim());
    }
    String section(RegExpMatch? start, RegExpMatch? next) => start == null
        ? ''
        : text.substring(start.end, next?.start ?? text.length).trim();
    return LegacyText(
      section(requirement, charge ?? effects),
      section(charge, effects),
      section(effects, null),
    );
  }

  static RegExpMatch? _label(String text, String label, int from) {
    final matches = RegExp('^$label:[ \\t]*', multiLine: true, caseSensitive: false)
        .allMatches(text, from);
    return matches.isEmpty ? null : matches.first;
  }

  String compose() => [
        if (requirement.isNotEmpty) 'Requirement: $requirement',
        if (charge.isNotEmpty) 'Charge: $charge',
        if (effects.isNotEmpty) 'Effects: $effects',
      ].join('\n\n');
}

class _CustomLegacyPageState extends State<CustomLegacyPage> {
  /// The data's five rings plus the Hero's Death placeholder.
  List<String> get _rings => [...gameData.ringNames(), ringVarious];
  static const _typeOptions = [
    'Interpersonal',
    'Mental',
    'Physical',
    'Spiritual',
  ];

  late final TextEditingController _name;
  late final TextEditingController _requirement;
  late final TextEditingController _charge;
  late final TextEditingController _effects;
  late String _ring;
  late final Set<String> _types;
  String _template = '';
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _ring = _rings.contains(initial?.ring) ? initial!.ring : ringWater;
    _types = {...(initial?.types ?? const ['Interpersonal', 'Mental'])};
    final text = initial == null
        ? const LegacyText('', '', '')
        : LegacyText.parse(gameData.descriptionFor(initial.name));
    _requirement = TextEditingController(
        text: text.requirement.isNotEmpty || initial == null
            ? text.requirement
            : gameData.shortDescFor(initial.name));
    _charge = TextEditingController(text: text.charge);
    _effects = TextEditingController(text: text.effects);
  }

  @override
  void dispose() {
    _name.dispose();
    _requirement.dispose();
    _charge.dispose();
    _effects.dispose();
    super.dispose();
  }

  /// Prefills ring, types and rules text from another Legacy (p. 6, step
  /// two: customise a template). The name is left alone.
  void _applyTemplate(String name) {
    final entry = gameData.advDisadvByName(name);
    setState(() {
      _template = name;
      if (entry == null) return;
      if (_rings.contains(entry.ring)) _ring = entry.ring;
      _types
        ..clear()
        ..addAll(entry.types.where(_typeOptions.contains));
      if (_types.isEmpty) _types.addAll(const ['Interpersonal', 'Mental']);
      final text = LegacyText.parse(gameData.descriptionFor(name));
      _requirement.text = text.requirement.isNotEmpty
          ? text.requirement
          : gameData.shortDescFor(name);
      _charge.text = text.charge;
      _effects.text = text.effects;
    });
  }

  void _save() {
    final l10n = context.l10n;
    final name = _name.text.trim();
    if (name.isEmpty) {
      showMessage(context, l10n.nameRequiredSnack);
      return;
    }
    final original = widget.initial?.name;
    // Custom names never shadow a bundled or campaign advantage: the store
    // relies on that to delete without a reload of the bundled data.
    final taken = name != original &&
        (gameData.advDisadvByName(name) != null ||
            gameData.hor.advantages.any((a) => a.name == name));
    if (taken) {
      setState(() => _nameError = l10n.customLegacyNameTaken);
      return;
    }
    final entry = AdvDisadv(
      name: name,
      category: categoryLegacies,
      ring: _ring,
      types: [
        for (final t in _typeOptions)
          if (_types.contains(t)) t,
        for (final t in _types)
          if (!_typeOptions.contains(t)) t,
      ],
      // New templates cite the custom-template rules; an edited entry keeps
      // whatever reference its author gave it.
      reference: widget.initial?.reference ??
          const Reference(book: customLegacyRefBook, page: customLegacyRefPage),
    );
    final requirement = _requirement.text.trim();
    final text = LegacyText(
        requirement, _charge.text.trim(), _effects.text.trim());
    // Memory first, disk in the background: awaiting real IO here would
    // hang the widget-test zone (see UserDataStore.saveHomebrewSchool).
    unawaited(userDataStore.saveCustomLegacy(entry, replacingName: original));
    if (original != null && original != name) {
      userDataStore.updateDescription(original, '', '');
    }
    userDataStore.updateDescription(name, text.compose(), requirement);
    unawaited(userDataStore.saveDescriptions());
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final templates = [
      for (final entry in gameData.advDisadvByCategory(categoryLegacies))
        if (entry.name != widget.initial?.name) entry.name
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null
            ? l10n.customLegacyTitle
            : l10n.customLegacyEditTitle),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _template,
            decoration:
                InputDecoration(labelText: l10n.customLegacyTemplate),
            items: [
              DropdownMenuItem(
                  value: '', child: Text(l10n.customLegacyTemplateNone)),
              for (final name in templates)
                DropdownMenuItem(value: name, child: Text(trData(name))),
            ],
            onChanged: (value) => _applyTemplate(value ?? ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              hintText: l10n.customLegacyNameHint,
              errorText: _nameError,
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _ring,
            decoration: InputDecoration(labelText: l10n.customLegacyRing),
            items: [
              for (final ring in _rings)
                DropdownMenuItem(value: ring, child: Text(trData(ring))),
            ],
            onChanged: (value) => setState(() => _ring = value ?? ringWater),
          ),
          const SizedBox(height: 16),
          Text(l10n.customLegacyTypes, style: theme.textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: [
              for (final type in _typeOptions)
                FilterChip(
                  label: Text(trData(type)),
                  selected: _types.contains(type),
                  onSelected: (on) => setState(
                      () => on ? _types.add(type) : _types.remove(type)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _textArea(_requirement, l10n.customLegacyRequirement,
              l10n.customLegacyRequirementHint),
          const SizedBox(height: 12),
          _textArea(_charge, l10n.customLegacyCharge,
              l10n.customLegacyChargeHint),
          const SizedBox(height: 12),
          _textArea(_effects, l10n.customLegacyEffects,
              l10n.customLegacyEffectsHint),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _textArea(
      TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 3,
        alignLabelWithHint: true,
      ),
    );
  }
}
