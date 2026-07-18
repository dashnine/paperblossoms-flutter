import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../game_data.dart';
import '../../l10n/l10n.dart';
import '../../rules_constants.dart';
import '../wizard_widgets.dart';
import 'school_builder_data.dart';
import 'school_builder_state.dart';
import 'school_builder_widgets.dart';

/// Sentinel dropdown values; real affiliations are data names.
const _kNone = '(none)';
const _kCustom = '(custom)';

/// Step 2: affiliation and school summary (PoW p. 77).
class SbPage2Affiliation extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage2Affiliation({
    super.key,
    required this.state,
    required this.onChanged,
  });

  @override
  State<SbPage2Affiliation> createState() => _SbPage2AffiliationState();
}

class _SbPage2AffiliationState extends State<SbPage2Affiliation> {
  late final _summary = TextEditingController(text: widget.state.summary);
  late final _summaryShort = TextEditingController(
    text: widget.state.summaryShort,
  );
  late final _custom = TextEditingController(text: widget.state.clan);

  late bool _isCustom =
      widget.state.clan.isNotEmpty &&
      !_knownAffiliations().contains(widget.state.clan);

  List<String> _knownAffiliations() => [
    for (final clan in gameData.clans) clan.name,
    ...extraAffiliations,
  ];

  @override
  void dispose() {
    _summary.dispose();
    _summaryShort.dispose();
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final known = _knownAffiliations();
    final dropdownValue = _isCustom
        ? _kCustom
        : state.clan.isEmpty
        ? _kNone
        : state.clan;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbAffiliationQuestion),
        WizDropdown(
          label: l10n.clanLabel,
          value: dropdownValue,
          options: [_kNone, ...known, _kCustom],
          labelOf: (option) => switch (option) {
            _kNone => l10n.sbAffiliationNone,
            _kCustom => l10n.sbAffiliationCustom,
            _ => trData(option),
          },
          onChanged: (value) {
            setState(() {
              _isCustom = value == _kCustom;
              state.clan = value == _kNone || value == _kCustom ? '' : value;
              if (_isCustom) _custom.text = '';
            });
            widget.onChanged();
          },
        ),
        if (_isCustom)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextField(
              controller: _custom,
              decoration: InputDecoration(
                labelText: l10n.sbCustomAffiliationLabel,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                state.clan = value;
                widget.onChanged();
              },
            ),
          ),
        if (state.clan == characterTypeRonin)
          SoftWarning(l10n.sbNoteRonin)
        else if (!_isCustom && state.clan.isEmpty)
          SoftWarning(l10n.sbNoteNoAffiliation)
        else if (_isCustom)
          SoftWarning(l10n.sbNoteCustomAffiliation),
        QuestionHeader(l10n.sbSummaryHeader),
        WizTextArea(
          label: l10n.sbSummaryLabel,
          controller: _summary,
          minLines: 4,
          onChanged: (value) {
            state.summary = value;
            widget.onChanged();
          },
        ),
        if (state.summary.trim().isEmpty) SoftWarning(l10n.sbWarnNoSummary),
        WizTextArea(
          label: l10n.sbSummaryShortLabel,
          controller: _summaryShort,
          minLines: 1,
          onChanged: (value) {
            state.summaryShort = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }
}
