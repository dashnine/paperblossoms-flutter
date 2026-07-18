import 'package:flutter/material.dart';

import '../../data_l10n.dart';
import '../../l10n/l10n.dart';
import '../wizard_widgets.dart';
import 'school_builder_state.dart';

/// Step 9: name the school (deliberately last in the book), set the fields
/// the book never charts (honor, reference), and review everything.
class SbPage9Final extends StatefulWidget {
  final SchoolBuilderState state;
  final VoidCallback onChanged;

  const SbPage9Final({super.key, required this.state, required this.onChanged});

  @override
  State<SbPage9Final> createState() => _SbPage9FinalState();
}

class _SbPage9FinalState extends State<SbPage9Final> {
  late final _name = TextEditingController(text: widget.state.name);
  late final _honor = TextEditingController(text: '${widget.state.honor}');
  late final _refBook = TextEditingController(text: widget.state.refBook);
  late final _refPage = TextEditingController(text: widget.state.refPage);

  @override
  void dispose() {
    _name.dispose();
    _honor.dispose();
    _refBook.dispose();
    _refPage.dispose();
    super.dispose();
  }

  Widget _field(
    TextEditingController controller,
    String label,
    ValueChanged<String> onChanged, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = widget.state;
    final rows = <(String, String)>[
      (l10n.sbReviewRoles, state.roles.map(trData).join(', ')),
      (l10n.clanLabel, state.clan.isEmpty ? '—' : trData(state.clan)),
      (l10n.sbReviewRings, state.ringIncrease.map(trData).join(', ')),
      (
        l10n.sbReviewSkills,
        '${state.startingSkills.length} / ${state.skillPicks}',
      ),
      (l10n.sbReviewAccess, state.techniquesAvailable.map(trData).join(', ')),
      (l10n.sbAbilityName, state.abilityName),
      (l10n.sbMasteryName, state.masteryName),
      (
        l10n.sbReviewCurriculum,
        [for (var r = 1; r <= 5; r++) '${state.filledSlots(r)}'].join(' · '),
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        QuestionHeader(l10n.sbNameQuestion),
        _field(_name, l10n.sbNameLabel, (value) {
          state.name = value;
          widget.onChanged();
        }),
        _field(_honor, l10n.sbHonorLabel, (value) {
          state
            ..honor = int.tryParse(value) ?? state.honor
            ..honorTouched = true;
          widget.onChanged();
        }, keyboardType: TextInputType.number),
        Row(
          children: [
            Expanded(
              child: _field(_refBook, l10n.sbRefBookLabel, (value) {
                state.refBook = value;
                widget.onChanged();
              }),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: _field(_refPage, l10n.sbRefPageLabel, (value) {
                state.refPage = value;
                widget.onChanged();
              }),
            ),
          ],
        ),
        QuestionHeader(l10n.sbReviewTitle),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(value.isEmpty ? '—' : value),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
